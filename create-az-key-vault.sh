#!/bin/bash

config_path=$1

if [ ! -f "$config_path" ]; then
    echo "Config path: $config_path does not exist."
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
subscription_id=`cat $config_path |  yq '.subscription_id'`
resource_group=`cat $config_path |  yq '.resource_group'`
location=`cat $config_path |  yq '.location'`

keyvault_name=`cat $config_path |  yq '.keyvault_name'` # Max char is 24
keyvault_key=`cat $config_path |  yq '.keyvault_key'`
service_principle_name=`cat $config_path |  yq '.service_principle_name'`
service_principle_filename="$service_principle_name.sp.json"

echo "Load Config completed"
echo "subscription_name = $subscription_name"
echo "subscription_id = $subscription_id"
echo "resource_group = $resource_group"
echo " "
echo "keyvault_name = $keyvault_name"
echo "keyvault_key = $keyvault_key"
echo "service_principle_name = $service_principle_name"
echo "----------------------------------------------"
read -p "Press enter to continue"

# Execute

echo "Setting default subscription to $subscription_name"
az account set --subscription "$subscription_name"

echo "Creating Azure KeyVault Resource: $keyvault_name"
az keyvault create --name $keyvault_name --resource-group $resource_group --location "$location"

echo "Creating Azure Service Principle: $service_principle_name"
az ad sp create-for-rbac -n "$service_principle_name" --role Contributor --scopes /subscriptions/$subscription_id/resourceGroups/$resource_group/providers/Microsoft.KeyVault/vaults/$keyvault_name > $service_principle_filename

appId=`cat $service_principle_filename |  yq '.appId'`
password=`cat $service_principle_filename |  yq '.password'`
tenant=`cat $service_principle_filename |  yq '.tenant'`

export AZURE_CLIENT_ID="$appId"
export AZURE_TENANT_ID="$tenant"
export AZURE_CLIENT_SECRET="$password"

echo "Creating Azure KeyVault - Key: $keyvault_key"
az keyvault key create --name $keyvault_key --vault-name $keyvault_name --protection software --ops encrypt decrypt

echo "Setting Azure KeyVault policy of the Key: $keyvault_key"
az keyvault set-policy --name $keyvault_name --resource-group $resource_group --spn $AZURE_CLIENT_ID --key-permissions encrypt decrypt
