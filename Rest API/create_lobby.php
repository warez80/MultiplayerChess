<?php

// Verify all parameters given
// t - token
// n - Lobby Name
// i - IP Address of lobby
// p (optional) - Password
if(empty($_POST['t']) || empty($_POST['n']) || empty($_POST['i']))
    die();

// Inputs
$token = $_POST['t'];
$lobby_name = $_POST['n'];
$host_ip = $_POST['i'];
$password = "";

// Optional
if(!empty($_POST['p']))
    $password = $_POST['p'];

// Output
$result = array();
$result['action'] = 'create_lobby';

$conn = open_database();

// Get Host Name
$stmt = $conn->prepare("SELECT username FROM users WHERE token = ?");
$stmt->bind_param("s", $token);

$stmt->execute();
$stmt->bind_result($host_name);
$stmt->store_result();

if($stmt->num_rows != 1) {
    $result['status'] = FAIL;
} else {
    $stmt->fetch();

    // Create Lobby
    $stmt = $conn->prepare("INSERT INTO lobbies (lobby_name, host_name, host_ip, password) VALUES (?, ?, ?, ?)");
    $stmt->bind_param("ssss", $lobby_name, $host_name, $host_ip, $password);

    $stmt->execute();

    $result['status'] = PASS;
}

close_database($conn);
array_push($out, $result);
?>
