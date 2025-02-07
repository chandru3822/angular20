package com.albatross.api.v1.company.blueraven.controllers.billOfMaterials;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.controllers.billOfMaterials.models.BillOfMaterialsPart;
import com.albatross.api.v1.company.blueraven.controllers.billOfMaterials.query.BillOfMaterialsQuery;
import com.albatross.api.v1.flow.model.User;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class BillOfMaterialsService {

    private final SecurityService securityService;
    private final SqlCache sqlCache;
    private final ObjectMapper om;

    @Transactional
    public List<BillOfMaterialsPart> upsertBomParts(Long projectId, List<BillOfMaterialsPart> parts){
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
                    map.put("projectId", projectId);
                    map.put("supplierId", p.getSupplierId());
                    map.put("supplierConfirmed", p.getSupplierConfirmed() != null && p.getSupplierConfirmed()); //if no value for supplierConfirmed, then false
                    Boolean archived = p.getQuantity() <= 0 || p.getArchived() != null && p.getArchived(); //make sure if they set the quantity to zero the part gets archived
                    map.put("archived", archived);
                    return map;
                }).toList();

        sqlCache.updateBatchBySql(BillOfMaterialsQuery.upsertBomParts, params);

        return getBomForProject(projectId);
    }

    public List<BillOfMaterialsPart> getBomForProject(Long projectId){
        HashMap<String, Object> params = new HashMap<>();
        params.put("projectId", projectId);

        return sqlCache.queryBySql(BillOfMaterialsQuery.getBomForProject, params, BillOfMaterialsPart.class);
    }

    public void deleteBillOfMaterialsAllParts(Long projectId){
        User user = securityService.getCurrentUser();
        HashMap<String, Object> params = new HashMap<>();
        params.put("userId", user.getId());
        params.put("projectId", projectId);

        sqlCache.updateBySql(BillOfMaterialsQuery.deleteAllBomParts, params);
    }

}
