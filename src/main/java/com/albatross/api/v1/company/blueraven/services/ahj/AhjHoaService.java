package com.albatross.api.v1.company.blueraven.services.ahj;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.enums.ObjectType;
import com.albatross.api.v1.company.blueraven.models.ahj.AhjUtility;
import com.albatross.api.v1.company.blueraven.models.ahj.AhjUtilityDetail;
import com.albatross.api.v1.company.blueraven.services.BlueravenCustomFieldValueService;
import com.albatross.api.v1.flow.model.User;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Service;

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
    private final NamedParameterJdbcTemplate jdbc;
    private final BlueravenCustomFieldValueService blueravenCustomFieldValueService;

    public List<AhjUtility> getAllAhjUtilities() {
        HashMap<String, Object> params = new HashMap<>();
        return sqlCache.query("ahj.hoa.list.all", params, AhjUtility.class);
    }

    public Optional<AhjUtilityDetail> getUtilityById(Long id) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("id", id);

        return sqlCache.get(
                "ahj.hoa.detailById", params, new AhjUtilityService.AhjUtilityDetailMapper<>(AhjUtilityDetail.class, om));
    }

    public Optional<AhjUtilityDetail> simpleUpdate(AhjUtility utility) {
        User currentUser = securityService.getCurrentUser();

        HashMap<String, Object> params = new HashMap<>();
        params.put("currentUser", currentUser.trueUserId());
        params.put("utilityName", utility.getName());
        params.put("metroAreaId", utility.getMetroAreaId());
        params.put("companyStateId", utility.getCompanyStateId());
        params.put("archived", utility.getArchived());
        params.put("id", utility.getId());

        sqlCache.update("ahj.hoa.simple.update", params);
        return getUtilityById(utility.getId());
    }

    public Optional<AhjUtilityDetail> updateUtility(AhjUtility utility) {
        User currentUser = securityService.getCurrentUser();

        HashMap<String, Object> params = new HashMap<>();
        params.put("currentUser", currentUser.trueUserId());
        params.put("utilityName", utility.getName());
        params.put("metroAreaId", utility.getMetroAreaId());
        params.put("companyStateId", utility.getCompanyStateId());
        params.put("archived", utility.getArchived());

        Long id;

        if (null != utility.getId()) {
            id = utility.getId();
            params.put("id", utility.getId());
            sqlCache.update("ahj.hoa.update", params);
        } else {
            id = sqlCache.updateReturningId("ahj.hoa.insert", params, "id").longValue();
        }

        blueravenCustomFieldValueService.handleSavingCustomFieldValuesUsingGroups(
                ObjectType.AHJ_UTILITY.textValue(), utility.getCustomFieldGroups(), id);

        return getUtilityById(id);
    }

}
