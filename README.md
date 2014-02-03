simple-oauth2-server
====

Simple demo of an OAuth2 Server 

#Requirements

* git
* vagrant 1.1+
* puppet

#Install

Clone the repo

	$ git clone https://github.com/kpacha/simple-oauth2-server.git

Install the php dependencies

	$ cd simple-oauth2-server/src
	$ curl -sS https://getcomposer.org/installer | php
	$ php composer.phar install

Init the project submodules

	$ cd ..
	$ git submodule init
	$ git submodule update

Start the engine!

	$ vagrant up

And your simple-oauth2-server will be waiting for you at `http://localhost:3000/oauth2-server-php/public`.

Also, there are some extras:

* phpinfo is published at `http://localhost:3000/phpinfo.php`
* phpmyadmin is installed at `http://localhost:3000/phpmyadmin/` (with the credentials defined at `provision/manifests/classes/mysql.pp`)

#Usage

The demo data has 2 users with different scopes:

* Client1: client_id: testclient  | client_secret: testpass | scope: basic, api1, api2
* Client2: client_id: testclient2 | client_secret: testpass | scope: basic, api3

##Client1 

Client1 requires a token with unauthorized scope

	$ curl -u testclient:testpass http://localhost:3000/oauth2-server-php/public/token.php -d 'grant_type=client_credentials&scope=basic api1 api3' -i
	HTTP/1.1 400 Bad Request
	Date: Sun, 02 Feb 2014 23:07:12 GMT
	Server: Apache/2.2.22 (Ubuntu)
	X-Powered-By: PHP/5.3.10-1ubuntu3.9
	Cache-Control: no-store
	Content-Length: 95
	Connection: close
	Content-Type: application/json

	{"error":"invalid_scope","error_description":"The scope requested is invalid for this request"}

Client1 requires a token with limited scope

	$ curl -u testclient:testpass http://localhost:3000/oauth2-server-php/public/token.php -d 'grant_type=client_credentials&scope=basic api1' -iHTTP/1.1 200 OK
	Date: Sun, 02 Feb 2014 23:08:20 GMT
	Server: Apache/2.2.22 (Ubuntu)
	X-Powered-By: PHP/5.3.10-1ubuntu3.9
	Cache-Control: no-store
	Pragma: no-cache
	Content-Length: 120
	Content-Type: application/json

	{"access_token":"f1193a0c343c2467f0763bb1542744357d41d78b","expires_in":3600,"token_type":"Bearer","scope":"basic api1"}

and he consumes it

	$ curl http://localhost:3000/oauth2-server-php/public/api1.php -d 'access_token=f1193a0c343c2467f0763bb1542744357d41d78b' -iHTTP/1.1 200 OK
	Date: Sun, 02 Feb 2014 23:09:19 GMT
	Server: Apache/2.2.22 (Ubuntu)
	X-Powered-By: PHP/5.3.10-1ubuntu3.9
	Vary: Accept-Encoding
	Content-Length: 52
	Content-Type: text/html

	{"success":true,"message":"You accessed the API 1!"}

but when he requires a resource out from the scope of its token...

	$ curl http://localhost:3000/oauth2-server-php/public/api2.php -d 'access_token=f1193a0c343c2467f0763bb1542744357d41d78b' -i
	HTTP/1.1 401 Authorization Required
	Date: Sun, 02 Feb 2014 23:10:08 GMT
	Server: Apache/2.2.22 (Ubuntu)
	X-Powered-By: PHP/5.3.10-1ubuntu3.9
	Cache-Control: no-store
	WWW-Authenticate: Bearer realm="Service", scope="api2", error="insufficient_scope", error_description="The request requires higher privileges than provided by the access token"
	Content-Length: 125
	Content-Type: application/json

	{"error":"insufficient_scope","error_description":"The request requires higher privileges than provided by the access token"}

so client1 requires a token for all its scopes

	$ curl -u testclient:testpass http://localhost:3000/oauth2-server-php/public/token.php -d 'grant_type=client_credentials&scope=basic api1 api2' -i
	HTTP/1.1 200 OK
	Date: Sun, 02 Feb 2014 23:11:05 GMT
	Server: Apache/2.2.22 (Ubuntu)
	X-Powered-By: PHP/5.3.10-1ubuntu3.9
	Cache-Control: no-store
	Pragma: no-cache
	Content-Length: 125
	Content-Type: application/json

	{"access_token":"e572c9f6ec7782d479007944c1a983578d63404e","expires_in":3600,"token_type":"Bearer","scope":"basic api1 api2"}

and now he's able to acces all its resources

	$ curl http://localhost:3000/oauth2-server-php/public/api2.php -d 'access_token=e572c9f6ec7782d479007944c1a983578d63404e' -iHTTP/1.1 200 OK
	Date: Sun, 02 Feb 2014 23:11:39 GMT
	Server: Apache/2.2.22 (Ubuntu)
	X-Powered-By: PHP/5.3.10-1ubuntu3.9
	Vary: Accept-Encoding
	Content-Length: 52
	Content-Type: text/html

	{"success":true,"message":"You accessed the API 2!"}

	$ curl http://localhost:3000/oauth2-server-php/public/api1.php -d 'access_token=e572c9f6ec7782d479007944c1a983578d63404e' -i
	HTTP/1.1 200 OK
	Date: Sun, 02 Feb 2014 23:11:48 GMT
	Server: Apache/2.2.22 (Ubuntu)
	X-Powered-By: PHP/5.3.10-1ubuntu3.9
	Vary: Accept-Encoding
	Content-Length: 52
	Content-Type: text/html

	{"success":true,"message":"You accessed the API 1!"}

##Client2

Client2 requires a token

	$ curl -u testclient2:testpass http://localhost:3000/oauth2-server-php/public/token.php -d 'grant_type=client_credentials&scope=basic api3' -i
	HTTP/1.1 200 OK
	Date: Sun, 02 Feb 2014 23:02:35 GMT
	Server: Apache/2.2.22 (Ubuntu)
	X-Powered-By: PHP/5.3.10-1ubuntu3.9
	Cache-Control: no-store
	Pragma: no-cache
	Content-Length: 120
	Content-Type: application/json

	{"access_token":"33726cf35644c6185af8614f4de8a04dd90e32b8","expires_in":3600,"token_type":"Bearer","scope":"basic api3"}

Client2 requires a token with unauthorized scope

	$ curl -u testclient2:testpass http://localhost:3000/oauth2-server-php/public/token.php -d 'grant_type=client_credentials&scope=basic api1 api3' -i
	HTTP/1.1 400 Bad Request
	Date: Sun, 02 Feb 2014 23:03:36 GMT
	Server: Apache/2.2.22 (Ubuntu)
	X-Powered-By: PHP/5.3.10-1ubuntu3.9
	Cache-Control: no-store
	Content-Length: 95
	Connection: close
	Content-Type: application/json

	{"error":"invalid_scope","error_description":"The scope requested is invalid for this request"}

Client2 consumes its valid token on authorized resource

	$ curl http://localhost:3000/oauth2-server-php/public/api3.php -d 'access_token=33726cf35644c6185af8614f4de8a04dd90e32b8' -iHTTP/1.1 200 OK
	Date: Sun, 02 Feb 2014 23:04:50 GMT
	Server: Apache/2.2.22 (Ubuntu)
	X-Powered-By: PHP/5.3.10-1ubuntu3.9
	Vary: Accept-Encoding
	Content-Length: 52
	Content-Type: text/html

	{"success":true,"message":"You accessed the API 3!"}

Client2 tries to consume an unauthorized resource

	$ curl http://localhost:3000/oauth2-server-php/public/api1.php -d 'access_token=33726cf35644c6185af8614f4de8a04dd90e32b8' -i
	HTTP/1.1 401 Authorization Required
	Date: Sun, 02 Feb 2014 23:05:48 GMT
	Server: Apache/2.2.22 (Ubuntu)
	X-Powered-By: PHP/5.3.10-1ubuntu3.9
	Cache-Control: no-store
	WWW-Authenticate: Bearer realm="Service", scope="api1", error="insufficient_scope", error_description="The request requires higher privileges than provided by the access token"
	Content-Length: 125
	Content-Type: application/json

	{"error":"insufficient_scope","error_description":"The request requires higher privileges than provided by the access token"}