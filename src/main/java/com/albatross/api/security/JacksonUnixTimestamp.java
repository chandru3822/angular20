package com.albatross.api.security;

import com.fasterxml.jackson.core.JsonGenerator;
import com.fasterxml.jackson.core.JsonParser;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.DeserializationContext;
import com.fasterxml.jackson.databind.JsonDeserializer;
import com.fasterxml.jackson.databind.JsonSerializer;
import com.fasterxml.jackson.databind.SerializerProvider;

import java.io.IOException;
import java.time.Instant;

/**
 * Helper class to serialize and deserialize {@link Instant} objects as Unix
 *  timestamps (seconds since epoch).
 */
public class JacksonUnixTimestamp {
    public static class Serializer extends JsonSerializer<Instant> {
        public void serialize(Instant value, JsonGenerator gen, SerializerProvider serializers)
                throws IOException, JsonProcessingException {
            gen.writeObject(value.getEpochSecond());
        }
    }

    public static class Deserializer extends JsonDeserializer<Instant> {
        public Instant deserialize(JsonParser p, DeserializationContext ctxt)
                throws IOException, JsonProcessingException {
            return Instant.ofEpochSecond(p.getValueAsLong());
        }
    }
}
