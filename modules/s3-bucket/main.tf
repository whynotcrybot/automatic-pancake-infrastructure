resource "null_resource" "berks_package" {
  provisioner "local-exec" {
    command = "rm -f ./cookbooks/cookbooks.tar.gz; berks package ./cookbooks/cookbooks.tar.gz --berksfile=./cookbooks/my-first-cookbook/Berksfile"
  }
}

resource "aws_s3_bucket" "configuration" {
  bucket = "automatic-pancake-configuration-bucket"
  acl    = "private"
}

resource "aws_s3_bucket_object" "object" {
  depends_on = [
    "aws_s3_bucket.configuration",
    "null_resource.berks_package"
  ]

  bucket = "${aws_s3_bucket.configuration.bucket}"
  key    = "cookbooks.tar.gz"
  source = "./cookbooks/cookbooks.tar.gz"
}
