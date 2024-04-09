# Identity Verification Samples

## Overview

The Identity Verification sample is designed to demonstrate how to integrate Falu's identity verification functionality
into your applications. This sample covers multiple programming languages, providing a comprehensive guide for
developers to incorporate identity verification features into their projects.

### Setting Up Environment Variables

#### [1. Python And Fast API]()

- Create a file named .env in the root directory of the [Python sample](./python).
- Open the .env file and add the following lines:

```text
FALU_API_KEY=flsk_123345345
```

#### [2. Java and Spring Boot]()

- Open the [application.properties](./java/src/main/resources/application.properties) resource file of
  the [Java sample](./java) and add or update the following line:

```properties
falu.apiKey=flsk_123345345
```

### Running the Samples Locally

### [1. Python And Fast API]()

To run the Identity Verification sample locally using Python, follow these steps:

- Navigate to the Python Sample Directory:

    ```bash
    cd identity-verification/python
    ```

- Install Dependencies:

    ```bash
    pipenv install
    ```

- Set Up Environment Variables:

  Follow the instructions provided above to set up your Falu API key in the .env file.

- Run the `uvicorn`

    ```bash
    uvicorn main:app --reload
    ```

### [2. Java And Spring Boot]()

To run the Identity Verification sample locally using Java and Spring Boot, follow these steps:

- Navigate to the Python Sample Directory:

```bash
cd identity-verification/java
```

- Set Up Environment Variables:

  Follow the instructions provided above to set up your Falu API key in the `application.properties` file.

- Run spring boot application

    ```bash
    ./gradlew bootRun
    ```

### [3. Call API Endpoints]()

Use the following endpoint to make a `POST` request:

- `${baseURL}/identity/create-verification`

The Sample request body can be as follows:

```json
{
  "options": {
    "allow_uploads": false,
    "document": {
      "allowed": [
        "driving_license",
        "passport",
        "id_card"
      ]
    }
  },
  "type": "document"
}
```