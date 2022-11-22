package com.albatross.api.v1.company.blueraven.services.ahj;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.enums.ObjectType;
import com.albatross.api.v1.company.blueraven.models.ahj.*;
import com.albatross.api.v1.company.blueraven.services.BlueravenCustomFieldValueService;
import com.albatross.api.v1.flow.model.User;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Optional;

@Slf4j
@Service
@RequiredArgsConstructor
public class AhjHoaService {

  private final SqlCache sqlCache;
  private final ObjectMapper om;
  private final SecurityService securityService;
  private final BlueravenCustomFieldValueService blueravenCustomFieldValueService;

  public List<AhjHoa> getAllAhjHoa() {
    HashMap<String, Object> params = new HashMap<>();
    return sqlCache.query("ahj.hoa.list.all", params, AhjHoa.class);
  }

  public Optional<AhjHoaDetail> getHoaById(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);

    Optional<AhjHoaDetail> result = sqlCache.get(
      "ahj.hoa.detailById", params, new AhjHoaDetailMapper<>(AhjHoaDetail.class, om));
    return result;
  }

  public Optional<AhjHoaDetail> simpleUpdate(AhjHoa hoa) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("currentUser", currentUser.trueUserId());
    params.put("hoaName", hoa.getName());
    params.put("companyStateId", hoa.getCompanyStateId());
    params.put("managementCompanyId", hoa.getManagementCompanyId());
    params.put("archived", hoa.getArchived());
    params.put("id", hoa.getId());

    sqlCache.update("ahj.hoa.simple.update", params);
    return getHoaById(hoa.getId());
  }

  public Optional<AhjHoaDetail> updateHoa(AhjHoa hoa) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("currentUser", currentUser.trueUserId());
    params.put("hoaName", hoa.getName());
    params.put("companyStateId", hoa.getCompanyStateId());
    params.put("managementCompanyId", hoa.getManagementCompanyId());
    params.put("archived", hoa.getArchived());

    Long id;

    if (null != hoa.getId()) {
      id = hoa.getId();
      params.put("id", hoa.getId());
      sqlCache.update("ahj.hoa.update", params);
    } else {
      id = sqlCache.updateReturningId("ahj.hoa.insert", params, "id").longValue();
    }

    blueravenCustomFieldValueService.handleSavingCustomFieldValuesUsingGroups(
      ObjectType.AHJ_HOA.textValue(), hoa.getCustomFieldGroups(), id);

    return getHoaById(id);
  }

  public List<AhjHoaCompany> getAhjHoaCompanies() {
    return sqlCache.query("ahj.hoa.getActiveManagementCompanies", Collections.emptyMap(), AhjHoaCompany.class);
  }

  // CONTACTS
  public Optional<AhjContact> getHoaContactById(Long contactId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", contactId);

    return sqlCache.get("ahj.hoa.contact.findById", params, AhjContact.class);
  }

  public Optional<AhjContact> saveHoaContact(
    Long hoaId, Long contactId, AhjContact contact) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("ahjHoaId", hoaId);
    params.put("currentUser", currentUser.trueUserId());
    params.put("name", contact.getName());
    params.put("title", contact.getTitle());
    params.put("email", contact.getEmail());
    params.put("phoneNumber", contact.getPhoneNumber());
    params.put("address", contact.getAddress());
    params.put("notes", contact.getNotes());
    params.put("hours", contact.getHours());
    params.put("contactTypeId", contact.getContactTypeId());

    if (contactId == null) {
      contactId = sqlCache.updateReturningId("ahj.hoa.contact.add", params, "id").longValue();
    } else {
      params.put("contactId", contactId);
      sqlCache.update("ahj.hoa.contact.update", params);
    }

    return getHoaContactById(contactId);
  }

  public void deleteHoaContact(Long contactId) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("contactId", contactId);
    params.put("currentUser", currentUser.trueUserId());

    sqlCache.update("ahj.hoa.contact.delete", params);
  }

  // LINKS
  public Optional<AhjLink> saveHoaLink(Long hoaId, Long linkId, AhjLink link) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("ahjHoaId", hoaId);
    params.put("name", link.getName());
    params.put("link", link.getLink());
    params.put("username", link.getUsername());
    params.put("password", link.getPassword());
    params.put("notes", link.getNotes());
    params.put("currentUser", currentUser.trueUserId());
    params.put("linkTypeId", link.getLinkTypeId());

    if (linkId == null) {
      linkId = sqlCache.updateReturningId("ahj.hoa.link.add", params, "id").longValue();
    } else {
      params.put("id", linkId);
      sqlCache.update("ahj.hoa.link.update", params);
    }

    HashMap<String, Object> idParam = new HashMap<>();
    idParam.put("id", linkId);
    return sqlCache.get("ahj.hoa.link.findById", idParam, AhjLink.class);
  }

  public void deleteHoaLink(Long linkId) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", linkId);
    params.put("currentUser", currentUser.trueUserId());

    sqlCache.update("ahj.hoa.link.delete", params);
  }

  public static class AhjHoaDetailMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public AhjHoaDetailMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<AhjLink>> linkTypeRef = new TypeReference<>() {};
      TypeReference<List<AhjContact>> contactTypeRef = new TypeReference<>() {};

      bw.registerCustomEditor(
        List.class,
        "links",
        new JsonCollectionDeserializer(linkTypeRef, objectMapper));

      bw.registerCustomEditor(
        List.class, "contacts", new JsonCollectionDeserializer(contactTypeRef, objectMapper));
    }
  }


}
