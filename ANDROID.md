# SpeedWay — build Android (Capacitor)

App ID: `com.speedway.app` · Nome: **SpeedWay**

## 1. Gerar o projeto Android (uma única vez)

```bash
npm run build          # gera .output/public
npx cap add android    # cria a pasta android/
npx cap sync android
```

## 2. Permissões — `android/app/src/main/AndroidManifest.xml`

Adicione dentro de `<manifest>`:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_LOCATION" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-feature android:name="android.hardware.location.gps" android:required="true" />
```

## 3. Rodar e empacotar

```bash
npx cap open android          # abre no Android Studio
# APK de teste
cd android && ./gradlew assembleDebug
# AAB para a Play Store (precisa de keystore configurado)
cd android && ./gradlew bundleRelease
```

## 4. Notas

- `capacitor.config.ts` usa `webDir: .output/public`. Rode `npm run build` antes de cada `npx cap sync`.
- O GPS usa o plugin nativo (`@capacitor/geolocation`) quando roda no aparelho e a API do navegador no site.
- A tela fica acesa durante a viagem via `@capacitor-community/keep-awake`.
- Viagens gravadas sem internet ficam no aparelho e sobem sozinhas quando a conexão volta.

## Como obter o APK para download

Este ambiente do Lovable não possui Java nem o Android SDK, portanto o APK não
pode ser compilado aqui. Existem duas formas de gerar o arquivo instalável:

### 1. Build automático no GitHub (recomendado, sem instalar nada)
1. Conecte o projeto ao GitHub (botão GitHub no topo do Lovable).
2. Publique o app e copie a URL (ex: `https://speedway.lovable.app`).
3. No repositório: Settings > Secrets and variables > Actions > Variables >
   crie `CAP_SERVER_URL` com essa URL.
4. Aba **Actions** > workflow **Build Android APK** > **Run workflow**.
5. Ao terminar, baixe o artefato `speedway-debug-apk` (contém `app-debug.apk`).
6. Envie o arquivo para o celular e instale (permita "fontes desconhecidas").

### 2. Build local
```bash
npm install
npm run build
CAP_SERVER_URL="https://seu-app.lovable.app" npx cap add android
CAP_SERVER_URL="https://seu-app.lovable.app" npx cap sync android
cd android && ./gradlew assembleDebug
# APK em android/app/build/outputs/apk/debug/app-debug.apk
```
Para a Play Store use `./gradlew bundleRelease` com uma keystore de assinatura.
