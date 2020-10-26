#!/#!/usr/bin/env bash

COMMIT_SHA_SHORT=$(git rev-parse --short HEAD)

DOCKER_BUILDKIT=1 docker build --network=host -t smartcommunitylab/dss:${COMMIT_SHA_SHORT} -t smartcommunitylab/dss:fix . && \
docker push smartcommunitylab/dss:${COMMIT_SHA_SHORT} && \
docker push smartcommunitylab/dss:fix
