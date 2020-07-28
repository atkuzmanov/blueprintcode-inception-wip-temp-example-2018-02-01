# BLUEPRINTCODE INCEPTION
---

`Inspired from things I have worked on or seen.`

---

This is a tool that deploys a brand new service to the int environment based on a blueprint project of your choice. 
It is capable of doing all or a subset of the following actions:

* Create a new local project based on a blueprint template of your choice.
* Check that project into a new Github repository.
* Set up CloudFormation stacks for a basic Auto Scaling Group with EC2 instances, an ELB and DNS entries.
* Create a pipeline of Jenkins jobs to build the RPM and deploy it to int.

## Blueprints

A blueprint can be created by creating a standard project in the language/framework of your choice. 
This script expects to find template keywords in the place of actual project-specific information e.g. the project name in `project.json`. 
It will replace these with values relevant to the project name you provide when the script starts.

For example, a template keyword of `"blueprintcode"` will be replaced with the string `"MyApplication"` when the script is provided with the application name `"my-application"`. 
***NOTE:*** The `"-"` in the application name is optional but important for things like class names and camel casing. Omitting it would result in `"Myapplication"` in the example above, which may not be the desired outcome.

The following is a list of valid template values that will be replaced:

    blueprintcode --> myapplication
    blueprintCode --> myApplication
    BlueprintCode --> MyApplication
    blueprint-code --> my-application
    Blueprint Code --> My Application
    blueprint.code --> my.application

Directories of the format `blueprintcode` will also be moved to `myapplication`.

The format of these values has been chosen to fit in code, scripts, READMEs and anywhere else as appropriate.

## Requirements

- Install tools:

        brew install hub
        brew install jq

- [Git set up for SSH use](https://help.github.com/articles/generating-an-ssh-key/). 
If you are behind a proxy, you'll need to add the following proxy command in `~/.ssh/config`:

        Host github.com
            ProxyCommand nc -x "socks.example.com:1010" %h %p

- Environment variables:

        export http_proxy=example.com:8080
        export https_proxy=example.com:8080
        export HTTP_PROXY=http://example.com:8080
        export HTTPS_PROXY=http://example.com:8080
        export BLUEPRINTCODE_INCEPTION_PATH=/path/to/this/code-base
        export EXAMPLE_CERT=/example/path/exampleCert.crt
        export EXAMPLE_CERT_KEY=/example/path/exampleCertKey.key

    `BLUEPRINTCODE_INCEPTION_PATH` should point to your blueprintcode inception folder with the resources from this repo available.

    The `EXAMPLE_CERT` and `EXAMPLE_CERT_KEY` files can be generated from a p12 as such:

        openssl pkcs12 -in /path/to/exampleInputCertificate.p12 -out /etc/pki/tls/certs/exampleCert.crt -clcerts -nokeys
        openssl pkcs12 -in /path/to/exampleInputCertificate.p12 -out /etc/pki/tls/private/exampleCertKey.key -nocerts -nodes

## How to use

    $ cd myworkspace
    $ git clone git@github.com:example/this-code-base.git
    $ export BLUEPRINTCODE_INCEPTION_PATH=/path/to/this/code-base
    $ sh blueprintcode-inception/app-inception-from-blueprintcode.sh

You will be presented with a series of yes/no questions for each component available to create via this script.

## CloudFormation

This step creates Amazon AWS CloudFormation stacks for the new application.
It requires the existence of a json file $BLUEPRINTCODE_INCEPTION_PATH/resources/infrastructure/aws-cloudformation-params-1.json containing the values to use for the stack template parameters:

    {
      "int": {
        "aws_account_id": "account-id",
        "parameters": {
          "BastionAccessSecurityGroup": "sg-1234567",
          "DomainNameBase": "[accout-hash].xhst.example.com.",
          "ImageId": "ami-1234567",
          "PrivateSubnet1Id": "subnet-1",
          "PrivateSubnet2Id": "subnet-2",
          "PrivateSubnet3Id": "subnet-3",
          "PublicSubnet1Id": "subnet-4",
          "PublicSubnet2Id": "subnet-5",
          "PublicSubnet3Id": "subnet-6",
          "VpcId": "vpc-1234567"
        }
      }
    }

Any additional properties will be ignored.

### TODO 

* Add functionality to integrate with the Amazon AWS Api about creation of infrastructure from CloudFormation templates.

## Problems

### Mac OSX

Depending on the version of curl you are using, you may get problems with curl unable to load the cert and key.  
If this happens, try changing the curl commands in the script to use your P12 with a password.  
Where the commands appear in the script, change:

```curl --cert-type PEM --cert $EXAMPLE_CERT --key $EXAMPLE_CERT_KEY```

to

```curl --cert /location/of/your/developer/certificate.p12:PASSWORD```

## TODO

* Further development and improvements.



---


