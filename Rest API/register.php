<?php

// Verify all parameters given
// u - username
// p - password
if(empty($_POST['u']) || empty($_POST['p']))
    die();

// Constants
define("TAKEN", "Username already taken");
define("INVALID", "Username or password invalid");
define("USERNAME_REGEX", "/[a-zA-Z0-9]{3,}/");
define("PASSWORD_REGEX", "/[\S]{5,}/");

// Inputs
$username = $_POST['u'];
$raw_password = $_POST['p'];
$password = md5($raw_password . SALT);

// Output
$result = array();
$result['action'] = 'register';

// Validate username and password
if(!preg_match(USERNAME_REGEX, $username) || !preg_match(PASSWORD_REGEX, $raw_password)) {
    $result['status'] = FAIL;
    $result['reason'] = INVALID;
} else {
    $conn = open_database();

    // Prepare
    $stmt = $conn->prepare("SELECT username FROM users WHERE username = ?");
    $stmt->bind_param("s", $username);

    // set parameters and execute
    $stmt->execute();
    $stmt->store_result();

    // Check if user can register this username
    if ($stmt->num_rows == 0) {
        // Prepare
        $stmt = $conn->prepare("INSERT INTO users (username, password) VALUES (?, ?)");
        $stmt->bind_param("ss", $username, $password);

        // set parameters and execute
        $stmt->execute();

        $result['status'] = PASS;
    } else {
       $result['status'] = FAIL;
       $result['reason'] = TAKEN;
    }

    close_database($conn);
}

array_push($out, $result);

?>
