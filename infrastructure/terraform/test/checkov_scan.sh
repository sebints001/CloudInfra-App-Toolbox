#!/bin/bash

echo "Running Checkov Security Scan..."
checkov -d ../modules
if [ $? -eq 0 ]; then
  echo "Checkov scan passed!"
else
  echo "Checkov scan failed! Please fix the reported issues."
  exit 1
fi
