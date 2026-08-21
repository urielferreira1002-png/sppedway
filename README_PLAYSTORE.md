Publish to Google Play — CI instructions

This project includes a GitHub Actions workflow to build an Android AAB and upload it to the Google Play Console.

Workflow location
- .github/workflows/publish-playstore.yml

What the workflow does
- Installs Node and Java, builds the web (npm run build).
- Runs `npx cap sync android` to copy web assets into the Android project.
- Restores a base64-encoded keystore from a secret and writes android/keystore.properties.
- Builds an Android App Bundle (AAB) with `./gradlew bundleRelease`.
- Uploads the AAB to Google Play (internal track) using the service account JSON.

Required GitHub repository secrets
- PLAY_SERVICE_ACCOUNT_JSON
  - Full JSON contents of the Google Cloud service account key (paste the JSON body).
- KEYSTORE_BASE64
  - base64-encoded contents of your release keystore (.jks). Example (PowerShell):
    [Convert]::ToBase64String([IO.File]::ReadAllBytes('android\\keystore\\my-release-key.jks')) | clip
- KEYSTORE_PASSWORD
  - The password used when generating the keystore.
- KEY_ALIAS
  - The alias used in the keystore when generating the key (e.g. my-key-alias).
- KEY_PASSWORD
  - The password for the key (frequently same as KEYSTORE_PASSWORD).

How to create the Play service account and grant access
1. In the Play Console: Settings → Developer account → API access → Create service account (opens Google Cloud Console).
2. In Google Cloud Console → IAM & Admin → Service Accounts: create a service account, then create and download a JSON key.
3. Back in Play Console → API access: link the service account and grant it the Release Manager role (or the minimal role needed).
4. Paste the JSON file contents into the PLAY_SERVICE_ACCOUNT_JSON secret in GitHub.

How to generate and prepare the keystore
1. Create keystore locally:
   keytool -genkeypair -v -keystore my-release-key.jks -alias my-key-alias -keyalg RSA -keysize 2048 -validity 10000
2. Move the keystore into the repo working folder (do NOT commit it), for example: android/keystore/my-release-key.jks
3. Base64-encode the keystore and add to GitHub secrets as KEYSTORE_BASE64 (see above).
4. Add KEYSTORE_PASSWORD, KEY_ALIAS, KEY_PASSWORD secrets as described above.

Triggering the workflow
- The workflow runs on push to main and manual dispatch (workflow_dispatch).
- For production releases, consider changing the trigger to tags (push on v* tags) and/or deploying to a different Play track (beta/production).

Security notes
- Never commit keystore (.jks) or the service account JSON to the repository.
- Use GitHub Secrets to store all credentials.
- Limit the service account permissions: Release Manager is sufficient for uploads.

Manual upload alternative
- If you prefer manual uploads, build locally with the provided build-release.bat / build-release.ps1 and upload the resulting AAB via Play Console → Release → Create new release.

Need help?
- I can update the workflow to trigger on tags, switch the default track, or create a small PR template for release notes. Reply which you'd like next.