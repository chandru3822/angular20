package com.albatross.api.security.jwt;

import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.SneakyThrows;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.codec.binary.Base64;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.jwt.Jwt;
import org.springframework.security.jwt.JwtHelper;
import org.springframework.security.jwt.crypto.sign.InvalidSignatureException;
import org.springframework.security.jwt.crypto.sign.MacSigner;
import org.springframework.stereotype.Component;

import javax.annotation.PostConstruct;
import java.io.IOException;
import java.time.Duration;
import java.time.Instant;
import java.util.Arrays;
import java.util.function.Predicate;

@Component
@SuppressWarnings("serial")
@Slf4j
public class JwtUtils {
    public static final String HEADER = "Authorization";
    public static final String TOKEN_PREFIX = "Bearer ";

    @Value("${security.jwt.expireDuration}")
    private Long jwtExpireDuration;

    @Value("${security.jwt.phrase}")
    private String jwtPhrase;

    @Autowired
    private ObjectMapper objectMapper;

    private MacSigner hmac;

    @PostConstruct
    public void init() {
        hmac = new MacSigner(jwtPhrase);
    }

    public JwtClaims validateAuthHeader(String s) {
        if (!s.startsWith(JwtUtils.TOKEN_PREFIX)) {
            log.info("AUTH: Rejecting call that had incorrect 'Authorization' header.");
            throw new JwtParseException("Invalid Authorization token. Format should be: Bearer [Token]");
        }

        s = s.substring(JwtUtils.TOKEN_PREFIX.length());
        return validateJWT(s);
    }

    public JwtClaims validateJWT(String s) {
        Jwt jwt;
        try {
            validateStructure(s);
            jwt = JwtHelper.decodeAndVerify(s, hmac);
        } catch (InvalidSignatureException e) {
            throw new JwtInvalidSignatureException("Calculated signature does not match actual value");
        }

        JwtClaims claims = getClaims(jwt);

        Instant now    = Instant.now(),
                expiry = claims.getIssuedAt()
                               .plus(Duration.ofDays(jwtExpireDuration));
        if (now.isAfter(expiry)) {
            Duration d = Duration.between(expiry, now);
            throw new JwtTokenExpiredException("Your token expired " + d.toMinutes()
                    + " minutes ago.");
        }
        return claims;
    }

    /**
     * Confirms that the given JWT string has the correct body structure (three
     * Base64 parts, separated by periods).
     *
     * <p>
     * This sort of validation is performed by all good JWT libraries, but doing it
     * manually allows this class to return a more informative error message.
     *
     * @param s the JWT string to validate
     * @throws JwtParseException if the JWT string has the wrong structure
     */
    private String validateStructure(String s) {
        String[] parts = s.split("\\.");
        if (parts.length != 3 || !each(parts, Base64::isBase64))
            throw new JwtParseException("JWT token does not have correct structure");
        return s;
    }

    /**
     * Returns true if <code>pred</code> returns true for all strings in
     *         <code>ss</code>, false otherwise.
     *
     * @param ss the strings to test
     * @param pred the predicate to test
     * @return true if <code>pred</code> returns true for all strings in
     *         <code>ss</code>, false otherwise
     */
    private boolean each(String[] ss, Predicate<String> pred) {
        return Arrays.stream(ss)
                     .allMatch(pred);
    }

    public JwtClaims getClaims(Jwt jwt) {
        JwtClaims claims;
        try {
            claims = objectMapper.readValue(jwt.getClaims(), JwtClaims.class);
        } catch (IOException e) {
            throw new JwtParseException("JWT claims appear corrupted", e);
        }
        return claims;
    }

    @SneakyThrows
    public String encodeDetails(JwtClaims details) {
        String json = objectMapper.writeValueAsString(details);
        return JwtHelper.encode(json, hmac).getEncoded();
    }

    public static class JwtParseException extends AuthenticationException {
        public JwtParseException(String msg) {
            super(msg);
        }

        public JwtParseException(String msg, Throwable t) {
            super(msg, t);
        }
    }

    public static class JwtTokenExpiredException extends AuthenticationException {
        public JwtTokenExpiredException(String msg) {
            super(msg);
        }
    }

    public static class JwtInvalidSignatureException extends AuthenticationException {
        public JwtInvalidSignatureException(String msg) {
            super(msg);
        }
    }
}
