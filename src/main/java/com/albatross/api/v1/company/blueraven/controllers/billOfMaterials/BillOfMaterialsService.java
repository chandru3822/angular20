package com.albatross.api.v1.company.blueraven.controllers.billOfMaterials;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.controllers.billOfMaterials.models.BillOfMaterials;
import com.albatross.api.v1.company.blueraven.controllers.billOfMaterials.models.BillOfMaterialsPart;
import com.albatross.api.v1.company.blueraven.controllers.billOfMaterials.query.BillOfMaterialsQuery;
import com.albatross.api.v1.flow.model.User;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Slf4j
@Service
@RequiredArgsConstructor
public class BillOfMaterialsService {

    private final SecurityService securityService;
    private final SqlCache sqlCache;
    private final ObjectMapper om;

    @Transactional
    public Optional<BillOfMaterials> createBomForProject(Long projectId, List<BillOfMaterialsPart> parts){
        User user = securityService.getCurrentUser();
        HashMap<String, Object> params = new HashMap<>();
        params.put("userId", user.getId());
        params.put("projectId", projectId);

        Long bomId = sqlCache.updateBySqlReturningId(BillOfMaterialsQuery.createBomForProject, params, "id").longValue();
        return updateBomParts(bomId, parts);
    }

    @Transactional
    public Optional<BillOfMaterials> updateBomParts(Long bomId, List<BillOfMaterialsPart> parts){
        //the passed in list of parts should be only the parts that have somehow changed;
        // we can then simply update their quantity, whether they're archived, and their dateModified/modifiedById
        User user = securityService.getCurrentUser();

        //do a batch update using upsertBomParts
        final List<Map<String, Object>> params =
                parts.stream().map(p -> {
                    final Map<String, Object> map = new HashMap<>();
                    map.put("userId", user.getId());
                    map.put("quantity", p.getQuantity());
                    map.put("partsMasterId", p.getPartsMasterId());
                    map.put("bomId", bomId);
                    map.put("supplierId", p.getSupplierId());
                    map.put("supplierConfirmed", p.getSupplierConfirmed() != null && p.getSupplierConfirmed()); //if no value for supplierConfirmed, then false
                    Boolean archived = p.getQuantity() > 0 ? p.getArchived() : true; //make sure if they set the quantity to zero the part gets archived
                    map.put("archived", archived);
                    return map;
                }).toList();

        sqlCache.updateBatchBySql(BillOfMaterialsQuery.upsertBomParts, params);

        return getBomById(bomId);
    }

    public Optional<BillOfMaterials> getBomForProject(Long projectId){
        HashMap<String, Object> params = new HashMap<>();
        params.put("projectId", projectId);

        return sqlCache.getBySql(BillOfMaterialsQuery.getBomForProject, params, new BomMapper<>(BillOfMaterials.class, om));
    }

    public Optional<BillOfMaterials> getBomById(Long bomId){
        HashMap<String, Object> params = new HashMap<>();
        params.put("bomId", bomId);
        return sqlCache.getBySql(BillOfMaterialsQuery.getBomById, params, new BomMapper<>(BillOfMaterials.class, om));
    }

    public void deleteBillOfMaterials(Long bomId){
        User user = securityService.getCurrentUser();
        HashMap<String, Object> params = new HashMap<>();
        params.put("userId", user.getId());
        params.put("bomId", bomId);

        sqlCache.updateBySql(BillOfMaterialsQuery.deleteBom, params);
    }

    public static class BomMapper<T> extends BeanPropertyRowMapper<T> {
        private final ObjectMapper objectMapper;

        public BomMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
            super(mappedClass);
            this.objectMapper = objectMapper;
        }

        @Override
        protected void initBeanWrapper(BeanWrapper bw) {
            TypeReference<List<BillOfMaterialsPart>> bomPartsRef = new TypeReference<>() {
            };
            bw.registerCustomEditor(
                    List.class,
                    "partsList",
                    new JsonCollectionDeserializer(bomPartsRef, objectMapper));
        }
    }
}
