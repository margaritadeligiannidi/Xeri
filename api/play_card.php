<?php
require_once __DIR__ . '/../lib/dbconnect.php';
require_once __DIR__ . '/../lib/auth.php';

header('Content-Type: application/json');

/* Authentication */
$player = current_player();
if (!$player) {
    http_response_code(401);
    echo json_encode(['error' => 'Not authenticated']);
    exit;
}

/*  card_id */
$input = json_decode(file_get_contents("php://input"), true);

$card_id =
    $_POST['card_id']
    ?? $input['card_id']
    ?? null;


if (!$card_id) {
    http_response_code(400);
    echo json_encode(['error' => 'Missing card_id']);
    exit;
}

/* κατάσταση παιχνιδιού */
$res = $mysqli->query("
    SELECT status, p_turn
    FROM game_status
    LIMIT 1
");
$game = $res->fetch_assoc();

if (!$game) {
    http_response_code(500);
    echo json_encode(['error' => 'Game status missing']);
    exit;
}

if ($game['status'] !== 'started') {
    http_response_code(409);
    echo json_encode([
        'error'  => 'Game not playable',
        'status' => $game['status']
    ]);
    exit;
}

/*  Έλεγχος κάρτας  */
$stmt = $mysqli->prepare("
    SELECT 1
    FROM cards
    WHERE card_id = ?
      AND location = ?
");
$location = "hand_$player";
$stmt->bind_param("is", $card_id, $location);
$stmt->execute();

if ($stmt->get_result()->num_rows === 0) {
    http_response_code(403);
    echo json_encode(['error' => 'Card does not belong to player']);
    exit;
}

/* κίνηση */
$before_turn = $game['p_turn'];

/*  Παίξε κάρτα  */
$stmt = $mysqli->prepare("CALL play_card(?, ?)");
$stmt->bind_param("si", $player, $card_id);

if (!$stmt->execute()) {
    http_response_code(500);
    echo json_encode(['error' => 'play_card failed']);
    exit;
}

/* καθάρισμα result sets */
while ($mysqli->more_results() && $mysqli->next_result()) {
    $mysqli->use_result();
}

/*  Έλεγχος αν έγινε κίνηση */
$res = $mysqli->query("
    SELECT status, p_turn
    FROM game_status
    LIMIT 1
");
$after = $res->fetch_assoc();

if ($after['p_turn'] === $before_turn && $after['status'] === 'started') {
    http_response_code(409);
    echo json_encode(['error' => 'Invalid move']);
    exit;
}



/* game_status */
$res = $mysqli->query("
    SELECT status, p_turn, result, last_event, p1_score, p2_score
    FROM game_status
    LIMIT 1
");
$game = $res->fetch_assoc();

/* table */
$res = $mysqli->query("
    SELECT card_id, suit, value, table_order
    FROM cards
    WHERE location = 'table'
    ORDER BY table_order
");
$table = $res->fetch_all(MYSQLI_ASSOC);

/* hand */
$res = $mysqli->query("
    SELECT card_id, suit, value
    FROM cards
    WHERE location = 'hand_$player'
");
$hand = $res->fetch_all(MYSQLI_ASSOC);

/* captured */
$res = $mysqli->query("
    SELECT card_id, suit, value
    FROM cards
    WHERE location = 'captured_$player'
");
$captured = $res->fetch_all(MYSQLI_ASSOC);

/*  JSON RESPONSE */
echo json_encode([
    'status'      => $game['status'],
    'p_turn'      => $game['p_turn'],
    'result'      => $game['result'],
    'last_event'  => $game['last_event'],
    'p1_score'    => $game['p1_score'],
    'p2_score'    => $game['p2_score'],
    'me'          => $player,
    'table'       => $table,
    'hand'        => $hand,
    'captured'    => $captured
]);
