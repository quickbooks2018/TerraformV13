#!/bin/bash
# Maintainer <Muhammad Asim quickbooks2018@gmail.com>
# Update route53 record for Eureka-Services
localip=$(curl -fs http://169.254.169.254/latest/meta-data/local-ipv4)
hostedzoneid="kkkallskshhgAAbbshhAA"
file=/tmp/record.json

# Multiple Services

# Shirt Service

cat << EOF > $file
{
  "Comment": "Update the A record set",
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "shirt.cloudgeeks.ca.local",
        "Type": "A",
        "TTL": 10,
        "ResourceRecords": [
          {
            "Value": "$localip"
          }
        ]
      }
    }
  ]
}
EOF

aws route53 change-resource-record-sets --hosted-zone-id $hostedzoneid --change-batch file://$file

# Shopping Cart Service

cat << EOF > $file
{
  "Comment": "Update the A record set",
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "shopping-cart.cloudgeeks.ca.local",
        "Type": "A",
        "TTL": 10,
        "ResourceRecords": [
          {
            "Value": "$localip"
          }
        ]
      }
    }
  ]
}
EOF

aws route53 change-resource-record-sets --hosted-zone-id $hostedzoneid --change-batch file://$file

#END
