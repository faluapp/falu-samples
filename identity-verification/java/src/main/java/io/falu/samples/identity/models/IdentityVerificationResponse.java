package io.falu.samples.identity.models;

import com.fasterxml.jackson.annotation.JsonProperty;

public record IdentityVerificationResponse(
        String id,
        String status,
        String type,
        @JsonProperty("client_secret")
        String clientSecret,
        String url,
        @JsonProperty("temporary_key")
        String temporaryKey) {
}
