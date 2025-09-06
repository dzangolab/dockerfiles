#!/bin/bash -eu

. /expand_secrets.sh

expand_secrets 

bash /entrypoint.sh
