#!/bin/bash

source ./config.sh

for i in {0..15}
do
  echo "===="
  echo " $i"
  echo "===="

  sed \
    -i'' ./config.sh \
    -e "s|^GITLAB_REGISTRY_ID=.*|GITLAB_REGISTRY_ID=$i|"

  ./garbige_untag.sh

  curl --silent --location --request GET "$GITLAB_URL/api/v4/projects/5/registry/repositories/$i/tags/?per_page=500&4age=1" --header "PRIVATE-TOKEN: $GITLAB_AUTH_TOKEN" | jq '.[]'

  git checkout ./config.sh
done

