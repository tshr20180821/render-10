#!/bin/bash

set -x

export PS4='+(${BASH_SOURCE}:${LINENO}): '

ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p ${TARGET_PORT} -i /home/${SSH_USER}/.ssh/${RENDER_EXTERNAL_HOSTNAME}-${SSH_USER} -fL 13632:127.0.0.1:3632 ${SSH_USER}@127.0.0.1
