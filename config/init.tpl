#!/bin/bash

curl -LO https://www.chef.io/chef/install.sh && sudo bash ./install.sh

aws s3 cp s3://automatic-pancake-configuration-bucket/cookbooks.tar.gz /tmp/cookbooks.tar.gz
aws s3 cp s3://automatic-pancake-configuration-bucket/dna.json /tmp/dna.json

chef-solo --recipe-url /tmp/cookbooks.tar.gz -j /tmp/dna.json
