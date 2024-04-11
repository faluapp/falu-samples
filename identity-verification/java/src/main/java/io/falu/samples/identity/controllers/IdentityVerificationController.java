package io.falu.samples.identity.controllers;

import io.falu.samples.identity.models.IdentityVerificationRequest;
import io.falu.samples.identity.services.IdentityService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import java.io.IOException;

@RestController()
public class IdentityVerificationController {
    @Autowired
    private IdentityService identityVerificationService;

    @PostMapping(path = "/identity/create-verification")
    public ResponseEntity<Object> createIdentityVerification(@RequestBody IdentityVerificationRequest request) throws IOException {
        return identityVerificationService.createIdentityVerification(request);
    }
}
