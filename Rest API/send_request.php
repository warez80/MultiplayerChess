<?php

// Verify all parameters given
// t - token
// h - host ip
// i - Invitee
if(empty($_POST['t']) || empty($_POST['h']) || empty($_POST['i']))
    die();

// Inputs
$token = $_POST['t'];
$host_ip = $_POST['h'];
$invitee = $_POST['i'];

// Output
$result = array();
$result['action'] = 'send_request';

$conn = open_database();

// Get Player username
$stmt = $conn->prepare("SELECT username FROM users WHERE token = ?");
$stmt->bind_param("s", $token);

$stmt->execute();
$stmt->bind_result($username);
$stmt->store_result();

if($stmt->num_rows != 1) {
    $result['status'] = FAIL;
} else {
    $stmt->fetch();

    // Create Request
    $stmt = $conn->prepare("INSERT INTO game_invites (host_ip, request_name, receive_name) VALUES (?, ?, ?)");
    $stmt->bind_param("sss", $host_ip, $username, $invitee);

    $stmt->execute();

    $result['status'] = PASS;
}

close_database($conn);
array_push($out, $result);
?>
