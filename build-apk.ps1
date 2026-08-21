# SpeedWay - Script PowerShell para gerar APK (Windows)
# Execute from the project root: 
#   Open PowerShell, then: Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass; .\build-apk.ps1

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Check-Command($name) {
    return [bool](Get-Command $name -ErrorAction SilentlyContinue)
}

Write-Host '=================================================='
Write-Host 'SpeedWay - Gerar APK (PowerShell)'
Write-Host '=================================================='

Write-Host 'Verificando pré-requisitos...'
if (-not (Check-Command node)) { Write-Error 'ERRO: node não encontrado no PATH. Instale Node.js e tente novamente.'; exit 1 }
if (-not (Check-Command npm))  { Write-Error 'ERRO: npm não encontrado no PATH. Instale Node.js e tente novamente.'; exit 1 }
if (-not (Check-Command npx))  { Write-Error 'ERRO: npx não encontrado no PATH. Instale Node.js e tente novamente.'; exit 1 }

# Verifica Java
try {
    & java -version *> $null 2>&1
    Write-Host 'Java encontrado. Certifique-se que é JDK 11+ para compilação Android.'
} catch {
    Write-Warning 'AVISO: Java não foi detectado no PATH. É necessário Java JDK 11+ para compilar o Android.'
    Write-Host 'Defina JAVA_HOME e adicione %JAVA_HOME%\bin ao PATH. Exemplo:'
    Write-Host 'setx JAVA_HOME "C:\Program Files\Zulu\zulu-11"'
    exit 1
}

if (-not (Check-Command adb)) { Write-Warning 'AVISO: adb (platform-tools) não encontrado no PATH. Você pode instalar platform-tools via Android SDK para poder instalar o APK com adb.' }

if (-not (Test-Path .\android\gradlew.bat)) { Write-Error 'ERRO: android\gradlew.bat não encontrado. Verifique se a pasta android existe e se o wrapper está presente.'; exit 1 }

# Step 1: npm install
Write-Host "`n1) Instalando dependências npm (pode demorar)..."
$npmInstallArgs = 'install','--legacy-peer-deps','--no-audit','--no-fund'
$proc = Start-Process -FilePath npm -ArgumentList $npmInstallArgs -NoNewWindow -Wait -PassThru
if ($proc.ExitCode -ne 0) { Write-Error 'ERRO: npm install falhou. Verifique a saída acima.'; exit 1 }

# Step 2: npm run build
Write-Host "`n2) Construindo os assets web (vite build)..."
$proc = Start-Process -FilePath npm -ArgumentList 'run','build' -NoNewWindow -Wait -PassThru
if ($proc.ExitCode -ne 0) { Write-Error 'ERRO: build web falhou. Verifique a saída acima.'; exit 1 }

# Step 3: npx cap sync android
Write-Host "`n3) Sincronizando com Capacitor (npx cap sync android)..."
$proc = Start-Process -FilePath npx -ArgumentList 'cap','sync','android' -NoNewWindow -Wait -PassThru
if ($proc.ExitCode -ne 0) { Write-Error 'ERRO: npx cap sync android falhou. Verifique se o Capacitor está instalado e configurado.'; exit 1 }

# Step 4: Gradle build
Write-Host "`n4) Compilando APK Android (assembleDebug). Isto usa o Gradle wrapper."
Push-Location android
try {
    $gradleProc = Start-Process -FilePath .\gradlew.bat -ArgumentList 'assembleDebug' -NoNewWindow -Wait -PassThru
    if ($gradleProc.ExitCode -ne 0) { throw 'Gradle build failed' }
} catch {
    Pop-Location
    Write-Error "ERRO: compilação Android falhou. Possíveis causas: JDK < 11, Android SDK ausente, memória insuficiente. Mensagem: $_"
    exit 1
}
Pop-Location

$apk = Join-Path -Path (Get-Location) -ChildPath 'android\app\build\outputs\apk\debug\app-debug.apk'

Write-Host "`nResultado:"
if (Test-Path $apk) {
    Write-Host "SUCESSO: APK gerado em:`n$apk`n"
    Write-Host "Para instalar em um dispositivo conectado via USB com depuração ativada, rode (no PowerShell):"
    Write-Host "adb install -r `"$apk`"`n"
} else {
    Write-Error "ERRO: APK esperado não foi encontrado em $apk. Verifique a saída do Gradle."; exit 1
}

Write-Host 'FIM.'
