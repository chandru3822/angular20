package com.albatross.api.v1.company.blueraven.services.featDB;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.controllers.featDB.FeatDbContactQuery;
import com.albatross.api.v1.company.blueraven.controllers.featDB.hoa.query.HoaContactQuery;
import com.albatross.api.v1.company.blueraven.controllers.featDB.hoa.query.HoaLinkQuery;
import com.albatross.api.v1.company.blueraven.controllers.featDB.hoa.query.HoaQuery;
import com.albatross.api.v1.company.blueraven.enums.ObjectType;
import com.albatross.api.v1.company.blueraven.models.featDB.*;
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
public class HoaService {

  private final SqlCache sqlCache;
  private final ObjectMapper om;
  private final SecurityService securityService;
  private final BlueravenCustomFieldValueService blueravenCustomFieldValueService;

  public List<Hoa> getAllHoa() {
    HashMap<String, Object> params = new HashMap<>();
    return sqlCache.queryBySql(HoaQuery.list, params, Hoa.class);
  }

  public Optional<HoaDetail> getHoaById(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);

    Optional<HoaDetail> result = sqlCache.getBySql(
      HoaQuery.detailById, params, new HoaDetailMapper<>(HoaDetail.class, om));
    return result;
  }

  public Optional<HoaDetail> simpleUpdate(Hoa hoa) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("currentUser", currentUser.trueUserId());
    params.put("hoaName", hoa.getName());
    params.put("companyStateId", hoa.getCompanyStateId());
    params.put("managementCompanyId", hoa.getManagementCompanyId());
    params.put("archived", hoa.getArchived());
    params.put("id", hoa.getId());

    sqlCache.updateBySql(HoaQuery.simpleUpdate, params);
    return getHoaById(hoa.getId());
  }

  public Optional<HoaDetail> updateHoa(Hoa hoa) {
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
      sqlCache.updateBySql(HoaQuery.update, params);
    } else {
      id = sqlCache.updateBySqlReturningId(HoaQuery.insert, params, "id").longValue();
    }

    blueravenCustomFieldValueService.handleSavingCustomFieldValuesUsingGroups(
      ObjectType.HOA, hoa.getCustomFieldGroups(), id);

    return getHoaById(id);
  }

  public List<HoaCompany> getHoaCompanies() {
    return sqlCache.queryBySql(HoaQuery.getActiveManagementCompanies, Collections.emptyMap(), HoaCompany.class);
  }

  // CONTACTS
  public Optional<FeatDbContact> getHoaContactById(Long contactId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", contactId);

    return sqlCache.get(FeatDbContactQuery.findById, params, FeatDbContact.class);
  }

  public Optional<FeatDbContact> saveHoaContact(
    Long hoaId, Long contactId, FeatDbContact contact) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("hoaId", hoaId);
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
      contactId = sqlCache.updateBySqlReturningId(HoaContactQuery.add, params, "id").longValue();
    } else {
      params.put("contactId", contactId);
      sqlCache.updateBySql(FeatDbContactQuery.update, params);
    }

    return getHoaContactById(contactId);
  }

  public void deleteHoaContact(Long contactId) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("contactId", contactId);
    params.put("currentUser", currentUser.trueUserId());

    sqlCache.updateBySql(FeatDbContactQuery.delete, params);
  }

  // LINKS
  public Optional<FeatDbLink> saveHoaLink(Long hoaId, Long linkId, FeatDbLink link) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("hoaId", hoaId);
    params.put("name", link.getName());
    params.put("link", link.getLink());
    params.put("username", link.getUsername());
    params.put("password", link.getPassword());
    params.put("notes", link.getNotes());
    params.put("currentUser", currentUser.trueUserId());
    params.put("linkTypeId", link.getLinkTypeId());

    if (linkId == null) {
      linkId = sqlCache.updateBySqlReturningId(HoaLinkQuery.add, params, "id").longValue();
    } else {
      params.put("id", linkId);
      sqlCache.updateBySql(HoaLinkQuery.update, params);
    }

    HashMap<String, Object> idParam = new HashMap<>();
    idParam.put("id", linkId);
    return sqlCache.getBySql(HoaLinkQuery.findById, idParam, FeatDbLink.class);
  }

  public void deleteHoaLink(Long linkId) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", linkId);
    params.put("currentUser", currentUser.trueUserId());

    sqlCache.updateBySql(HoaLinkQuery.delete, params);
  }

  public static class HoaDetailMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public HoaDetailMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<FeatDbLink>> linkTypeRef = new TypeReference<>() {};
      TypeReference<List<FeatDbContact>> contactTypeRef = new TypeReference<>() {};

      bw.registerCustomEditor(
        List.class,
        "links",
        new JsonCollectionDeserializer(linkTypeRef, objectMapper));

      bw.registerCustomEditor(
        List.class, "contacts", new JsonCollectionDeserializer(contactTypeRef, objectMapper));
    }
  }


}
