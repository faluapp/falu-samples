from typing import List, Optional

from pydantic import BaseModel


class IdentityVerificationOptionsForDocument(BaseModel):
	allowed: List[str]


class IdentityVerificationOptionsForSelfie(BaseModel):
	pass


class IdentityVerificationOptionsForVideo(BaseModel):
	poses: List[str]
	recital: int


class IdentityVerificationOptionsForIdNumber(BaseModel):
	pass


class IdentityVerificationOptionsForTax(BaseModel):
	allowed: List[str]


class IdentityVerificationOptions(BaseModel):
	allow_uploads: Optional[bool] = None
	id_number: Optional[IdentityVerificationOptionsForIdNumber] = None
	document: Optional[IdentityVerificationOptionsForDocument] = None
	selfie: Optional[IdentityVerificationOptionsForSelfie] = None
	video: Optional[IdentityVerificationOptionsForVideo] = None
	tax_id: Optional[IdentityVerificationOptionsForTax] = None


class IdentityVerificationCreation(BaseModel):
	type: str
	return_url: Optional[str] = None
	options: IdentityVerificationOptions()


class IdentityVerification(BaseModel):
	id: str
	status: Optional[str] = None
	type: Optional[str] = None
	options: Optional[IdentityVerificationOptions] = None
	client_secret: Optional[str] = None
	url: Optional[str] = None
	reports: Optional[List[str]] = None
	temporary_key: str


class TemporaryKey(BaseModel):
	id: str
	secret: str
	workspace: str
	objects: List[str]
	expires: str
