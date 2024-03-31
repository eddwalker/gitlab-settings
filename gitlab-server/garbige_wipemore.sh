#!/bin/bash

for i in {0..15}
do
  echo "===="
  echo " $i"
  echo "===="

  sed \
    -i'' ./config.sh \
    -e "s|^GITLAB_REGISTRY_ID=.*|GITLAB_REGISTRY_ID=$i|"

  ./garbige_untag.sh

  curl --silent --location --request GET "https://gitlab.local/api/v4/projects/5/registry/repositories/$i/tags/?per_page=500&4age=1" --header "PRIVATE-TOKEN: glpat-xW_HU_vEc2vaXqJFfyro" | jq '.[]'

done

