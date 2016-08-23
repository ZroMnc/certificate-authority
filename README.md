# Certificate Authority

Builds your very own certificate authority for local development 

This tool creates a fake root and intermediate ca base on the two openssl configuration files `root.cnf` and `intermedieate.cnf`.

## How to use it
Very simple.
```bash
$ ./create-ca.sh
```
This will create two directories `./root` and `./intermediate` and holding the appropriate files. If you want some more details
just read this blog post - this is pretty much an implementation like [this](https://jamielinux.com/docs/openssl-certificate-authority/).

Done!

## Next Steps
* Create a CSR and have the intermediate cert sign it

## Kudos
* [jamielinux]((https://jamielinux.com/docs/openssl-certificate-authority/) for the tutorial and helping me understand.
* [kintoandar](https://github.com/kintoandar) for the basic script.

## WARNING:
DO NOT USE THIS IN PRODUCTION!
