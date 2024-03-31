#!/usr/bin/env bash

docker exec -it gitlab-server_web_1 gitlab-ctl registry-garbage-collect -m
