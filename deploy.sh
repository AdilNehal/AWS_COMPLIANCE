#!/bin/bash


zip -r lambda.zip lambda-python.py

# Initialize and apply Terraform configuration
terraform init
terraform apply -auto-approve
