package com.albatross.api.disclosureForm;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import java.math.BigDecimal;

@Data
public class SrecDTO {
  @JsonProperty("form_name")
  private String formName;

  @JsonProperty("form_type")
  private String formType;

  @JsonProperty("vendor_id")
  private Integer vendorId;

  @JsonProperty("is_spanish")
  private String isSpanish;

  @JsonProperty("deposit_owed")
  private String depositOwed;

  @JsonProperty("customer_name")
  private String customerName;

  @JsonProperty("customer_type")
  private String customerType;

  @JsonProperty("repairs_party")
  private String repairsParty;

  @JsonProperty("repairs_years")
  private Integer repairsYears;

  @JsonProperty("abp_contingent")
  private String abpContingent;

  @JsonProperty("installer_known")
  private String installerKnown;

  @JsonProperty("installer_address_1")
  private String installerAddress1;

  @JsonProperty("installer_address_2")
  private String installerAddress2;

  @JsonProperty("installer_address_city")
  private String installerAddressCity;

  @JsonProperty("installer_address_state")
  private String installerAddressState;

  @JsonProperty("installer_address_zip")
  private String installerAddressZip;

  @JsonProperty("installer_address_phone")
  private String installerAddressPhone;

  @JsonProperty("installer_address_email")
  private String installerAddressEmail;

  @JsonProperty("electric_utility")
  private String electricUtility;

  @JsonProperty("installer_name_1")
  private String installerName1;

  @JsonProperty("intermediary_due")
  private String intermediaryDue;

  @JsonProperty("reference_number")
  private String referenceNumber;

  @JsonProperty("repairs_included")
  private String repairsIncluded;

  @JsonProperty("seller_address_1")
  private String sellerAddress1;

  @JsonProperty("seller_address_2")
  private String sellerAddress2;

  @JsonProperty("who_keeps_rebate")
  private String whoKeepsRebate;

  @JsonProperty("final_amount_owed")
  private String finalAmountOwed;

  @JsonProperty("final_payment_due")
  private String finalPaymentDue;

  @JsonProperty("installation_owed")
  private String installationOwed;

  @JsonProperty("inverter_warranty")
  private String inverterWarranty;

  @JsonProperty("maintenance_party")
  private String maintenanceParty;

  @JsonProperty("maintenance_years")
  private Integer maintenanceYears;

  @JsonProperty("mounting_location")
  private String mountingLocation;

  @JsonProperty("project_guarantee")
  private String projectGuarantee;

  @JsonProperty("seller_legal_name")
  private String sellerLegalName;

  @JsonProperty("will_terms_change")
  private String willTermsChange;

  @JsonProperty("customer_address_1")
  private String customerAddress1;

  @JsonProperty("expected_rec_value")
  private BigDecimal expectedRecValue;

  @JsonProperty("project_size_kw_ac")
  private BigDecimal projectSizeKwAc;

  @JsonProperty("project_size_kw_dc")
  private BigDecimal projectSizeKwDc;

  @JsonProperty("seller_address_zip")
  private String sellerAddressZip;

  @JsonProperty("project_submit_date")
  private String projectSubmitDate;

  @JsonProperty("roof_warranty_party")
  private String roofWarrantyParty;

  @JsonProperty("roof_warranty_years")
  private Integer roofWarrantyYears;

  @JsonProperty("seller_address_city")
  private String sellerAddressCity;

  @JsonProperty("customer_address_zip")
  private String customerAddressZip;

  @JsonProperty("initial_deposit_owed")
  private String initialDepositOwed;

  @JsonProperty("loss_damage_included")
  private String lossDamageIncluded;

  @JsonProperty("maintenance_included")
  private String maintenanceIncluded;

  @JsonProperty("mechanic_waiver_date")
  private String mechanicWaiverDate;

  @JsonProperty("panel_warranty_years")
  private Integer panelWarrantyYears;

  @JsonProperty("rec_customer_payment")
  private String recCustomerPayment;

  @JsonProperty("seller_address_email")
  private String sellerAddressEmail;

  @JsonProperty("seller_address_phone")
  private String sellerAddressPhone;

  @JsonProperty("seller_address_state")
  private String sellerAddressState;

  @JsonProperty("customer_address_city")
  private String customerAddressCity;

  @JsonProperty("expected_project_life")
  private Integer expectedProjectLife;

  @JsonProperty("interconnection_party")
  private String interconnectionParty;

  @JsonProperty("intermediary_payments")
  private Integer intermediaryPayments;

  @JsonProperty("seller_marketing_name")
  private String sellerMarketingName;

  @JsonProperty("installer_marketing_name")
  private String installerMarketingName;

  @JsonProperty("customer_address_email")
  private String customerAddressEmail;

  @JsonProperty("customer_address_phone")
  private String customerAddressPhone;

  @JsonProperty("customer_address_state")
  private String customerAddressState;

  @JsonProperty("install_warranty_party")
  private String installWarrantyParty;

  @JsonProperty("install_warranty_years")
  private Integer installWarrantyYears;

  @JsonProperty("installer_legal_name")
  private String installerLegalName;

  @JsonProperty("installer_legal_name_1")
  private String installerLegalName1;

  @JsonProperty("loss_damage_exceptions")
  private String lossDamageExceptions;

  @JsonProperty("roof_warranty_included")
  private String roofWarrantyIncluded;

  @JsonProperty("auto_esign_email_option")
  private String autoEsignEmailOption;

  @JsonProperty("collateral_fee_required")
  private String collateralFeeRequired;

  @JsonProperty("install_start_date_days")
  private Integer installStartDateDays;

  @JsonProperty("inverter_warranty_years")
  private Integer inverterWarrantyYears;

  @JsonProperty("panel_warranty_included")
  private String panelWarrantyIncluded;

  @JsonProperty("gross_electric_production")
  private BigDecimal grossElectricProduction;

  @JsonProperty("install_warranty_included")
  private String installWarrantyIncluded;

  @JsonProperty("install_completion_date_days")
  private Integer installCompletionDateDays;

  @JsonProperty("project_performance_explanation")
  private String projectPerformanceExplanation;

  @JsonProperty("smart_inverter_rebate_submission")
  private String smartInverterRebateSubmission;

  @JsonProperty("explanatory_information")
  private String explanatoryInformation;

  @JsonProperty("transfer_requirements")
  private String transferRequirements;

  @JsonProperty("muni_coop_name")
  @JsonInclude(JsonInclude.Include.NON_NULL)
  private String muniCOOPName;

  @JsonProperty("expected_annual_electricity_usage")
  private BigDecimal expectedAnnualElectricityUsage;

  @JsonProperty("electric_service_billing_type")
  private String electricServiceBillingType;

  @JsonProperty("include_battery")
  private String includeBattery;

  @JsonProperty("battery_size")
  private BigDecimal batterySize;

  @JsonProperty("energy_storage_rebate")
  private String energyStorageRebate;

  @JsonProperty("energy_storage_rebate_recipient")
  private String energyStorageRebateRecipient;

  @JsonProperty("rebate_rate")
  private Integer rebateRate;

  @JsonProperty("netmetering_excess_generation_credit")
  private String netmeteringExcessGenerationCredit;

  public SrecDTO() {
    this.formType = "purchase_form";
    this.vendorId = 39;
    this.isSpanish = "No";
    this.customerType = "Residential/Small Commercial";
    this.repairsParty = "Installer";
    this.repairsYears = 2;
    this.abpContingent = "No";
    this.installerKnown = "Yes";
    this.installerAddress1 = "1403 North Research Way";
    this.installerAddress2 = "Bldg J";
    this.installerAddressCity = "Orem";
    this.installerAddressState = "UT";
    this.installerAddressZip = "84097";
    this.installerAddressPhone = "3854820045";
    this.installerAddressEmail = "environmentalattributes@blueravensolar.com";
    this.installerName1 = "Blue Raven Solar";
    this.intermediaryDue = "N/A";
    this.repairsIncluded = "Yes";
    this.sellerAddress1 = "1403 North Research Way";
    this.sellerAddress2 = "Bldg J";
    this.whoKeepsRebate = "Seller";
    this.inverterWarranty = "Yes";
    this.maintenanceParty = "Seller";
    this.maintenanceYears = 1;
    this.mountingLocation = "Roof-mounted";
    this.projectGuarantee = "For 2 years, installer guarantees that the system will produce: a) within 50PR of Estimated System Output for any 3-month period; and b) within 10PR of Estimated System Output for any 18-month period.";
    this.sellerLegalName = "Blue Raven Solar, LLC";
    this.willTermsChange = "No";
    this.sellerAddressZip = "84097";
    this.projectSubmitDate = "Within 3 weeks after contract signing.";
    this.roofWarrantyParty = "Approved Vendor";
    this.roofWarrantyYears = 10;
    this.sellerAddressCity = "Orem";
    this.lossDamageIncluded = "Yes";
    this.maintenanceIncluded = "No";
    this.mechanicWaiverDate = "N/A";
    this.panelWarrantyYears = 25;
    this.sellerAddressEmail = "environmentalattributes@blueravensolar.com";
    this.sellerAddressPhone = "3854820045";
    this.sellerAddressState = "UT";
    this.expectedProjectLife = 25;
    this.interconnectionParty = "Approved Vendor";
    this.intermediaryPayments = 0;
    this.sellerMarketingName = "Blue Raven Solar";
	this.installerMarketingName = "Blue Raven Solar";
    this.installWarrantyParty = "Approved Vendor";
    this.installWarrantyYears = 10;
    this.installerLegalName = "Blue Raven Solar, LLC";
    this.installerLegalName1 = "Blue Raven Solar, LLC";
    this.lossDamageExceptions = "None";
    this.roofWarrantyIncluded = "Yes";
    this.autoEsignEmailOption = "Yes";
    this.collateralFeeRequired = "No";
    this.installStartDateDays = 49;
    this.inverterWarrantyYears = 25;
    this.panelWarrantyIncluded = "Yes";
    this.installWarrantyIncluded = "Yes";
    this.installCompletionDateDays = 77;
    this.projectPerformanceExplanation = "system performance is based on the Aurora software we use";
    this.smartInverterRebateSubmission = "No";
	this.explanatoryInformation = "Customer is contractually obligated to provide production for the next 15 years. If the customer moves, or the system goes offline; the customer must complete the necessary actions to give production data to the Company.";
	this.transferRequirements = "Customer must provide contact information for the new homeowner and proof of ownership. Customer must also explain how the system cost will be paid off, either by the new homeowner or themselves.";
  }
}
