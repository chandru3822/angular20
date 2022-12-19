package com.albatross.api.v1.company.blueraven.controllers.proposal;

import com.albatross.api.config.AppProperties;
import com.albatross.api.config.CachingConfig;
import com.albatross.api.exception.ApiException;
import com.albatross.api.exception.NotFoundException;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.controllers.proposal.mappers.ProposalTemplateBlockMapper;
import com.albatross.api.v1.company.blueraven.controllers.proposal.mappers.ProposalTemplateMapper;
import com.albatross.api.v1.company.blueraven.controllers.proposal.models.ProposalGeneratedType;
import com.albatross.api.v1.company.blueraven.controllers.proposal.models.ProposalTag;
import com.albatross.api.v1.company.blueraven.controllers.proposal.models.ProposalTemplate;
import com.albatross.api.v1.company.blueraven.controllers.proposal.models.ProposalTemplateBlock;
import com.albatross.api.v1.company.blueraven.controllers.proposal.query.ProposalTemplateQuery;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.jayway.jsonpath.DocumentContext;
import com.jayway.jsonpath.JsonPath;
import com.jayway.jsonpath.Option;
import com.jayway.jsonpath.spi.json.JacksonJsonProvider;
import com.jayway.jsonpath.spi.mapper.JacksonMappingProvider;
import freemarker.template.Template;
import freemarker.template.TemplateException;
import lombok.extern.slf4j.Slf4j;
import org.postgresql.util.PGobject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.core.io.buffer.DataBuffer;
import org.springframework.core.io.buffer.DataBufferUtils;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.util.UriComponentsBuilder;
import reactor.core.publisher.Flux;

import javax.script.ScriptEngine;
import javax.script.ScriptEngineManager;
import javax.script.ScriptException;
import javax.script.SimpleBindings;
import java.io.IOException;
import java.io.StringWriter;
import java.net.URI;
import java.time.Duration;
import java.time.Instant;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.function.Function;
import java.util.function.Predicate;
import java.util.stream.Collectors;

import static java.util.Comparator.*;
import static java.util.stream.Collectors.groupingBy;
import static java.util.stream.Collectors.toList;

//  TODO:
//  * update template/theme

@Slf4j
@Service
@PreAuthorize("hasCompanyAccess(3) && hasFeatureAccess('PROPOSALS')")
public class ProposalTemplateService {
  private final SqlCache sqlCache;
  private final ObjectMapper objectMapper;
  private final AppProperties appProperties;
  private final freemarker.template.Configuration freemarkerConfiguration;
  private final com.jayway.jsonpath.Configuration jsonPathConfiguration;
  private final ScriptEngine engine;


  public ProposalTemplateService(
    @Autowired SqlCache sqlCache,
    @Autowired ObjectMapper objectMapper,
    @Autowired AppProperties appProperties,
    @Autowired freemarker.template.Configuration freemarkerConfiguration) {
    this.sqlCache = sqlCache;
    this.objectMapper = objectMapper;
    this.appProperties = appProperties;
    this.freemarkerConfiguration = freemarkerConfiguration;

    this.jsonPathConfiguration =
      com.jayway.jsonpath.Configuration.builder()
        .jsonProvider(new JacksonJsonProvider(objectMapper))
        .options(Option.DEFAULT_PATH_LEAF_TO_NULL, Option.SUPPRESS_EXCEPTIONS)
        .mappingProvider(new JacksonMappingProvider())
        .build();

//    NOTE (kaleb): is this the best way to handle this?
    this.engine = new ScriptEngineManager().getEngineByName("graal.js");
  }

  public ProposalTemplate getTemplateById(Long templateId, Map<String, Object> context, ProposalGeneratedType proposalGeneratedType) {
    return getTemplateById(templateId, context, proposalGeneratedType, false);
  }

  private <T> Predicate<T> distinctByKey(Function<? super T, Object> keyExtractor) {
    Set<Object> seen = ConcurrentHashMap.newKeySet();
    return t -> seen.add(keyExtractor.apply(t));
  }

  public ProposalTemplate getTemplateById(Long templateId, Map<String, Object> context, ProposalGeneratedType proposalGeneratedType, boolean isDebug) {
    final ProposalTemplate template =
      sqlCache.getBySql(ProposalTemplateQuery.findById, Map.of("id", templateId), new ProposalTemplateMapper(objectMapper))
        .orElseThrow(NotFoundException::new);

    Map<Integer, List<ProposalTemplateBlock>> blockHierarchy = template.getBlocks().stream()
      .filter(p -> p.getParentId() != null)
      .collect(groupingBy(ProposalTemplateBlock::getParentId, toList()));

    List<ProposalTemplateBlock> hiddenBlocks = template.getBlocks().stream()
      .filter(block -> {
        String visibility = block.getVisibility();
        if (visibility == null || visibility.trim().equals("")) {
          return false;
        }
        return !eval(visibility, context);
      }).toList();

    List<Integer> hidden = hiddenBlocks.stream()
      .map(b -> findDescendants(b, blockHierarchy))
      .flatMap(List::stream)
      .collect(toList());

    hidden.addAll(hiddenBlocks.stream().map(ProposalTemplateBlock::getId).toList());

    final List<ProposalTemplateBlock> mergedBlocks =
      template.getBlocks().stream()
        //filters out any blocks + descendants where the visibility is evaluated as false
        .filter(block -> !hidden.contains(block.getId()))
        //sort so the blocks with the same uuid are sorted together with blocks with any visibility take preference (higher sort)
        .sorted(nullsLast(
          comparing(ProposalTemplateBlock::getBlockUUID, nullsLast(naturalOrder()))
            .thenComparing(ProposalTemplateBlock::getVisibility, nullsLast(naturalOrder()))
        ))
        //this will create a distinct list of blocks based on the block UUID given the previous sort order
        .filter(distinctByKey(ProposalTemplateBlock::getBlockUUID))
        .map(block -> replaceVarFromContext(block, context, isDebug))
        .map(block -> replaceImageBlockWithURL(block, context, proposalGeneratedType, isDebug))
        .map(block -> replaceImagePlaceholderFromContext(block, context, isDebug))
        .map(block -> replaceStylePlaceholder(block, context, proposalGeneratedType, isDebug))
        .sorted(nullsFirst(
          comparing(ProposalTemplateBlock::getParentId, nullsFirst(naturalOrder()))
            .thenComparing(ProposalTemplateBlock::getBlockOrder, nullsFirst(naturalOrder()))
            .thenComparing(ProposalTemplateBlock::getId)
        ))
        .collect(toList());

    template.setBlocks(mergedBlocks);
    return template;
  }

  /**
   * Finds all descendants for a particular block
   *
   * @param block
   * @param context
   * @return
   */
  private List<Integer> findDescendants(ProposalTemplateBlock block, Map<Integer, List<ProposalTemplateBlock>> context) {
    List<Integer> descendantIds = new ArrayList<>();
    List<ProposalTemplateBlock> children = context.getOrDefault(block.getId(), List.of());

    if (!children.isEmpty()) {
      for (ProposalTemplateBlock childBlock : children) {
        descendantIds.add(childBlock.getId());

        List<Integer> descendants = findDescendants(childBlock, context);
        descendantIds.addAll(descendants);
      }
    }

    return descendantIds;
  }

  private boolean eval(String script, Map<String, Object> context) {
    try {
      Instant start = Instant.now();
      Object eval = engine.eval(script, new SimpleBindings(context));
      Duration between = Duration.between(start, Instant.now());
      log.debug("GraalJS Eval: `{}` = {} in {}", script, eval, between);

      if (eval instanceof Boolean b) {
        return b;
      }

      return Objects.nonNull(eval);

    } catch (ScriptException e) {
      throw new RuntimeException(e);
    }
  }

  @SuppressWarnings("unchecked")
  private ProposalTemplateBlock replaceVarFromContext(
    ProposalTemplateBlock block, Map<String, Object> context, boolean isDebug) {
    // there isn't anything to process so just return as is
    if (block.getBlockValue() == null) {
      return block;
    }

    final DocumentContext documentContext =
      JsonPath.using(this.jsonPathConfiguration).parse(block.getBlockValue());

    final String replacementPath = "$..content[?(@.type=='mention')]";

    documentContext.map(replacementPath,
      (val, configuration) -> {
        if (val instanceof Map current) {
          final Object id = getNestedValue(current, "attrs", "id");
          if (id != null) {
            final Object replacementText = context.getOrDefault((String) id, null);
            if (replacementText != null) {
              current.put("type", "text");
              current.put("text", replacementText.toString());
              current.remove("attrs");
            } else {
              log.debug("No replacement found for key={} in provided context", id);
            }
          }
        }
        return val;
      });

    if (!isDebug) {
      documentContext.delete(replacementPath);
    }

    return block;
  }

  private ProposalTemplateBlock replaceImagePlaceholderFromContext(ProposalTemplateBlock block, Map<String, Object> context, boolean isDebug) {
    if (block.getBlockKind() == null) {
      return block;
    }

    final Object actualImageUrl = context.getOrDefault(block.getBlockKind(), null);
    if (actualImageUrl != null) {
      block.setBlockType("ImageBlock");
      block.setBlockValue(Map.of("url", actualImageUrl));
    }
    return block;
  }

  private ProposalTemplateBlock replaceStylePlaceholder(ProposalTemplateBlock block, Map<String, Object> context, ProposalGeneratedType proposalGeneratedType, boolean isDebug) {
    if (block.getBlockStyle() == null) {
      return block;
    }

    if (block.getBlockStyle() instanceof Map style) {
      final String backgroundImageKey = "@backgroundImage";
      final Object valueKey = style.getOrDefault(backgroundImageKey, null);
      if (valueKey != null) {
        URI uri = buildUri(valueKey.toString(), proposalGeneratedType);
        style.put("backgroundImage", String.format("url(%s)", uri));
        style.remove(backgroundImageKey);
      }
      block.setBlockStyle(style);
    }

    return block;
  }

  private ProposalTemplateBlock replaceImageBlockWithURL(ProposalTemplateBlock block, Map<String, Object> context, ProposalGeneratedType proposalGeneratedType, boolean isDebug) {
    if (!Objects.equals(block.getBlockType(), "ImageBlock")) {
      return block;
    }

    if (block.getBlockValue() instanceof Map value) {
      final var uuid = value.getOrDefault("uuid", null);
      if (uuid != null) {
        final URI uri = buildUri(uuid.toString(), proposalGeneratedType);
        block.setBlockValue(Map.of("url", uri.toString()));
      }
    }

    return block;
  }

  private URI buildUri(String uuid, ProposalGeneratedType proposalGeneratedType) {
    final var params = ProposalGeneratedType.getOptions(proposalGeneratedType);

    return UriComponentsBuilder.fromUri(appProperties.getHost())
      .pathSegment("public", "image", uuid)
      .queryParams(params)
      .build()
      .toUri();
  }

  private <T> T getNestedValue(Map map, String... keys) {
    Object value = map;
    for (String key : keys) {
      if (value instanceof Map) {
        value = ((Map) value).get(key);
      }
    }
    return (T) value;
  }

  @Cacheable(value = CachingConfig.PROPOSAL_TEMPLATE, key = "#templateId")
  public Optional<ProposalTemplate> getTemplateById(Long templateId) {
    return sqlCache.getBySql(
      ProposalTemplateQuery.findById,
      Map.of("id", templateId),
      new ProposalTemplateMapper(objectMapper));
  }

  @Transactional
  @CacheEvict(value = CachingConfig.PROPOSAL_TEMPLATE, key = "#templateId")
  @PreAuthorize("hasFeatureAccessLevel('PROPOSALS_ADMIN')")
  public void updateTemplate(Long templateId) {
    throw new ApiException("Not implemented");
  }

  @Transactional
  @CacheEvict(value = CachingConfig.PROPOSAL_TEMPLATE, key = "#templateId")
  @PreAuthorize("hasFeatureAccessLevel('PROPOSALS_ADMIN')")
  public List<ProposalTemplateBlock> updateTemplateBlocks(
    Long templateId, List<ProposalTemplateBlock> blocks, Long currentUserId) {

    final List<Map<String, Object>> params =
      blocks.stream()
        .map(
          block -> {
            final Map<String, Object> map = new HashMap<>();
            map.put("id", block.getId());
            map.put("templateId", templateId);
            map.put("version", block.getVersion());
            map.put("themeValueId", block.getThemeKeyId());
            map.put("blockTypeId", block.getBlockTypeId());
            map.put("blockKindId", block.getBlockKindId());
            map.put("blockStyle", getPGobject(block.getBlockStyle()));
            map.put("blockValue", getPGobject(block.getBlockValue()));
            map.put("visibility", block.getVisibility());
            map.put("blockOrder", block.getBlockOrder());
            map.put("parentId", block.getParentId());
            map.put("modifiedById", currentUserId);
            return map;
          })
        .toList();

    sqlCache.updateBatchBySql(ProposalTemplateQuery.updateBlocks, params);

    final Set<Integer> updated =
      blocks.stream().map(ProposalTemplateBlock::getId).collect(Collectors.toSet());

    return getTemplateBlocks(updated);
  }

  @Cacheable(value = CachingConfig.PROPOSAL_TEMPLATE)
  @PreAuthorize("hasFeatureAccessLevel('PROPOSALS_ADMIN')")
  public List<ProposalTag> getAvailableTags() {
    return sqlCache.queryBySql(ProposalTemplateQuery.availableTags, Map.of(), new BeanPropertyRowMapper<>(ProposalTag.class));
  }


  public ContentAwareByteArrayOutputStream generatePdf(Long templateId, Map<String, Object> context, boolean isDebug) throws Exception {
    final ProposalTemplate proposalTemplate = getTemplateById(templateId, context, ProposalGeneratedType.PRINT, isDebug);
    return generatePdf(proposalTemplate.getBlocks(), proposalTemplate.getTheme().getThemeStyle());
  }

  private ContentAwareByteArrayOutputStream generatePdf(List<ProposalTemplateBlock> blocks, Object theme) throws IOException, TemplateException {

    final ContentAwareByteArrayOutputStream outputStream = new ContentAwareByteArrayOutputStream();

    final String generatedHtml = generateHtml(blocks, theme);

    final Flux<DataBuffer> pdf = WebClient.create()
      .post()
      .uri(appProperties.getHtmlToPdfApi())
      .contentType(MediaType.APPLICATION_FORM_URLENCODED)
      .accept(MediaType.APPLICATION_PDF)
      .body(BodyInserters.fromFormData("html", generatedHtml))
      .exchangeToFlux(response -> {

        response.headers().header(HttpHeaders.CONTENT_LENGTH).stream()
          .findFirst()
          .map(Long::valueOf)
          .ifPresent(outputStream::setContentLength);

        response.headers().header(HttpHeaders.CONTENT_TYPE).stream()
          .findFirst()
          .ifPresent(outputStream::setContentType);

        if (response.statusCode() == HttpStatus.OK) {
          return response.bodyToFlux(DataBuffer.class);
        }
        return Flux.empty();
      })
      .doOnError((e) -> {
        log.error("[PDF] Error processing PDF, error={}", e.getMessage());
      });

    DataBufferUtils.write(pdf, outputStream).blockLast();
    return outputStream;
  }

  private String generateHtml(List<ProposalTemplateBlock> blocks, Object theme) throws TemplateException, IOException {
    final Instant start = Instant.now();

    final StringWriter stringWriter = new StringWriter();
    final Template template = freemarkerConfiguration.getTemplate("proposal/index.ftlh");
    template.process(Map.of("template", blocks, "theme", theme), stringWriter);
    final String processedTemplate = stringWriter.toString();

    log.debug("Duration of template processing:  {}", Duration.between(start, Instant.now()));
    log.debug(processedTemplate);
    return processedTemplate;
  }

  private List<ProposalTemplateBlock> getTemplateBlocks(Set<Integer> ids) {
    return sqlCache.queryBySql(
      ProposalTemplateQuery.findBlocksByIds,
      Map.of("ids", ids),
      new ProposalTemplateBlockMapper(objectMapper));
  }

  private PGobject getPGobject(Object original) {

    if (original == null) {
      return null;
    }

    try {
      final PGobject pGobject = new PGobject();
      pGobject.setType("jsonb");
      pGobject.setValue(objectMapper.writeValueAsString(original));
      return pGobject;
    } catch (Exception e) {
      log.warn("Error creating PGObject for obj={}, msg={}", original, e.getMessage());
      throw new RuntimeException("Error creating object");
    }
  }

}
