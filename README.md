# sops-with-azure-keyvault-secrets

For SOPS documentation: https://github.com/mildronize/actions-get-secret-sops

Supported Platform: WSL, Linux, Mac OS

## How to add secrets 

1. Decrypt SOPS to plain text (**DO NOT PUSH PLAIN TEXT**)
   ```bash
   ./decrypt.sh thadaw/dev.enc.yaml > thadaw/dev.plain.yaml
   ```

2. Modify `thadaw/dev.plain.yaml` (**DO NOT PUSH THIS FILE**)
3. Encrypt and replace with same file
    ```bash
    ./modify_sops.sh thadaw/dev.plain.yaml thadaw/dev.enc.yaml
    ```
4. Commit & Push code
5. Release to Pipeline (GitHub Action)
    ```bash
    ./scripts/bump-and-tag-version.sh 
    ```

    It will tag version, for example:

    ```
    Tag created and pushed: "0.0.1"
    ```

    Using this version to next step

6. Go to GitHub Action Repo which using this project for downloading secrets.

    ```yaml
    - name: Checkout Secrets
      uses: actions/checkout@v3
      with:
        repository: mildronize/sops-with-azure-keyvault-secrets
        ref: 0.0.1
        token: ${{ secrets.GITHUB_TOKEN_FOR_ACCESS_PRIVATE_REPO }}
        path: ./sops-with-azure-keyvault-secrets
    ```

## Create new Env

1. Create KeyVault and SOPS

    ```bash
    ./create-az-key-vault.sh ./thadaw/dev.config.yaml
    ```

2. Encrypt secret from plain text

    ```bash
    ./encrypt.sh ./thadaw/prod.config.yaml ./thadaw/prod.plain.yaml > ./thadaw/prod.enc.yaml
    ```

## Installation

```
brew install sops
brew install jq
brew install pwgen
```

Install SOPS on Ubuntu or WSL

```
wget https://github.com/mozilla/sops/releases/download/v3.7.2/sops_3.7.2_amd64.deb
sudo dpkg -i sops_3.7.2_amd64.deb
```