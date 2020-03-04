package com.albatross.api.v1.flow.services.propTool;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.model.propTool.Product;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Optional;


/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Slf4j
@Service
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class ProductService {

  private final SqlCache sqlCache;

  private final SecurityService securityService;

  @Autowired
  ObjectMapper om;

  public List<Product> getProductsForCompany() {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    List<Product> results = sqlCache.query("propToolProduct.getAllForCompany", params, Product.class);
    return results;
  }

  public Optional<Product> getProduct(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    Optional<Product> results = sqlCache.get("propToolProduct.getOne", params, Product.class);
    return results;
  }

  public Optional<Product> saveProduct(Product product) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("productName", product.getProductName());
    params.put("termLength", product.getTermLength());
    params.put("interestRate", product.getInterestRate());
    params.put("dealerFee", product.getDealerFee());
    params.put("active", product.getActive());
    Long id;

    if(null != product.getId()) {
      id = product.getId();
      params.put("modifiedById", user.getId());
      params.put("id", id);
      sqlCache.update("propToolProduct.update", params);
    } else {
      params.put("createdById", user.getId());
      params.put("companyId", user.getCompanyId());
      id = sqlCache.updateReturningId("propToolProduct.insert", params, "id").longValue();
    }

    return getProduct(id);
  }

  public void deleteProduct(Long id) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("modifiedById", user.getId());

    sqlCache.update("propToolProduct.delete", params);
  }

}
