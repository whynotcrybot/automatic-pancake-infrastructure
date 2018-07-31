resource "null_resource" "berks_package" {
  triggers = {
    timestamp = "$timestamp()"
  }

  provisioner "local-exec" {
    command = "rm -f ./cookbooks/cookbooks.tar.gz; berks package ./cookbooks/cookbooks.tar.gz --berksfile=./cookbooks/my-first-cookbook/Berksfile"
  }
}

data "template_file" "dna" {
  template = "${file("./config/dna.json.tpl")}"

  vars {
    recipe = "my-first-cookbook::default"
  }
}

resource "aws_s3_bucket" "configuration" {
  bucket = "automatic-pancake-configuration-bucket"
  acl    = "private"
}

resource "aws_s3_bucket_object" "cookbooks" {
  depends_on = [
    "aws_s3_bucket.configuration",
    "null_resource.berks_package"
  ]

  bucket = "${aws_s3_bucket.configuration.bucket}"
  key    = "cookbooks.tar.gz"
  source = "./cookbooks/cookbooks.tar.gz"
  etag   = "${md5(file("./cookbooks/cookbooks.tar.gz"))}"
}

resource "aws_s3_bucket_object" "dna" {
  depends_on = ["aws_s3_bucket.configuration"]

  bucket = "${aws_s3_bucket.configuration.bucket}"
  key    = "dna.json"
  content = "${data.template_file.dna.rendered}"
  etag   = "${md5("${data.template_file.dna.rendered}")}"
}
