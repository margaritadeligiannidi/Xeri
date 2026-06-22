<?php
require_once __DIR__ . '/../lib/dbconnect.php';
require_once __DIR__ . '/../lib/auth.php';

header('Content-Type: application/json');

/*  Authentication */
$me = current_player();
if (!$me) {
    http_response_code(401);
    echo json_encode(['error' => 'Not authenticated']);
    exit;
}

/*  Κατάσταση παιχνιδιού */
$res = $mysqli->query("
    SELECT status
    FROM game_status
    LIMIT 1
    FOR UPDATE
");
$game = $res->fetch_assoc();

if (!in_array($game['status'], ['ended', 'aborted'], true)) {
    http_response_code(409);
    echo json_encode(['error' => 'Game is still running']);
    exit;
}

/*  Restart */
if (!$mysqli->query("CALL start_game()")) {
    http_response_code(500);
    echo json_encode(['error' => 'Failed to restart game']);
    exit;
}

/*  Νέα κατάσταση */
$res = $mysqli->query("
    SELECT status, p_turn, p1_score, p2_score
    FROM game_status
    LIMIT 1
");
$new = $res->fetch_assoc();

echo json_encode([
    'success'  => true,
    'status'   => $new['status'],
    'p_turn'   => $new['p_turn'],
    'me'       => $me,
    'message'  => 'Game restarted'
]);
