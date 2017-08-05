#!/usr/bin/env bash

stackname=$1

#check if there are 3 arguments
if [ $# -eq 1 ]; then
   if [ -z "$stackname" ]; then
       echo "stack name not set"
       exit 1
   fi
else
   echo "Usage: $0 [stackname]"
   exit 1
fi

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

echo -e "Verifying OpenContrail $stackname stack for POC\n"
echo -e "Checking wether EC2 instances are UP and RUNNING\n"

ctrlname=$(cat cloudformation/contrail/cstack-parameters.json | grep CCName1 -A2 | awk '{print $2}' | sed -n 2p)
computename=$(cat cloudformation/contrail/cstack-parameters.json | grep CCName2 -A2 | awk '{print $2}' | sed -n 2p)

echo $ctrlname
echo $computename

aws ec2 wait instance-running --filters "Name=tag:Name,Values="$ctrlname""
aws ec2 wait instance-running --filters "Name=tag:Name,Values="$computename""

echo "EC2 insances are RUNNING"
echo

echo "[contrailc]">>$DIR/ansible/playbook/inventory/hosts
contrailc_ip=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$ctrlname" | grep PublicIpAddress | cut -d':' -f2 | tr -d '", ')
echo "$contrailc_ip">>$DIR/ansible/playbook/inventory/hosts
echo "">>$DIR/ansible/playbook/inventory/hosts

echo "[compute01]">>$DIR/ansible/playbook/inventory/hosts
compute01_ip=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$computename" | grep PublicIpAddress | cut -d':' -f2 | tr -d '", ')
echo "$compute01_ip">>$DIR/ansible/playbook/inventory/hosts
echo "">>$DIR/ansible/playbook/inventory/hosts

echo "ContrailC and Compute01 IP.................."
echo ContrailC: "${contrailc_ip}"
echo Compute01: "${compute01_ip}"

# Update testbed.py file with private address
contrailc_pip=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$ctrlname" | grep "\<PrivateIpAddress\>" | cut -d':' -f2 | tr -d '", ' | sort -u)

compute01_pip=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$computename" | grep "\<PrivateIpAddress\>" | cut -d':' -f2 | tr -d '", ' | sort -u)

echo "ctrlname=$ctrlname">>$DIR/ansible/playbook/inventory/group_vars/all.yml
echo "computename=$computename">>$DIR/ansible/playbook/inventory/group_vars/all.yml

echo ContrailCp: "${contrailc_pip}"
echo Compute01p: "${compute01_pip}"

sed -i "s/1.1.1.1/$contrailc_pip/" $DIR/ansible/files/testbed_single.py
sed -i "s/1.1.1.2/$compute01_pip/" $DIR/ansible/files/testbed_single.py
