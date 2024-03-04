variable "regionn" {
  type    = string
  default = "ap-south-1"
  #choose the region whichever is closest to you (for me it is Mumbai)

}

variable "my_bucket_name" {
  default = ""
  #here the value will be given in the terraform.tfvars file
  #create terraform.tfvars file and add the following content
  #my_bucket_name = "<bucket-name>"
  type=string
}