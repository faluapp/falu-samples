import os
import json
import requests

import azure.functions as func
from .serializer import TemporaryKeySerializer, IdentityVerificationCreationSerializer, IdentityVerificationSerializer

headers = {
    'Content-Type': 'application/json; charset=utf-8',
    'Authorization': "{} {}".format("Bearer", os.environ.get('FALU_API_KEY')),
    'X-Falu-Version': '2022-05-01',
}


def main(req: func.HttpRequest) -> func.HttpResponse:

    serializer = IdentityVerificationCreationSerializer(**req.get_json())

    if serializer is not None:
        r = requests.post("https://api.falu.io/v1/identity/verifications", data=json.dumps(serializer.__dict__),
                          headers=headers)

        if r.status_code == 200 or r.status_code == 201 or r.status_code == 204:
            print(r.json())
            data = IdentityVerificationSerializer(**r.json())

            if data is not None:
                temp_key = create_temporary_key(data.id)
                if temp_key is None:
                    return func.HttpResponse("Key generation failed", status_code=400)
                data.__dict__["temporary_key"] = temp_key
                return func.HttpResponse(json.dumps(data.__dict__), status_code=200, mimetype='application/json')
        elif r.status_code == 400:
            return func.HttpResponse(json.dumps(r.json()), status_code=400, mimetype='application/json')


def create_temporary_key(identity_verification):
    request = {
        "identity_verification": identity_verification
    }

    r = requests.post("https://api.falu.io/v1/temporary_keys", data=json.dumps(request),
                      headers=headers)

    if r.status_code == 200 or r.status_code == 201 or r.status_code == 204:
        serializer = TemporaryKeySerializer(**r.json())

        if serializer.secret is not None:
            return serializer.secret
        else:
            return None

    return None
