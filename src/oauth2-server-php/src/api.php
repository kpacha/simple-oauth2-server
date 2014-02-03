<?php
// include our OAuth2 Server object
require_once __DIR__.'/server.php';

$request = OAuth2\Request::createFromGlobals();
$response = new OAuth2\Response();
$scopeRequired = 'api' . $apiId; // this resource requires "apiX" scope
// Handle a request for an OAuth2.0 Access Token and send the response to the client
if (!$server->verifyResourceRequest($request, $response, $scopeRequired)) {
    $response->send();
    die;
}
echo json_encode(array('success' => true, 'message' => 'You accessed the API ' . $apiId . '!'));