<?php

// Verify all parameters given
// t - token
// l - Lobby ID
if(empty($_POST['t']) || empty($_POST['l']))
    die();

// Inputs
$token = $_POST['t'];
$lobby_id = $_POST['l'];

// Output
$result = array();
$result['action'] = 'get_moves';

$conn = open_database();

// Get Player ID
$stmt = $conn->prepare("SELECT moves.move, users.username FROM moves INNER JOIN users ON moves.player_id = users.id WHERE moves.lobby_id = ? ORDER BY moves.id DESC");
$stmt->bind_param("s", $lobby_id);

$stmt->execute();
$stmt->bind_result($move, $username);
$stmt->store_result();

$result['result'] = array();

if($stmt->num_rows > 0)
    $result['status'] = PASS;
else
    $result['status'] = FAIL;

$i = 0;
while($stmt->fetch()) {
    $moveArr = array();
    $moveArr['index'] = $i++;
    $moveArr['move'] = $move;
    $moveArr['username'] = $username;
    array_push($result['result'], $moveArr);
}

close_database($conn);
array_push($out, $result);
?>
