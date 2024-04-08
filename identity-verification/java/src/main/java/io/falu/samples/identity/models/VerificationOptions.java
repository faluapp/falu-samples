package io.falu.samples.identity.models;

import com.fasterxml.jackson.annotation.JsonProperty;

public record VerificationOptions(
        @JsonProperty("allow_uploads")
        String allowUploads,
        @JsonProperty("id_number")
        VerificationOptionsForIdNumber idNumber,

        VerificationOptionsForSelfie selfie,

        VerificationOptionsForVideo video,

        VerificationOptionsForDocument document
) {
}
