#! /bin/bash
cd $(dirname $0)

# The zone file with the custom rule you want to update
ZONEFILE="/etc/firewalld/zones/public.xml"
# This template needs to be created in advance and have the IP address replaced with DDNS_IPADDRESS
ZONEFILE_TEMPLATE="/etc/firewalld/zones/public.xml.TEMPLATE"

# Using positional vars $1 domain name $2 zone
DYN_NAME="$1"

# NEWIP - use first record returned by dig if multiple
NEWIP=$(/usr/bin/dig $DYN_NAME +short | head -1)

# Check response from dig - must not be empty (not resolved / no connection) 
function fn_dig_check ()
if [[ $NEWIP == "" ]];
 then
  logger update_trusted_source.sh:error:domain not resolved domain=$DYN_NAME zone=$zone
  exit 2
fi


# Check if old ip is different than new ip
function fn_update ()
{
OLDIP=$(/bin/cat ./ip_of_$DYN_NAME 2>/dev/null)
if [ "$NEWIP" == "$OLDIP" ];
 then
  exit 1
 else
  echo "New IP address found for $DYN_NAME - $NEWIP"
  fn_update_action
fi
}

# Copy a firewalld template over the active one and swap out the IP address.
function fn_update_action ()
{
  echo "Copying $ZONEFILE_TEMPLATE over $ZONEFILE"
  cp $ZONEFILE_TEMPLATE $ZONEFILE
  echo "Updating IP in firewall rule $ZONEFILE"
  sed -i 's/DDNS_IPADDRESS/'$NEWIP'/g' $ZONEFILE
  cat $ZONEFILE
  echo $NEWIP > ./ip_of_$DYN_NAME
  systemctl restart firewalld
  logger update_trusted_source.sh:info:rule changed ip added domain=$DYN_NAME zone=$zone NEWIP=$NEWIP
  
}

fn_dig_check
fn_update
exit
