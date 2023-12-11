package com.albatross.api.v1.company.blueraven.models;

import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
public class ProposalCommissionDetail {
  private Double redline_amount, source_discount, adders_dollar_watts, base_price, commissions_dollar_watts,
    total_ppw, system_size, cash_price, loan_amount, monthly_payment, commission_kw, total_commissions, above_line_rebate;
  private Boolean recommended;

}
