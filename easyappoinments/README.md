### easyappoinments docker file

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

The app requires `mysql:5.7` image and depends on `mysql`service.

Add the `.env` file with the following variables.

```bash
BASE_URL=http://localhost:8000
LANGUAGE=english
DEBUG_MODE=FALSE

DB_HOST=mysql
DB_NAME=databasename // DB_NAME should match with the environment MYSQL_DATABASE defined in mysql service
DB_USERNAME=dbusername
DB_PASSWORD=dbpassword

GOOGLE_SYNC_FEATURE=FALSE
GOOGLE_PRODUCT_NAME=''
GOOGLE_CLIENT_ID=''
GOOGLE_CLIENT_SECRET=''
GOOGLE_API_KEY=''
```
