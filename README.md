# simple pki MAKEer

## Preq

- OpenSSL (LibreSSL is default on MacOS and won't work!)
- kubectl for uploading secret

## Init PKI
```
make init
```
## Create Server Certificate
```
make server_cert CN=testCert SAN="DNS:bla1.testCert, DNS:bla2.testCert"
```
## Get server cert info
```
make cert_info CN=server
```

## Upload server certificate as K8 secret 
```
make k8_secret CN=server NAME=server NAMESPACE=cluster1-uboot-cluster
```