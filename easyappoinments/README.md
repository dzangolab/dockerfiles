### easyappoinments docker file

## Arguments used in Dockerfile

```bash
DEBIAN_FRONTEND=noninteractive
EASYAPPOINMENT_RELEASE=1.4.1
```

### Requirements

Add the `env` in the `inside docker/server`.
Add `config.php` in the root directory with the
BASE_URL='http://localhost:8000/'
LANGUAGE='english'
DEBUG_MODE=FALSE

DB_HOST='mysql'
DB_NAME='databasename'
DB_USERNAME='dbusername'
DB_PASSWORD='dbpassword'

GOOGLE_SYNC_FEATURE=FALSE
GOOGLE_PRODUCT_NAME=''
GOOGLE_CLIENT_ID=''
GOOGLE_CLIENT_SECRET =''
GOOGLE_API_KEY=''
