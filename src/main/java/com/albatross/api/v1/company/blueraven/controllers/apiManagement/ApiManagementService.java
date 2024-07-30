package com.albatross.api.v1.company.blueraven.controllers.apiManagement;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.controllers.apiManagement.models.Key;
import com.albatross.api.v1.company.blueraven.controllers.apiManagement.models.Partner;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanWrapper;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class ApiManagementService {

    private final ObjectMapper om;
    private final SqlCache sqlCache;
    private final SecurityService securityService;

    public List<Partner> getPartners() {
        return sqlCache.queryBySql(ApiManagementQuery.getPartners, null, new ApiManagementService.PartnerMapper<>(Partner.class, om));
    }

    public Partner addPartner(Partner partner) {
        Map<String, Object> params = Map.of(
            "code", partner.getCode(),
            "name", partner.getName(),
            "userId", securityService.getCurrentUser().trueUserId()
        );

        var newPartner = sqlCache.getBySql(ApiManagementQuery.addPartner, params,  new ApiManagementService.PartnerMapper<>(Partner.class, om));
        return newPartner.orElseThrow();
    }

    public void updatePartner(Partner partner) {
        Map<String, Object> params = Map.of(
            "id", partner.getId(),
            "name", partner.getName(),
            "userId", securityService.getCurrentUser().trueUserId()
        );

        sqlCache.updateBySql(ApiManagementQuery.updatePartner, params);
    }

    public Key addKey(Key key) {
        Map<String, Object> params = Map.of(
            "description", key.getDescription(),
            "isAdmin", key.getIsAdmin(),
            "userId", securityService.getCurrentUser().trueUserId(),
            "partnerId", key.getPartnerId()
        );

        var newKey = sqlCache.getBySql(ApiManagementQuery.addKey, params, Key.class);
        return newKey.orElseThrow();
    }

    public void updateKey(Key key) {
        Map<String, Object> params = new HashMap<>();
        params.put("id", key.getId());
        params.put("description", key.getDescription());
        params.put("isAdmin", key.getIsAdmin());
        params.put("validUntil", key.getValidUntil());
        params.put("userId", securityService.getCurrentUser().trueUserId());

        sqlCache.updateBySql(ApiManagementQuery.updateKey, params);
    }

    public static class PartnerMapper<T> extends BeanPropertyRowMapper<T> {
        private final ObjectMapper om;

        public PartnerMapper(Class<T> mappedClass, ObjectMapper om) {
            super(mappedClass);
            this.om = om;
        }

        @Override
        protected void initBeanWrapper(BeanWrapper bw) {
            TypeReference<List<Key>> keyRef = new TypeReference<>() {};
            bw.registerCustomEditor(List.class, "keys", new JsonCollectionDeserializer(keyRef, om));
        }
    }
}
