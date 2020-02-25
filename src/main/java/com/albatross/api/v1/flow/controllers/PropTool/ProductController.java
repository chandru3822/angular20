package com.albatross.api.v1.flow.controllers.PropTool;

import com.albatross.api.v1.flow.model.propTool.Product;
import com.albatross.api.v1.flow.services.propTool.ProductService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */

@Slf4j
@RestController
@RequestMapping(value = "/api/v1/flow/propTool/product")
public class ProductController {

  @Autowired
  private ProductService productService;

  @GetMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<Product> getProductsForCompany() {
    return productService.getProductsForCompany();
  }

  @DeleteMapping(value = "/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteProduct(@PathVariable Long id) {
    productService.deleteProduct(id);
  }

  @PutMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<Product> saveProduct(@RequestBody Product product) {
    return productService.saveProduct(product);
  }

}
