<?php
require_once __DIR__ . '/../vendor/autoload.php';

$dsn      = 'mysql:dbname=oauth;host=localhost';
$username = 'oauthuser';
$password = 'oauthpassword';

$storage = new OAuth2\Storage\Pdo(array('dsn' => $dsn, 'username' => $username, 'password' => $password));
$server = new OAuth2\Server($storage);

$scopeUtil = new OAuth2\Scope($storage);
$server->setScopeUtil($scopeUtil);

// Add the "Client Credentials" grant type (it is the simplest of the grant types)
$server->addGrantType(new OAuth2\GrantType\ClientCredentials($storage));
// Add the "Authorization Code" grant type (this is where the oauth magic happens)
$server->addGrantType(new OAuth2\GrantType\AuthorizationCode($storage));
