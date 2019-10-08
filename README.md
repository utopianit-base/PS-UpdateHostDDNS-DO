# PS-UpdateHostDDNS-DO
Powershell script to update a DNS host record on DigitalOcean DNS based on the local Public IP. Used for free Dynamic DNS using a DigitalOcean DNS account.

Using the (free) DigitalOcean DNS service, you can run this PowerShell script with a few minor updates to update a DNS host record with your public IP address. This can be scheduled to run, for example, every 5 minutes on a local machine and if your home/office broadband connection changes IP address, the record will be automatically updated by the script.

You'll need to put in a DigitalOcean API key into the api.key text file which can be configured by following this:

https://www.digitalocean.com/docs/api/create-personal-access-token/

Next, within the main PS script, you'll need to update it with the domain and record that you want to update.

The script will run, read the API key and check the current DNS record. If it's changed, it'll update it.

