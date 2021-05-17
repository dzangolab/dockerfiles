### easyappoinments docker file

### Arguments used in Dockerfile

```bash
DEBIAN_FRONTEND=noninteractive
EASYAPPOINMENT_RELEASE=1.4.1
```

###Installation
Clone the repository

```bash
git clone https://github.com/dzangolab/dockerfiles.git
```

Change the directory

```bash
cd easyappoinments
```

Build the image

```bash
docker build -t easyappoinment:latest .
```

### Usage

Write the `docker-compose.yml` file and add the follwing services.

The app requires `mysql:5.7` image and depends on `mysql`service.

Add the `.env` file with the following variables.

```bash
BASE_URL='http://localhost:8000/'
LANGUAGE='english'
DEBUG_MODE=FALSE

DB_HOST='mysql'
DB_NAME='databasename' // it should match with the environment MYSQL_DATABASE defined in mysql service
DB_USERNAME='dbusername'
DB_PASSWORD='dbpassword'

GOOGLE_SYNC_FEATURE=FALSE
GOOGLE_PRODUCT_NAME=''
GOOGLE_CLIENT_ID=''
GOOGLE_CLIENT_SECRET=''
GOOGLE_API_KEY=''
```
