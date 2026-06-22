<?php
require_once __DIR__ . '/../lib/dbconnect.php';
require_once __DIR__ . '/../lib/auth.php';

header('Content-Type: application/json');

$me = current_player();
if (!$me) {
    http_response_code(401);
    echo json_encode(['error' => 'Not authenticated']);
    exit;
}

// πάρε κατάσταση παιχνιδιού
$res = $mysqli->query("
    SELECT status, p_turn
    FROM game_status
    LIMIT 1
");
$game = $res->fetch_assoc();

// αν δεν παίζεται, απλά logout
if ($game['status'] !== 'started') {
    echo json_encode(['status' => 'ok']);
    exit;
}

// νικητής = ο άλλος
$winner = ($me === 'P1') ? 'P2' : 'P1';

$mysqli->query("
    UPDATE game_status
    SET status = 'aborted',
        result = '$winner',
        last_event = 'PLAYER_QUIT_$me'
");

echo json_encode([
    'status' => 'aborted',
    'winner' => $winner
]);
