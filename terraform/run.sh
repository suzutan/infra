#!/bin/bash

target=$1
if [ -z "$target" ]; then
  echo "Usage: $0 <target> <mode>"
  exit 1
fi
mode=$2
if [ -z "$mode" ]; then
  echo "Usage: $0 <target> <mode>"
  exit 1
fi


cd $(dirname $0)

terraform fmt -recursive .

cd $target

terraform init

case $mode in
  "plan")
    terraform plan
    ;;
  "apply")
    terraform apply
    ;;
  "destroy")
    terraform destroy
    ;;
  *)
    echo "Usage: $0 <target> <mode>"
    exit 1
    ;;
esac
