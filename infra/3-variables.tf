// Terraform variables placeholder
variable "project_name" {
  description = "Short project name used in resource naming."
  type        = string
  default     = "fedramp-zt-partner-mvp"
}

variable "env" {
  description = "Deployment environment."
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS region for deployment."
  type        = string
  default     = "us-east-1"
}

variable "lambda_runtime" {
  description = "Python runtime for Lambda."
  type        = string
  default     = "python3.11"
}

variable "log_retention_days" {
  description = "CloudWatch log retention."
  type        = number
  default     = 14
}

variable "revoke_schedule_expression" {
  description = "Schedule expression for the revoke Lambda."
  type        = string
  default     = "rate(5 minutes)"
}

variable "default_access_duration_minutes" {
  description = "Default access duration for approved requests."
  type        = number
  default     = 60
}

variable "tags" {
  description = "Extra tags to apply to resources."
  type        = map(string)
  default     = {}
}


###################################################
#                          Level 2
###################################################

