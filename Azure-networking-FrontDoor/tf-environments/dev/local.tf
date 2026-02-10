locals {
  all_tags = merge(
    {
      Automation     = "True"
      ServiceAccount = "Terraform-pipeline"
      CostCenter     = "West Europe"
    },
    {
      Application    = "NONE"
      Environment    = "NONE"
      BackupSchedule = "NONE"
      BackupType     = "NONE"
    }
  )

  # VM TAGS
  vm_tags = {
    core = {
      Name        = "core-vm"
      Environment = "dev"
      Application = "core"
    }
    app = {
      Name        = "app-vm"
      Environment = "dev"
      Application = "app"
    }
  }
}