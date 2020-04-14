package com.albatross.api.v1.company.blueraven.services.commissionManagement;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.models.commissionManagement.Residual;
import com.albatross.api.v1.flow.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class ResidualService {

    private final SqlCache sqlCache;
    private final SecurityService securityService;

    public Residual updateResidual(Residual residual) {

        HashMap<String, Object> params = new HashMap<>();
        params.put("name", "put name here or whatever");

        User currentUser = securityService.getCurrentUser();
        String key = "residual.insert";

        if (residual.getId() == null) {
            params.put("createdBy", currentUser.getId());
        } else {
            key = "residual.update";
            params.put("updatedBy", currentUser.getId());
            params.put("id", residual.getId());
        }

        long id = sqlCache.updateReturningId(key, params, "id").longValue();

        return getResidual(id);
    }

    public List<Residual> getResiduals() {
        List<Residual> results = sqlCache.query("residual.getAll", Collections.emptyMap(), Residual.class);
        return results;
    }

    public Residual getResidual(Long id) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("id", id);
        Optional<Residual> result = sqlCache.get("residual.getOne", params, Residual.class);
        return result.orElse(null);
    }

    public void deleteResidual(Long id) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("id", id);
        sqlCache.get("residual.delete", params, Residual.class);
    }
}
