package com.albatross.api.v1.company.blueraven.services.featDB;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.controllers.featDB.FeatDbContactQuery;
import com.albatross.api.v1.company.blueraven.controllers.featDB.suppliers.query.SupplierContactQuery;
import com.albatross.api.v1.company.blueraven.controllers.featDB.suppliers.query.SupplierLinkQuery;
import com.albatross.api.v1.company.blueraven.controllers.featDB.suppliers.query.SupplierQuery;
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

import java.util.*;

@Slf4j
@Service
@RequiredArgsConstructor
public class SupplierService {

  private final SqlCache sqlCache;
  private final ObjectMapper om;
  private final SecurityService securityService;
  private final BlueravenCustomFieldValueService blueravenCustomFieldValueService;

  public List<Supplier> getAllSuppliers() {
    HashMap<String, Object> params = new HashMap<>();
    return sqlCache.queryBySql(SupplierQuery.list, params, Supplier.class);
  }

  public Optional<SupplierDetail> getSupplierById(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);

    return sqlCache.getBySql(
      SupplierQuery.detailById, params, new SupplierDetailMapper<>(SupplierDetail.class, om));
  }

  public Optional<SupplierDetail> simpleUpdate(Supplier supplier) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("currentUser", currentUser.trueUserId());
    params.put("supplierName", supplier.getName());
    params.put("companyStateId", supplier.getCompanyStateId());
    params.put("archived", supplier.getArchived());
    params.put("id", supplier.getId());

    sqlCache.updateBySql(SupplierQuery.simpleUpdate, params);
    return getSupplierById(supplier.getId());
  }

  public Optional<SupplierDetail> updateSupplier(Supplier supplier) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("currentUser", currentUser.trueUserId());
    params.put("supplierName", supplier.getName());
    params.put("companyStateId", supplier.getCompanyStateId());
    params.put("archived", supplier.getArchived());

    Long id;

    if (null != supplier.getId()) {
      id = supplier.getId();
      params.put("id", supplier.getId());
      sqlCache.updateBySql(SupplierQuery.update, params);
    } else {
      id = sqlCache.updateBySqlReturningId(SupplierQuery.insert, params, "id").longValue();
    }

    blueravenCustomFieldValueService.handleSavingCustomFieldValuesUsingGroups(
      ObjectType.SUPPLIERS, supplier.getCustomFieldGroups(), id);

    return getSupplierById(id);
  }

  public void deleteSupplier(Long id) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("currentUser", currentUser.trueUserId());

    sqlCache.updateBySql(SupplierQuery.delete, params);
  }

  // CONTACTS
  public Optional<FeatDbContact> getSupplierContactById(Long contactId) {
    return sqlCache.getBySql(FeatDbContactQuery.findById, Map.of("id", contactId), FeatDbContact.class);
  }

  public Optional<FeatDbContact> saveSupplierContact(
    Long supplierId, Long contactId, FeatDbContact contact) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("supplierId", supplierId);
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
      contactId = sqlCache.updateBySqlReturningId(SupplierContactQuery.add, params, "id").longValue();
    } else {
      params.put("contactId", contactId);
      sqlCache.updateBySql(FeatDbContactQuery.update, params);
    }

    return getSupplierContactById(contactId);
  }

  public void deleteSupplierContact(Long contactId) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("contactId", contactId);
    params.put("currentUser", currentUser.trueUserId());

    sqlCache.updateBySql(FeatDbContactQuery.delete, params);
  }

  // LINKS
  public Optional<FeatDbLink> saveSupplierLink(Long supplierId, Long linkId, FeatDbLink link) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("supplierId", supplierId);
    params.put("name", link.getName());
    params.put("link", link.getLink());
    params.put("username", link.getUsername());
    params.put("password", link.getPassword());
    params.put("notes", link.getNotes());
    params.put("currentUser", currentUser.trueUserId());
    params.put("linkTypeId", link.getLinkTypeId());

    if (linkId == null) {
      linkId = sqlCache.updateBySqlReturningId(SupplierLinkQuery.add, params, "id").longValue();
    } else {
      params.put("id", linkId);
      sqlCache.updateBySql(SupplierLinkQuery.update, params);
    }

    HashMap<String, Object> idParam = new HashMap<>();
    idParam.put("id", linkId);
    return sqlCache.getBySql(SupplierLinkQuery.findById, idParam, FeatDbLink.class);
  }

  public void deleteSupplierLink(Long linkId) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", linkId);
    params.put("currentUser", currentUser.trueUserId());

    sqlCache.updateBySql(SupplierLinkQuery.delete, params);
  }

  public static class SupplierDetailMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public SupplierDetailMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
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
