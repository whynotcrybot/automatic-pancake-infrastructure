#!/bin/bash

yum update -y
yum install -y httpd24 php70 mysql56-server php70-mysqlnd
service httpd start
chkconfig httpd on
