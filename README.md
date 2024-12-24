# DIT ("Deliver it")

DIT is a batch tool for delivering software

## Features

- Build a website for browsing the repository
- Build a project site
- Build an archive website for all tags
- Pushing to GITHUB repositories
- Pushing to remote repositories via SSH
- Build docker images for all tags

## Install

### GIT Hook

Install a global GIT hook

In `~/.gitconfig`:

    ...
    [core]
    hooksPath = /path-to-this-repo/git-hooks

If done, DIT will be executed after every push.

### Configuration

Copy the file `config/config-default.sh` to
- `~/.config/dit` or
- `/etc/dit`
and enable the modules to your need.

## Documentation

Every project may contain a file named `.dit.yml`, which should have values like:
```
project:
  name: "your-repo"
  title: "your project title"
  description: "a brief description of your project"
  author: Your name
  email: "yourmail@example.com"

modules:
  archive: on
  docker: off
  github: off
  public: true
  site: on
  sshpush: on
```

If the file does not exist, DIT will use default values:
- The project name is the directory name in which your GIT repo resists.
- The title will be taken from the project name
- Author information will be taken from the last commit
- All enabled modules will be executed