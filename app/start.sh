#!/bin/bash

set -x

a2enmod authz_groupfile

apachectl -DFOREGROUND
