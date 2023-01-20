locals {
}

terraform {
  //  source = "git::git@github.com:Tathagat-289/terraformResources.git//list-output"
  source = "github.com/Tathagat-289/terraformResources//list-output"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

inputs = {
  tfv = "tfversion1"
  sl = "sl1"
}
