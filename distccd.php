<?php

$pid = getmypid();

error_log(date("Y-m-d H:i:s") . " ${pid} distccd.php start");

$data = gzdecode(file_get_contents("php://input"));

error_log(date("Y-m-d H:i:s") . " ${pid} distccd.php check point 010");

$socket = socket_create(AF_INET, SOCK_STREAM, SOL_TCP);

error_log(date("Y-m-d H:i:s") . " ${pid} distccd.php check point 020");

$rc = socket_connect($socket, '127.0.0.1', 3632);

error_log(date("Y-m-d H:i:s") . " ${pid} distccd.php check point 030 " . $rc);

$rc = socket_write($socket, $data);

error_log(date("Y-m-d H:i:s") . " ${pid} distccd.php check point 040 " . $rc);

$res = '';
for (;;) {
    error_log(date("Y-m-d H:i:s") . " ${pid} distccd.php check point 050");
    $buffer = socket_read($socket, 8192);
    if (strlen($buffer) === 0) {
        break;
    }
    $res .= $buffer;
}

error_log(date("Y-m-d H:i:s") . " ${pid} distccd.php check point 060 " . strlen($res));

socket_close($socket);

error_log(date("Y-m-d H:i:s") . " ${pid} distccd.php check point 070");

header('Content-Type: text/plain');

error_log(date("Y-m-d H:i:s") . " ${pid} distccd.php check point 080");

echo base64_encode($res);
