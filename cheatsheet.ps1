#Script replaces tags in index.html and main.js with elements from config JSON for the game

#parameters
param(
    [Parameter(Mandatory)]
    [string]$ConfigJSON,
    [string]$OutputFolder
)

if (!Test-Path $ConfigJSON) {
    #JSON not found
   Write-Host "JSON file not found"
   exit 1
}

$JSONfile = get-item $ConfigJSON
$JSONObject = convertfrom-json $ConfigJSON

if ($PSBoundParameters.ContainsKey("OutputFolder")) {
    if (!Test-Path $OutputFolder) {
        #JSON not found
       Write-Host "Output folder not found"
       exit 2
    }
}
else {
    $OutputFolder = $JSONfile.Parent.FullName
}

#Template files
$tHTML = Get-Content ./index.html
$tJS = Get-Content ./js.main.js

#HTML

#Metadata
$tHTML.Replace('{{TITLE}}', $JSONObject.title)


#Output
