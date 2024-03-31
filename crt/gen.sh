#!/usr/bin/env bash
# Desc: Create self-signed certs for gitlab and configure docker/curl for it
# Run: as root on node with docker for gitlab
# Note: you must add NS A record or static line in /etc/hosts for gitlab host i.e. gitlab.local 

set -e

# openssl s_client -showcerts -verify 5 -connect gitlab.local:443 < /dev/null 2>/dev/null | openssl x509 -outform PEM | tee ~/docker-com.crt
# cp ~/docker-com.crt /etc/docker/certs.d/gitlab.local/
# systemctl restart docker

name=gitlab.local
days=3650
type=rsa:4096
docker_cert_dir=/etc/docker/certs.d/$name
ca_cert_dir=/usr/local/share/ca-certificates/


printf "%s\n" "Check DNS.."
if nslookup $name 1>/dev/null 2>&1 ; then
  echo "OK: DNS found for name=$name"
else
  echo "Error: DNS canot be resolver, NS A record or static line in /etc/hosts. try:"
  echo "       echo '$(hostname -i) $name' >> /etc/hosts"
  echo ".. and run again"
fi

printf "%s\n" "Create cert.."
openssl req \
  -x509               \
  -nodes              \
  -sha256             \
  -days   $days       \
  -newkey $type       \
  -keyout $name.key   \
  -out    $name.crt   \
  -subj   "/CN=$name" \
  -extensions san     \
  -config <(echo '[req]'; echo "distinguished_name=req";
            echo '[san]'; echo "subjectAltName=DNS:$name,DNS:*.$name")

chmod 600 $name.*

printf "%s\n" "Cert details:"
openssl x509 \
  -in $name.crt \
  -noout \
  -text \
| grep -E '(Issuer:|Not Before|Not After|Subject:|Public-Key:|DNS:|Signature Algorithm:)'

printf "%s\n" "Copy cert to docker certs.."
mkdir -p $docker_cert_dir
rsync -a $name.crt $docker_cert_dir/

printf "%s\n" "Restart docker.."
systemctl restart docker

printf "%s\n" "Copy cert to ca certs.. $ca_cert_dir"
rsync -a $name.crt $ca_cert_dir

printf "%s\n" "Update ca certs.."
update-ca-certificates

printf "%s\n" "OK"
