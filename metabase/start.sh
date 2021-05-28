#!/bin/bash

if [ -n "${APP_KEY_FILE}" ]; then
  APP_KEY=$(cat "$APP_KEY_FILE")
  export APP_KEY
fi

# check for docker secrets file
if [[ -n "${MB_DB_USER_FILE}" ]]; then
  MB_DB_USER=$(cat "${MB_DB_USER_FILE}")
  export MD_DB_USER
fi

if [[  -n "${MB_DB_PASS_FILE}" ]]; then
  MB_DB_PASS=$(cat "${MB_DB_PASS_FILE}")
  export MB_DB_PASS
fi

if [[  -n "${MB_DB_DBNAME_FILE}" ]]; then
  MB_DB_DBNAME=$(cat "${MB_DB_DBNAME_FILE}")
  export MB_DB_DBNAME
fi

/app/run_metabase.sh
