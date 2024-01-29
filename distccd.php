<?php

$pid = getmypid();

error_log(date("Y-m-d H:i:s") . " ${pid} distccd.php start");

$data = file_get_contents("php://input");

error_log(date("Y-m-d H:i:s") . " ${pid} distccd.php check point 010 " . strlen($data));

$data = gzdecode($data);

error_log(date("Y-m-d H:i:s") . " ${pid} distccd.php check point 020 " . strlen($data));

$socket = socket_create(AF_INET, SOCK_STREAM, SOL_TCP);

error_log(date("Y-m-d H:i:s") . " ${pid} distccd.php check point 030");

$rc = socket_connect($socket, '127.0.0.1', 3632);

error_log(date("Y-m-d H:i:s") . " ${pid} distccd.php check point 040 " . $rc);

$rc = socket_write($socket, $data);

error_log(date("Y-m-d H:i:s") . " ${pid} distccd.php check point 050 " . $rc);

$res = '';
for (;;) {
    error_log(date("Y-m-d H:i:s") . " ${pid} distccd.php check point 060");
    $buffer = socket_read($socket, 8192);
    if (strlen($buffer) === 0) {
        break;
    }
    $res .= $buffer;
}

error_log(date("Y-m-d H:i:s") . " ${pid} distccd.php check point 070 " . strlen($res));

socket_close($socket);

error_log(date("Y-m-d H:i:s") . " ${pid} distccd.php check point 080");

header('Content-Type: text/plain');

error_log(date("Y-m-d H:i:s") . " ${pid} distccd.php check point 090");

echo base64_encode($res);
