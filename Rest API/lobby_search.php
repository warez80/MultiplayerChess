<?php

// Verify all parameters given
// t - Token
// n - Lobby Name (Optional)
if(empty($_POST['t']))
    die();

// Inputs
$lobby_name = "%";
if(!empty($_POST['n']))
 $lobby_name = "%" . $_POST['n'] . "%";

// Output
$result = array();
$result['action'] = 'lobby_search';

$conn = open_database();

// Get Lobbies
$sql = "SELECT id, lobby_name, host_name, host_ip, password FROM lobbies WHERE lobby_name LIKE ? ORDER BY created_at DESC LIMIT 100";
if(empty($_POST['n']))
    $sql = "SELECT id, lobby_name, host_name, host_ip, password FROM lobbies ORDER BY created_at DESC LIMIT 100";

$stmt = $conn->prepare($sql);

if(!empty($_POST['n']))
    $stmt->bind_param("s", $lobby_name);

$stmt->execute();
$stmt->bind_result($id, $lobby_name, $host_name, $host_ip, $password);
$stmt->store_result();

$result['result'] = array();
$result['action'] = 'lobby_search';

if($stmt->num_rows > 0)
    $result['status'] = PASS;
else
    $result['status'] = FAIL;

while($stmt->fetch()) {
    $row = array();
    $row['id'] = $id;
    $row['lobby_name'] = $lobby_name;
    $row['host_name'] = $host_name;
    $row['host_ip'] = $host_ip;
    $row['password'] = $password;
    array_push($result['result'], $row);
}

close_database($conn);
array_push($out, $result);
?>
