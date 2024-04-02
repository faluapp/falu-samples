# Falu Samples

If you are here looking for documentation, please help write it

## Infrastructure

### Azure resources

> Ensure the Azure CLI tools are installed and that you are logged in.

Example command (single line):

```bash
az deployment group create --resource-group "FALU-SAMPLES" --template-file "deploy/main.bicep" --subscription "FALU SAMPLES" --confirm-with-what-if
```