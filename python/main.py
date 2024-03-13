import os

import falu
from fastapi import FastAPI, HTTPException

from models import IdentityVerificationCreation, IdentityVerification

falu.api_key = os.environ.get("FALU_API_KEY")

app = FastAPI()


@app.post("/identity/create-verification", response_model=IdentityVerification)
async def create_verification(verification: IdentityVerificationCreation):
	verification, error = falu.IdentityVerification.create_identity_verification(data=verification.dict())

	if verification and verification.resource is not None:
		temp_key = create_key(verification.id)

		if temp_key is None:
			raise HTTPException(status_code=400, detail="Key generation failed")

		data = verification.resource
		data["temporary_key"] = temp_key
		return data
	else:
		raise HTTPException(status_code=error.status_code, detail=error.problem)


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
