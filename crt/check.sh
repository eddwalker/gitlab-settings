#!/usr/bin/env bash
# Desc: script waits ssl port is up and ask you password for gitlab to ensure you can Login Succeeded
# Run:  on any machine (with installed gitlab cert if this sert is self-signed)
# Usage: ./$0 (gitlab-hostname:sslport) (username)

dest=${1:-gitlab.local:443} 
user=${2:-root}

date
printf "%s " "Waiting for service at $dest"
while true
do 
   out="$(echo | openssl s_client  -connect $dest 2>&1)"
   if [[ $out =~ (Error|:error:) ]]
   then
     printf "%s" "."
     sleep 1.2
     continue
   fi
   printf "SSL output: %s\n" "$out"
   printf "Login as %s:\n"   "$user"
   docker login -u $user $dest
   break
done
