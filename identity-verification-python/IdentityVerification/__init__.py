import os
import json
import requests
import falu

import azure.functions as func
from .serializer import TemporaryKeySerializer, IdentityVerificationCreationSerializer, IdentityVerificationSerializer

falu.api_key = os.environ.get('FALU_API_KEY')


def main(req: func.HttpRequest) -> func.HttpResponse:

    serializer = IdentityVerificationCreationSerializer(**req.get_json())

    if serializer is not None:
        verification, error = falu.IdentityVerification.create_identity_verification(
            data=serializer.__dict__)

        if verification:
            if verification.resource is not None:
                temp_key = create_key(verification.id)

                if temp_key is None:
                    return func.HttpResponse("Key generation failed", status_code=400)

                data = verification.resource
                data["temporary_key"] = temp_key
                return func.HttpResponse(json.dumps(data), status_code=200, mimetype='application/json')
        elif error:
            return func.HttpResponse(error.problem, status_code=error.status_code, mimetype='application/json')


def create_key(identity_verification):
    request = {
        "identity_verification": identity_verification
    }

    temporary_key, error = falu.TemporaryKey.create_temporary_key(data=request)

    if temporary_key is not None:
        if temporary_key.secret is not None:
            return temporary_key.secret
        else:
            return None

    return None
