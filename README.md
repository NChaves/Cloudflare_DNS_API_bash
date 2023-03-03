# Cloudflare_DNS_API_bash
Script to update Cloudflare DNS records as Cronjob

## Editing different sections of the script.

## ## Cloudflare authentication details
On the below section, you need to update the script with your Cloudflare account details. This includes email address, API token and the Zone ID that you want to keep updated.

```
## Keep these private
cloudflare_auth_email=Your_Email
cloudflare_auth_key="Your_API_Token"
zoneid="Your_Zone_ID"
```

Zone ID can be found in the overview page of your selected zone. Once in the zone overview, you can find the Zone ID at the bottom-right of the page.
Just below the Zone ID, and Account ID, you can then also create a new API Token.

We created an API token with permissions as below;

```
All zones - DNS:Read, DNS:Edit
```

## ## Cloudflare Proxied DNS Records as Array
This section is an array of domain name entries, here you list the “A” records to be updated by the script.

```
dnsrecords_proxied=(
"domain.com"
"www.domain.com"
"sub1.domain.com"
"sub2.domain.com"
"sub3.domain.com"
"sub3.domain.com"
)
```

The above array is named “*_proxied”, this refers to the A records that you want the “Proxy status“ to be set as “Proxied”.
There are cases where you do not want a record to be proxied, add those records to the next array.

## ## Cloudflare Non-Proxied DNS Records as Array
This next array, “*_not_proxied” you use for DNS records you do not want to proxy through Cloudflare. In the example below, there are a couple of records that are specifically for use with a VPN server.

```
dnsrecords_not_proxied=(
"vpn01.domain.com"
"vpn02.domain.com"
)
```

Leave the array empty if you do not have any records you want to set as “DNS only”.

## ## Files to log to (replace “path/to/” with script path)
Next, you need to replace the “path/to/” with the path to the directory you chose to put your script in. For this example, we would change “path/to/log.log” to “/home/filebrowser/cloudflare/log.log”.

```
log=path/to/log.log
log_ip=path/to/previous_ip
```

The above will allow the script to store the current IP and logs of each run.

You can also rename the files used, making them unique to the script, would suggest changing “log.log” to “template_log.log” and “previous_ip” to “template_previous_ip”. Recommended if running multiple copies of the script for different Cloudflare zones.

The script logs the last 1000 entries, you can increase or decrease the number of lines saved by changing the lines below;

```
echo "$(tail -n 1000 $log)" > $log
```

You will find them in lines 38 and 87 of the script.

See [this article](https://cloudtechtips.com/linux/script-to-update-cloudflare-dns-records-as-cronjob/937/) for more info on how to run it as a cronjob.
