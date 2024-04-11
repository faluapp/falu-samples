package io.falu.samples.identity.services;

import io.falu.Falu;
import io.falu.FaluClientOptions;
import io.falu.client.ResourceResponse;
import io.falu.models.identityVerification.*;
import io.falu.models.temporaryKeys.TemporaryKey;
import io.falu.models.temporaryKeys.TemporaryKeyCreateRequest;
import io.falu.networking.RequestOptions;
import io.falu.samples.identity.models.IdentityVerificationRequest;
import io.falu.samples.identity.models.IdentityVerificationResponse;
import io.falu.samples.identity.models.VerificationOptions;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

import java.io.IOException;

@Service
public class IdentityService {

    @Value("${falu.apiKey}")
    private String apiKey;

    private RequestOptions requestOptions = RequestOptions.builder().build();

    private static IdentityVerificationOptions makeVerificationOptions(VerificationOptions options) {
        if (options.selfie() != null) {
            return IdentityVerificationOptions.builder()
                    .selfie(IdentityVerificationOptionsForSelfie.builder().build())
                    .build();
        }

        if (options.video() != null) {
            return IdentityVerificationOptions.builder()
                    .video(IdentityVerificationOptionsForVideo.builder()
                            .poses(options.video().poses())
                            .recital(options.video().recital())
                            .build()
                    )
                    .build();
        }

        if (options.document() != null) {
            return IdentityVerificationOptions.builder()
                    .document(IdentityVerificationOptionsForDocument.builder()
                            .allowed(options.document().allowed())
                            .build()
                    )
                    .build();
        }


        return IdentityVerificationOptions.builder()
                .idNumber(IdentityVerificationOptionsForIdNumber.builder().build())
                .build();
    }

    public ResponseEntity<Object> createIdentityVerification(IdentityVerificationRequest request) throws IOException {
        if (request == null) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Request body cannot be empty");
        }

        FaluClientOptions options = FaluClientOptions.builder()
                .apiKey(apiKey)
                .enableLogging(true)
                .build();

        Falu falu = new Falu(options);

        IdentityVerificationCreateRequest verificationCreateRequest = IdentityVerificationCreateRequest.builder()
                .type(request.type())
                .returnUrl(request.returnUrl())
                .options(makeVerificationOptions(request.options()))
                .build();

        ResourceResponse<IdentityVerification> response = falu.getIdentityVerificationService()
                .createIdentityVerification(verificationCreateRequest, requestOptions);

        if (response == null) {
            return ResponseEntity
                    .internalServerError()
                    .build();
        }

        if (response.getResource() == null && response.getError() != null) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response.getError());
        }

        IdentityVerification verification = response.getResource();

        TemporaryKey temporaryKey = generateTemporaryKey(verification.getId(), falu);

        if (temporaryKey == null) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Failed to generate Temporary Key");
        }

        IdentityVerificationResponse verificationResponse = new IdentityVerificationResponse(
                verification.getId(),
                verification.getStatus(),
                verification.getType(),
                verification.getClientSecret(),
                verification.getUrl(),
                temporaryKey.getSecret()
        );

        return ResponseEntity.ok(verificationResponse);
    }

    private TemporaryKey generateTemporaryKey(String verification, Falu falu) throws IOException {
        TemporaryKeyCreateRequest request = TemporaryKeyCreateRequest.builder()
                .identityVerification(verification)
                .build();

        ResourceResponse<TemporaryKey> response = falu.getTemporaryKeyService().createTemporaryKey(request, requestOptions);

        if (response != null && response.successful() && response.getResource() != null) {
            return response.getResource();
        }

        return null;
    }
}
