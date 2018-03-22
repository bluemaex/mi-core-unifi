# This script will try to manage the ssl certificates for us, we support
# own ssl certificates, let's encrypt and selfsigned fallbacks for dev
# usage

# Request and manage SSL certificates
/opt/core/bin/ssl-generator.sh /opt/local/etc/nginx/ssl nginx_ssl nginx svc:/pkgsrc/nginx:default

# Add generated SSL to Unifi Controller
/opt/core/bin/ssl-unifi.sh

# Add the unifi script to the letsencrypt renew hook if used
if [[ -r "/opt/local/etc/letsencrypt/renew-hook.sh" ]]; then
   echo '/opt/core/bin/ssl-unifi.sh' >> /opt/local/etc/letsencrypt/renew-hook.sh
fi
