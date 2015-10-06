#
# Cookbook Name:: pw-testhelper
# Recipe:: default
#
# Copyright (C) 2015 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#
node.default['pw-testhelper']['directory'] = "/tmp/serverspec-test"
node.default['pw-testhelper']['file_name'] = "node.json"

directory node.default['pw-testhelper']['directory'] do
  recursive true
end

ruby_block "dump_node_attributes" do
  block do
    require 'json'
    attrs = {}

    attrs = Chef::Mixin::DeepMerge.deep_merge(node.default_attrs, attrs) unless node.default_attrs.empty?
    attrs = Chef::Mixin::DeepMerge.deep_merge(node.normal_attrs, attrs) unless node.normal_attrs.empty?
    attrs = Chef::Mixin::DeepMerge.deep_merge(node.override_attrs, attrs) unless node.override_attrs.empty?

    recipe_json = "{ \"run_list\": \[ "
    recipe_json << node.run_list.expand(node.chef_environment).recipes.map! { |k| "\"#{k}\"" }.join(",")
    recipe_json << " \] }"
    attrs = Chef::Mixin::DeepMerge.deep_merge(JSON.parse(recipe_json), attrs)

    File.open("#{node.default['pw-testhelper']['directory']}/#{node.default['pw-testhelper']['file_name']}", 'w') { |file| file.write(JSON.pretty_generate(attrs)) }
  end
end
