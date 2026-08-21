@echo off
setlocal enabledelayedexpansion

echo ==================================================
echo SpeedWay - Gerar APK/Bundle de Release assinado
echo ==================================================

echo Este script assume que você criou um keystore e um arquivo android\keystore.properties
echo baseado em android\keystore.properties.example (não compartilhe senhas).

echo 1) Gerar um keystore (se ainda não tiver):
echo keytool -genkeypair -v -keystore my-release-key.jks -alias my-key-alias -keyalg RSA -keysize 2048 -validity 10000

echo 2) Mova o keystore para uma pasta segura no repositório, por exemplo android\keystore\my-release-key.jks

echo 3) Crie android\keystore.properties com os valores corretos. Você pode copiar o exemplo:
if not exist android\keystore.properties (
  echo Copiando exemplo android\keystore.properties.example para android\keystore.properties (edite os valores)...
  copy android\keystore.properties.example android\keystore.properties >nul 2>&1 || echo Falha ao copiar: crie o arquivo manualmente.
  echo Edite android\keystore.properties e coloque paths/senhas reais antes de prosseguir.
  pause
  exit /b 1
)

echo Verificando pré-requisitos básicos...
where java >nul 2>&1 || (echo ERRO: Java JDK 11+ não encontrado no PATH. Instale e configure JAVA_HOME.& pause & exit /b 1)
where .\android\gradlew.bat >nul 2>&1 || (echo ERRO: android\gradlew.bat não encontrado. Execute 'npx cap add android' se necessário.& pause & exit /b 1)

echo Fazendo build da web e sincronizando antes do release...
npm install --legacy-peer-deps --no-audit --no-fund || (echo npm install falhou & pause & exit /b 1)
npm run build || (echo build web falhou & pause & exit /b 1)
npx cap sync android || (echo cap sync falhou & pause & exit /b 1)

cd android

echo Rodando assembleRelease (vai gerar AAB/APK assinado se keystore.properties estiver correto)...
call gradlew.bat assembleRelease
if %errorlevel% neq 0 (
  echo ERRO: compilação release falhou. Verifique a saída do Gradle.& pause & exit /b 1
)

set "AAB=app\build\outputs\bundle\release\app-release.aab"
set "APK=app\build\outputs\apk\release\app-release-unsigned.apk"

if exist "%AAB%" (
  echo SUCESSO: AAB gerado em: %CD%\%AAB%
) else if exist "%APK%" (
  echo SUCESSO: APK de release (possivelmente não assinado) gerado em: %CD%\%APK%
) else (
  echo Aviso: nenhum artefato de release encontrado nas localizações esperadas. Verifique build.gradle e saída do Gradle.
)

echo FIM. Pressione qualquer tecla para fechar.
pause >nul
