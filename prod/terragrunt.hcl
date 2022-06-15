locals {
}

terraform {
  //  source = "git::git@github.com:Tathagat-289/terraformResources.git//module3"
  source = "github.com/Tathagat-289/terraformResources//module1"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

inputs = {
  tfv = "tfversion1"
  sl = "sl1"
}
