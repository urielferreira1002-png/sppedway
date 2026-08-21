# SpeedWay - Gerar Release assinado (PowerShell)
# Uso: Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass; .\build-release.ps1

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Write-Host '=================================================='
Write-Host 'SpeedWay - Gerar Release assinado (PowerShell)'
Write-Host '=================================================='

# Recomendações:
Write-Host 'Certifique-se de ter criado um keystore (com keytool) e de ter um arquivo android/keystore.properties baseado em android/keystore.properties.example.'

if (-not (Test-Path 'android\keystore.properties')) {
    Write-Warning 'android\keystore.properties não encontrado.'
    if (Test-Path 'android\keystore.properties.example') {
        Copy-Item 'android\keystore.properties.example' 'android\keystore.properties' -ErrorAction SilentlyContinue
        Write-Host 'Arquivo android\keystore.properties.example copiado para android\keystore.properties. Edite-o e coloque valores reais antes de continuar.'
    }
    Write-Host 'Edite android\keystore.properties e execute este script novamente.'
    exit 1
}

if (-not (Get-Command java -ErrorAction SilentlyContinue)) { Write-Error 'Java JDK 11+ não encontrado no PATH. Instale e configure JAVA_HOME.'; exit 1 }
if (-not (Test-Path 'android\gradlew.bat')) { Write-Error 'android\gradlew.bat não encontrado. Execute npx cap add android se necessário.'; exit 1 }

Write-Host '`n1) Instalando dependências e build web...'
Start-Process -FilePath npm -ArgumentList 'install','--legacy-peer-deps','--no-audit','--no-fund' -NoNewWindow -Wait -PassThru | Out-Null
Start-Process -FilePath npm -ArgumentList 'run','build' -NoNewWindow -Wait -PassThru | Out-Null

Write-Host '`n2) Sincronizando com Capacitor...'
Start-Process -FilePath npx -ArgumentList 'cap','sync','android' -NoNewWindow -Wait -PassThru | Out-Null

Write-Host '`n3) Executando assembleRelease...'
Push-Location android
try {
    Start-Process -FilePath .\gradlew.bat -ArgumentList 'assembleRelease' -NoNewWindow -Wait -PassThru | Out-Null
} catch {
    Pop-Location
    Write-Error "Gradle build falhou: $_"
    exit 1
}
Pop-Location

$aab = Join-Path -Path (Get-Location) -ChildPath 'android\app\build\outputs\bundle\release\app-release.aab'
$apk = Join-Path -Path (Get-Location) -ChildPath 'android\app\build\outputs\apk\release\app-release-unsigned.apk'

if (Test-Path $aab) { Write-Host "SUCESSO: AAB gerado em: $aab" }
elseif (Test-Path $apk) { Write-Host "SUCESSO: APK de release gerado em: $apk" }
else { Write-Warning 'Nenhum artefato de release encontrado nas localizações esperadas. Verifique a saída do Gradle.' }

Write-Host 'FIM.'
