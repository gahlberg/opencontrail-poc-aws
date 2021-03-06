#!/usr/bin/env bash

stackname=$1
templatefile=$2
parametersfile=$3

if [ -z "$stackname" ]; then
    echo "stack name not set"
    exit 1
fi

if [ -z "$templatefile" ]; then
    echo "template file not set"
    exit 1
fi

if [ -z "$parametersfile" ]; then
    echo "parameters file not set"
    exit 1
fi

echo "Creating vMX stack($stackname) for POC\n"

aws cloudformation create-stack \
    --stack-name $stackname  \
    --capabilities="CAPABILITY_IAM" \
    --template-body file://cloudformation/vmx/$templatefile.json \
    --parameters file://cloudformation/vmx/$parametersfile.json

echo "Creation of this stack will take minimum 45 minutes\n"
echo "Wait till the stack($stackname) is created\n"
aws cloudformation wait stack-create-complete --stack-name $stackname && aws cloudformation describe-stacks --stack-name $stackname
