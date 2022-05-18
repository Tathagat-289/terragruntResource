variable "access_key" {}

variable "secret_key" {}



variable "tag" {
  default = "terragrunt-bugbash"
}

variable "region" {
  default = "us-east-1"
}

provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region = var.region
}

terraform {
  backend "local" {}
}

resource "aws_instance" "ec2_instance_test" {
  ami           = "ami-0663143d1f1caa3bf"
  instance_type = "t2.nano"
  tags = {
    Name = var.tag
  }
}

resource "aws_ssm_document" "LDS-EC2InstallConfigCloudWatch" {
  name          = "LDS-EC2InstallConfigCloudWatch"
  document_type = "Command"
  #replace content
  content = <<DOC
{
  "schemaVersion": "2.2",
  "description": "InstallAndConfigureCloudWatch",
  "parameters": {
    "ParameterStoreConfigName": {
      "type": "String",
      "description": "Parameter Store Config Name",
      "default": "AmazonCloudWatchConfig"
    }
  },
  "mainSteps": [
    {
      "action": "aws:configurePackage",
      "name": "InstallCloudWatchAgent",
      "inputs": {
        "name": "AmazonCloudWatchAgent",
        "action": "Install",
        "installationType": "Uninstall and reinstall",
        "version": "",
        "additionalArguments": "{}"
      }
    },
    {
      "name": "ConfigureCloudWatchAgent",
      "action": "aws:runPowerShellScript",
      "precondition": {
        "StringEquals": [
          "platformType",
          "Windows"
        ]
      },
      "inputs": {
        "runCommand": [
          " Set-StrictMode -Version 2.0",
          " $ErrorActionPreference = 'Stop'",
          " $Cmd = \"$${Env:ProgramFiles}\\Amazon\\AmazonCloudWatchAgent\\amazon-cloudwatch-agent-ctl.ps1\"",
          " if (!(Test-Path -LiteralPath \"$${Cmd}\")) {",
          "     Write-Output 'CloudWatch Agent not installed.  Please install it using the AWS-ConfigureAWSPackage SSM Document.'",
          "     exit 1",
          " }",
          " Set-StrictMode -Off",
          " exit $LASTEXITCODE"
        ]
      }
    }
  ]
}
DOC
}
resource "aws_ssm_association" "LDS-EC2InstallConfigCloudWatch" {
  name = aws_ssm_document.LDS-EC2InstallConfigCloudWatch.name
  targets {
    key    = "tag:linedata.domainjoin"
    values = ["ldsprod"] #should this reference the domain value from somewhere else?
  }
}

output "tag" {
  value = var.tag
}
