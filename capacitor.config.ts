import type { CapacitorConfig } from "@capacitor/cli";

/**
 * Android packaging for SpeedWay.
 *
 * `server.url` points at the hosted build so the installed APK always runs the
 * latest deploy. Remove `server` and run `npx cap sync` after `vite build` if
 * you prefer bundling the web assets inside the APK.
 */
const config: CapacitorConfig = {
  appId: "com.speedway.app",
  appName: "SpeedWay",
  webDir: ".output/public",
  android: {
    allowMixedContent: false,
    backgroundColor: "#0B1220",
  },
  server: {
    androidScheme: "https",
    // Defina CAP_SERVER_URL (ex: https://seu-app.lovable.app) no build para
    // gerar um APK que carrega o site publicado (recomendado para SSR).
    ...(process.env["CAP_SERVER_URL"]
      ? { url: process.env["CAP_SERVER_URL"], cleartext: false }
      : {}),
  },
  plugins: {
    SplashScreen: {
      launchAutoHide: false,
      backgroundColor: "#0B1220",
      androidSplashResourceName: "splash",
      androidScaleType: "CENTER_CROP",
      showSpinner: false,
    },
    StatusBar: {
      style: "DARK",
      backgroundColor: "#0B1220",
    },
    Geolocation: {
      // Android asks for both permissions; background tracking needs the
      // coarse+fine pair plus the foreground-service entry in the manifest.
      permissions: ["ACCESS_FINE_LOCATION", "ACCESS_COARSE_LOCATION"],
    },
  },
};

export default config;
