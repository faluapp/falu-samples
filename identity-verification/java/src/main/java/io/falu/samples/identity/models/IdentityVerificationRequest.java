package io.falu.samples.identity.models;

import com.fasterxml.jackson.annotation.JsonProperty;

public record IdentityVerificationRequest(
        String type,
        @JsonProperty("return_url")
        String returnUrl,
        VerificationOptions options) {
}
