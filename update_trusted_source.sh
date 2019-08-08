#! /bin/bash
cd $(dirname $0)

# The zone file with the custom rule you want to update
ZONEFILE="/etc/firewalld/zones/public.xml"
# This template needs to be created in advance and have the IP address replaced with DDNS_IPADDRESS
ZONEFILE_TEMPLATE="/etc/firewalld/zones/public.xml.TEMPLATE"

# Using positional vars $1 domain name $2 zone
dyn_name="$1"
# defaults to trusted zone
if [[ $2 = "" ]];
 then
  zone="public"
 else
  zone="$2"
fi

# newip - use first record returned by dig if multiple
newip=$(/usr/bin/dig $dyn_name +short | head -1)


# Check response from dig - must not be empty (not resolved / no connection) 
function fn_dig_check ()
if [[ $newip == "" ]];
 then
  logger update_trusted_source.sh:error:domain not resolved domain=$dyn_name zone=$zone
  exit 2
fi


# Check if old ip is different than new ip
function fn_update ()
{
oldip=$(/bin/cat ./ip_of_$dyn_name 2>/dev/null)
if [[ $newip = $oldip ]];
 then
  echo "IP has not changed - exiting"
  exit 2
 else
  echo "New IP address found for $1 - $newip"
  fn_update_action
fi
}

# Copy a firewalld template over the active one and swap out the IP address.
function fn_update_action ()
{
  echo "Copying $ZONEFILE_TEMPLATE over $ZONEFILE"
  cp $ZONEFILE_TEMPLATE $ZONEFILE
  echo "Updating IP in firewall rule $ZONEFILE"
  sed -i 's/DDNS_IPADDRESS/'DDNS_IPADDRESS'/g' $ZONEFILE
  cat $ZONEFILE
  echo $newip > ./ip_of_$dyn_name
  systemctl restart firewalld
  logger update_trusted_source.sh:info:rule changed ip added domain=$dyn_name zone=$zone newip=$newip
  
}

fn_dig_check
fn_update
exit
