#!/bin/bash -eu

. /expand_secrets.sh

expand_secrets 

bash /usr/src/appEntry/start.sh
