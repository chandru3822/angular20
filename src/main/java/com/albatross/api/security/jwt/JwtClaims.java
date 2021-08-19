package com.albatross.api.security.jwt;

import com.albatross.api.security.JacksonUnixTimestamp;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.databind.annotation.JsonDeserialize;
import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import com.fasterxml.jackson.databind.ser.std.ToStringSerializer;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.NonNull;
import lombok.experimental.Accessors;

import java.time.Instant;

import static com.fasterxml.jackson.annotation.JsonInclude.Include.NON_NULL;

/**
 * This class defines what claims will be in the JWT body.
 *
 * <p>
 * The JWT body is not encrypted, so don't put anything insecure in here.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(NON_NULL)
@Accessors(chain = true)
public class JwtClaims {
  /**
   * The user id, associated with the <a href=
   * "https://tools.ietf.org/html/draft-ietf-oauth-json-web-token-32#page-9">sub</a>
   * field.
   *
   * <p>
   * Must be stored as a String or URI.
   */
  @JsonProperty("sub")
  @JsonSerialize(using = ToStringSerializer.class)
  @NonNull
  private Long userId;

  /**
   * The timestamp of when this JWT was issued; associated with the <a href=
   * "https://tools.ietf.org/html/draft-ietf-oauth-json-web-token-32#page-10">iat</a>
   * field.
   *
   * <p>
   * Must be stored as <a href=
   * "https://tools.ietf.org/html/draft-ietf-oauth-json-web-token-32#page-6">seconds
   * since epoch</a>.
   */
  @JsonProperty("iat")
  @JsonSerialize(using = JacksonUnixTimestamp.Serializer.class)
  @JsonDeserialize(using = JacksonUnixTimestamp.Deserializer.class)
  @NonNull
  private Instant issuedAt;

  /**
   * The id of the user who is masquerading. Optional; this field will be
   * omitted from the JWT if it is null.
   */
  @JsonProperty("masqueradingUserId")
  @JsonSerialize(using = ToStringSerializer.class)
  private Long masqueradingUserId;

  /**
   * The company_id of the user who is masquerading. This does not get set to the company of the user they masqueraded as
   * used to overwrite the user's default in case we try to masquerade to company_id 3 and their default is 19
   * omitted from the JWT if it is null.
   */
  @JsonProperty("companyId")
  @JsonSerialize(using = ToStringSerializer.class)
  private Long companyId;


  @JsonProperty("exp")
  @JsonSerialize(using = JacksonUnixTimestamp.Serializer.class)
  @JsonDeserialize(using = JacksonUnixTimestamp.Deserializer.class)
  private Instant expiresAt;
}
