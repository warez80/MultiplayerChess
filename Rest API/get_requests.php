<?php

// Verify all parameters given
// t - token
if(empty($_POST['t']))
    die();

// Inputs
$token = $_POST['t'];

$conn = open_database();

// Prepare
$stmt = $conn->prepare("SELECT username FROM users WHERE token = ?");
$stmt->bind_param("s", $token);

// set parameters and execute
$stmt->execute();
$stmt->bind_result($username);
$stmt->store_result();

if($stmt->num_rows != 1) {
    $result['status'] = FAIL;
} else {
    $stmt->fetch();

    // Prepare
    $stmt = $conn->prepare("SELECT id, host_ip, request_name FROM game_invites WHERE receive_name = ?");
    $stmt->bind_param("s", $username);

    // set parameters and execute
    $stmt->execute();
    $stmt->bind_result($id, $host_ip, $request_name);
    $stmt->store_result();

    // Fill out search
    $result = array();
    $result['action'] = 'get_requests';
    $result['result'] = array();
    $result['status'] = PASS;

    while($stmt->fetch()) {
        $row = array();
        $row['request_name'] = $request_name;
        $row['host_ip'] = $host_ip;
        array_push($result['result'], $row);

        // Delete
        $stmt = $conn->prepare("DELETE FROM game_invites WHERE id = ?");
        $stmt->bind_param("s", $id);

        // set parameters and execute
        $stmt->execute();
    }
}

close_database($conn);
array_push($out, $result);
?>
