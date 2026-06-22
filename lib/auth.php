<?php
require_once __DIR__ . '/dbconnect.php';

function current_player() {
    global $mysqli;

    $token = $_SERVER['HTTP_X_TOKEN'] ?? null;
    if (!$token) {
        return null;
    }

    $stmt = $mysqli->prepare("
        SELECT player_id FROM players WHERE token=?
    ");
    $stmt->bind_param("s", $token);
    $stmt->execute();

    $res = $stmt->get_result()->fetch_assoc();

    if (!$res) {
        return null;
    }

    /* ενημέρωση δραστηριότητας */
    $stmt = $mysqli->prepare("
        UPDATE players
        SET last_seen = NOW()
        WHERE token = ?
    ");
    $stmt->bind_param("s", $token);
    $stmt->execute();

    return $res['player_id'];
}
