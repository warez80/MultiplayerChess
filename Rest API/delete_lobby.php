<?php

// Verify all parameters given
// t - Token
if(empty($_POST['t']))
    die();

// Inputs
$token = $_POST['t'];

// Output
$result = array();
$result['action'] = 'delete_lobby';

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

    // Delete lobbies
    $stmt = $conn->prepare("DELETE FROM lobbies WHERE host_name = ?");
    $stmt->bind_param("s", $host_name);

    $stmt->execute();

    $result['status'] = PASS;
}

close_database($conn);
array_push($out, $result);
?>
