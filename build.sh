#!/bin/bash

DEPLOY=unset

while getopts 'd' OPTION; do
  case "$OPTION" in
    d)
      DEPLOY=true ;;
    ?)
      echo "Usage: $(basename $0) [-d]"
      exit 1
      ;;
  esac
done

echo "Creating archive...";
rm -f function.zip && zip -r function.zip function.rb lib vendor
echo "Done!"

if [ "$DEPLOY" = true ]; then
  echo "Deploying..."
  aws lambda update-function-code --function-name service-pdf-parser --zip-file fileb://function.zip
  echo "Done!"
fi
