package com.albatross.api.config;

import lombok.Data;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;

@Configuration
@Data
public class WellsFargoConfiguration {
  @Value("${wellsfargo.enabled:true}")
  private Boolean enabled;

  @Value("${wellsfargo.sftp.host:safetransvalidate.wellsfargo.com}")
  private String sftpHost;

  @Value("${wellsfargo.sftp.port:#{null}}")
  private Integer sftpPort;

  //READ ME!!!! - Wells Fargo PRODUCTION will ONLY allow connections via RSA key NOT via username/password
  //if you try to connect without the RSA key it will default the connection attempt to use username/password, and you will get auth failures
  //if you get 3 auth failures in prod you will lock the h6r3lai8 user account and you will have to call them to unlock the account
  //when the account is locked you still get Auth Failed errors, there is no indication that it is due to a locked account
  @Value("${wellsfargo.sftp.user:h6r3lai8}")
  private String sftpUser;

  @Value("${wellsfargo.sftp.password:#{null}}")
  private String sftpPassword;

  @Value("${wellsfargo.sftp.keyPath:~/.ssh/7o/id_rsa_br_wellsfargo}")
  private String sftpKeyPath;

  @Value("${wellsfargo.sftp.uploadPath:inbound/BLUER019_PMGR_1/}")
  private String sftpUploadPath;

  @Value("${wellsfargo.sftp.checkHostKey:true}")
  private Boolean sftpCheckHostKey;

  @Value("${wellsfargo.routingNumber:121000248}") //previously 124002971
  private String routingNumber;

  @Value("${wellsfargo.accountNumber:4078359346}")
  private String accountNumber;

  @Value("${wellsfargo.checkTemplateId:SR0000CL1444CS1784}")
  private String checkTemplateId;

  @Value("${wellsfargo.transactionNumberKey:wells-fargo-transaction}")
  private String transactionNumberKey;

  @Value("${wellsfargo.checkNumberKey:wells-fargo-check}")
  private String checkNumberKey;

  // ---- Blue Raven Address ----

  @Value("${wellsfargo.address.br.name}")
  private String addressName;

  @Value("${wellsfargo.address.br.street1}")
  private String street1;

  @Value("${wellsfargo.address.br.street2}")
  private String street2;

  @Value("${wellsfargo.address.br.city}")
  private String city;

  @Value("${wellsfargo.address.br.state}")
  private String state;

  @Value("${wellsfargo.address.br.postalCode}")
  private String postalCode;

  // ---- Wells Fargo Address ----

  @Value("${wellsfargo.address.bank.name}")
  private String bankAddressName;

  @Value("${wellsfargo.address.bank.street1}")
  private String bankStreet1;

  @Value("${wellsfargo.address.bank.city}")
  private String bankCity;

  @Value("${wellsfargo.address.bank.state}")
  private String bankState;

  @Value("${wellsfargo.address.bank.postalCode}")
  private String bankPostalCode;

  public String getSftpKeyPath() {
    return sftpKeyPath.replace("~", System.getProperty("user.home"));
  }
}
