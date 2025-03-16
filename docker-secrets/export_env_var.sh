#!/bin/bash
#!/bin/bash

# Check if two arguments were provided
if [ $# -ne 2 ]; then
    echo "Usage: $0 <variable_name> <variable_value>"
    exit 1
fi

# Get the name and value of the environment variable from the arguments
var_name=$1
var_value=$2

# Set the environment variable
# ${var_name}=${var_value}
# export "$var_name"
export -- ${var_name}=${var_value}

# Print a confirmation message
echo "Environment variable $var_name set to: $var_value"

# Optionally, print the variable to verify it's set
echo "Verification: $var_name = ${!var_name}"
