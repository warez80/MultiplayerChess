<?php

// Verify all parameters given
// u - username
// p - password
// i - ip address
if(empty($_POST['u']) || empty($_POST['p']) || empty($_POST['i']))
    die();

// Constants
define("INVALID", "Invalid Username or Password");

// Inputs
$username = $_POST['u'];
$password = md5($_POST['p'] . SALT);
$ipaddr = $_POST['i'];

$conn = open_database();

// Prepare
$stmt = $conn->prepare("SELECT password FROM users WHERE username = ?");
$stmt->bind_param("s", $username);

// set parameters and execute
$stmt->execute();
$stmt->bind_result($result_password);
$stmt->store_result();

// Check if user can login
$result = array();
$result['action'] = 'login';

if ($stmt->num_rows == 1) {
    $stmt->fetch();

    if($result_password == $password) {
        $token = generate_auth_token();

        // Add auth token to record
        $stmt = $conn->prepare("UPDATE users SET token = ?, ip_addr = ? WHERE username = ?");
        $stmt->bind_param("sss", $token, $ipaddr, $username);

        // set parameters and execute
        $stmt->execute();

        // Update status
        update_status($token, ACTIVE);

        $result['status'] = PASS;
        $result['auth_token'] = $token;
    } else {
        $result['status'] = FAIL;
        $result['reason'] = INVALID;
    }
} else {
    $result['status'] = FAIL;
    $result['reason'] = INVALID;
}

close_database($conn);

array_push($out, $result);

function generate_auth_token() {
    if (function_exists('com_create_guid') === true)
    {
        return trim(com_create_guid(), '{}');
    }

    return sprintf('%04X%04X-%04X-%04X-%04X-%04X%04X%04X', mt_rand(0, 65535), mt_rand(0, 65535), mt_rand(0, 65535), mt_rand(16384, 20479), mt_rand(32768, 49151), mt_rand(0, 65535), mt_rand(0, 65535), mt_rand(0, 65535));
}
?>
