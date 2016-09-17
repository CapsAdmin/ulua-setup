$ROOT_DIR = $PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition

function Remove($path) {
	if(Test-Path "$path" -PathType Container) {
		Write-Host -NoNewline "removing directory: '$ROOT_DIR\$path' ... "
		Get-ChildItem -Path "$path\\*" -Recurse -Force | Remove-Item -Force -Recurse
		Remove-Item $path -Recurse -Force
		Write-Host "OK"
	} elseif(Test-Path "$path" -PathType Leaf) {
		Write-Host -NoNewline "removing file: '$ROOT_DIR\$path' ... "
		Remove-Item -Force "$path"
		Write-Host "OK"
	} else {
		Write-Host "could not find: $path"
	}
}

function Download($url, $location) {
	if(!(Test-Path "$location")) {
		Write-Host -NoNewline "'$url' >> '$ROOT_DIR\$location' ... "
		if (Get-Module -ListAvailable -Name BitsTransfer) {
			Import-Module BitsTransfer
			Start-BitsTransfer -Source $url -Destination $location
		} else {
			(New-Object System.Net.WebClient).DownloadFile($url, $location)
		}
		Write-Host "OK"
	} else {
		Write-Host "'$ROOT_DIR\$location' already exists"
	}
}

function Extract($file, $location) {
	Write-Host -NoNewline "$file >> '$location' ... "

	$shell = New-Object -Com Shell.Application
	
	$zip = $shell.NameSpace("$ROOT_DIR\$file")
	
	if (!$zip) {
		Write-Error "could not extract $ROOT_DIR\$file!"
	}
	
	if (!(Test-Path $location)) {
		New-Item -ItemType directory -Path $location | Out-Null
	}
		
	foreach($item in $zip.items()) {
		$shell.Namespace($location).CopyHere($item, 0x14)
	}

	Write-Host "OK"
}

function Setup($url, $dir)
{	
	Download $url temp.zip
	Remove $dir
	Extract temp.zip $dir
	Remove temp.zip
}
if (!(Test-Path "ulua\lua.cmd"))
{
	Setup http://ulua.io/download/ulua~latest.zip ulua
}

.\ulua\lua.cmd main.lua
