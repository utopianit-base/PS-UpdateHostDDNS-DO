# Uses version 2 of the DigitalOcean RESTful Web API
# https://developers.digitalocean.com/

# On Error - Stop
$ErrorActionPreference = "Stop"

# The scriptpath is the path for storing files and settings such as 
# your API key. The default path is the same directory as the script.
$scriptpath = Split-Path $MyInvocation.MyCommand.Path
# Uncomment if you want to use your my documents folder
#$scriptpath = ([environment]::getfolderpath("mydocuments"))

# Reads api.txt file for the API key
Function ReadAPIKey
{ 
  if (Test-Path $scriptpath\api.txt)
  {
    return Get-Content $scriptpath\api.txt
  }
  else
  {
    $ignore = New-Item $scriptpath\api.txt -type file
    Write-Host "ERROR: API is missing from api.txt file!" -foregroundcolor red
    break
  }
}

# Your API key is read from a separate text file called api.txt
# This file should only contain your API key
$api_key = ReadAPIKey 
#$api_key = {{ THIS IS MY PRIVATE DIGITALOCEAN API KEY HARDCODE IN }}

if ($api_key -eq $null)
{
  Write-Host "ERROR: No API key set in api.txt file!" -foregroundcolor red
  break
}

$header = @{"Authorization"="Bearer " + $api_key;"Content-Type"="application/json"}

# Create a DNS record for the newly created domain
Function CreateRecord ($data)
{
  $r = Invoke-WebRequest -Uri $url/domains/$newdomain/records -Method POST -Headers $header -Body $data
  return $r.Content | ConvertFrom-Json
}

# Update DNS record for the newly created domain
Function UpdateRecord ($data, $recordid)
{
  $r = Invoke-WebRequest -Uri $url/domains/$newdomain/records/$recordid -Method PUT -Headers $header -Body $data
  return $r.Content | ConvertFrom-Json
}

Function UpdateHostRecordIP ($hostrecord,$ipv4) {
    $newipv4record = @{data=$ipv4} | ConvertTo-Json
    $allrecords = ListAllRecords
    $recordid = @($allrecords.domain_records | Where name -EQ $hostrecord).id 
    UpdateRecord -data $newipv4record -recordid $recordid
}

Function UpdateHostDDNS ($hostrecord) {
    $ipv4 = Invoke-RestMethod http://ipinfo.io/json | Select -exp ip
    write-host "Setting $hostrecord as $ipv4..."
    $result = UpdateHostRecordIP -hostrecord $hostrecord -ipv4 $ipv4
    if($result.domain_record.data -eq $ipv4) {
        write-host "Successfully updated."
    } else {
        write-host "Failed to update."
    }
}

# Creates a DNS MX record on your new domain
Function CreateMXRecord($priority, $address)
{
  $mxrecord = @{priority=$priority;data=$address;type="MX"} | ConvertTo-Json
  CreateRecord -data $mxrecord
}

#######################################################################
#######################################################################

Write-Host ""
Write-Host "UpdateHostDDNS Using DO API v2 - PowerShell"
Write-Host "==========================================="
$newdomain = "yourdomainhere.com"
UpdateHostDDNS -hostrecord home
