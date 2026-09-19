$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$appRoot = Join-Path $root 'app'
$phpRoot = Join-Path $root 'php'
$mariaRoot = Join-Path $root 'mariadb'
$dataRoot = Join-Path $root 'data'
$dbRoot = Join-Path $dataRoot 'mysql'
$envPath = Join-Path $appRoot '.env'
$dbPort = 3307
$webPort = 8787

New-Item -ItemType Directory -Force -Path $dataRoot, $dbRoot | Out-Null

$php = Join-Path $phpRoot 'php.exe'
$server = Join-Path $mariaRoot 'bin\mariadbd.exe'
$client = Join-Path $mariaRoot 'bin\mariadb.exe'

if (-not (Test-Path $php) -or -not (Test-Path $server) -or -not (Test-Path $client)) {
    throw 'The bundled PHP or MariaDB runtime is incomplete.'
}

if (-not (Test-Path $envPath)) {
    $password = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 24 | ForEach-Object {[char]$_})
    @"
APP_ENV=local
APP_URL=http://127.0.0.1:$webPort
APP_TIMEZONE=Asia/Aden
FORCE_SECURE_COOKIES=0
DB_HOST=127.0.0.1
DB_PORT=$dbPort
DB_NAME=first_british_courses
DB_USER=root
DB_PASSWORD=
ADMIN_USERNAME=admin
ADMIN_EMAIL=admin@localhost
ADMIN_FULL_NAME=System Administrator
ADMIN_PASSWORD=$password
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=
GOOGLE_REDIRECT_URI=http://127.0.0.1:$webPort/api/?action=google_callback
TESSERACT_BIN=
LIVEKIT_URL=
LIVEKIT_API_KEY=
LIVEKIT_API_SECRET=
"@ | Set-Content -Encoding UTF8 $envPath
}

$ready = $false
try {
    & $client --protocol=tcp -h 127.0.0.1 -P $dbPort -u root -e 'SELECT 1' 2>$null | Out-Null
    $ready = ($LASTEXITCODE -eq 0)
} catch { $ready = $false }

if (-not $ready) {
    if (-not (Test-Path (Join-Path $dbRoot 'mysql'))) {
        & $server --initialize-insecure --datadir=$dbRoot 2>&1 | Out-File (Join-Path $dataRoot 'mysql-init.log')
    }
    Start-Process -FilePath $server -WorkingDirectory $mariaRoot -ArgumentList "--datadir=$dbRoot --port=$dbPort --bind-address=127.0.0.1 --skip-name-resolve" -WindowStyle Hidden
    for ($attempt = 0; $attempt -lt 30; $attempt++) {
        Start-Sleep -Milliseconds 500
        & $client --protocol=tcp -h 127.0.0.1 -P $dbPort -u root -e 'SELECT 1' 2>$null | Out-Null
        if ($LASTEXITCODE -eq 0) { $ready = $true; break }
    }
}

if (-not $ready) { throw 'MariaDB did not start. Check data\mysql-init.log.' }

& $client --protocol=tcp -h 127.0.0.1 -P $dbPort -u root -e 'CREATE DATABASE IF NOT EXISTS first_british_courses CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci' 2>$null
$schemaMarker = Join-Path $dataRoot '.schema-installed'
if (-not (Test-Path $schemaMarker)) {
    Get-Content (Join-Path $appRoot 'database\schema.sql') | & $client --protocol=tcp -h 127.0.0.1 -P $dbPort -u root first_british_courses
    if ($LASTEXITCODE -ne 0) { throw 'Database schema installation failed.' }
    & $php (Join-Path $appRoot 'install\seed.php')
    if ($LASTEXITCODE -ne 0) { throw 'Initial administrator setup failed.' }
    New-Item -ItemType File $schemaMarker | Out-Null
}

$webReady = $false
try { Invoke-WebRequest "http://127.0.0.1:$webPort/" -UseBasicParsing -TimeoutSec 2 | Out-Null; $webReady = $true } catch { $webReady = $false }
if (-not $webReady) {
    Start-Process -FilePath $php -WorkingDirectory $appRoot -ArgumentList "-S 127.0.0.1:$webPort -t public" -WindowStyle Hidden
    Start-Sleep -Seconds 1
}
Start-Process "http://127.0.0.1:$webPort/"