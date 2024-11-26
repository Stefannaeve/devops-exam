variable "prefix" {
  type        = string
  description = "Prefix for all resource names"
}

variable "notification_email" {
  default = "stefan.naeve@hotmail.com"
  type = string
  description = "Mail address the alarm will be sent to"
}

variable "bucket_name" {
  default = "pgr301-couch-explorers"
  type = string
  description = "The bucket prefix"
}

variable "bucket_folder" {
  default = "23"
  type = string
  description = "The folder inside of the bucket"
}