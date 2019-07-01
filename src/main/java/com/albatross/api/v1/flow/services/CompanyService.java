package com.albatross.api.v1.flow.services;

import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.services.dto.DtoCompany;
import com.google.common.collect.ImmutableMap;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Collection;
import java.util.Optional;

@Slf4j
@Service
public class CompanyService {
    @Autowired
    private SqlCache sqlCache;

    public Collection<DtoCompany> getCompanies(Pagination pagination) {
        return sqlCache.queryBySql("select id, company_name as name from flow.company offset :offset limit :limit;",
                ImmutableMap.of("offset", pagination.getStartOffset(),
                                "limit", pagination.getSize()),
                DtoCompany.class);
    }

    public Optional<DtoCompany> getCompany(Long id) {
        return sqlCache.getBySql("select id, company_name as name from flow.company where id = :id;",
                ImmutableMap.of("id", id),
                DtoCompany.class);
    }
}
