# variables
RG="eraki-spk-shr-rg"
WEBAPP_NAME="eraki-spk-01-webapp"
# WEBAPP_NAME="eraki-spk-02-webapp"

WEBAPP_CONF_DIR="webapp01/site"
# WEBAPP_CONF_DIR="webapp02/site"

ZIP_FILE="./webapp01/site.zip"
# ZIP_FILE="./webapp02/site.zip"


echo "Creating ZIP package from $WEBAPP_CONF_DIR"
if [ -f "$ZIP_FILE" ]; then
  echo "Removing existing ZIP: $ZIP_FILE"
  rm "$ZIP_FILE"
fi


cd "$WEBAPP_CONF_DIR"
zip -r "$ZIP_FILE" "$WEBAPP_CONF_DIR"
cd - > /dev/null
echo "ZIP package created at $ZIP_FILE"

echo "Deploying ZIP to Azure Web App: $WEBAPP_NAME in resource group: $RG..."
az webapp deploy \
  --resource-group "$RG" \
  --name "$WEBAPP_NAME" \
  --src-path "$ZIP_FILE" \
  --type zip

echo "Deployment completed successfully!"
