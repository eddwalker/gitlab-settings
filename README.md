# GitLab Settings

This repository contains GitLab init scripts and settings.
Supported OS: ubuntu 22.04

## Script installs dockerized versions of

  - **gitlab-server** - serves GitLab Server and GitLab Docker registry
  - **runner-docker** - Kaniko Dockerfiles builder
  - **squid-docker**  - caching apt/files proxy for runner-docker

## How to init

  - If your GitLab server name does NOT match gitlab.local, replace gitlab.local with the actual GitLab server name using:
```
      grep -R gitlab.local .
```
  - If you wish to use your own certificates:
```
      create crt/gitlab.local.key and crt/gitlab.local.crt
```
  - If you wish to generate a self-signed certificate for the GitLab server:
```
      cd crt && ./gen.sh ; cd -
```
  - To install GitLab server, proxy, and build agent, run:
```
      ./init.sh
```
  - If you want to find out the root password for the GitLab server user 'root', wait for the gitlab server to be up at (default: https://gitlab.local) and run:
```
      cd gitlab-server && ./root_pass_show.sh ; cd -
```
  - If you want to check connectivity to the GitLab server with the root password, run:
```
      cd crt && check.sh ; cd -
```
  - Refer to README.md in subfolders for more detailed installation instructions.
