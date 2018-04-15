<?php
// Flags
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// Constants
define("PASS", "Success");
define("FAIL", "Fail");
define("SALT", "!~(COP_4331)~!");
define("DEFAULT_TOKEN", "-");

// Statuses
define("OFFLINE", 1);
define("ACTIVE", 2);
define("IN_GAME", 4);
define("IN_LOBBY", 5);

// DB Info
define("DB_SERVER", "localhost");
define("DB_USER", "COP4331_User");
define("DB_PASSWORD", "Pl3Ase_D0nt_H4cK_m3!!");
define("DB_NAME", "COP4331_Spring_2018");

// Convert a status to a string
function get_status_string($status) {
    switch($status) {
        case OFFLINE:
            return "Offline";
        case ACTIVE:
            return "Active";
        case IN_GAME:
            return "In Game";
        case IN_LOBBY:
            return "In Lobby";
    }
}

// Opens a databse connection
function open_database() {
    // Create connection
    $conn = new mysqli(DB_SERVER, DB_USER, DB_PASSWORD, DB_NAME);
    // Check connection
    if ($conn->connect_error) {
        die("Connection failed: " . $conn->connect_error);
    }

    return $conn;
}

// Close a database connection
function close_database($conn) {
    $conn->close();
}

// Validates a token
function validate_token($token) {
    if($token == DEFAULT_TOKEN)
        die();

    $conn = open_database();

    // Add auth token to record
    $stmt = $conn->prepare("SELECT token FROM users WHERE token = ?");
    $stmt->bind_param("s", $token);

    // set parameters and execute
    $stmt->execute();
    $stmt->store_result();

    // Check if token was found
    if ($stmt->num_rows != 1)
        die();

    close_database($conn);
}

// Updates status of a User
function update_status($token, $status) {
    $conn = open_database();

    // Add auth token to record
    $stmt = $conn->prepare("UPDATE users SET status = ?, last_status = CURRENT_TIMESTAMP WHERE token = ?");
    $stmt->bind_param("is", $status, $token);

    // set parameters and execute
    $stmt->execute();

    close_database($conn);
}
?>
