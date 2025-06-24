# dzangolab/kimai

A custom Docker image for the Outline [Outline](https://www.getoutline.com/) app with added support for docker secrets.

## Base image

This image is based on the [outlinewiki/outline:0.84](https://hub.docker.com/layers/outlinewiki/outline/0.84/images/sha256-e81661ce2ef8e623eb36e8cd9f37ce4c1b75b895ff9234bb26b97c9fe0066b9c) image.

## Environment variables

WIP

If you want to test it locally, create a google client id and secret if you don't have one:

1. Open the Google Cloud Console at console.cloud.google.com 

2. In the top-left project dropdown, create a new project, or select an existing one 

3. Go to APIs & Services → OAuth consent screen.

4. Choose External

5. Fill in App name, Support email, and other required fields

6. Go to APIs & Services → Credentials, click Create credentials → OAuth client ID 

7. Choose Web application, then set:

8. Authorized JavaScript origins:
http://localhost:3000

9. Authorized redirect URIs:
http://localhost:3000/auth/google.callback 

Click Create, and Google will reveal your Client ID and Client Secret. Copy and paste them in the secrets folder corresponding file.

10. docker compose up --build

11. Go to [localhost:3000](http://localhost:3000/)

12. Connect using your dzango email ( cannot connect with a personal account )
