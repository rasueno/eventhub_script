
subscription=$(cat eventhub.ini | grep subscription | cut -d= -f2 | xargs)
storage_resource_group=$(cat eventhub.ini | grep storage_resource_group | cut -d= -f2 | xargs)
storage_account=$(cat eventhub.ini | grep storage_account | cut -d= -f2 | xargs)
container_name=$(cat eventhub.ini | grep container_name | cut -d= -f2 | xargs)
namespace=$(cat eventhub.ini | grep namespace | cut -d= -f2 | xargs)
container_name=$(cat eventhub.ini | grep container_name | cut -d= -f2 | xargs)
statefile=${storage_resource_group}-${namespace}-tfstate
eventsnum=$(cat eventhub.ini | grep evenhubsnum | cut -d= -f2 | xargs)
tags=$(cat eventhub.ini | grep tags | sed 's/^[^=]*=//' | sed -e "s/\"/\\\"/g")
event_resource_group=$(cat eventhub.ini | grep event_resource_group | cut -d= -f2 | xargs)

echo "Subscription: $subscription"
echo "Resource Group: $resource_group"
echo "Eventhub Namespace: $namespace"
echo ""
echo "Statefile: $statefile"
echo ""
echo "Number of eventhubs (topics): $eventsnum"
echo "Generating tf files"

echo "key = \"${statefile}\"" > backend.tfvars


echo "terraform {" > eventhub.tf
echo "  backend "azurerm" {" >> eventhub.tf
echo "    resource_group_name  = \"${storage_resource_group}\"" >> eventhub.tf
echo "    storage_account_name = \"${storage_account}\"" >> eventhub.tf
echo "    container_name       = \"${container_name}\"" >> eventhub.tf
echo "  }" >> eventhub.tf
echo "}" >> eventhub.tf

echo "" >> eventhub.tf
echo "" >> eventhub.tf

echo "provider \"azurerm\" {" >> eventhub.tf
# echo "  version = \"~> 2.25.0\"" >> eventhub.tf
echo "  subscription_id = \"${subscription}\"" >> eventhub.tf
echo "  client_id       = \"${ARM_CLIENT_ID}\"" >> eventhub.tf
echo "  client_secret   = \"${ARM_CLIENT_SECRET}\"" >> eventhub.tf
echo "  tenant_id       = \"${ARM_TENANT_ID}\"" >> eventhub.tf
echo "" >> eventhub.tf
echo "  features {}" >> eventhub.tf
echo "}" >> eventhub.tf

echo "" >> eventhub.tf
echo "" >> eventhub.tf

echo "data \"azurerm_resource_group\" \"rg\" {" >> eventhub.tf
echo "  name = \"${event_resource_group}\"" >> eventhub.tf
echo "}" >> eventhub.tf

echo "" >> eventhub.tf
echo "" >> eventhub.tf

echo "resource \"azurerm_eventhub_namespace\" \"ehn\" {" >> eventhub.tf
echo "  name                = \"${namespace}\"" >> eventhub.tf
echo "  location            = \"westus\"" >> eventhub.tf
echo "  resource_group_name = data.azurerm_resource_group.rg.name" >> eventhub.tf
echo "  sku                 = \"Standard\"" >> eventhub.tf
echo "  capacity            = \"1\"" >> eventhub.tf
echo "  tags                = ${tags}" >> eventhub.tf
echo "}" >> eventhub.tf

echo "" >> eventhub.tf
echo "" >> eventhub.tf


for((i=0;i<$eventsnum;i++)) do

eventhub_name=$(cat eventhub.ini | grep eventhub${i}_name | cut -d= -f2 | xargs)
partition_count=$(cat eventhub.ini | grep eventhub${i}_partition_count | cut -d= -f2 | xargs)
message_retention=$(cat eventhub.ini | grep eventhub${i}_message_retention | cut -d= -f2 | xargs)

echo "resource \"azurerm_eventhub\" \"eh${i}\" {" >> eventhub.tf
echo "  name                = \"${eventhub_name}\"" >> eventhub.tf
echo "  namespace_name      = \"${namespace}\"" >> eventhub.tf
echo "  resource_group_name = data.azurerm_resource_group.rg.name" >> eventhub.tf
echo "  partition_count     = \"${partition_count}\"" >> eventhub.tf
echo "  message_retention   = \"${message_retention}\"" >> eventhub.tf
echo "}" >> eventhub.tf

echo "" >> eventhub.tf
echo "" >> eventhub.tf
done