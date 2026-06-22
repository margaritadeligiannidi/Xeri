<?php
require_once __DIR__ . '/../lib/dbconnect.php';
require_once __DIR__ . '/../lib/auth.php';

header('Content-Type: application/json');

date_default_timezone_set('Europe/Athens');

$TIMEOUT_SECONDS = 60;

$me = current_player();
if (!$me) {
    http_response_code(401);
    echo json_encode(['error' => 'Not authenticated']);
    exit;
}

/*  ΚΑΤΑΣΤΑΣΗ ΠΑΙΧΝΙΔΙΟΥ */
$res = $mysqli->query("
    SELECT status, p_turn, result, last_event, p1_score, p2_score, last_change
    FROM game_status
    LIMIT 1
");
$game = $res->fetch_assoc();


/* TIMEOUT CHECK */
$idle = null;

if ($game['status'] === 'started' && !empty($game['last_change'])) {
    $idle = time() - strtotime($game['last_change']);

    if ($idle >= 60) {
        $loser  = $game['p_turn'];
        $winner = ($loser === 'P1') ? 'P2' : 'P1';

        $mysqli->query("
            UPDATE game_status
            SET status='aborted',
                result='$winner',
                last_event='TIMEOUT_$loser'
        ");


        echo json_encode([
            'status' => 'aborted',
            'idle' => $idle
        ]);
        exit;
    }
}


/*  ΠΑΙΚΤΕΣ */
$res = $mysqli->query("
    SELECT COUNT(*) AS c
    FROM players
    WHERE token IS NOT NULL
");
$count = (int)$res->fetch_assoc()['c'];

if ($count < 2 && $game['status'] !== 'aborted') {
    echo json_encode([
        'status'  => 'not active',
        'message' => 'Waiting for other player'
    ]);
    exit;
}

/*  AUTO START */
if ($game['status'] === 'not active' && $count === 2) {

    $mysqli->query("CALL start_game()");

    $res = $mysqli->query("
        SELECT status, p_turn, result, last_event, p1_score, p2_score
        FROM game_status
        LIMIT 1
    ");
    $game = $res->fetch_assoc();
}

/*  TABLE */
$res = $mysqli->query("
    SELECT card_id, suit, value, table_order
    FROM cards
    WHERE location = 'table'
    ORDER BY table_order
");
$table = $res->fetch_all(MYSQLI_ASSOC);

/*  HAND */
$res = $mysqli->query("
    SELECT card_id, suit, value
    FROM cards
    WHERE location = 'hand_$me'
");
$hand = $res->fetch_all(MYSQLI_ASSOC);

/*  CAPTURED */
$res = $mysqli->query("
    SELECT card_id, suit, value
    FROM cards
    WHERE location = 'captured_$me'
");
$captured = $res->fetch_all(MYSQLI_ASSOC);

/* RESPONSE */
echo json_encode([
    'status'     => $game['status'],
    'p_turn'     => $game['p_turn'],
    'result'     => $game['result'],
    'last_event' => $game['last_event'],
    'p1_score'   => $game['p1_score'],
    'p2_score'   => $game['p2_score'],
    'me'         => $me,
    'table'      => $table,
    'hand'       => $hand,
    'captured'   => $captured,
    'idle' => $idle
]);