from typing import List


class TemporaryKeySerializer(object):

    def __init__(self, id, secret, workspace, objects, expires, *args, **kwargs):
        self.id = id
        self.secret = secret
        self.workspace = workspace
        self.objects = objects,
        self.expires = expires


class IdentityVerificationOptionsForDocument(object):

    def __init__(self, allowed: List[str], *args, **kwargs):
        self.allowed = allowed


class IdentityVerificationOptionsForSelfie(object):
    def __init__(self, *args, **kwargs):
        pass


class IdentityVerificationOptionsForVideo(object):

    def __init__(self, recital: int, poses: List[str] = None, *args, **kwargs):
        self.poses = poses
        self.recital = self.recital


class IdentityVerificationOptionsForIdNumber():

    def __init__(self):
        pass


class IdentityVerificationOptions(object):
    def __init__(self, allow_uploads: bool = None, document: IdentityVerificationOptionsForDocument = None, selfie: IdentityVerificationOptionsForSelfie = None, video: IdentityVerificationOptionsForVideo = None, *args, **kwargs):
        self.allow_uploads = allow_uploads
        self.document = document
        self.selfie = selfie
        self.video = video


class IdentityVerificationCreationSerializer(object):

    def __init__(self, type, return_url: str = None, options: IdentityVerificationOptions = None, *args, **kwargs):
        self.type = type
        self.return_url = return_url
        self.options = options


class IdentityVerificationSerializer(object):
    def __init__(self, id: str, status: str, type: str, options: IdentityVerificationOptions = None, client_secret: str = None, url: str = None, reports: List[str] = None, *args, **kwargs):
        self.id = id
        self.status = status
        self.type = type
        self.options = options
        self.client_secret = client_secret
        self.url = url
        self.reports = reports
