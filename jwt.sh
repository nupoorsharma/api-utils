#!/bin/bash
if [ $# -le 3 ]; then
        echo "usage: jwt.sh /path/to/privatekey.jks <email_address> <expiry_in_secs> <URL>"
        exit 1;
fi

keytool -v -importkeystore -srckeystore $1 -destkeystore privateKey.p12 -deststoretype PKCS12

openssl pkcs12 -in privateKey.p12 -nocerts -nodes -out private_key
echo
echo private key:
tail -n +5  private_key
echo

header=`echo -n '{"alg":"RS256","typ":"JWT"}'`
echo header:
echo $header
echo

jwt1=`echo -n $header | openssl base64 -e`


payload=`echo -n '{\
"iss":"'$2'",\
"sub":"'$2'",\
"aud":"'$4'/v1/oauth2/token",\
"exp":'$(($(date +%s)+$3))',\
"iat":'$(date +%s)'}'`
echo payload:
echo $payload
echo

jwt2=`echo -n $payload | openssl base64 -e`

jwt3=`echo -n "$jwt1.$jwt2" | tr -d '\n' | tr -d '=' | tr '/+' '_-'`

jwt4=`echo -n "$jwt3" | openssl sha -sha256 -sign private_key | openssl base64 -e`

jwt5=`echo -n "$jwt4" | tr -d '\n' | tr -d '=' | tr '/+' '_-'`

echo
echo "Generated Assertion:"
echo
echo $jwt3.$jwt5
echo
echo "Your access token response:"
echo

curl -H "Content-type: application/x-www-form-urlencoded" -X POST "$4/v1/oauth2/token" -d \
"grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=$jwt3.$jwt5" ; echo
