#Script replaces tags in index.html and main.js with elements from config JSON for the game

<# TODO:
Overwrite option
 #>

#parameters
param(
    [Parameter(Mandatory)]
    [string]$ConfigJSON,
    [string]$OutputFolder
)

if (!(Test-Path $ConfigJSON)) {
    #JSON not found
   Write-Host "JSON file not found"
   exit 1
}
$ConfigJSON = "./examples/ds3/ds3.json"
$JSONfile = get-item $ConfigJSON
$JSONObject = Get-Content $ConfigJSON | convertfrom-json

write-host "JSON file found at $($JSONfile.FullName)"
write-host "folder is $($JSONfile.Directory)"

if ($PSBoundParameters.ContainsKey("OutputFolder")) {
    if (!Test-Path $OutputFolder) {
        #JSON not found
       Write-Host "Output folder not found"
       exit 2
    }
}
else {
    
    $OutputFolder = $JSONfile.Directory
    write-host "using json file folder for output:$($OutputFolder)"
}

#Template files
$tHTML = Get-Content ./index.html
$tJS = Get-Content ./js/main.js

#HTML

#single replacements

$JSONObject.singles | ForEach-Object {

    $tHTML = $tHTML.Replace("{{$($_.find)}}", $_.replace)
}



#Output
Set-Content "$OutputFolder/index.html" $tHTML
new-item "$OutputFolder/js/" -ItemType Directory -force
set-content "$OutputFolder/js/main.js" $tJS
copy-item "./css" "$OutputFolder" -force -recurse
copy-item "./img" "$OutputFolder" -force -recurse
copy-item "./js/jquery.highlight.js" "$OutputFolder/js"
