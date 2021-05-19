### Easyappoinments docker file

#### List of env vars supported


|Env variable|Type|Required|Default|Description|
|---|---|---|---|---|
|BASE_URL|String|TRUE||Base url of the app e.g: https://localhost:8000|
|LANGUAGE|String| |english| Language of the app|
|DEBUG_MODE|String| |FALSE|Enable/Disable debug mode, set to `TRUE` to enable debug mode|
|DB_HOST|String|TRUE| |Database host|
|DB_NAME|String|TRUE| |Database name|
|DB_USERNAME|String|TRUE| |Database username|
|DB_PASSWORD|String|TRUE| |Database password|
|DB_PASSWORD_FILE|String|TRUE| |Provide file to set DB_PASSWORD, `this will override DB_PASSWORD` |
|GOOGLE_SYNC_FEATURE|String| |FALSE|Enable/Disable google calendar sync feature, set to `TRUE` to enable the feature|
|GOOGLE_PRODUCT_NAME|String||||
|GOOGLE_CLIENT_ID|String||||
|GOOGLE_CLIENT_SECRET|String||||
|GOOGLE_CLIENT_SECRET_FILE|String| | |Provide file to set GOOGLE_CLIENT_SECRET, `this will override GOOGLE_CLIENT_SECRET`|
|GOOGLE_API_KEY|String||||
|GOOGLE_API_KEY_FILE|String| | |Provide file to set GOOGLE_API_KEY, `this will override GOOGLE_API_KEY`|
