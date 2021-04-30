#!/bin/sh

# https://developer.akamai.com/api/core_features/enhanced_content_control_utility/v1.html#posteccurequests
# https://developer.akamai.com/api/getting-started#httpiesample

ENDPOINT=akab-3sfyrfzb7ssskx3w-kpgfz47qmva6g753.luna.akamaiapis.net

COMMAND=$(echo '{
  "propertyName": "cdn.dailyhotel.com",
  "propertyNameExactMatch": true,
  "propertyType": "HOST_HEADER",
  "metadata": "<?xml version=\"1.0\"?>\n<eccu>\n  <match:recursive-dirs value=\"test/fe\">\n    <revalidate>now</revalidate>\n  </match:recursive-dirs>\n</eccu>",
  "notes": "Invalidate images in dir(fe)",
  "requestName": "fe_jenkins",
  "statusUpdateEmails": [
    "dev.tool@dailyhotel.com"
  ]
}' | http --auth-type=edgegrid -a default: :${ENDPOINT}/eccu-api/v1/requests)

# require jq
REQUESTID=$($COMMAND | jq '.requestId')
RESULT=$(http --auth-type=edgegrid -a default: :${ENDPOINT}/eccu-api/v1/requests/$REQUESTID | jq '.status')

# echo $RESULT
if [ "$RESULT" = '"SUCCEEDED"' ]; then
    echo success
    exit 0
else
    echo fail
    exit 1
fi
