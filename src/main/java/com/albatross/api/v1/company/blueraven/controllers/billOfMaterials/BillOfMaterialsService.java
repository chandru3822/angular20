package com.albatross.api.v1.company.blueraven.controllers.billOfMaterials;

import com.albatross.api.exception.ApiException;
import com.albatross.api.pdf.PdfService;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.controllers.billOfMaterials.models.BillOfMaterialsPart;
import com.albatross.api.v1.company.blueraven.controllers.billOfMaterials.models.BillOfMaterialsPdfTemplatePart;
import com.albatross.api.v1.company.blueraven.controllers.billOfMaterials.models.BillOfMaterialsPdfTemplatePartDetails;
import com.albatross.api.v1.company.blueraven.controllers.billOfMaterials.models.BillOfMaterialsPermitPack;
import com.albatross.api.v1.company.blueraven.controllers.billOfMaterials.query.BillOfMaterialsQuery;
import com.albatross.api.v1.company.blueraven.controllers.proposal.BlueravenProposalService;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.model.project.Project;
import com.albatross.api.v1.flow.services.ContactService;
import com.albatross.api.v1.flow.services.ProjectService;
import com.fasterxml.jackson.databind.ObjectMapper;
import freemarker.template.Template;
import freemarker.template.TemplateException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.io.Resource;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.IOException;
import java.io.StringWriter;
import java.text.SimpleDateFormat;
import java.time.Duration;
import java.time.Instant;
import java.util.*;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class BillOfMaterialsService {

    private final SecurityService securityService;
    private final SqlCache sqlCache;
    private final ObjectMapper om;
    private final BlueravenProposalService blueravenProposalService;
    private final ContactService contactService;
    private final ProjectService projectService;
    private final PdfService pdfService;
    private final freemarker.template.Configuration freemarkerConfiguration;


    @Transactional
    public List<BillOfMaterialsPart> upsertBomParts(Long projectId, Long permitPackId, List<BillOfMaterialsPart> parts){
        //the passed in list of parts should be only the parts that have somehow changed;
        // we can then simply update their quantity, whether they're archived, and their dateModified/modifiedById
        User user = securityService.getCurrentUser();

        //do a batch update using upsertBomParts

        //first get all the parts with:
        //  - a parts master id
        //  - NO id
        //  - a non-zero quantity
        // to insert into the Parts Master BillOfMaterialsParts
        final List<Map<String, Object>> insertParamsWithPartsMasterId =
                parts.stream().filter(p ->p.getId() == null && p.getPartsMasterId() != null && p.getQuantity()>0).map(p -> {
                    final Map<String, Object> map = new HashMap<>();
                    map.put("userId", user.getId());
                    map.put("id", p.getId());
                    map.put("quantity", (p.getQuantity() == null || p.getQuantity() == 0) ? null : p.getQuantity());
                    map.put("partsMasterId", p.getPartsMasterId());
                    map.put("permitPackId", permitPackId);
                    map.put("projectId", projectId);
                    map.put("supplierId", p.getSupplierId());
                    map.put("supplierConfirmed", p.getSupplierConfirmed() != null && p.getSupplierConfirmed()); //if no value for supplierConfirmed, then false
                    //archived should always be false; we filter out any trying to insert with a quantity of zero, but we'll leave this here just in case
                    Boolean archived = p.getQuantity() <= 0 || p.getArchived() != null && p.getArchived(); //make sure if they set the quantity to zero the part gets archived
                    map.put("archived", archived);
                    return map;
                }).toList();

        //get all the parts with:
        //  - a parts master id
        //  - an id
        // these are already in the Parts Master BillOfMaterialsParts, and need to be updated
        final List<Map<String, Object>> updateParamsWithPartsMasterId =
                parts.stream().filter(p ->p.getId() != null && p.getPartsMasterId() != null).map(p -> {
                    final Map<String, Object> map = new HashMap<>();
                    map.put("userId", user.getId());
                    map.put("id", p.getId());
                    map.put("quantity", (p.getQuantity() == null || p.getQuantity() == 0) ? null : p.getQuantity());
                    map.put("partsMasterId", p.getPartsMasterId());
                    map.put("projectId", projectId);
                    map.put("permitPackId", permitPackId);
                    map.put("supplierId", p.getSupplierId());
                    map.put("supplierConfirmed", p.getSupplierConfirmed() != null && p.getSupplierConfirmed()); //if no value for supplierConfirmed, then false
                    Boolean archived = (p.getQuantity()!= null && p.getQuantity() <= 0) || p.getArchived() != null && p.getArchived(); //make sure if they set the quantity to zero the part gets archived
                    map.put("archived", archived);
                    return map;
                }).toList();


        // for all the parts with no customPartsId and no partsMasterId
        // check if a part with the same part number and name exists in the part table
        // if so, get it's id; if not, add it and get the new id
        //
        // this adds the id to the part, so it should be picked up by the next filter
        for(BillOfMaterialsPart p : parts){
            if(p.getPartsMasterId() == null && p.getCustomPartId() == null && p.getQuantity() > 0) {
                final Map<String, Object> map = new HashMap<>();
                map.put("userId", user.getId());
                map.put("partName", p.getDescription());
                map.put("partNum", p.getPartNumber());

                //first check if a part with the same name and part number exists in the custom parts table
                Long id = sqlCache.queryForObjectBySql(BillOfMaterialsQuery.getFromCustomPartsByNamePartNumber, map, Long.class);
                if(id == null) {
                    //if not, add it
                    //todo: check if it's in the parts master table, if so, don't set an id and return an error somehow
                    id = sqlCache.updateBySqlReturningId(BillOfMaterialsQuery.addToCustomParts, map, "id").longValue();
                }
                p.setCustomPartId(id);
            }
        }

        //get all the parts with:
        //  - NO parts master id
        //  - NO id
        //  - a custom part id
        //  - a non-zero quantity
        // to insert into the Custom BillOfMaterialsParts
        final List<Map<String, Object>> insertParamsNoPartsMasterId =
                parts.stream().filter(p ->p.getId() == null && p.getPartsMasterId() == null && p.getCustomPartId() != null && p.getQuantity() > 0).map(p -> {
                    final Map<String, Object> map = new HashMap<>();
                    map.put("userId", user.getId());
                    map.put("id", p.getId());
                    map.put("quantity", (p.getQuantity() == null || p.getQuantity() == 0) ? null : p.getQuantity());
                    map.put("customPartId", p.getCustomPartId());
                    map.put("permitPackId", permitPackId);
                    map.put("projectId", projectId);
                    map.put("supplierId", p.getSupplierId());
                    map.put("supplierConfirmed", p.getSupplierConfirmed() != null && p.getSupplierConfirmed()); //if no value for supplierConfirmed, then false
                    //archived should always be false; we filter out any trying to insert with a quantity of zero, but we'll leave this here just in case
                    Boolean archived = p.getQuantity() <= 0 || p.getArchived() != null && p.getArchived(); //make sure if they set the quantity to zero the part gets archived
                    map.put("archived", archived);
                    return map;
                }).toList();


        //get all the parts with:
        //  - NO parts master id
        //  - an id
        // these already exist in the Custom BillOfMaterialsParts, and need to be
        final List<Map<String, Object>> updateParamsNoPartsMasterId =
                parts.stream().filter(p ->p.getId() != null && p.getPartsMasterId() == null).map(p -> {
                    final Map<String, Object> map = new HashMap<>();
                    map.put("userId", user.getId());
                    map.put("id", p.getId());
                    map.put("quantity", (p.getQuantity() == null || p.getQuantity() == 0) ? null : p.getQuantity());
                    map.put("customPartId", p.getCustomPartId());
                    map.put("projectId", projectId);
                    map.put("supplierId", p.getSupplierId());
                    map.put("supplierConfirmed", p.getSupplierConfirmed() != null && p.getSupplierConfirmed()); //if no value for supplierConfirmed, then false
                    Boolean archived = (p.getQuantity()!= null && p.getQuantity() <= 0) || p.getArchived() != null && p.getArchived(); //make sure if they set the quantity to zero the part gets archived
                    map.put("archived", archived);
                    return map;
                }).toList();

        if(insertParamsWithPartsMasterId.size() > 0) {
            sqlCache.updateBatchBySql(BillOfMaterialsQuery.insertBomParts, insertParamsWithPartsMasterId);
        }
        if(updateParamsWithPartsMasterId.size() > 0) {
            sqlCache.updateBatchBySql(BillOfMaterialsQuery.updateBomParts, updateParamsWithPartsMasterId);
        }
        if(insertParamsNoPartsMasterId.size() > 0) {
            sqlCache.updateBatchBySql(BillOfMaterialsQuery.insertBomNonPartsMasterParts, insertParamsNoPartsMasterId);
            sqlCache.updateBatchBySql(BillOfMaterialsQuery.increaseCustomPartsUsage, insertParamsNoPartsMasterId);
        }
        if(updateParamsNoPartsMasterId.size() > 0) {
            sqlCache.updateBatchBySql(BillOfMaterialsQuery.updateBomNonPartsMasterParts, updateParamsNoPartsMasterId);
            sqlCache.updateBatchBySql(BillOfMaterialsQuery.increaseCustomPartsUsage, updateParamsNoPartsMasterId);
        }
        return getBomForProject(projectId, permitPackId);
    }

    public List<BillOfMaterialsPart> getBomForProject(Long projectId, Long permitPackId){
        HashMap<String, Object> params = new HashMap<>();
        params.put("projectId", projectId);
        params.put("permitPackId", permitPackId);

        List<BillOfMaterialsPart> parts = sqlCache.queryBySql(BillOfMaterialsQuery.getBomForProject, params, BillOfMaterialsPart.class);
        List<BillOfMaterialsPart> tempParts = sqlCache.queryBySql(BillOfMaterialsQuery.getNonPartsMasterPartsForProjectBom, params, BillOfMaterialsPart.class);
        parts.addAll(tempParts);
        return parts;
    }

    public void deleteBillOfMaterialsAllParts(Long projectId){
        User user = securityService.getCurrentUser();
        HashMap<String, Object> params = new HashMap<>();
        params.put("userId", user.getId());
        params.put("projectId", projectId);

        sqlCache.updateBySql(BillOfMaterialsQuery.deleteAllBomParts, params);
    }

    public List<BillOfMaterialsPermitPack> getBomPermitPacksForProject(Long projectId){
        HashMap<String, Object> params = new HashMap<>();
        params.put("projectId", projectId);
        return sqlCache.queryBySql(BillOfMaterialsQuery.getBomPermitPacksForProject, params, BillOfMaterialsPermitPack.class);
    }

    public Resource generateMaterialListPDF (Long projectId, List<BillOfMaterialsPart> parts){

//        get design log number
        HashMap<String, Object> params = new HashMap<>();
        params.put("projectId", projectId);
        Long designLogNumber = sqlCache.getBySql(BillOfMaterialsQuery.getDesignLogNumber, params, new SingleColumnRowMapper<>(Long.class)).orElse(null);
//        get permit pack log number
        Long permitPackLogNumber = sqlCache.getBySql(BillOfMaterialsQuery.getPermitPackLogNumber, params, new SingleColumnRowMapper<>(Long.class)).orElse(null);
//        get project/contact? name, address, phone number
        Project project = projectService.getProject(projectId).orElse(new Project());
        String address = buildAddress(project.getStreet1(), project.getStreet2(), project.getCity(), project.getState(), project.getPostalCode());

       SimpleDateFormat formatterCreatedDate = new SimpleDateFormat("MM/dd/yy");


        HashMap<String, Object> templateParams = new HashMap<>();
        templateParams.put("designLogNumber", designLogNumber);
        templateParams.put("permitPackLogNumber", permitPackLogNumber);
        templateParams.put("projectId", projectId);
        templateParams.put("date", formatterCreatedDate.format(new Date()));
        templateParams.put("shipToName", project.getProjectName());
        templateParams.put("shipToAddress", address);
        templateParams.put("shipToPhoneNumber", project.getPhone());

        Map<String, List<BillOfMaterialsPart>> partsGrouped = parts.stream().collect(Collectors.groupingBy(p -> p.getObjectType()));
        templateParams.put("parts", partsGrouped);

        try {
            final String generatedHtml = generateHtml(templateParams);
            return pdfService.convert(generatedHtml);
        } catch (ApiException apiException) {
            throw apiException;
        } catch (Exception e) {
            log.error("[BOM] Error generating Bill of Materials Pdf", e);
            throw new ApiException("Unknown error generating pdf");
        }
    }


    private BillOfMaterialsPdfTemplatePart templatePartFromBillOfMaterialsPart(BillOfMaterialsPart part){
        BillOfMaterialsPdfTemplatePart templatePart = new BillOfMaterialsPdfTemplatePart();
        BillOfMaterialsPdfTemplatePartDetails details = new BillOfMaterialsPdfTemplatePartDetails();
        templatePart.setObjectType(part.getObjectType());
        details.setPartNumber(part.getPartNumber());
        details.setDescription(part.getDescription());
        details.setQuantity(part.getQuantity());
        templatePart.setDetails(details);

        return templatePart;
    }


    private String generateHtml(Map<String, Object> params) throws TemplateException, IOException {
        final Instant start = Instant.now();

        final StringWriter stringWriter = new StringWriter();
        final Template template = freemarkerConfiguration.getTemplate("bom/index.ftlh");

        template.process(params, stringWriter);
        final String processedTemplate = stringWriter.toString();

        log.debug("Duration of template processing:  {}", Duration.between(start, Instant.now()));
        log.debug(processedTemplate);
        return processedTemplate;
    }



    public String buildAddress(String street1, String street2, String city, String state, String zip) {
        StringBuilder sb = new StringBuilder();
        if(street1 != null){
            sb.append(street1);
        }
        if(street2 != null && street2.length() > 0){
            sb.append("<br/>").append(street2);
        }
        if(city != null){
            sb.append("<br/>").append(city);
        }
        if(state != null) {
            sb.append(", ").append(state);
        }
        if(zip != null){
            sb.append(" ").append(zip);
        }
        return sb.toString();
    }
}
