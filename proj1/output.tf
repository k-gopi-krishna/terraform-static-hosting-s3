
output "website_endpoint" { #outputting the website endpoint
    value = aws_s3_bucket.buck.website_endpoint
}
