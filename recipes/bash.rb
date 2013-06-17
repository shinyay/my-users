# Load contents from an encrypted data bag
user = Chef::EncryptedDataBagItem.load("users", 'deploy')
user_name = user['name']
password  = user['password']
ssh_key   = user['ssh_key']
home      = "/home/#{user_name}"

# Create a bash_profile include directory
directory "#{home}/.bash_profile_inc" do
  owner user_name
  group user_name
end

# Put a file [base_profile.sh] to bash_profile include
cookbook_file "#{home}/.bash_profile_inc/base_profile.sh" do
  source "base_profile.sh"
  mode 0644
  owner user_name
  group user_name
end

# Modify a bash_profile which load [.bash_profile_inc]
script "include bash_profile" do
  environment 'HOME' => home
  user   user_name
  group  user_name
  interpreter "bash"
  not_if "grep -q 'bash_profile_include' #{home}/.bash_profile"
  flags  "-e"
  code <<-"EOH"
cat << EOF >> #{home}/.bash_profile 2>&1
# bash_profile_include
for file in \\`find ~/.bash_profile_inc -type f\\`; do
  source \\$file
done
EOF
  EOH
end

