# SSLPinning

[Reference](https://www.raywenderlich.com/1484288-preventing-man-in-the-middle-attacks-in-ios-with-ssl-pinning)

##### SSL Certificate Pinning Under the Hood
SSL Certificate Pinning, or pinning for short,
is the process of associating a host with its certificate or public key.
Once you know a host’s certificate or public key, you pin it to that host.
In other words, you configure the app to reject all but one or a few predefined certificates or public keys.
Whenever the app connects to a server,
it compares the server certificate with the pinned certificate(s) or public key(s).
If and only if they match, the app trusts the server and establishes the connection.
You usually add a service’s certificate or public key at development time. 
In other words, your mobile app should include the digital certificate or the public key within your app’s bundle.
This is the preferred method, since an attacker cannot taint the pin.

##### Why Do You Need SSL Certificate Pinning?
Usually, you delegate setting up and maintaining TLS sessions to iOS. 
This means that when the app tries to establish a connection,
it doesn’t determine which certificates to trust and which not to. 
The app relies entirely on the certificates that the iOS Trust Store provides.
This method has a weakness, however: An attacker can generate a self-signed certificate and
include it in the iOS Trust Store or hack a root CA certificate.
This allows such an attacker to set up a man-in-the-middle attack and 
capture the transmitted data moving to and from your app.

Restricting the set of trusted certificates through pinning prevents attackers from analyzing the
functionality of the app and the way it communicates with the server.
