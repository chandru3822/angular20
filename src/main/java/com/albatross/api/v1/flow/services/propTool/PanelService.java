package com.albatross.api.v1.flow.services.propTool;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.model.propTool.Panel;
import com.albatross.api.v1.flow.model.propTool.PanelState;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Optional;


/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Slf4j
@Service
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class PanelService {

  private final SqlCache sqlCache;

  private final SecurityService securityService;

  @Autowired
  ObjectMapper om;

  public List<Panel> getPanelsForCompany() {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    List<Panel> results = sqlCache.query("propToolPanel.getAllForCompany", params, new PanelMapper<>(Panel.class, om));
    return results;
  }

  public Optional<Panel> getPanel(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    Optional<Panel> results = sqlCache.get("propToolPanel.getOne", params, new PanelMapper<>(Panel.class, om));
    return results;
  }

  public Optional<Panel> savePanel(Panel panel) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("panelName", panel.getPanelName());
    params.put("wattage", panel.getWattage());
    params.put("panelType", panel.getPanelType());
    params.put("panelColor", panel.getPanelColor());
    params.put("active", panel.getActive());
    Long id;

    if(null != panel.getId()) {
      id = panel.getId();
      params.put("modifiedById", user.trueUserId());
      params.put("id", id);
      sqlCache.update("propToolPanel.update", params);
    } else {
      params.put("createdById", user.trueUserId());
      params.put("companyId", user.getCompanyId());
      id = sqlCache.updateReturningId("propToolPanel.insert", params, "id").longValue();
    }

    for (PanelState panelState: panel.getPanelStates()) {
      params.put("panelId", id);
      params.put("companyStateId", panelState.getCompanyStateId());
      params.put("adderAmount", panelState.getAdderAmount());
      params.put("archived", panelState.isArchived());

      if(null != panelState.getId()) {
        params.put("panelStateId", panelState.getId());
        sqlCache.update("propToolPanel.updateState", params);
      } else {
        if (!panelState.isArchived()) {
          if (!params.containsKey("createdById")) {
            params.put("createdById", user.trueUserId());
          }

          sqlCache.update("propToolPanel.insertStates", params);
        }

      }
    }

    return getPanel(id);
  }

  public void deletePanel(Long id) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("modifiedById", user.trueUserId());

    sqlCache.update("propToolPanel.delete", params);
  }

  public static class PanelMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public PanelMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<PanelState>> panelStateRef = new TypeReference<>() {
      };
      bw.registerCustomEditor(List.class, "panelStates",
          new JsonCollectionDeserializer(panelStateRef, objectMapper));
    }
  }

}
