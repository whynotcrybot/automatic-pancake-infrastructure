#
# Cookbook:: my-first-cookbook
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

include_recipe "git"
include_recipe "nodejs"

# Clone git repo
git "/tmp/app" do
  repository "git://github.com/whynotcrybot/automatic-pancake"
  reference "master"
  action :sync
end

# Install Node JS dependencies
execute 'dependencies' do
  cwd '/tmp/app'
  command 'npm i'
end

# Start the application
service "app_service" do
  supports :start => true
  start_command "node /tmp/app/server.js"
  action [ :start ]
end
