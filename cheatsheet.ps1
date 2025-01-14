#Script replaces tags in index.html and main.js with elements from config JSON for the game

<# TODO:
Overwrite option
 #>

#parameters
param(
    #[Parameter(Mandatory)]
    [string]$ConfigJSON = "./examples/ds3/ds3.json",
    [string]$OutputFolder
)

if (!(Test-Path $ConfigJSON)) {
    #JSON not found
    Write-Host "JSON file not found"
    exit 1
}
#$ConfigJSON = "./examples/ds3/ds3.json"
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

#region tabs

$boolFirst = $true
$navlinks = ""
$tabdata = ""
$jsHiddenCats = ''


$JSONObject.tabs | ForEach-Object {
    #$tab = [System.Web.HttpUtility]::UrlEncode($_.title)
    $tab = $_.title -replace "\W"
    if ($boolFirst) {
        $navlinks += '<li class="active">'
        $tabdata += "      <!-- $($_.title.ToUpper()) START -->      
        <div class=""tab-pane active"" id=""tab$tab"">
        "
        $boolFirst = $false
    }
    else {
        $navlinks += '<li>'
        $tabdata += "      <!-- $($_.title.ToUpper()) START -->      
        <div class=""tab-pane"" id=""tab$tab"">
        "
    }
    
    $navlinks += "<a href=""#tab$tab"" data-toggle=""tab"" data-target=""#tab$tab,#btnHideCompleted"">$($_.title)</a></li>
    "

    #tabdata - the real meat is here
    #filters
    
    
    $tabdata += '<h2>Filter Checklist 
    '
    #NG  don't really like this
    if ($_.ngtoggle) {
        $tabdata += '      <span class="btn-group btn-group-toggle" data-toggle="buttons">
            <label class="btn btn-default"><input type="radio" name="journey" data-ng-toggle="1">NG</label>
            <label class="btn btn-default"><input type="radio" name="journey" data-ng-toggle="2">NG+</label>
            <label class="btn btn-default"><input type="radio" name="journey" data-ng-toggle="3">NG++</label>
          </span>
          '     
    }
    $tabdata += '    </h2>
    '

    #filter buttons
    $tabdata += '<div class="btn-group">
    '
    

    foreach ($filter in $_.filters) {

        $tabdata += '<div class="btn-group btn-group-vertical">
            <div class="btn-group">
              <div class="btn-group-vertical" data-toggle="buttons">
                <label class="btn btn-default dropdown-toggle">
                  <input type="checkbox" data-category-toggle />
                  <span class="glyphicon glyphicon-eye-close"></span>
                  <span class="glyphicon glyphicon-eye-open"></span>
                  ' + $filter.category + '
                </label>
              </div>
            </div>
            <div class="btn-group">
              <div class="btn-group-vertical btn-group-sm" data-toggle="buttons">
              '

        foreach ($item in $filter.items) {
            #$datatitle = [System.Web.HttpUtility]::UrlEncode($item.title)
            $datatitle = $item.title -replace "\W"
            $tabdata += ' <label class="btn btn-default">
                  <input type="checkbox" data-item-toggle="f_' + $datatitle + '" />
                  <span class="glyphicon glyphicon-eye-close"></span>
                  <span class="glyphicon glyphicon-eye-open"></span>
                  '+ $item.title + '
                </label>
                '
            if ($jsHiddenCats -eq '') {
                $jsHiddenCats = "$($datatitle): false"
            }
            else {
                $jsHiddenCats += ",`n$($datatitle): false"
            }

        }
        $tabdata += '</div>
        </div>
      </div>
      '
    }

    #foreach item here, then end div
    
    
    $tabdata += '</div>
    '

    #next - steps
    $sectionid = 0
    $tocdata = '<h2>' + $_.title + ' Checklist <span id="' + $tab + '_overall_total"></span></h2>
    <ul class="table_of_contents">
    '
    $listdata = ""
    
    foreach ($section in $_.sections) {
        $sectionid += 1
        #$datatitle = [System.Web.HttpUtility]::UrlEncode($section.title)
        $datatitle = $section.title -replace "\W"
        $tocdata += '<li><a href="#' + $datatitle + '">' + $section.title + '</a> <span id="' + $tab + '_nav_totals_' + $sectionid + '"></span></li>
        '
        
        $listdata += '<h3 id="' + $datatitle + '"><a href="#' + $datatitle + '_col" data-toggle="collapse" class="btn btn-primary btn-collapse btn-sm"></a><a href="' + $section.url + '">' + $section.title + '</a> <span id="' + $tab + '_totals_' + $sectionid + '"></span></h3>
          <ul id="' + $datatitle + '_col" class="collapse in">
        '

        $stepid = 0
        foreach ($step in $section.steps) {
            $stepid += 1
            $listdata += '<li data-id="' + $tab + '_' + $sectionid + '_' + $stepid + '" class="'
            #tags 
            $taglist=''
            foreach ($tag in $step.tags)
            {
                if($taglist -eq '') {$taglist = 'f_' + ($tag -replace "\W")} else {$taglist += ' f_' + ($tag -replace "\W")}
            }
            if($taglist -eq '') {$taglist='f_none'}
            $listdata +=$taglist
            #rest
            $listdata += '">' + $step.text + '</li>
            '
        }
        $listdata += '</ul>
        '
    }

    $tabdata += $tocdata

    $tabdata += '</ul>

        <div class="form-group">
          <input type="search" id="' + $tab + '_search" class="form-control" placeholder="Start typing to filter results..." />
        </div>

        <div id="' + $tab + '_list">
        '
    $tabdata += $listdata

    #close tab div
    $tabdata += '</div>
    </div>
    '
}

#endregion tabs

$tHTML = $tHTML.Replace("{{NAVLINKS}}", $navlinks)

$tHTML = $tHTML.Replace("{{TABDATA}}", $tabdata)

$tJS = $tJS.Replace("//{{HIDDENCATS}}", $jsHiddenCats)



#Output
Set-Content "$OutputFolder/index.html" $tHTML
new-item "$OutputFolder/js/" -ItemType Directory -force
set-content "$OutputFolder/js/main.js" $tJS
copy-item "./css" "$OutputFolder" -force -recurse
copy-item "./img" "$OutputFolder" -force -recurse
copy-item "./js/jquery.highlight.js" "$OutputFolder/js"
