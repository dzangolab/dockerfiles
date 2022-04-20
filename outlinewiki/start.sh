#! /bin/sh

set -e

if [ -n "${AWS_ACCESS_KEY_ID_FILE}" ]; then
  AWS_ACCESS_KEY_ID=$(cat "$AWS_ACCESS_KEY_ID_FILE")
  export AWS_ACCESS_KEY_ID
fi

if [ -n "${AWS_SECRET_ACCESS_KEY_FILE}" ]; then
  AWS_SECRET_ACCESS_KEY=$(cat "$AWS_SECRET_ACCESS_KEY_FILE")
  export AWS_SECRET_ACCESS_KEY
fi

if [ -n "${DB_PASSWORD_FILE}" ]; then
  DB_PASSWORD=$(cat "$DB_PASSWORD_FILE")
  export DB_PASSWORD
fi

if [ -n "${GOOGLE_CLIENT_ID_FILE}" ]; then
  GOOGLE_CLIENT_ID=$(cat "$GOOGLE_CLIENT_ID_FILE")
  export GOOGLE_CLIENT_ID
fi

if [ -n "${GOOGLE_CLIENT_SECRET_FILE}" ]; then
  GOOGLE_CLIENT_SECRET=$(cat "$GOOGLE_CLIENT_SECRET_FILE")
  export GOOGLE_CLIENT_SECRET
fi

if [ -n "${SECRET_KEY_FILE}" ]; then
  SECRET_KEY=$(cat "$SECRET_KEY_FILE")
  export SECRET_KEY
fi

if [ -n "${SMTP_PASSWORD_FILE}" ]; then
  SMTP_PASSWORD=$(cat "$SMTP_PASSWORD_FILE")
  export SMTP_PASSWORD
fi

if [ -n "${UTILS_SECRET_FILE}" ]; then
  UTILS_SECRET=$(cat "$UTILS_SECRET_FILE")
  export UTILS_SECRET
fi
