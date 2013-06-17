#
# Cookbook Name:: my-users
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
# Load contents from an encrypted data bag
user = Chef::EncryptedDataBagItem.load("users", 'deploy')
user_name = user['name']
password  = user['password']
ssh_key   = user['ssh_key']
home      = "/home/#{user_name}"

# Create a User [deploy]
user user_name do
  password password
  home  home
  shell "/bin/bash"
  supports :manage_home => true # Manage home directory
end

# Add [deploy] to [wheel]group
group "wheel" do
  action [:modify]
  members [user_name]
  append true
end

# Create .ssh directory
directory "#{home}/.ssh" do
  owner user_name
  group user_name
end

# create an authorized_keys file
authorized_keys_file ="#{home}/.ssh/authorized_keys"
file authorized_keys_file do
  owner user_name
  mode  0600
  content "#{ssh_key} #{user_name}" 
  not_if { ::File.exists?("#{authorized_keys_file}")} 
end

