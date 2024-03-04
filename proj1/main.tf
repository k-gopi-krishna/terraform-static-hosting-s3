/*
create a file named terraform.tfvars and add the following content
my_bucket_name = "<bucket-name>"
Important Note 1: The bucket name should be unique across all the AWS accounts. So, make sure to use a unique name for the bucket.
Important Note 2: Make sure to exclude terraform.tfvars from the version control system. It contains sensitive information.
*/

provider "aws" {
  region = var.regionn
}
resource "aws_s3_bucket" "buck" {
    bucket = var.my_bucket_name #creating an s3 bucket
}

resource "aws_s3_bucket_public_access_block" "pub" {#giving public access so that anyone can access the contents of the bucket
    bucket = aws_s3_bucket.buck.id
    block_public_acls = false
    block_public_policy = false
    ignore_public_acls = false
    restrict_public_buckets = false
}
resource "aws_s3_bucket_ownership_controls" "bowm" {
    bucket = aws_s3_bucket.buck.id #giving the ownership of the bucket to the owner
    rule{
        object_ownership = "BucketOwnerPreferred"
    }
  
}
resource "aws_s3_bucket_acl" "bacl" {
    bucket = aws_s3_bucket.buck.id
    acl = "public-read" #giving public read access to the bucket
    depends_on = [ aws_s3_bucket_ownership_controls.bowm,aws_s3_bucket_public_access_block.pub ]
}
resource "aws_s3_bucket_policy" "mpol" {
    bucket = aws_s3_bucket.buck.id #creating a policy for the bucket so that anyone can access the contents of the bucket
     policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : "*",
        "Action" : "s3:GetObject",
        "Resource": "arn:aws:s3:::${var.my_bucket_name}/*"
      }
    ]
  })
    depends_on = [ aws_s3_bucket_acl.bacl ]
  
}
module "template_files" {
    #using the module to temporarly store the contents of the webfiles before uploading them to the s3 bucket
    source = "hashicorp/dir/template"
    base_dir = "${path.module}/webfiles"
  
}
resource "aws_s3_bucket_website_configuration" "webc" {
    #configuring the s3 bucket to host a static website
    #optional : you can add the error document 
    bucket = aws_s3_bucket.buck.id
    index_document {
        suffix = "index.html"
    } 
    
}
resource "aws_s3_object" "sup" {
    #uploading the contents of the webfiles which are stored into the module to the s3 bucket
    bucket = aws_s3_bucket.buck.id
    for_each = module.template_files.files
    key = each.key
    content_type = each.value.content_type
    source = each.value.source_path
    content = each.value.content
    etag = each.value.digests.md5
  
}
