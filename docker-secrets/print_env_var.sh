#!/bin/bash

# Check if an argument was provided
if [ $# -eq 0 ]; then
    echo "Please provide the name of the environment variable as an argument."
    exit 1
fi

# Get the name of the environment variable from the first argument
var_name=$1
 
# Check if the variable exists and print its value
if [ -n "$var_name:-" ]; then
    echo "The value of $var_name is: ${!var_name}"
else
    echo "Environment variable $var_name does not exist."
fi
