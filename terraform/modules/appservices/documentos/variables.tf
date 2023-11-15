variable "imagebuild" {
  type        = string
  description = "the latest image build version"
}

variable "mongodb" {
  description = "Cosmosdb account"
  type        = any
}

variable "serviceplan1" {
  description = "Service plan EAST"
  type        = any

}
variable "serviceplan2" {
  description = "Service plan WEST"
  type        = any
}

variable "frontdoorprofile" {
  description = "Front door profile"
  type        = any
}