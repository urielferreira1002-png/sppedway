@echo off
setlocal enabledelayedexpansion

echo ==================================================
echo SpeedWay - Script auxiliar para gerar APK (Windows)
echo ==================================================

echo Verificando pré-requisitos...
where node >nul 2>&1 || (echo ERRO: Node.js não encontrado no PATH. Instale Node.js e tente novamente.& pause & exit /b 1)
where npm >nul 2>&1 || (echo ERRO: npm não encontrado no PATH. Instale Node.js e tente novamente.& pause & exit /b 1)
where npx >nul 2>&1 || (echo ERRO: npx não encontrado no PATH. Instale Node.js e tente novamente.& pause & exit /b 1)

java -version >nul 2>&1
if %errorlevel% neq 0 (
  echo AVISO: Java não foi detectado no PATH. É necessário Java JDK 11+ para compilar o Android.& echo.
  echo Defina JAVA_HOME para a pasta do JDK e adicione %%JAVA_HOME%%\bin ao PATH. Exemplo:
  echo setx JAVA_HOME "C:\Program Files\Zulu\zulu-11"
  echo setx PATH "%%JAVA_HOME%%\bin;%%PATH%%"
  echo.
  pause
  exit /b 1
) else (
  echo Java detectado (verifique ser JDK 11+ se necessário).
)

where adb >nul 2>&1 || (
  echo AVISO: adb (Android platform-tools) não foi encontrado no PATH. Instalar platform-tools permite usar "adb install" posteriormente.
)

if not exist android\gradlew.bat (
  echo ERRO: wrapper do Gradle não encontrado em android\gradlew.bat. Execute "npx cap add android" ou verifique o repositório.& pause & exit /b 1
)

echo.
echo 1) Instalando dependências npm (pode demorar)...
npm install --legacy-peer-deps --no-audit --no-fund
if %errorlevel% neq 0 (
  echo ERRO: npm install falhou. Verifique a saída acima.& pause & exit /b 1
)

echo.
echo 2) Construindo os assets web (vite build)...
npm run build
if %errorlevel% neq 0 (
  echo ERRO: build web falhou. Verifique a saída acima.& pause & exit /b 1
)

echo.
echo 3) Sincronizando com Capacitor (cap sync android)...
npx cap sync android
if %errorlevel% neq 0 (
  echo ERRO: npx cap sync android falhou. Verifique se o Capacitor está instalado e configurado.& pause & exit /b 1
)

echo.
echo 4) Compilando APK Android (assembleDebug). Isto usa o Gradle wrapper.
cd android
call gradlew.bat assembleDebug
if %errorlevel% neq 0 (
  echo ERRO: compilação Android falhou. Verifique a saída do Gradle acima. Possíveis causas: JDK versão menor que 11, SDK Android ausente, memória insuficiente.& pause & exit /b 1
)
cd ..

echo.
set "APK=android\app\build\outputs\apk\debug\app-debug.apk"
if exist "%APK%" (
  echo SUCESSO: APK gerado em:
  echo %CD%\%APK%
  echo.
  echo Para instalar em um dispositivo conectado via USB com depuração ativada, rode:
  echo adb install -r "%APK%"
) else (
  echo ERRO: APK esperado não foi encontrado em %APK%. Verifique o log do Gradle.& pause & exit /b 1
)

echo.
echo FIM. Pressione qualquer tecla para fechar.
pause >nul
