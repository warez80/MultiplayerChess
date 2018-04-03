<?php

// Verify all parameters given
// t - token
// s - Search String
if(empty($_POST['t']) || empty($_POST['s']))
    die();

// Inputs
$search = "%" . $_POST['s'] . "%";

$conn = open_database();

// Prepare
$stmt = $conn->prepare("SELECT username, status, ip_addr, last_status FROM users WHERE username LIKE ?");
$stmt->bind_param("s", $search);

// set parameters and execute
$stmt->execute();
$stmt->bind_result($username, $status, $ip_addr, $last_status);
$stmt->store_result();

// Fill out search
$result = array();
$result['action'] = 'user_search';
$result['result'] = array();

while($stmt->fetch()) {
    $row = array();
    $row['username'] = $username;
    $row['ip_addr'] = $ip_addr;
    $row['status'] = get_status_string($status);
    $row['last_status'] = $last_status;
    array_push($result['result'], $row);
}

close_database($conn);
array_push($out, $result);
?>
