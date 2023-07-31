from rest_framework import serializers


class StringListField(serializers.ListField):
    child = serializers.CharField()


class IdentityVerificationOptionsForDocument(serializers.Serializer):
    allowed = StringListField()

    def update(self, instance, validated_data):
        pass

    def create(self, validated_data):
        pass


class IdentityVerificationOptionsForSelfie(serializers.Serializer):
    def update(self, instance, validated_data):
        pass

    def create(self, validated_data):
        pass


class IdentityVerificationOptionsForVideo(serializers.Serializer):
    poses = serializers.ListSerializer(child=serializers.CharField(), required=False, allow_null=True)
    recital = serializers.IntegerField(allow_null=True, required=False)

    def update(self, instance, validated_data):
        pass

    def create(self, validated_data):
        pass


class IdentityVerificationOptionsForIdNumber(serializers.Serializer):

    def update(self, instance, validated_data):
        pass

    def create(self, validated_data):
        pass


class IdentityVerificationOptions(serializers.Serializer):
    allow_uploads = serializers.BooleanField(required=False, default=False)
    id_number = IdentityVerificationOptionsForIdNumber(allow_null=True, required=False)
    document = IdentityVerificationOptionsForDocument(allow_null=True, required=False)
    selfie = IdentityVerificationOptionsForSelfie(allow_null=True, required=False)
    video = IdentityVerificationOptionsForVideo(allow_null=True, required=False)

    def update(self, instance, validated_data):
        pass

    def create(self, validated_data):
        pass


class IdentityVerificationCreationSerializer(serializers.Serializer):
    type = serializers.CharField(required=True, max_length=200)
    return_url = serializers.CharField(required=False, max_length=500, allow_null=True)
    options = IdentityVerificationOptions()

    def update(self, instance, validated_data):
        pass

    def create(self, validated_data):
        pass


class IdentityVerificationSerializer(serializers.Serializer):
    id = serializers.CharField(required=True, max_length=200)
    status = serializers.CharField(required=False, max_length=200)
    type = serializers.CharField(required=False, max_length=200)
    options = IdentityVerificationOptions(required=False)
    client_secret = serializers.CharField(required=False, max_length=200)
    url = serializers.CharField(required=False, max_length=200)
    reports = StringListField(required=False)

    def update(self, instance, validated_data):
        pass

    def create(self, validated_data):
        pass


class TemporaryKeySerializer(serializers.Serializer):
    id = serializers.CharField(required=True, max_length=200)
    secret = serializers.CharField(required=True, max_length=200)
    workspace = serializers.CharField(required=True, max_length=200)
    objects = StringListField()
    expires = serializers.DateTimeField()

    def update(self, instance, validated_data):
        pass

    def create(self, validated_data):
        pass
