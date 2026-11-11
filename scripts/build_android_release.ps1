param([switch]$ApkOnly)

# These overrides apply only to this build process. Android builds do not need
# Windows/Linux desktop plugin symlinks or a change to Windows Developer Mode.
$dhikrPlatformFlags = @('FLUTTER_WINDOWS', 'FLUTTER_LINUX', 'FLUTTER_MACOS')
$dhikrPreviousFlags = @{}
$dhikrProjectPath = Split-Path -Parent $PSScriptRoot

function Invoke-DhikrChecked {
    param([string]$Executable, [string[]]$ToolArguments)
    & $Executable @ToolArguments
    if ($LASTEXITCODE -ne 0) {
        throw "$Executable failed with exit code $LASTEXITCODE"
    }
}

Push-Location $dhikrProjectPath
try {
    foreach ($dhikrFlag in $dhikrPlatformFlags) {
        $dhikrPreviousFlags[$dhikrFlag] = [Environment]::GetEnvironmentVariable($dhikrFlag, 'Process')
        [Environment]::SetEnvironmentVariable($dhikrFlag, 'false', 'Process')
    }
    # Do not skip this step: it generates Android's native plugin registrant.
    Invoke-DhikrChecked 'flutter' @('pub', 'get')
    $dhikrRegistrant = Join-Path $dhikrProjectPath 'android/app/src/main/java/io/flutter/plugins/GeneratedPluginRegistrant.java'
    if (-not (Test-Path -LiteralPath $dhikrRegistrant)) {
        throw 'Flutter did not generate the Android plugin registrant.'
    }
    if ((Get-Content -LiteralPath $dhikrRegistrant -Raw) -notmatch 'new com\.tekartik\.sqflite\.SqflitePlugin\(') {
        throw 'The generated Android registrant does not register SQLite.'
    }
    if (-not (Test-Path -LiteralPath 'android/key.properties')) {
        throw 'Configure the production upload keystore in android/key.properties before building.'
    }
    Invoke-DhikrChecked 'flutter' @('build', 'apk', '--release', '--no-pub')
    Invoke-DhikrChecked 'python' @('scripts/verify_android_plugins.py', 'build/app/outputs/flutter-apk/app-release.apk')
    if (-not $ApkOnly) {
        Invoke-DhikrChecked 'flutter' @('build', 'appbundle', '--release', '--no-pub')
        Invoke-DhikrChecked 'python' @('scripts/verify_android_plugins.py', 'build/app/outputs/bundle/release/app-release.aab')
    }
} finally {
    foreach ($dhikrFlag in $dhikrPlatformFlags) {
        [Environment]::SetEnvironmentVariable($dhikrFlag, $dhikrPreviousFlags[$dhikrFlag], 'Process')
    }
    Pop-Location
}
