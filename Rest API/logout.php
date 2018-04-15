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
$stmt->store_result();

// Check if user can login
$result = array();
$result['action'] = 'logout';

if ($stmt->num_rows == 1) {

    // Remove auth token from record
    $stmt = $conn->prepare("UPDATE users SET token = '" . DEFAULT_TOKEN . "', ip_addr = '' WHERE token = ?");
    $stmt->bind_param("s", $token);

    // set parameters and execute
    $stmt->execute();

    // Update status
    update_status($token, OFFLINE);

    $result['status'] = PASS;
} else {
    $result['status'] = FAIL;
}

close_database($conn);
array_push($out, $result);
?>
