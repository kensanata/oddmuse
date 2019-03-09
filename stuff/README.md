Extra Files
===========

Some of the modules requires extra files -- graphics, templates, and
so on.

Gopher Server
-------------

Example usage:

Change your working directory to the root of the Oddmuse repository
(the parent directory of this directory).

Set the environment variable `WikiDataDir` to `test-data`:

```
export WikiDataDir=test-data
```

Test that the simple web server works by running `stuff/server.pl`.
This should start the web server on `http://localhost:8080/`. Visit
the link using your web browser and edit `HomePage`.

You should see a `test-data` directory containing the new page.

Now start the gopher server on port 7070 by running
`stuff/gopher-server.pl --port=7070`. If you don't provide an explicit
port a random port is used and you'll need to read the server output
to determine the actual port. That's why we're setting the port
ourselves. Remember that using ports below 1024 require special
privileges. Don't use them unless you know what you're doing.

Test the gopher server by simulating a request using `echo HomePage |
nc localhost 7070`. You should get back the content of the page you
wrote.

Let's test encryption. Create a self-signed certificate and a private
key. If you use the following command, you can leave all the fields
empty except for the common name. The common name you provide must
match the server name you are using. In our case, that would be
`localhost`.

```
openssl req -new -x509 -days 365 -nodes -out \
        gopher-server-cert.pem -keyout gopher-server-key.pem
```

Start the gopher server on port 7443 using this information with
`stuff/gopher-server.pl --port=7443
--wiki_key_file=gopher-server-key.pem
--wiki_cert_file=gopher-server-cert.pem`.

If you test this by simulating an unencrypted request using `echo
HomePage | nc localhost 7443`, you shouldn't get any output. Use `echo
HomePage | gnutls-cli --no-ca-verification localhost:7443` and you
should get back your page. Actually, you have the certificate right
there so you might as well provide it: `echo HomePage | gnutls-cli
--x509cafile=gopher-server-cert.pem localhost:7443`

What you'd expect to see is a lot of cryptography output by
`gnutls-cli` and at the very end the content of the page. If you're
seeing `Fatal error: Error in the pull function` instead, then perhaps
the timing of things is a bit off. Introducing a short wait fixed this
for me. `(sleep 1;echo HomePage) | gnutls-cli
--x509cafile=gopher-server-cert.pem localhost:7443`

Good luck!
