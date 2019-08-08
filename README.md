Bash script that maintaines source ip based on domain name in firewalld. 


install bind-utils first
```
yum -y install bind-utils
```

Copy your firewalld zone file (e.g. public.xml) to a new file called public.xml.TEMPLATE, and replace the IP address in your custom rule for the DDNS IP address with the text ````DDNS_IPADDRESS````. The custom rule section should look something like this:
```
  <rule family="ipv4">
    <source address="DDNS_IPADDRESS"/>
    <port protocol="tcp" port="1234"/>
    <accept/>
  </rule>
````

Script is called followed by domain name. 
```
./update_trusted_source.sh example.com
```

Set up cron job to run it specific intervals, like 5 min. or so.
```
*/5 * * * * /path/to/update_trusted_source.sh example.com
```


How about adding more than one source? 

Use wrapper around this script.

Use file "domains" and append them one per line.

Then run it with:
```
./update_trusted_source_wrapper.sh
```

