#!/bin/bash

## packerBuild {app} {stage}
function packerBuild {
  APP=$1
  STAGE=$2
  if [ ! -d "./terraform/env/$STAGE" ]; then echo 'Stage path "'$STAGE'" does not exist'; return; fi
  COMMAND="cd ./packer && packer build -machine-readable ./${APP}-server.json | tee ${APP}-build.log && cd ../";
  eval $COMMAND;
  AMI_ID=`grep 'A disk image was created' ./packer/${APP}-build.log | cut -d, -f6 | cut -d: -f2 | cut -d ' ' -f2`
  echo $AMI_ID;
  echo -n $AMI_ID > ./terraform/env/${STAGE}/${APP}.ami
}

packerBuild websocket production
packerBuild manager production
packerBuild spawner production

# terraform plan
