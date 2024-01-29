<?php

$rc = opcache_compile_file('/var/www/html/auth/distccd.php');
error_log("distccd.php : " . $rc);
