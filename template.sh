#!/usr/bin/bash

## Cloudflare authentication details
## Keep these private
cloudflare_auth_email=Your_Email
cloudflare_auth_key="Your_API_Token"
zoneid="Your_Zone_ID"

## Cloudflare Proxied DNS Records as Array
dnsrecords_proxied=(
    "domain.com"
    "www.domain.com"
    "sub1.domain.com"
    "sub2.domain.com"
    "sub3.domain.com"
    "sub3.domain.com"
    )
    
## Cloudflare Non-Proxied DNS Records as Array
dnsrecords_not_proxied=(
    "vpn01.domain.com"
    "vpn02.domain.com"
    )

## Files to log to (replace "path/to/" with script path)
log=path/to/log.log
log_ip=path/to/previous_ip
## Getting Date/Time
dt=$(date '+%d/%m/%Y %H:%M:%S')
## Get old IP from file
old_ip=$(cat $log_ip)
## Get the current external IP address
ip=$(curl -s -X GET https://api.ipify.org)

## Checking if IP changed since last update
if [[ ! $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]] || [ $ip = $old_ip ]; then
echo -en "$dt - Previous IP:$old_ip\n$dt - Current  IP:$ip\n$dt - No Changes Required....\n" >> $log
echo "$(tail -n 1000 $log)" > $log
  exit
  ## Exit if IP has not changed
else
## If the IP changed, not match the one on file "previous_ip"
echo -en "$dt - Previous IP:$old_ip\n$dt - Current  IP:$ip\n$dt - Starting Updates....\n" >> $log
## Processing Proxied DNS Records
for dnsrecord in "${dnsrecords_proxied[@]}"
do

## For each DNS Record in Array "dnsrecords"

# Getting the DNS Record ID
dnsrecordid=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$zoneid/dns_records?type=A&name=$dnsrecord" \
  -H "X-Auth-Email: $cloudflare_auth_email" \
  -H "Authorization: Bearer $cloudflare_auth_key" \
  -H "Content-Type: application/json" | jq -r  '{"result"}[] | .[0] | .id') &&

# Updating the DNS Record
curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$zoneid/dns_records/$dnsrecordid" \
  -H "X-Auth-Email: $cloudflare_auth_email" \
  -H "Authorization: Bearer $cloudflare_auth_key" \
  -H "Content-Type: application/json" \
  --data "{\"type\":\"A\",\"name\":\"$dnsrecord\",\"content\":\"$ip\",\"ttl\":1,\"proxied\":true}" | jq
echo -en "$dt - Updated - $dnsrecord \n"  >> $log
done

## Processing Non Proxied DNS Records
for dnsrecord in "${dnsrecords_not_proxied[@]}"
do

## For each DNS Record in Array "dnsrecords"

# Getting the DNS Record ID
dnsrecordid=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$zoneid/dns_records?type=A&name=$dnsrecord" \
  -H "X-Auth-Email: $cloudflare_auth_email" \
  -H "Authorization: Bearer $cloudflare_auth_key" \
  -H "Content-Type: application/json" | jq -r  '{"result"}[] | .[0] | .id') &&

# Updating the DNS Record
curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$zoneid/dns_records/$dnsrecordid" \
  -H "X-Auth-Email: $cloudflare_auth_email" \
  -H "Authorization: Bearer $cloudflare_auth_key" \
  -H "Content-Type: application/json" \
  --data "{\"type\":\"A\",\"name\":\"$dnsrecord\",\"content\":\"$ip\",\"ttl\":1,\"proxied\":false}" | jq
echo -en "$dt - Updated - $dnsrecord \n"  >> $log
done
echo $ip > $log_ip
echo -en "$dt - Updates Completed.... \n"  >> $log
echo "$(tail -n 1000 $log)" > $log
fi
