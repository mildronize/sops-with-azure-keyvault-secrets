#!/bin/bash

config_path=$1
plain_file=$2

if [ ! -f "$config_path" ]; then
    echo 1>&2 "Config path: $config_path does not exist."
    exit 1
fi

# Check command

RequiredCommands=("az" "yq" "sops")

for cmd in ${RequiredCommands[@]};
do
    if ! command -v $cmd &> /dev/null
    then
        echo "$cmd could not be found, please install"
        exit
    fi
done

# Load Config
subscription_name=`cat $config_path |  yq '.subscription_name'`

echo 1>&2 "Load Config completed"
echo 1>&2 "subscription_name = $subscription_name"
echo 1>&2 "----------------------------------------------"

read -p "Press enter to continue"

# Execute

export AZURE_AUTH_METHOD="cli"

echo 1>&2 "Setting default subscription to $subscription_name"
az account set --subscription "$subscription_name"

sops --decrypt $target_file