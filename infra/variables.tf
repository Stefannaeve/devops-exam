variable "prefix" {
  type        = string
  description = "Prefix for all resource names"
}

variable "notification_email" {
  default = "stefan.naeve@hotmail.com"
  type = string
}