simple-oauth2-server
====

Simple demo of an OAuth2 Server based on the oauth2-server-php project

#Requirements

* git
* vagrant 1.4

#Install

Clone the repo

	$ git clone https://github.com/kpacha/simple-oauth2-server.git

Start the engine!

	$ vagrant up

Install the php dependencies

	$ vagrant ssh
    $ cd /vagrant/src/simple-oauth2-server
	$ curl -sS https://getcomposer.org/installer | php
	$ php composer.phar install

And your simple-oauth2-server will be waiting for you at `http://localhost:3000/`.

#Usage

The demo data has 2 users with different scopes:

User | Client ID | Client Secret | Scope
-----|-----------|---------------|------
Client1 | testclient | testpass | basic, api1, api2
Client2 | testclient2 | testpass | basic, api3

Also, this toy exposes several interesting endpoints

File | Function
-----|-----------
token.php | Authentication endpoint: creates a token after checking the received credentials
checktoken.php | Validation endpoint: validates a token and returns its params
api1.php | Resource endpoint: simple endpoint for the scope 'api1'
api2.php | Resource endpoint: simple endpoint for the scope 'api2'
api3.php | Resource endpoint: simple endpoint for the scope 'api3'

So you can use the included resource endpoint and/or use as many Remote Resource Services as you want.
 
##Client1 

Client1 requires a token with unauthorized scope

	$ curl -i -u testclient:testpass http://localhost:3000/token.php -d 'grant_type=client_credentials&scope=basic api1 api3'
	HTTP/1.1 400 Bad Request
	Server: nginx/1.6.2
	Content-Type: application/json
	X-Powered-By: PHP/5.5.9-1ubuntu4.5
	Cache-Control: no-store
	Content-Length: 95
	Accept-Ranges: bytes
	Date: Sun, 14 Dec 2014 15:52:30 GMT
	X-Varnish: 1248919758
	Age: 0
	Via: 1.1 varnish
	Connection: keep-alive

	{"error":"invalid_scope","error_description":"The scope requested is invalid for this request"}

Client1 requires a token with limited scope

	$ curl -i -u testclient:testpass http://localhost:3000/token.php -d 'grant_type=client_credentials&scope=basic api1'
	HTTP/1.1 200 OK
	Server: nginx/1.6.2
	Content-Type: application/json
	X-Powered-By: PHP/5.5.9-1ubuntu4.5
	Cache-Control: no-store
	Pragma: no-cache
	Content-Length: 120
	Accept-Ranges: bytes
	Date: Sun, 14 Dec 2014 15:53:04 GMT
	X-Varnish: 1248919759
	Age: 0
	Via: 1.1 varnish
	Connection: keep-alive

	{"access_token":"639e0a939dc4df586d3b22ec56042fcf7818260d","expires_in":3600,"token_type":"Bearer","scope":"basic api1"}

and he consumes it

	$ curl -i http://localhost:3000/api1.php -d 'access_token=639e0a939dc4df586d3b22ec56042fcf7818260d'
	HTTP/1.1 200 OK
	Server: nginx/1.6.2
	Content-Type: application/json
	X-Powered-By: PHP/5.5.9-1ubuntu4.5
	Content-Length: 52
	Accept-Ranges: bytes
	Date: Sun, 14 Dec 2014 15:54:02 GMT
	X-Varnish: 1248919760
	Age: 0
	Via: 1.1 varnish
	Connection: keep-alive

	{"success":true,"message":"You accessed the API 1!"}

but when he requires a resource out from the scope of its token...

	$ curl -i http://localhost:3000/api2.php -d 'access_token=639e0a939dc4df586d3b22ec56042fcf7818260d'
	HTTP/1.1 401 Unauthorized
	Server: nginx/1.6.2
	Content-Type: application/json
	X-Powered-By: PHP/5.5.9-1ubuntu4.5
	Cache-Control: no-store
	WWW-Authenticate: Bearer realm="Service", scope="api2", error="insufficient_scope", error_description="The request requires higher privileges than provided by the access token"
	Content-Length: 125
	Accept-Ranges: bytes
	Date: Sun, 14 Dec 2014 15:54:33 GMT
	X-Varnish: 1248919761
	Age: 0
	Via: 1.1 varnish
	Connection: keep-alive

	{"error":"insufficient_scope","error_description":"The request requires higher privileges than provided by the access token"}

so client1 requires a token for all its scopes

	$ curl -i -u testclient:testpass http://localhost:3000/token.php -d 'grant_type=client_credentials&scope=basic api1 api2'
	HTTP/1.1 200 OK
	Server: nginx/1.6.2
	Content-Type: application/json
	X-Powered-By: PHP/5.5.9-1ubuntu4.5
	Cache-Control: no-store
	Pragma: no-cache
	Content-Length: 125
	Accept-Ranges: bytes
	Date: Sun, 14 Dec 2014 15:55:09 GMT
	X-Varnish: 1248919762
	Age: 0
	Via: 1.1 varnish
	Connection: keep-alive

	{"access_token":"af59bf1a037baf3cd256365c02efcdef26d79a12","expires_in":3600,"token_type":"Bearer","scope":"basic api1 api2"}

and now he's able to acces all its resources

	$ curl -i http://localhost:3000/api2.php -d 'access_token=af59bf1a037baf3cd256365c02efcdef26d79a12'
	HTTP/1.1 200 OK
	Server: nginx/1.6.2
	Content-Type: application/json
	X-Powered-By: PHP/5.5.9-1ubuntu4.5
	Content-Length: 52
	Accept-Ranges: bytes
	Date: Sun, 14 Dec 2014 15:55:54 GMT
	X-Varnish: 1248919763
	Age: 0
	Via: 1.1 varnish
	Connection: keep-alive

	{"success":true,"message":"You accessed the API 2!"}

	$ curl -i http://localhost:3000/api1.php -d 'access_token=af59bf1a037baf3cd256365c02efcdef26d79a12'
	HTTP/1.1 200 OK
	Server: nginx/1.6.2
	Content-Type: application/json
	X-Powered-By: PHP/5.5.9-1ubuntu4.5
	Content-Length: 52
	Accept-Ranges: bytes
	Date: Sun, 14 Dec 2014 15:56:17 GMT
	X-Varnish: 1248919764
	Age: 0
	Via: 1.1 varnish
	Connection: keep-alive

	{"success":true,"message":"You accessed the API 1!"}

##Client2

Client2 requires a token

	$ curl -i -u testclient2:testpass http://localhost:3000/token.php -d 'grant_type=client_credentials&scope=basic api3'
	HTTP/1.1 200 OK
	Server: nginx/1.6.2
	Content-Type: application/json
	X-Powered-By: PHP/5.5.9-1ubuntu4.5
	Cache-Control: no-store
	Pragma: no-cache
	Content-Length: 120
	Accept-Ranges: bytes
	Date: Sun, 14 Dec 2014 15:56:48 GMT
	X-Varnish: 1248919765
	Age: 0
	Via: 1.1 varnish
	Connection: keep-alive

	{"access_token":"f47566c92f2d589ed351ea11ab3f9864b2197b18","expires_in":3600,"token_type":"Bearer","scope":"basic api3"}

Client2 requires a token with unauthorized scope

	$ curl -i -u testclient2:testpass http://localhost:3000/token.php -d 'grant_type=client_credentials&scope=basic api1 api3'
	HTTP/1.1 400 Bad Request
	Server: nginx/1.6.2
	Content-Type: application/json
	X-Powered-By: PHP/5.5.9-1ubuntu4.5
	Cache-Control: no-store
	Content-Length: 95
	Accept-Ranges: bytes
	Date: Sun, 14 Dec 2014 15:57:19 GMT
	X-Varnish: 1248919766
	Age: 0
	Via: 1.1 varnish
	Connection: keep-alive

	{"error":"invalid_scope","error_description":"The scope requested is invalid for this request"}

Client2 consumes its valid token on authorized resource

	$ curl -i http://localhost:3000/api3.php -d 'access_token=f47566c92f2d589ed351ea11ab3f9864b2197b18'
	HTTP/1.1 200 OK
	Server: nginx/1.6.2
	Content-Type: application/json
	X-Powered-By: PHP/5.5.9-1ubuntu4.5
	Content-Length: 52
	Accept-Ranges: bytes
	Date: Sun, 14 Dec 2014 15:58:29 GMT
	X-Varnish: 1248919767
	Age: 0
	Via: 1.1 varnish
	Connection: keep-alive

	{"success":true,"message":"You accessed the API 3!"}

Client2 tries to consume an unauthorized resource

	$ curl -i http://localhost:3000/api1.php -d 'access_token=f47566c92f2d589ed351ea11ab3f9864b2197b18'
	HTTP/1.1 401 Unauthorized
	Server: nginx/1.6.2
	Content-Type: application/json
	X-Powered-By: PHP/5.5.9-1ubuntu4.5
	Cache-Control: no-store
	WWW-Authenticate: Bearer realm="Service", scope="api1", error="insufficient_scope", error_description="The request requires higher privileges than provided by the access token"
	Content-Length: 125
	Accept-Ranges: bytes
	Date: Sun, 14 Dec 2014 15:59:11 GMT
	X-Varnish: 1248919768
	Age: 0
	Via: 1.1 varnish
	Connection: keep-alive

	{"error":"insufficient_scope","error_description":"The request requires higher privileges than provided by the access token"}

##Remote Resource Service

_This section shows you the interaction between your Remote Resource Services and the checktoken endpoint of the simple-oauth2-server. Your service should extract the token from the received request and use it to call the simple-oauth2-server._

A remote Resource Service tries to validate a received token and it's not valid

	$ curl -i http://localhost:3000/checktoken.php -d 'access_token=f47566c92f2d589ed351ea11ab3f9864b2197b12'
	HTTP/1.1 401 Unauthorized
	Server: nginx/1.6.2
	Content-Type: application/json
	X-Powered-By: PHP/5.5.9-1ubuntu4.5
	Cache-Control: public, max-age=1800
	WWW-Authenticate: Bearer realm="Service", error="invalid_token", error_description="The access token provided is invalid"
	X-Api-Server-Time: 1418572973
	X-Api-User:
	X-Api-Client:
	X-Api-Context:
	Content-Length: 81
	Accept-Ranges: bytes
	Date: Sun, 14 Dec 2014 16:02:53 GMT
	X-Varnish: 1248919770
	Age: 0
	Via: 1.1 varnish
	Connection: keep-alive

	{"access_token":null,"user_id":null,"client_id":null,"scope":null,"expires":null}

A remote Resource Service tries to validate a received token and it's valid

	$ curl -i http://localhost:3000/checktoken.php -d 'access_token=f47566c92f2d589ed351ea11ab3f9864b2197b18'
	HTTP/1.1 200 OK
	Server: nginx/1.6.2
	Content-Type: application/json
	X-Powered-By: PHP/5.5.9-1ubuntu4.5
	X-Api-Server-Time: 1418572826
	X-Api-User:
	X-Api-Client: testclient2
	X-Api-Context: basic api3
	Cache-Control: public, max-age=1800
	Content-Length: 142
	Accept-Ranges: bytes
	Date: Sun, 14 Dec 2014 16:00:26 GMT
	X-Varnish: 1248919769
	Age: 0
	Via: 1.1 varnish
	Connection: keep-alive

	{"access_token":"f47566c92f2d589ed351ea11ab3f9864b2197b18","user_id":null,"client_id":"testclient2","scope":"basic api3","expires":1418576208}

A remote Resource Service tries to validate a received token enabling cache

	$ curl -i 'http://localhost:3000/checktoken.php?access_token=f47566c92f2d589ed351ea11ab3f9864b2197b18'
	HTTP/1.1 200 OK
	Server: nginx/1.6.2
	Content-Type: application/json
	X-Powered-By: PHP/5.5.9-1ubuntu4.5
	X-Api-Server-Time: 1418573025
	X-Api-User:
	X-Api-Client: testclient2
	X-Api-Context: basic api3
	Cache-Control: public, max-age=1800
	Content-Length: 142
	Accept-Ranges: bytes
	Date: Sun, 14 Dec 2014 16:03:45 GMT
	X-Varnish: 1248919771
	Age: 0
	Via: 1.1 varnish
	Connection: keep-alive

	{"access_token":"f47566c92f2d589ed351ea11ab3f9864b2197b18","user_id":null,"client_id":"testclient2","scope":"basic api3","expires":1418576208}

So next time any Resource Service tries to do the same, it will get a cached response

	$ curl -i 'http://localhost:3000/checktoken.php?access_token=f47566c92f2d589ed351ea11ab3f9864b2197b18'
	HTTP/1.1 200 OK
	Server: nginx/1.6.2
	Content-Type: application/json
	X-Powered-By: PHP/5.5.9-1ubuntu4.5
	X-Api-Server-Time: 1418573025
	X-Api-User:
	X-Api-Client: testclient2
	X-Api-Context: basic api3
	Cache-Control: public, max-age=1800
	Content-Length: 142
	Accept-Ranges: bytes
	Date: Sun, 14 Dec 2014 16:04:39 GMT
	X-Varnish: 1248919772 1248919771
	Age: 54
	Via: 1.1 varnish
	Connection: keep-alive

	{"access_token":"f47566c92f2d589ed351ea11ab3f9864b2197b18","user_id":null,"client_id":"testclient2","scope":"basic api3","expires":1418576208}
