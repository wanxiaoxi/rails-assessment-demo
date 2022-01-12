# README

## Rails Demo - Event Log Parser

### Requirements
- parse serially submitted event logs
- get the source and destination IP of each event
  - indicate if IP address is valid (bonus)
  - indicate if IP address is public or private (bonus)
- ability to see all parsed logs and delete them
- CRUD comments (enumerable) for each event (bonus)

### Submission Comments
- Opted to orient the front-end as a rest api, since I don't have a GUI background for html/css.
- Main parse implementation is under app/models/event.rb

## API Summary
```
URI     Pattern

POST    /api/v1/events
GET     /api/v1/events
GET     /api/v1/events/:id
DELETE  /api/v1/events/:id
GET     /api/v1/events/delete_all

POST    /api/v1/events/:event_id/comments
GET     /api/v1/events/:event_id/comments
GET     /api/v1/events/:event_id/comments/:id
PUT     /api/v1/events/:event_id/comments/:id
DELETE  /api/v1/events/:event_id/comments/:id
GET     /api/v1/events/:event_id/comments/delete_all
```

### EC2 URI
```
http://ec2-54-218-248-24.us-west-2.compute.amazonaws.com/api/v1/events
```

## CLI (bash + jq) examples

Note: Set EC2 URL as local env var
```
$ URI=http://ec2-54-218-248-24.us-west-2.compute.amazonaws.com/api/v1/events
```

##### Submit a single event log to the service
```
$ curl -X POST $URI -d "<37>CEF:0|TippingPoint|UnityOne|1.0.0.17|7610|Adlumin RepDV Manual Block|1|app=IP cnt=3 dst=52.10.98.6 dpt=443 act=Block cn1=0 cn1Label=VLAN ID cn2=33554431 cn2Label=Taxonomy cn3=0 cn3Label=Packet Trace cs1=WCU-External-Outbound cs1Label=Profile Name cs2=6e664408-b90a-48e2-9a2d-c01cb9258381 cs2Label=Policy UUID cs3=00000001-0001-0001-0001-000000007610 cs3Label=Signature UUID cs4=1-1B 1-1A cs4Label=ZoneNames cs5=TipSMS cs5Label=SMS Name dvchost=PAS-TIP2600NX-01 cs6=50.227.44.198 cs6Label=Filter Message Parms src=50.227.44.198 spt=10162 externalId=19278229 rt=1539348361056 cat=Reputation proto=IP deviceInboundInterface=3 c6a2= c6a2Label=Source IPv6 c6a3= c6a3Label=Destination IPv6 request= requestMethod= dhost= sourceTranslatedAddress=50.227.44.198 c6a1= c6a1Label=Client IPv6 suser= sntdom= duser= dntdom="
```

##### Loop through a list of newline-separated event log texts and submit them to the service
```
$ cat sample_events.txt | while read line; do curl -X POST $URI -d "$line" ; done
```

##### Get events in which the source IP is private and display their object id, summary, raw data.
``` 
$ curl -X GET $URI | jq '.[] | select(.summary.source_ip_private == true) | {"id": .id, "summary": .summary, "raw": .raw}'
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 13977    0 13977    0     0  1516k      0 --:--:-- --:--:-- --:--:-- 1516k
{
  "id": "085ff34a-0a65-4c7f-bb9c-d4c2aa7a7760",
  "summary": {
    "source_ip": "192.168.1.50",
    "source_ip_valid": true,
    "source_ip_private": true,
    "destination_ip": "72.44.211.23",
    "destination_ip_valid": true,
    "destination_ip_private": false
  },
  "raw": "<36>CEF:0|TippingPoint|UnityOne|1.0.0.17|560|0560: TCP: Version Request (TCP)|4|app=TCP cnt=1 dst=72.44.211.23 dpt=443 act=Block cn1=0 cn1Label=VLAN ID cn2=84084733 cn2Label=Taxonomy cn3=0 cn3Label=Packet Trace cs1=WCU-External-Inbound cs1Label=Profile Name cs2=00000002-0002-0002-0002-000000000560 cs2Label=Policy UUID cs3=00000001-0001-0001-0001-000000000560 cs3Label=Signature UUID cs4=6A 6B cs4Label=ZoneNames cs5=TipSMS cs5Label=SMS Name dvchost=Phoenix-1400N-1 cs6= cs6Label=Filter Message Parms src=192.168.1.50 spt=52669 externalId=19277738 rt=1539337861062 cat=Reconnaissance proto=TCP deviceInboundInterface=11 c6a2= c6a2Label=Source IPv6 c6a3= c6a3Label=Destination IPv6 request= requestMethod= dhost=DTM-AdluminMBP sourceTranslatedAddress=192.168.1.50 c6a1= c6a1Label=Client IPv6 suser= sntdom= duser= dntdom="
}
{
  "id": "11b4a9ca-4498-44d1-b999-edfc818e9c0f",
  "summary": {
    "source_ip": "10.0.1.175",
    "source_ip_valid": true,
    "source_ip_private": true,
    "destination_ip": "185.26.219.34",
    "destination_ip_valid": true,
    "destination_ip_private": false
  },
  "raw": "<36>CEF:0|TippingPoint|UnityOne|1.0.0.17|560|0560: TCP: Version Request (TCP)|4|app=TCP cnt=1 dst=185.26.219.34 dpt=443 act=Block cn1=0 cn1Label=VLAN ID cn2=84084733 cn2Label=Taxonomy cn3=0 cn3Label=Packet Trace cs1=WCU-External-Inbound cs1Label=Profile Name cs2=00000002-0002-0002-0002-000000000560 cs2Label=Policy UUID cs3=00000001-0001-0001-0001-000000000560 cs3Label=Signature UUID cs4=6A 6B cs4Label=ZoneNames cs5=TipSMS cs5Label=SMS Name dvchost=Phoenix-1400N-1 cs6= cs6Label=Filter Message Parms src=10.0.1.175 spt=52669 externalId=19277738 rt=1539337861062 cat=Reconnaissance proto=TCP deviceInboundInterface=11 c6a2= c6a2Label=Source IPv6 c6a3= c6a3Label=Destination IPv6 request= requestMethod= dhost=DTM-AdluminMBP sourceTranslatedAddress=10.0.1.175 c6a1= c6a1Label=Client IPv6 suser= sntdom= duser= dntdom="
}
```

##### Get an individual event
```
$ curl -X GET $URI/9ecdc00d-c6b6-45b4-af71-9ac45782ec33 | jq
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  2128    0  2128    0     0   415k      0 --:--:-- --:--:-- --:--:--  415k
{
  "summary": {
    "source_ip": "50.227.44.198",
    "source_ip_valid": true,
    "source_ip_private": false,
    "destination_ip": "52.10.98.6",
    "destination_ip_valid": true,
    "destination_ip_private": false
  },
  "details": {
    "eventHeadings": [
      "CEF:0",
      "TippingPoint",
      "UnityOne",
      "1.0.0.17",
      "7610",
      "Adlumin RepDV Manual Block",
      "1"
    ],
    "app": "IP",
    "cnt": "3",
    "dst": "52.10.98.6",
    "dpt": "443",
    "act": "Block",
    "cn1": "0",
    "cn1Label": "VLAN ID",
    "cn2": "33554431",
    "cn2Label": "Taxonomy",
    "cn3": "0",
    "cn3Label": "Packet Trace",
    "cs1": "WCU-External-Outbound",
    "cs1Label": "Profile Name",
    "cs2": "6e664408-b90a-48e2-9a2d-c01cb9258381",
    "cs2Label": "Policy UUID",
    "cs3": "00000001-0001-0001-0001-000000007610",
    "cs3Label": "Signature UUID",
    "cs4": "1-1B 1-1A",
    "cs4Label": "ZoneNames",
    "cs5": "TipSMS",
    "cs5Label": "SMS Name",
    "dvchost": "PAS-TIP2600NX-01",
    "cs6": "50.227.44.198",
    "cs6Label": "Filter Message Parms",
    "src": "50.227.44.198",
    "spt": "10162",
    "externalId": "19278229",
    "rt": "1539348361056",
    "cat": "Reputation",
    "proto": "IP",
    "deviceInboundInterface": "3",
    "c6a2": null,
    "c6a2Label": "Source IPv6",
    "c6a3": null,
    "c6a3Label": "Destination IPv6",
    "request": null,
    "requestMethod": null,
    "dhost": null,
    "sourceTranslatedAddress": "50.227.44.198",
    "c6a1": null,
    "c6a1Label": "Client IPv6",
    "suser": null,
    "sntdom": null,
    "duser": null,
    "dntdom": null
  },
  "raw": "<37>CEF:0|TippingPoint|UnityOne|1.0.0.17|7610|Adlumin RepDV Manual Block|1|app=IP cnt=3 dst=52.10.98.6 dpt=443 act=Block cn1=0 cn1Label=VLAN ID cn2=33554431 cn2Label=Taxonomy cn3=0 cn3Label=Packet Trace cs1=WCU-External-Outbound cs1Label=Profile Name cs2=6e664408-b90a-48e2-9a2d-c01cb9258381 cs2Label=Policy UUID cs3=00000001-0001-0001-0001-000000007610 cs3Label=Signature UUID cs4=1-1B 1-1A cs4Label=ZoneNames cs5=TipSMS cs5Label=SMS Name dvchost=PAS-TIP2600NX-01 cs6=50.227.44.198 cs6Label=Filter Message Parms src=50.227.44.198 spt=10162 externalId=19278229 rt=1539348361056 cat=Reputation proto=IP deviceInboundInterface=3 c6a2= c6a2Label=Source IPv6 c6a3= c6a3Label=Destination IPv6 request= requestMethod= dhost= sourceTranslatedAddress=50.227.44.198 c6a1= c6a1Label=Client IPv6 suser= sntdom= duser= dntdom=",
  "id": "9ecdc00d-c6b6-45b4-af71-9ac45782ec33",
  "added": "2022-01-12T09:29:12.464Z"
}
```

##### Delete an individual event
```
$ curl -X DELETE $URI/6f79c740-d9d8-4515-9ca1-9bd352b86c8a
{"message":"Event 6f79c740-d9d8-4515-9ca1-9bd352b86c8a successfully deleted"}
```

##### Delete all events
```
$ curl -X GET $URI/delete_all
{"message":"6 events deleted"}
```

##### Add comments to an event
```
$ curl -X POST $URI/0941aa38-3d6b-43f1-9921-d460b1d61eea/comments -d "first comment"
$ curl -X POST $URI/0941aa38-3d6b-43f1-9921-d460b1d61eea/comments -d "second comment"
```

##### Update a comment
```
$  curl -X PUT $URI/0941aa38-3d6b-43f1-9921-d460b1d61eea/comments/98c7da31-0d5c-478b-906e-319c3e35f985 -d "amended first comment"
{"message":"Comment successfully updated."}

$ curl -X GET $URI/0941aa38-3d6b-43f1-9921-d460b1d61eea/comments/98c7da31-0d5c-478b-906e-319c3e35f985 | jq
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   209    0   209    0     0   1201      0 --:--:-- --:--:-- --:--:--  1201
{
  "id": "98c7da31-0d5c-478b-906e-319c3e35f985",
  "event_id": "0941aa38-3d6b-43f1-9921-d460b1d61eea",
  "comment": "amended first comment",
  "created_at": "2022-01-12T09:32:37.466Z",
  "updated_at": "2022-01-12T09:52:21.115Z"
}
```
