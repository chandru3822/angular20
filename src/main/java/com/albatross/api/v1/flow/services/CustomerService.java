package com.albatross.api.v1.flow.services;

import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.services.dto.DtoCustomer;
import com.google.common.collect.ImmutableMap;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Collection;
import java.util.Optional;

@Slf4j
@Service
public class CustomerService {
    @Autowired
    private SqlCache sqlCache;

    public Collection<DtoCustomer> getCustomers(Long companyId, Pagination pagination) {
        return sqlCache.query("customer.getAllForCompany",
                ImmutableMap.of("companyId", companyId,
                                "offset", pagination.getStartOffset(),
                                "limit", pagination.getSize()),
                DtoCustomer.class);
    }

    public Optional<DtoCustomer> getCustomer(Long companyId, Long customerId) {
        return sqlCache.get("customer.get",
                ImmutableMap.of("companyId", companyId,
                                "customerId", customerId),
                DtoCustomer.class);
    }
}
