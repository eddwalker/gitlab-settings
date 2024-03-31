
== CA

   All self signed gitlab certs must be added to runner and setup with env like:
   CA_CERTIFICATES_PATH=/opt/crt/gitlab.local.crt
   if cert path not match default ca location: /etc/gitlab-runner/certs/ca.crt

== Troubleshooting

   https://docs.gitlab.com/runner/faq/index.html

== Runner Images

   type   | compressed | unconpressed | image name
   Ubuntu     160 MB        350 MB      gitlab/gitlab-runner:latest
   Alpine      45 MB        130 MB      gitlab/gitlab-runner:alpine
   RH8          ?             ?         gitlab/gitlab-runner:ubi-fips

== Install

  1. In gitlab create token in CI repo:

     Team-op -> k8s-example -> Settings -> Repository -> Deploy Tokens

     Add add token here instead of next:


     Team-op -> k8s-example -> Settings -> Access Tokens -> [ Add new token ]

     - Token name:      standalone-0-docker-runner # some name pointing to hostname running doker with runner
     - Expiration date: xxxx-xx-xx                 # any you want, 1 year maximum allowed
     - Select a role:   guest                      # default role
     - Select scopes:   read_registry              # check registry, not repository

     Press [ Create Project access token ]
     Under "Your new project access token" press [Copy]

  2. On HOST node with docker (not in container) run:

     # not-work-anymore: cp crt/gitlab.local.crt /usr/local/share/ca-certificates/gitlab.local.crt
     # not-work-anymore: update-ca-certificates

     # This for runner container requests to git repos -- https://gitlab.local/team-op/repo.git
     mkdir -p /etc/docker/certs.d/gitlab.local
     cp ../crt/gitlab.local.crt /etc/docker/certs.d/gitlab.local/ca.crt

     # This for runner container requests git registry -- https://gitlab.local:5005/some/path:tag
     mkdir -p /etc/docker/certs.d/gitlab.local:5005
     cp ../crt/gitlab.local.crt /etc/docker/certs.d/gitlab.local:5005/ca.crt
     systemctl restart docker

     docker login gitlab.local:5005
     user: text from Token name
     pass: copied token

     # If connection OK you must see text (but it is not guaranty for perms): Login Succeeded

  3. Setup runner

     # ./up.sh
     ||
     # docker-compose up -d
     # docker-compose logs gitlab-runner
     # docker-compose exec gitlab-runner bash
     :/# <-- put to container console command from https://gitlab.local/admin/runners
     Ctrl+d

  4. Check container logs for errors

     # docker-compose logs -f gitlab-runner

  5. Run CI pipeline and see for errors in step 3 log

  6. Run kaniko-init Job manually in Gitlab and when repeat step 5, if CI shown error like:

     ERROR: Job failed: failed to pull image "gitlab.local:5005/team-op/k8s-example/master-kaniko:staging"
     with specified policies [always]: Error response from daemon: pull access denied for gitlab.local:5005/team-op/k8s-example/master-kaniko,
     repository does not exist or may require 'docker login': denied: requested access to the resource is denied

== Remove

   $ docker-compose docker stop gitlab-runner && docker-compose rm gitlab-runner

== Register a runner:

   https://docs.gitlab.com/runner/register/index.html

== Notes

1.

While put token in new runned container, register will ask for default image
this image will be fetched every time you run pipeline.
Image name may be ruby:1.7 or ubuntu:22.04 or docker:dind or even ""
IF you change it in config file you have tp remove old stalled build whick cached old wrong value.

To found whereis config file run on docker host node:

$ docker volume ls |grep gitlab-runner-config
...
runner-docker_gitlab-runner-config
$ docker volume inspect runner-docker_gitlab-runner-config | grep -oP 'Mountpoint[:" ]+\K[^"]+'
/var/lib/docker/volumes/runner-docker_gitlab-runner-config/_data
$ vi /var/lib/docker/volumes/runner-docker_gitlab-runner-config/_data/config.toml
and fix image =.

2.

Also, if using image = 'docker:dind' people said build crash with dns like errors,
its fixing in /var/lib/docker/volumes/runner-docker_gitlab-runner-config/_data/config.toml:
  -- volumes = ["/cache"]
  ++ volumes = ["/var/run/docker.sock:/var/run/docker.sock","/cache"]

I already have such sock volume in docker-compose.yaml since followed oficial gitlab runner install.
So same volume in config.toml may be overkill.

3.
In the same config.toml file, you can increase the concurrent = 1 to at least 2 to improve performance.
Runner restart is not required for GitLab to accept changes.
