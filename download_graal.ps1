$JavaPath = "${env:USERPROFILE}\Java"

$GraalUrl = $null
$GraalFile = "${JavaPath}\jvm.zip"

$FileGlob = $null # has version numbers after that we cannot know ahead of time (e.g. graalvm-jdk-17.0.11+9)

Write-Host "What Minecraft version will you be using?"
Write-Host "a. 1.16.5"
Write-Host "b. 1.18.2 or newer"
while ($true) {
    $Response = (Read-Host -Prompt "Enter your selection").ToLowerInvariant()
    if ($Response -eq "a") {
        $GraalUrl = "https://github.com/graalvm/graalvm-ce-builds/releases/download/vm-21.3.3.1/graalvm-ce-java11-windows-amd64-21.3.3.1.zip"
        $FileGlob = "graalvm-ce-java11"
        break
    }
    elseif ($Response -eq "b") {
        $GraalUrl = "https://download.oracle.com/graalvm/21/latest/graalvm-jdk-21_windows-x64_bin.zip"
        $FileGlob = "graalvm-jdk-21"
        break
    }
    else {
        Write-Host "Invalid selection, choose again!"
    }
}

if (!(Test-Path -Path "${JavaPath}" -PathType Container)) {
    New-Item -ItemType Directory -Path "${JavaPath}" | Out-Null
}

$ProgressPreference = "SilentlyContinue" # never change microsoft: https://stackoverflow.com/a/43477248/9091276
Write-Host "Downloading java..."
Invoke-WebRequest -OutFile "${GraalFile}" -Uri "${GraalUrl}"
Write-Host "Extracting archive..."
Expand-Archive -DestinationPath "${JavaPath}" -Path "${GraalFile}" -Force # overwrite if previously existing

$JavaFolder = Get-ChildItem -Filter "${FileGlob}*" -Depth 0 -Path "${JavaPath}"

Write-Host "Success! Java has been downloaded and saved in ${JavaPath}\${JavaFolder}"
Write-Host "Optionally, though highly recommended, we can set environment variables for you"
Write-Host "This means that all your serverpacks will automatically begin to use this version of java"
Write-Host "and that it will be visible to your MC launcher in the java selection settings"
Write-Host ""
Write-Host "This requires administrator priviledges, and two administrator popups will occur if you choose to accept this."
$Response = (Read-Host -Prompt "Continue? (y/n)").ToLowerInvariant()

if ($Response -eq "y") {
    Write-Host "Setting environment variables..."

    Start-Process powershell "-Command setx /M JAVA_HOME ${JavaPath}\${JavaFolder}" -Verb RunAs
    Start-Process powershell '-Command setx /M Path \"${env:JAVA_HOME}\bin;${env:Path}\"' -Verb RunAs # The \" is VERY important, otherwise it WILL erase the entire Path
}
else {
    Write-Host "Skipping environment variables"
}

Write-Host ""
Write-Host "Press any key to exit!"
$host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | Out-Null
