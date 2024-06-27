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

#tabs

$boolFirst = true
$navlinks=""
$tabdata=""

$JSONObject.tabs | ForEach-Object {
    if ($boolFirst) {
        $navlinks+= '<li class="active">'
        $tabdata += "      <!-- $($_.title.ToUpper()) START -->'n      <div class=""tab-pane active"" id=""tab$tab"">`n"
        $boolFirst = false
    }
    else {
        $navlinks += '<li>'
        $tabdata += "      <!-- $($_.title.ToUpper()) START -->'n      <div class=""tab-pane"" id=""tab$tab"">`n"
    }
    $tab = [System.Web.HttpUtility]::UrlEncode($_.title)
    $navlinks= += "<a href=""#tab$tab"" data-toggle=""tab"" data-target=""#tab$tab,#btnHideCompleted"">$($_.title)</a></li>`n"

    #tabdata - the real meat is here
    #filters
    
    
    $tabdata += '<h2>Filter Checklist '
    #NG  don't really like this
    if ($_.ngtoggle) {
        $tabdata += '      <span class="btn-group btn-group-toggle" data-toggle="buttons">
            <label class=""btn btn-default""><input type="radio" name="journey" data-ng-toggle="1">NG</label>
            <label class="btn btn-default"><input type="radio" name="journey" data-ng-toggle="2">NG+</label>
            <label class="btn btn-default"><input type="radio" name="journey" data-ng-toggle="3">NG++</label>
          </span>`n'     
    }
    $tabdata += '    </h2>`n'

    #filter buttons
    $tabdata +='<div class="btn-group">`n'

    foreach ($filter in $_.filters) {

     $tabdata +=    '<div class="btn-group btn-group-vertical">
            <div class="btn-group">
              <div class="btn-group-vertical" data-toggle="buttons">
                <label class="btn btn-default dropdown-toggle">
                  <input type="checkbox" data-category-toggle />
                  <span class="glyphicon glyphicon-eye-close"></span>
                  <span class="glyphicon glyphicon-eye-open"></span>
                  ' + $filter.category + '
                </label>
              </div>
            </div>'
    }
    #foreach item here, then end div
    
    


}


$tHTML = $tHTML.Replace("{{NAVLINKS}}", $navlinks)

$tHTML = $tHTML.Replace("{{TABDATA}", $tabdata)



#Output
Set-Content "$OutputFolder/index.html" $tHTML
new-item "$OutputFolder/js/" -ItemType Directory -force
set-content "$OutputFolder/js/main.js" $tJS
copy-item "./css" "$OutputFolder" -force -recurse
copy-item "./img" "$OutputFolder" -force -recurse
copy-item "./js/jquery.highlight.js" "$OutputFolder/js"
