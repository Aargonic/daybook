# Builds Daybook.apk with the Android SDK command-line tools (no Gradle needed).
$ErrorActionPreference = 'Stop'
$here = $PSScriptRoot
$jdk  = 'C:\Users\sempa\AppData\Local\Programs\Eclipse Adoptium\jdk-17.0.20.101-hotspot'
$sdk  = "$env:LOCALAPPDATA\Android\Sdk"
$bt   = "$sdk\build-tools\34.0.0"
$jar  = "$sdk\platforms\android-34\android.jar"
$env:JAVA_HOME = $jdk
$env:PATH = "$jdk\bin;$env:PATH"
$out  = "$here\build"

if (Test-Path $out) { Remove-Item -Recurse -Force $out }
New-Item -ItemType Directory -Force "$out\classes", "$out\dex" | Out-Null

# Signing key: created once, then reused so later builds install as updates.
$props = "$here\keystore.properties"
if (-not (Test-Path $props)) {
    $pw = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 24 | ForEach-Object { [char]$_ })
    & keytool -genkeypair -keystore "$here\daybook.jks" -alias daybook -keyalg RSA -keysize 2048 -validity 10000 `
        -storepass $pw -keypass $pw -dname "CN=Daybook" | Out-Null
    Set-Content $props "storePassword=$pw" -Encoding ascii
}
$pw = ((Get-Content $props) -replace '^storePassword=', '')

& "$bt\aapt2.exe" compile --dir "$here\res" -o "$out\res.zip"
& "$bt\aapt2.exe" link -o "$out\unsigned.apk" -I $jar --manifest "$here\AndroidManifest.xml" "$out\res.zip"
if ($LASTEXITCODE) { throw 'aapt2 link failed' }

$src = Get-ChildItem "$here\src" -Recurse -Filter *.java | ForEach-Object FullName
& javac -source 8 -target 8 -bootclasspath $jar -Xlint:-options -d "$out\classes" $src
if ($LASTEXITCODE) { throw 'javac failed' }
$classes = Get-ChildItem "$out\classes" -Recurse -Filter *.class | ForEach-Object FullName
& "$bt\d8.bat" --release --min-api 26 --lib $jar --output "$out\dex" $classes
if ($LASTEXITCODE) { throw 'd8 failed' }

Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [System.IO.Compression.ZipFile]::Open("$out\unsigned.apk", 'Update')
[System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, "$out\dex\classes.dex", 'classes.dex') | Out-Null
$zip.Dispose()

& "$bt\zipalign.exe" -f -p 4 "$out\unsigned.apk" "$out\aligned.apk"
& "$bt\apksigner.bat" sign --ks "$here\daybook.jks" --ks-pass "pass:$pw" --out "$here\Daybook.apk" "$out\aligned.apk"
if ($LASTEXITCODE) { throw 'signing failed' }
& "$bt\apksigner.bat" verify "$here\Daybook.apk"
if ($LASTEXITCODE) { throw 'verify failed' }
Write-Output "Built $here\Daybook.apk"
