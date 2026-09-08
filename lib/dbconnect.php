<?php

$env = parse_ini_file(__DIR__ . '/.env');

if (!$env) {
    die("Unable to load .env file");
}

$user = $env['DB_USER'];
$pass = $env['DB_PASS'];
$host = $env['DB_HOST'];
$db   = $env['DB_NAME'];
$socket = $env['DB_SOCKET'] ?? null;

if (gethostname() == 'users.iee.ihu.gr' && $socket) {

    $mysqli = new mysqli(
        $host,
        $user,
        $pass,
        $db,
        null,
        $socket
    );

} else {

    $mysqli = new mysqli($host, $user, $pass, $db);
}

if ($mysqli->connect_errno) {
    echo "Failed to connect to MySQL: (" .
        $mysqli->connect_errno . ") " .
        $mysqli->connect_error;
}

?>
