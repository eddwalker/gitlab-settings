#!/bin/sh

# Ensure presence.
mkdir -p /data/squid/cache
mkdir -p /data/squid/log
touch /data/squid/log/access.log
touch /data/squid/log/store.log
touch /data/squid/log/cache.log

# Ensure permissions.
chown proxy:proxy /data/squid/cache
chown root:root   /data/squid/log
chown proxy:proxy /data/squid/log/access.log
chown proxy:proxy /data/squid/log/store.log
chown proxy:proxy /data/squid/log/cache.log

sed -i'' /etc/squid-deb-proxy/squid-deb-proxy.conf \
    -e 's/^http_access deny/#http_access deny/' \
    -e 's/^cache deny/#cache deny/'
    
# Start the proxy.
/etc/init.d/squid-deb-proxy restart

# Watch the log.
echo -n > /var/log/squid-deb-proxy/access.log
tail -f   /var/log/squid-deb-proxy/access.log
