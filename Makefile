
init: clean
	# Create dirs
	mkdir -p ca/root-ca/private ca/root-ca/db crl certs
	chmod 700 ca/root-ca/private

	# Create database
	cp /dev/null ca/root-ca/db/root-ca.db
	cp /dev/null ca/root-ca/db/root-ca.db.attr
	echo 01 > ca/root-ca/db/root-ca.crt.srl
	echo 01 > ca/root-ca/db/root-ca.crl.srl

	# Create Root CA
	openssl req -new \
    -config config/root-ca.conf \
    -out ca/root-ca.csr \
    -keyout ca/root-ca/private/root-ca.key

	openssl ca -selfsign \
    -config config/root-ca.conf \
    -in ca/root-ca.csr \
    -out ca/root-ca.crt \
    -extensions root_ca_ext

	# Create Signing CA
	mkdir -p ca/signing-ca/private ca/signing-ca/db crl certs
	chmod 700 ca/signing-ca/private
	cp /dev/null ca/signing-ca/db/signing-ca.db
	cp /dev/null ca/signing-ca/db/signing-ca.db.attr
	echo 01 > ca/signing-ca/db/signing-ca.crt.srl
	echo 01 > ca/signing-ca/db/signing-ca.crl.srl

	openssl req -new \
    -config config/signing-ca.conf \
    -out ca/signing-ca.csr \
    -keyout ca/signing-ca/private/signing-ca.key

	openssl ca \
    -config config/root-ca.conf \
    -in ca/signing-ca.csr \
    -out ca/signing-ca.crt \
    -extensions signing_ca_ext

server_cert:

	openssl req -new \
		-config config/server.conf \
		-out certs/${CN}.csr \
		-keyout certs/${CN}.key
	
	openssl ca \
		-config config/signing-ca.conf \
		-in certs/${CN}.csr \
		-out certs/${CN}.crt \
		-extensions server_ext

cert_info:

	openssl x509 -in certs/${CN}.crt -text


k8_secret:
	kubectl create secret tls ${NAME} \
		--key certs/${CN}.key \
		--cert certs/${CN}.crt \
		-n ${NAMESPACE}


clean:
	rm -rf ca/
	rm -rf crl
	rm -rf certs