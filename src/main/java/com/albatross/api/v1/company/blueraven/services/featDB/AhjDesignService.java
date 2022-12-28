package com.albatross.api.v1.company.blueraven.services.featDB;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.controllers.featDB.ahj.query.AhjDesignQuery;
import com.albatross.api.v1.company.blueraven.enums.ObjectType;
import com.albatross.api.v1.company.blueraven.models.featDB.AhjDesign;
import com.albatross.api.v1.company.blueraven.models.featDB.AhjDesignDetail;
import com.albatross.api.v1.company.blueraven.services.BlueravenCustomFieldValueService;
import com.albatross.api.v1.flow.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Optional;

@Service
@PreAuthorize("hasCompanyAccess(3) && hasFeatureAccessLevel('AHJ')")
@RequiredArgsConstructor
public class AhjDesignService {
  private final SqlCache sqlCache;
  private final SecurityService securityService;
  private final BlueravenCustomFieldValueService blueravenCustomFieldValueService;

  public Optional<AhjDesignDetail> getAhjDesignDetailByAhjId(Long ahjId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("ahjId", ahjId);

    Optional<AhjDesignDetail> design =
        sqlCache.getBySql(
          AhjDesignQuery.detailByAhj,
            params,
            AhjDesignDetail.class);

    if (design.isPresent()) {
      return design;
    }

    User currentUser = securityService.getCurrentUser();
    params.put("currentUser", currentUser.trueUserId());

    // add a blank design and return that
    var created =
        sqlCache.getBySql(AhjDesignQuery.create, params, new SingleColumnRowMapper<>(Integer.class));

    if (created.isPresent()) {
      return sqlCache.getBySql(
        AhjDesignQuery.detailByAhj, params, AhjDesignDetail.class);
    }
    return Optional.empty();
  }

  public Optional<AhjDesignDetail> saveAhjDesign(
      Long ahjId, Long designId, AhjDesign design, Boolean returnValue) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("currentUser", currentUser.trueUserId());

    if (design.getUpdateAllInState() != null && design.getUpdateAllInState() && design.getAhjIds().size() > 0) {
      params.put("ahjIds", design.getAhjIds());
      //todo: this is very slow. needs to be fixed.
      blueravenCustomFieldValueService.bulkHandleSavingCustomFieldValuesUsingGroups(
          ObjectType.AHJ_DESIGN, design.getCustomFieldGroups(), design.getDesignIds());
    } else {
      params.put("ahjId", ahjId);

      if (designId == null) {
        sqlCache.updateBySqlReturningId(AhjDesignQuery.create, params, "id").longValue();
      } else {
        params.put("id", designId);
        blueravenCustomFieldValueService.handleSavingCustomFieldValuesUsingGroups(
            ObjectType.AHJ_DESIGN, design.getCustomFieldGroups(), designId);
      }
    }

    return returnValue ? getAhjDesignDetailByAhjId(ahjId) : Optional.empty();
  }

  public List<AhjDesign> searchAhjsByState(Long stateId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("stateId", stateId);
    return sqlCache.queryBySql(AhjDesignQuery.searchAhjsByState, params, AhjDesign.class);
  }

}
