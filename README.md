# api-utils
This repo contains two utilities to quick start your experience with the MetaMind vision api. These utilities are:

- `jwt.sh`: a shell script which simplifies the configuration of your private key.

- `slurp.sh`: a shell script which simplifies the process of uploading bulk images to the MetaMind vision api.

# JWT.SH usage
Clone this repo to your local system:

```
git clone https://github.com/MetaMind/api-utils
```

Make sure your script is executable:

```
chmod +x jwt.sh
```

Update the parameters in the following command to: the .jks keystore file you downloaded from Salesforce, the email address you used to sign up for an account, and the token expiration time:

```
./jwt.sh <key_file>.jks <email_address> <expiration_in_seconds> https://api.metamind.io
```

You'll be prompted to create a new arbitrary password. jwt.sh will then return
a generated assertion and an access token. The access token will be used to
authenticate yourself against the MetaMind API.

```
Enter destination keystore password:  
Enter source keystore password:  
Existing entry alias test exists, overwrite? [no]:  yes
Entry for alias test successfully imported.
Import command completed:  1 entries successfully imported, 0 entries failed or
cancelled
[Storing privateKey.p12]
Enter Import Password:
MAC verified OK

Generated Assertion:

0000

Your access token response:

{"access_token":"0000","token_type":"Bearer","expires_in":3599}
```

Expiration time means this token will only be valid for a preset time. For testing a good default is one hour and can be set this way:

```
./jwt.sh privatekey.jks <email_address> 3600 https://api.metamind.io"
```

# SLURP.SH usage
Clone this repo to your local system:

```
git clone https://github.com/MetaMind/api-utils
```

Slurp requires some external dependencies to process JSON:

```
brew install jq
```

Make sure your script is executable:

```
chmod +x slurp.sh
```

Slurp will upload a directory to MetaMind's api where the parent directory is the dataset name and child directories are the labels for images in those folders.

```
Mountains vs Beach/
+-- Mountains
	+-- image1.jpg
	+-- image2.jpg
	+-- image3.jpg
+-- Beaches
	+-- image1.jpg
	+-- image2.jpg
	+-- image3.jpg
```

Run slurp on your dataset. This command takes an access token, a url
endpoint, and a directory:

```
./slurp.sh <access_token> https://api.metamind.io <dataset_directory>
```

### SLURP.SH on windows
- Download the binary for your platform at [https://stedolan.github.io/jq](https://stedolan.github.io/jq)
- rename to jq
- add to PATH
- use slurp
