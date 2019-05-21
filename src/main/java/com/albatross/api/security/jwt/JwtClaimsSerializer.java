package com.albatross.api.security.jwt;

import com.fasterxml.jackson.core.JsonGenerator;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonSerializer;
import com.fasterxml.jackson.databind.SerializerProvider;
import org.springframework.beans.factory.annotation.Autowired;

import java.io.IOException;

public class JwtClaimsSerializer extends JsonSerializer<JwtClaims> {
    @Autowired
    private JwtUtils jwtUtils;

    @Override
    public void serialize(JwtClaims jwt, JsonGenerator gen, SerializerProvider serializers)
            throws IOException, JsonProcessingException {
        gen.writeObject(jwtUtils.encodeDetails(jwt));
    }
}
