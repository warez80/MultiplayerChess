<?php

// Verify all parameters given
// t - token
// m - Move String
// l - Lobby ID
if(empty($_POST['t']) || empty($_POST['m']) || empty($_POST['l']))
    die();

// Inputs
$token = $_POST['t'];
$move = $_POST['m'];
$lobby_id = $_POST['l'];

// Output
$result = array();
$result['action'] = 'add_move';

$conn = open_database();

// Get Player ID
$stmt = $conn->prepare("SELECT id FROM users WHERE token = ?");
$stmt->bind_param("s", $token);

$stmt->execute();
$stmt->bind_result($player_id);
$stmt->store_result();

if($stmt->num_rows != 1) {
    $result['status'] = FAIL;
} else {
    $stmt->fetch();

    // Create Lobby
    $stmt = $conn->prepare("INSERT INTO moves (lobby_id, player_id, move) VALUES (?, ?, ?)");
    $stmt->bind_param("iis", $lobby_id, $player_id, $move);

    $stmt->execute();

    $result['status'] = PASS;
}

close_database($conn);
array_push($out, $result);
?>
