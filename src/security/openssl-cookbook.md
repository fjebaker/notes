# OpenSSL Cookbook

OpenSSL is a very comprehensive and complete command line tool, which I started using during my IoT learning. I will document here, the commands that I find particularly useful.

<!--BEGIN TOC-->
## Table of Contents
1. [Becoming a Certificate Authority](#becoming-a-certificate-authority)
    1. [Preparing the environment](#preparing-the-environment)
    2. [Creating the Root key and certificate](#creating-the-root-key-and-certificate)
2. [Starting an SSL/TLS Server](#starting-an-ssl/tls-server)
3. [Accessing an SSL/TLS server](#accessing-an-ssl/tls-server)

<!--END TOC-->

A small note; all the private directories and files (mainly keys) should be `chmod 400`, though I leave this out as it becomes tedious to include everywhere.

## Becoming a Certificate Authority
Following [this guide](https://jamielinux.com/docs/openssl-certificate-authority/create-the-root-pair.html), becoming a CA with OpenSSL is very straight forward. It notes that the root key should only be used to create new CAs, which sign on behalf of the root -- the root should be used as rarely as possible.

### Preparing the environment
We will organise our environment as
```bash
mkdir certs crl newcerts private  \
    && touch index.txt \
    && echo 1000 > serial
```

Next we will create a configuration file that OpenSSL will read. As we wish to become a CA, we will format it as such
```
[ ca ]
# `man ca`
default_ca = CA_default

[ CA_default ]
# Directory and file locations.
dir               = ROOT_DIRECTORY
certs             = $dir/certs
crl_dir           = $dir/crl
new_certs_dir     = $dir/newcerts
database          = $dir/index.txt
serial            = $dir/serial
RANDFILE          = $dir/private/.rand

# The root key and root certificate.
private_key       = $dir/private/ca.key.pem
certificate       = $dir/certs/ca.cert.pem

# For certificate revocation lists.
crlnumber         = $dir/crlnumber
crl               = $dir/crl/ca.crl.pem
crl_extensions    = crl_ext
default_crl_days  = 30

default_md        = sha256

name_opt          = ca_default
cert_opt          = ca_default
default_days      = 375
preserve          = no
policy            = policy_strict
```
Note that you must set `dir` with your `ROOT_DIRECTORY`. We can now define different policies for our keys; `policy_strict` dictates the root certificate should only be used to create intermediate certificates:

```
[ policy_strict ]
# See the POLICY FORMAT section of `man ca`.
countryName             = match
stateOrProvinceName     = match
organizationName        = match
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional
```
We use `policy_loose` for the created intermediate certificate authorities:
```
[ policy_loose ]
# See the POLICY FORMAT section of the `ca` man page.
countryName             = optional
stateOrProvinceName     = optional
localityName            = optional
organizationName        = optional
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional
```
Now we configure the `req` section, used when requesting the creation or signing of certificates
```
[ req ]
# Options for the `req` tool (`man req`).
default_bits        = 2048
distinguished_name  = req_distinguished_name
string_mask         = utf8only

default_md          = sha256

# Extension to add when the -x509 option is used.
x509_extensions     = v3_ca
```
The next section declares the information required during a [certificate signing request](https://en.wikipedia.org/wiki/Certificate_signing_request)
```
[ req_distinguished_name ]
countryName                     = Country Name (2 letter code)
stateOrProvinceName             = State or Province Name
localityName                    = Locality Name
0.organizationName              = Organization Name
organizationalUnitName          = Organizational Unit Name
commonName                      = Common Name
emailAddress                    = Email Address
```
The remaining sections specify different flags when signing certificates, such as `v3_ca` for X509s.

The full configuration file is available [in my notes](https://github.com/febk/notes/blob/master/security/openssl.cnf).

### Creating the Root key and certificate
The root key (private) and root certificate (public) can be created with a passphrase; in the root directory, run
```bash
openssl genrsa -aes256 -out private/ca.key.pem 4096
```

We now request a root certificate from our key: in OpenSSL, when using the `req` command, you must include the configuration file in a flag
```bash
openssl req -config openssl.cnf \
      -key private/ca.key.pem \
      -new -x509 -days 7300 -sha256 -extensions v3_ca \
      -out certs/ca.cert.pem
```

We can verify the root certificate with
```bash
openssl x509 -noout -text -in certs/ca.cert.pem
```
which will print the signature algorithm used, the validity dates, the public key length, the issuer and the subject, which in our case will be identical, since this is self signed.

## Starting an SSL/TLS Server
Using the directory configuration from the previous section on becoming a CA, we can start an OpenSSL server using just the root key and certificate
```
openssl s_server -key private/ca.key.pem  -cert certs/ca.cert.pem -accept 4433 -www
```
now listening on 4433. Visit [locahost:4433](https://localhost:4433) to see the response from the server.

## Accessing an SSL/TLS server
We can access any server with 
```
openssl s_client -connect localhost:4433
```
which will print the certificate chain into the console.