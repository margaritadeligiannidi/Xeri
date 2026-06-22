<?php
header('Content-Type: application/json');
require_once __DIR__ . '/../lib/dbconnect.php';

$input = json_decode(file_get_contents("php://input"), true);

$username  = $_POST['username']  ?? $input['username']  ?? null;
$player_id = $_POST['player_id'] ?? $input['player_id'] ?? null;

if (!$username || !$player_id) {
    http_response_code(400);
    echo json_encode(['error'=>'Missing data']);
    exit;
}

/* έγκυρος ρόλος */
if (!in_array($player_id, ['P1','P2'])) {
    http_response_code(400);
    echo json_encode(['error'=>'Invalid player']);
    exit;
}

/* Αν ειναι aborted, ended, καθαριζει πρωτα τους παικτες */
$stmt = $mysqli->prepare("
    SELECT status FROM game_status
");
$stmt->execute();
$stmt->bind_result($status);
$stmt->fetch();
$stmt->close();

if ($status === 'aborted' || $status === 'ended') {

    /* NULL παίκτη */
    $stmt = $mysqli->prepare("
        UPDATE players
        SET username=NULL, token=NULL, last_action=NULL
    ");
    $stmt->execute();
    $stmt->close();

    /* STATUS */
    $stmt = $mysqli->prepare("
        UPDATE game_status
        SET status='not active'
    ");
    $stmt->execute();
    $stmt->close();
}

/* έλεγχος αν ρόλος είναι κατειλημμένος */
$stmt = $mysqli->prepare("
    SELECT token FROM players WHERE player_id=?
");
$stmt->bind_param("s", $player_id);
$stmt->execute();
$stmt->bind_result($existing_token);
$stmt->fetch();
$stmt->close();

if ($existing_token !== null) {
    http_response_code(409);
    echo json_encode(['error'=>'Ο ρόλος είναι ήδη κατειλημμένος']);
    exit;
}

/* δημιουργία token */
$token = bin2hex(random_bytes(16));

/* ενημέρωση παίκτη */
$stmt = $mysqli->prepare("
    UPDATE players
    SET username=?, token=?, last_action=NOW()
    WHERE player_id=?
");
$stmt->bind_param("sss", $username, $token, $player_id);
$stmt->execute();
$stmt->close();

echo json_encode([
    'success' => true,
    'token'   => $token,
    'player'  => $player_id
]);
