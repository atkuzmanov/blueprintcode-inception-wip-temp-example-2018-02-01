#!/bin/bash

### Requirements
## Install:
# brew install hub
# brew install jq
## Environment variables:
# export http_proxy=example.com:8080
# export https_proxy=example.com:8080
# export HTTP_PROXY=http://example.com:8080
# export HTTPS_PROXY=http://example.com:8080
# export EXAMPLE_CERT=/example/path/exampleCert.crt
# export EXAMPLE_CERT_KEY=/example/path/exampleCertKey.key
# export BLUEPRINTCODE_INCEPTION_PATH=/path/to/this/code-base

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NOCOLOUR='\033[0m'
API='-api'
INDENT="-->"
DOUBLEINDENT="---->"

CREATEDLOCALPROJECT=0
CREATEDJENKINSJOBS=0

function instantiate_project_in_github {
  printf "$YELLOW$DOUBLEINDENT Creating Github repository $ENTITY_NAME... $NOCOLOUR\n"
  cd ${ENTITY_NAME}
  git init
  hub create exampleGithubOrganisationName/${ENTITY_NAME} -p
  git add .
  git commit -m "First commit to ${ENTITY_NAME}."
  git push origin master
  printf "\n$YELLOW$DOUBLEINDENT The new repository is ready at ${GREEN}https://github.com/exampleGithubOrganisationName/${ENTITY_NAME} ${NOCOLOUR}\n\n"
  cd ..
  return 1
}

function get_human_friendly_name {
  awk_command='{
    split($0, name_pieces, "-");
    new_name = "";
    for (i=1; i <= length(name_pieces); i++) {
      new_name = new_name (toupper(substr(name_pieces[i], 0, 1)) substr(name_pieces[i], 2) " ")
    };
    print new_name
  }'
  human_friendly_name=`echo $1 | awk "$awk_command"`
  echo $human_friendly_name
}

function get_name_of_class {
  awk_command='{
    split($0, name_pieces, "-");
    new_name = "";
    for (i=1; i <= length(name_pieces); i++) {
      new_name = new_name (toupper(substr(name_pieces[i], 0, 1)) substr(name_pieces[i], 2))
    };
    print new_name
  }'
  get_name_of_class=`echo $1 | awk "$awk_command"`
  echo $get_name_of_class
}

function get_name_in_camel_case {
  awk_command='{
    split($0, name_pieces, "-");
    new_name = "";
    for (i=1; i <= length(name_pieces); i++) {
      if (i > 1) {
        new_name = new_name (toupper(substr(name_pieces[i], 0, 1)) substr(name_pieces[i], 2))
      }
      else {
        new_name = new_name name_pieces[i]
      }
    };
    print new_name
  }'
  get_name_of_class=`echo $1 | awk "$awk_command"`
  echo $get_name_of_class
}

function use_blueprintcode_inception_template {
  read_name_of_template
  printf "\n$YELLOW$DOUBLEINDENT Getting template for the new project...${NOCOLOUR}\n"
  rm -rf ${ENTITY_NAME}
  mkdir ${ENTITY_NAME}
  cd ${ENTITY_NAME}

  git init
  git remote add upstream git@github.com:exampleGithubOrganisationName/$NAME_OF_TEMPLATE.git
  git pull upstream master

  project_name=${ENTITY_NAME//-}
  dot_name=`echo "$ENTITY_NAME" | tr - .`
  human_friendly_name=`get_human_friendly_name "$ENTITY_NAME"`
  name_of_class=`get_name_of_class "$ENTITY_NAME"`
  name_in_camel_case=`get_name_in_camel_case "$ENTITY_NAME"`

  dirsToMove=`find . -name "blueprintcode" -type d`
  for directory in ${dirsToMove[@]}
  do
    newDir=`echo $directory | sed "s/blueprintcode//"`
    mv $directory $newDir$project_name
  done

  grep -rl blueprint-code ./ | xargs sed -i '.bak' "s/blueprint-code/$ENTITY_NAME/g"
  grep -rl --exclude-dir "*.git*" "Blueprint Code" ./ | xargs sed -i '.bak' "s/Blueprint Code/$human_friendly_name/g"
  grep -rl --exclude-dir "*.git*" blueprintcode ./ | xargs sed -i '.bak' "s/blueprintcode/$project_name/g"
  grep -rl blueprintCode ./ | xargs sed -i '.bak' "s/blueprintCode/$name_in_camel_case/g"
  grep -rl --exclude-dir "*.git*" BlueprintCode ./ | xargs sed -i '.bak' "s/BlueprintCode/$name_of_class/g"
  grep -rl --exclude-dir "*.git*" "blueprint.code" ./ | xargs sed -i '.bak' "s/blueprint.code/$dot_name/g"

  find . -name "*.bak" -type f -delete
  rm -rf .git
  cd ..

  CREATEDLOCALPROJECT=1
  return 1
}

function example_curl_json_payload {
  printf "\n$YELLOW$DOUBLEINDENT Example test function to create curl command with json payload. ${RED}Example test! ${MAGENTA}Continue?$NOCOLOUR"
  read -r -p " [y/n] " response
  if [[ ${response} =~ ^([yY])$ ]]
  then
      continue
  else
      return 0
  fi
  #
  printf "\n$MAGENTA$DOUBLEINDENT Please input some test data $./>$NOCOLOUR\n"
  read testData1
  #
  EXAMPLE_JSON_PAYLOAD="{\"example_json_element_1\": \"$testData1\", \"entity_name\": \"$ENTITY_NAME\", \"example_json_element_3\": \"example_json_element_3\"}"
  curl --cert-type PEM --cert $DEFAULT_CERTIFICATE --key $DEFAULT_CERTIFICATE_KEY -i -H "Accept: application/json" -H "Content-Type: application/json" -X POST -d "${EXAMPLE_JSON_PAYLOAD}" https://example.com/api/example/endpoint
  printf "\n"
  sleep 5
  #
  printf "$YELLOW$DOUBLEINDENT Repositories configuration file path: $BLUE $BLUEPRINTCODE_INCEPTION_PATH/resources/infrastructure/aws-repos-config-1.json $NOCOLOUR\n"
  #
  return 1
}

function build_cloud_infrastructure {
  printf "$YELLOW$DOUBLEINDENT Going to create CloudFormation stacks...$NOCOLOUR\n"

  cd "/Users/$(whoami)"
  configFile="aws-cloudformation-params-1.json"

  if ! [[ -f $configFile ]]; then
      echo "$RED$DOUBLEINDENT Please ensure a `$BLUEPRINTCODE_INCEPTION_PATH/resources/infrastructure/aws-cloudformation-params-1.json` stack config file is provided as required."
      exit
  fi

  rm -f $BLUEPRINTCODE_INCEPTION_PATH/resources/infrastructure/app.json.tmp

  sed "s/blueprint-code/$ENTITY_NAME/g" $BLUEPRINTCODE_INCEPTION_PATH/resources/infrastructure/app.json > $BLUEPRINTCODE_INCEPTION_PATH/resources/infrastructure/app.json.tmp

  config=`cat $configFile`

  accountId=`echo $config | jq -r ".int.aws_account_id"`
  domainNameBase=`echo $config | jq -r ".int.parameters.DomainNameBase"`
  vpcId=`echo $config | jq -r ".int.parameters.VpcId"`
  privateSubnet1=`echo $config | jq -r ".int.parameters.PrivateSubnet1Id"`
  privateSubnet2=`echo $config | jq -r ".int.parameters.PrivateSubnet2Id"`
  privateSubnet3=`echo $config | jq -r ".int.parameters.PrivateSubnet3Id"`
  publicSubnet1=`echo $config | jq -r ".int.parameters.PublicSubnet1Id"`
  publicSubnet2=`echo $config | jq -r ".int.parameters.PublicSubnet2Id"`
  publicSubnet3=`echo $config | jq -r ".int.parameters.PublicSubnet3Id"`
  bastionAccessSG=`echo $config | jq -r ".int.parameters.BastionAccessSecurityGroup"`
  imageId=`echo $config | jq -r ".int.parameters.ImageId"`

  region="eu-west-1"
  domainNameBaseWithEnvironment="int.$domainNameBase"
  prettyDomainName=`echo "$domainNameBase" | sed 's/.$//'`
  prettyDnsName="$ENTITY_NAME.int.$prettyDomainName"
  environment="int"
  updatePauseTime="PT1M"
  updateMinInService="2"
  maxSize="3"
  keyName="exampleKeyName"
  minSize="2"
  updateMaxBatchSize="1"
  instanceType="t2.nano"

  export DEFAULT_CERTIFICATE_PASSWORD=na
  echo "511603603783\n$region\nno\notg-dns\n.$environment.\n$ENTITY_NAME\napi.example.com.\n$prettyDnsName\n\n" | echo $BLUEPRINTCODE_INCEPTION_PATH/resources/stacks/dns.json

  echo "$accountId\n$region\nYes\napp\n$domainNameBase\n$domainNameBaseWithEnvironment\n$environment\n$vpcId\n$ENTITY_NAME\n$updatePauseTime\n$privateSubnet3\n$updateMinInService\n$imageId\n$maxSize\n$keyName\n$privateSubnet1\n$bastionAccessSG\n$minSize\n$publicSubnet1\n$publicSubnet2\n$privateSubnet2\n$updateMaxBatchSize\n$instanceType\n$publicSubnet3\n\n" | echo $BLUEPRINTCODE_INCEPTION_PATH/resources/stacks/app.json.tmp

  rm -f $BLUEPRINTCODE_INCEPTION_PATH/resources/stacks/app.json.tmp

  cd -
  return 1
}

function read_multiple_lines {
  while IFS= read -r line; do
        if [[ $line = "" ]] ; then
                break
        fi
    input="$input $line;"
  done

  echo "$input"
}

function instantiate_jenkins_jobs {
  printf "$YELLOW$DOUBLEINDENT Instantiating Jenkins jobs...$NOCOLOUR\n"
  rm -rf $BLUEPRINTCODE_INCEPTION_PATH/temp-jenkins
  mkdir $BLUEPRINTCODE_INCEPTION_PATH/temp-jenkins

  printf "\n$MAGENTA$DOUBLEINDENT Please enter the domain hostname of your Jenkins application$NOCOLOUR\n"
  read JENKINS_HOSTNAME

  printf "\n$MAGENTA$DOUBLEINDENT Please enter build commands. Lines can be separated by a single line break. Hit enter twice to submit, or hit enter to use default command: [example-default-build-command]$NOCOLOUR\n"
  buildCommand=`read_multiple_lines`

  if [[ -z "$buildCommand" ]]; then
    buildCommand="example-default-build-command"
  fi

  printf "\n$MAGENTA$DOUBLEINDENT Please enter the name of your rpm build job, or hit enter to use the default: [$ENTITY_NAME-rpm].$NOCOLOUR\n"
  read rpm_job_name

  if [[ -z "$rpm_job_name" ]]; then
    rpm_job_name="$ENTITY_NAME-rpm"
  fi

  printf "\n$MAGENTA$DOUBLEINDENT Please enter the name for your deployment job, or hit enter to use the default: [$ENTITY_NAME-integration-deploy])$NOCOLOUR\n"
  read deploy_job_name

  if [[ -z "$deploy_job_name" ]]; then
    deploy_job_name="$ENTITY_NAME-int-deploy"
  fi

  cat $BLUEPRINTCODE_INCEPTION_PATH/resources/jenkins/jenkins-rpm.xml | sed "s|EntityName|$ENTITY_NAME|g" | sed "s|BUILD_COMMAND|$buildCommand|g" > $BLUEPRINTCODE_INCEPTION_PATH/temp-jenkins/jenkins-rpm.xml

  curl --cert-type PEM --cert $DEFAULT_CERTIFICATE --key $DEFAULT_CERTIFICATE_KEY -X POST -H "Content-Type:application/xml" --data-binary @$BLUEPRINTCODE_INCEPTION_PATH/temp-jenkins/jenkins-rpm.xml "https://$JENKINS_HOSTNAME/createItem?name=$rpm_job_name"
  printf "$YELLOW$DOUBLEINDENT $rpm_job_name: OK$NOCOLOUR\n"

  cat $BLUEPRINTCODE_INCEPTION_PATH/resources/jenkins/jenkins-integration-deploy.xml | sed "s|EntityName|$ENTITY_NAME|g" > $BLUEPRINTCODE_INCEPTION_PATH/temp-jenkins/jenkins-integration-deploy.xml

  curl --cert-type PEM --cert $DEFAULT_CERTIFICATE --key $DEFAULT_CERTIFICATE_KEY -X POST -H "Content-Type:application/xml" --data-binary @$BLUEPRINTCODE_INCEPTION_PATH/temp-jenkins/jenkins-integration-deploy.xml "https://$JENKINS_HOSTNAME/createItem?name=$deploy_job_name"
  printf "$YELLOW$DOUBLEINDENT $deploy_job_name: OK$NOCOLOUR\n"

  rm -rf $BLUEPRINTCODE_INCEPTION_PATH/temp-jenkins

  return 1
}

function wait_for_stack_updates_completion {
  latestEvent=""
  until [[ $latestEvent =~ ^.*AWS::CloudFormation::Stack.*(UPDATE|CREATE)_COMPLETE$ ]]; do
    printf "$YELLOW$DOUBLEINDENT Waiting for stack updates to complete...$NOCOLOUR\n"
    latestEvent=`curl -s --cert-type PEM --cert $DEFAULT_CERTIFICATE --key $DEFAULT_CERTIFICATE_KEY https://example-aws-cloudformation-rest-api.com/example/endpoint/events | jq -r ".[0]"`
    sleep 10
  done
}

function deploy_to_integration_env {
  wait_for_stack_updates_completion
  printf "$YELLOW$DOUBLEINDENT Deploying component to INTEGRATION$NOCOLOUR\n"
  curl --cert-type PEM --cert $DEFAULT_CERTIFICATE --key $DEFAULT_CERTIFICATE_KEY -X POST "https://$JENKINS_HOSTNAME/job/${ENTITY_NAME}-rpm/build"
  printf "$YELLOW$DOUBLEINDENT You can follow the deployment progress on: https://$JENKINS_HOSTNAME/job/${ENTITY_NAME}-rpm/$NOCOLOUR\n"
  open "https://$JENKINS_HOSTNAME/job/${ENTITY_NAME}-rpm/"
  return 1
}

function read_entity_name {
  suffix=""
  if [[ -n "$BLUEPRINTCODE_LAST_ENTITY_NAME" ]]; then
    suffix=" (or hit enter to use previous value \"$BLUEPRINTCODE_LAST_ENTITY_NAME\")"
  fi
  printf "$MAGENTA$INDENT Please choose a name for your project$suffix$NOCOLOUR\n"
  read ENTITY_NAME
  if [[ -z "$ENTITY_NAME" ]]; then
    ENTITY_NAME=$BLUEPRINTCODE_LAST_ENTITY_NAME
  fi
  echo "export BLUEPRINTCODE_LAST_ENTITY_NAME=$ENTITY_NAME" >> "$BLUEPRINTCODE_INCEPTION_PATH/.blueprintcode-inception"
}

function read_name_of_template {
  suffix=""
  if [[ -n "$BLUEPRINTCODE_LAST_TEMPLATE_NAME" ]]; then
    suffix=" (or hit enter to use previous value \"$BLUEPRINTCODE_LAST_TEMPLATE_NAME\")"
  fi
  printf "$MAGENTA$DOUBLEINDENT Which template would you like to use? Should be a Github project in exampleGithubOrganisationName.$suffix$NOCOLOUR\n"
  read NAME_OF_TEMPLATE
  if [[ -z "$NAME_OF_TEMPLATE" ]]; then
    NAME_OF_TEMPLATE=$BLUEPRINTCODE_LAST_TEMPLATE_NAME
  fi
  echo "export BLUEPRINTCODE_LAST_TEMPLATE_NAME=$NAME_OF_TEMPLATE" >> "$BLUEPRINTCODE_INCEPTION_PATH/.blueprintcode-inception"
}

function step_that_is_optional {
  printf "$2"
  read -r -p " [y/n] " response
  if [[ ${response} =~ ^[yY]$ ]]; then
      $1
      retval=$?
      if (($retval != 0)); then
        printf "$3"
      fi
  elif [[ ${response} =~ ^[nN]$ ]]; then
    continue
  else
    printf "$RED$DOUBLEINDENT Bad input, please try again.\n"
    step_that_is_optional "$1" "$2" "$3"
  fi
}

function verifications_before_start {
  if [[ -z "$DEFAULT_CERTIFICATE" ]]; then
    echo "$RED$DOUBLEINDENT DEFAULT_CERTIFICATE environment variable is required.$NOCOLOUR";
    exit;
  fi
  #
  if [[ -z "$DEFAULT_CERTIFICATE_KEY" ]]; then
    echo "$RED$DOUBLEINDENT DEFAULT_CERTIFICATE environment variable required.$NOCOLOUR";
    exit;
  fi
  #
  if [[ -f "$BLUEPRINTCODE_INCEPTION_PATH/.blueprintcode-inception" ]]; then
      source "$BLUEPRINTCODE_INCEPTION_PATH/.blueprintcode-inception"
      rm -f "$BLUEPRINTCODE_INCEPTION_PATH/.blueprintcode-inception"
  fi
}

printf "$BLUE$INDENT Welcome to Blueprintcode Inception!$NOCOLOUR\n"
verifications_before_start
read_entity_name

step_that_is_optional \
  use_blueprintcode_inception_template \
  "$MAGENTA$INDENT Would you like to create a new local project?$NOCOLOUR" \
  "\n$GREEN$INDENT Created local project for the new application.$NOCOLOUR\n"

step_that_is_optional \
  instantiate_project_in_github \
  "$MAGENTA$INDENT Would you like to create a new Github project?$NOCOLOUR" \
  "\n$GREEN$INDENT Created Github project for the new application.$NOCOLOUR\n"

step_that_is_optional \
  example_curl_json_payload \
  "$MAGENTA$INDENT Would you like to create to run the example_curl_json_payload function?$NOCOLOUR" \
  "\n$GREEN$INDENT Finished running example_curl_json_payload function.$NOCOLOUR\n"

step_that_is_optional \
  build_cloud_infrastructure \
  "$MAGENTA$INDENT Would you like to create Amazon AWS CloudFormation infrastructure stacks?$NOCOLOUR" \
  "\n$GREEN$INDENT Created Amazon AWS CloudFormation infrastructure stacks for the new application.$NOCOLOUR\n"

step_that_is_optional \
  instantiate_jenkins_jobs \
  "$MAGENTA$INDENT Would you like to create Jenkins jobs for the new application?$NOCOLOUR" \
  "\n$GREEN$INDENT Created Jenkins Jobs for the new application.$NOCOLOUR\n"

step_that_is_optional \
  deploy_to_integration_env \
  "$MAGENTA$INDENT Would you like to deploy the new application to the integration environment?$NOCOLOUR" \
  "\n$GREEN$INDENT Deploying the new application to the integration environment...$NOCOLOUR\n"
