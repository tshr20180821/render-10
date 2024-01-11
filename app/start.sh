#!/bin/bash

set -x

a2enmod authz_groupfile

find / -name httpd -print
find / -name envvars -print

httpd -DFOREGROUND