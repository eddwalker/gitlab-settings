=== APT Proxy Server

Taken from https://github.com/sameersbn/docker-apt-cacher-ng

== Proxy stats and options

http://localhost:3142/acng-report.html
||
http://10.10.9.169:3142/acng-report.html


== Setup proxy for APT clients

Put into /etc/apt/apt.conf.d/01proxy with the following content:

Acquire::HTTP::Proxy "http://10.10.9.169:3142";
Acquire::HTTPS::Proxy "false";


== Setup proxy in Docker

Similarly, to use Apt-Cacher NG in you Docker containers add the following line
to your Dockerfile before any apt-get commands.

RUN echo 'Acquire::HTTP::Proxy "http://10.10.9.169:3142";' >> /etc/apt/apt.conf.d/01proxy \
 && echo 'Acquire::HTTPS::Proxy "false";' >> /etc/apt/apt.conf.d/01proxy


== Setup proxy for curl or wget

Variable case is not important:

export http_proxy="http://10.10.9.169:3142"
export https_proxy="http://10.10.9.169:3142"

Where:
  - 10.10.9.169 is 'ip address' of Docker node running apt proxy ng image
  - 3142 is 'port' from docker-compose.yaml

Typically, the configuration provided above is sufficient for tools like curl or wget to automatically detect the proxy server.
However, if you need to explicitly specify the proxy server, you can use the following options:

curl -svx $http_proxy https://ifconfig.me 2>&1    | grep -E '([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)' ; printf '\n'
||
curl -svx $https_proxy https://ifconfig.me 2>&1   | grep -E '([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)' ; printf '\n'
||
wget -O- --proxy=on -vvv https://ifconfig.me 2>&1 | grep -E '([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)'
