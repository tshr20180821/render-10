#!/bin/bash

set -x

export PS4='+(${BASH_SOURCE}:${LINENO}): '

curl -sSLO https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb
dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb

apt-fast -qq update

DEBIAN_FRONTEND=noninteractive apt-get -qq install -y --no-install-recommends dotnet-sdk-8.0
