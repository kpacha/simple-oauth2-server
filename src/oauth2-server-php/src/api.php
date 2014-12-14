<?php
// include our OAuth2 Server object
require_once __DIR__.'/server.php';

$request = OAuth2\Request::createFromGlobals();
$response = new OAuth2\Response();

if ($server->verifyResourceRequest($request, $response, 'api' . $apiId)) {
	$response->setParameters(array(
	    'success' => true,
	    'message' => 'You accessed the API ' . $apiId . '!',
	));
}
$response->send();