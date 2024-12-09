# do NOT change this file,
# instead copy this file to at least one of:
# - ~/.config/dit
# - /etc/dit

project_config_file=.dit.yml
debug=off

#
archive=off
archive_dir="/path/to/archive_dir"
archive_ssh=off
archive_ssh_user=myusername
archive_ssh_host=myhostname.example
archive_ssh_path="/path/to/dir"

sshpush=off
ssh_user=myusername
ssh_host=myhostname.example
ssh_path="/path/to/dir"

site=off
site_clone_url="http://clone.host.example"
site_dir="path/to/dir"
site_index_create=true
site_index_title="My projects"
site_sync_ssh_user=myusername
site_sync_ssh_host="ssh_host.example"
site_sync_ssh_path="path/to/dir"

# Build dockerimage (if Dockerfile exists)
docker=off
docker_owner="My Name"
dockerhub_owner="hubowner"

github=off
github_owner="username_at_github"

# copy project to a public website directory
public=off
public_dir="path/to/dir"
public_index_create=on
public_index_title="My projects"
public_sync_ssh_user=myusername
public_sync_ssh_host=sshhost.example
public_sync_ssh_path="path/to/dir"
public_markdown_to_html=on

# Notify is able to send a mail
# If 'notify' is off, all output will be written to standard out
notify=false
notify_sendmail=true
notify_smtp=true
notify_smtp_host="smtp server"
notify_smtp_from="myemail@example"
notify_stdout=true # copy to standard out
notify_add_receiver_mail="email@example"

# Danger: do not set the name, it will be auto-configured with the repo-name
repo_project_name=

repo_project_description=

# default module settings
repo_modules_docker=off
repo_modules_archive=on
repo_modules_site=on
repo_modules_github=on
repo_modules_sshpush=on
repo_modules_public=on