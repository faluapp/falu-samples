from django.urls import path

from identity import views

urlpatterns = [
	path('identity/create-verification/', views.IdentityVerificationCreationView.as_view()),
]
