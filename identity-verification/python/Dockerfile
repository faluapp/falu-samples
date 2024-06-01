FROM python:3.11-slim-buster

LABEL org.opencontainers.image.description="Sample Python application providing server-side identity verification functionality using Falu."
EXPOSE 8000
ENV PYTHONUNBUFFERED 1

WORKDIR /app

RUN pip install pipenv

COPY . .
RUN pipenv install --system --deploy --ignore-pipfile

CMD ["fastapi", "run"]
