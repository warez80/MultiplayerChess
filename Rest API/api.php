<?php
// Includes
require_once("commons.php");

// Check for action
if(empty($_POST['a']))
    die();

$valid_token = False;

// Validate token & Update status if token exists
if(!empty($_POST['t'])) {
    validate_token($_POST['t']);
    update_status($_POST['t'], ACTIVE);
    $validate_token = True;
}

// Output json
$out = array();

// Trigger Action
switch($_POST['a']) {
    case "login":
        require_once('login.php');
        break;
    case "register":
        require_once('register.php');
        break;
    case "logout":
        require_once('logout.php');
        break;
    case "user_search":
        require_once('user_search.php');
        break;
    case "create_lobby":
        require_once('create_lobby.php');
        break;
    case "lobby_search":
        require_once('lobby_search.php');
        break;
    case "delete_lobby":
        require_once('delete_lobby.php');
        break;
    case "add_move":
        require_once('add_move.php');
        break;
    case "get_moves":
        require_once('get_moves.php');
        break;
    case "send_request":
        require_once('send_request.php');
        break;
    case "get_requests":
        require_once('get_requests.php');
        break;
    default:
        $result = array();
        $result['status'] = FAIL;
        array_push($out, $result);
        break;
}

// Print Result
echo json_encode($out);
?>
