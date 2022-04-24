#!/bin/bash

plain_file=$1
encrypted_file=$2

vault_url=`yq '.sops.azure_kv[0].vault_url' $encrypted_file`
vault_name=`yq '.sops.azure_kv[0].name' $encrypted_file`
vault_version=`yq '.sops.azure_kv[0].version' $encrypted_file`
keyvault_id="$vault_url/keys/$vault_name/$vault_version"

# echo $vault_url
sops --encrypt --azure-kv $keyvault_id $plain_file > $encrypted_file
