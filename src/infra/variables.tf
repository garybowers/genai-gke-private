variable "billing_account" {
  type = string
  description = "Which billing account to be used"
}

variable "parent_folder" {
  type = string
  description = "Which folder should the project be created in"
}

variable "prefix" {
  type        = string
  description = "Prefix for resources"
}

variable "regions" {
  type = string
  description = "Which regions should be used?"
  default = ["europe-west1"]
}
