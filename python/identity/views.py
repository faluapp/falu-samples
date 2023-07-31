import falu
from django.conf import settings
from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView

from .serializer import IdentityVerificationCreationSerializer

falu.api_key = settings.FALU_API_KEY


class IdentityVerificationCreationView(APIView):
	def post(self, request, format=None):
		serializer = IdentityVerificationCreationSerializer(data=request.data)

		if serializer.is_valid():
			verification, error = falu.IdentityVerification.create_identity_verification(data=serializer.data)

			if verification:
				if verification.resource is not None:
					temp_key = create_key(verification.id)

					if temp_key is None:
						return Response({"Key generation failed"}, status=status.HTTP_400_BAD_REQUEST)

					data = verification.resource
					data["temporary_key"] = temp_key
					return Response(data, status=status.HTTP_200_OK)
			elif error:
				return Response(error.problem, status=error.status_code)

		return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


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
