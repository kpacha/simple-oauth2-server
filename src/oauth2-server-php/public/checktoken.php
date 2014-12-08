<?php

// include our OAuth2 Server object
require_once __DIR__.'/../src/server.php';
$request = OAuth2\Request::createFromGlobals();

$response = new OAuth2\Response();
$scopeRequired = 'api1'; // this resource requires "apiX" scope
// Handle a request for an OAuth2.0 Access Token and send the response to the client
if (!$server->verifyResourceRequest($request, $response, $scopeRequired)) {
    $response->send();
    die;
}

$tokenData = $server->getAccessTokenData($request, $response, $scopeRequired);
$response->setParameters(array(
    'access_token' => $tokenData['access_token'],
    'user_id' => $tokenData['user_id'],
    'client_id' => $tokenData['client_id'],
    'scope' => $tokenData['scope'],
    'expires' => $tokenData['expires'],
));
$response->setHttpHeader("X-Api-Server-Time", time());
$response->setHttpHeader("X-Api-User", $tokenData['user_id']);
$response->setHttpHeader("X-Api-Client", $tokenData['client_id']);
$response->setHttpHeader("X-Api-Context", $tokenData['scope']);
$response->setHttpHeader("Cache-Control", "public, max-age=1800");

$response->send();
