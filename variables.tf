variable "VpcBlock" {
  type        = string
  default     = "192.168.0.0/16"
  description = "The CIDR range for the VPC. This should be a valid private (RFC 1918) CIDR range."
}

variable "PublicSubnet01Block" {
  type        = string
  default     = "192.168.0.0/18"
  description = "CidrBlock for public subnet 01 within the VPC"
}

variable "PublicSubnet02Block" {
  type        = string
  default     = "192.168.64.0/18"
  description = "CidrBlock for public subnet 02 within the VPC"
}

variable "PrivateSubnet01Block" {
  type        = string
  default     = "192.168.128.0/18"
  description = "CidrBlock for private subnet 01 within the VPC"
}

variable "PrivateSubnet02Block" {
  type        = string
  default     = "192.168.192.0/18"
  description = "CidrBlock for private subnet 02 within the VPC"
}
