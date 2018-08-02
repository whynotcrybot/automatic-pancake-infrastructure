#
# Cookbook:: my-first-cookbook
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

include_recipe "git"
include_recipe "nodejs"

git "/tmp/app" do
  repository "git://github.com/whynotcrybot/automatic-pancake"
  reference "master"
  action :sync
end

execute 'npm i' do
  cwd '/tmp/app'
  command 'npm i'
end

service "myapp_service" do
  supports :start => true
  start_command "node /tmp/app/server.js"
  action [ :start ]
end
