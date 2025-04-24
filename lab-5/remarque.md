il y'a deux configurations du backend , l'un dans le fichier [backend](backend.tf) et l'autre dans le fichier [main](main.tf)


pour creer la configuration il faut en amont creer les ressources suivante: 

az group create --name my-terraform-rg --location westeurope

az storage account create \
  --name azurebackend<prenom> \
  --resource-group my-terraform-rg \
  --location westeurope \
  --sku Standard_LRS

az storage container create \
  --name backend \
  --account-name azurebackend<prenom>


pour supprimer 

az storage container delete \
  --name backend \
  --account-name azurebackend<prenom>

az storage account delete \
  --name azurebackend<prenom> \
  --resource-group my-terraform-rg

az group delete --name my-terraform-rg --yes --no-wait
