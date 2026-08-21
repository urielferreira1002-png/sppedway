Release template

Use this template when creating a new release tag (ex.: v1.2.0) and dispatching the Play Store workflow.

---
Version: v{MAJOR}.{MINOR}.{PATCH}
Date: YYYY-MM-DD
Authors: @your-github-user

Summary
-------
Short (one-line) summary of the release.

Highlights
----------
- Feature or bugfix 1
- Feature or bugfix 2

Changes (detailed)
------------------
- Component: Description of change, migration steps if any.

Migration / Upgrade notes
-------------------------
- Backwards-incompatible changes and steps for customers/servers.

Testing / QA
------------
- [ ] Manual smoke test on device (Android) passes
- [ ] Key flows tested: login, primary screens, offline behaviour
- [ ] E2E tests (if any) run and pass
- [ ] Performance basic checks

Play Store checklist
--------------------
Before creating the release in Play Console or running the CI workflow ensure the following are ready:

Store Listing
- App title (short):
- Short description (max 80 chars):
- Full description:
- Graphic assets required (prepare in advance): phone screenshots (portrait), feature graphic, icon, promotional images
- Privacy policy URL (public):

Release & Distribution
- Release notes / "What's new" (use the Highlights section above)
- Target countries / Pricing
- Targeted Android API and compatibility notes

Content and Policy
- [ ] Content rating questionnaire completed
- [ ] Ads and permissions declared correctly (e.g., location usage)
- [ ] Privacy policy uploaded and reachable

Artifact & Signing
- [ ] AAB built and signed (or CI workflow running with correct secrets)
- [ ] Confirm keystore is valid and not expired

Testing Release
- [ ] Internal test track: upload and verify install on test devices
- [ ] Beta track (optional): expand to more testers

Release notes example (for Play Console "What's new")
- Fixed: crash when opening map on older devices
- Added: driver speed graph on Stats screen
- Improved: login performance and offline caching

How to trigger CI upload (recommended)
1. Create annotated tag: git tag -a v1.2.0 -m "Release v1.2.0"
2. Push tag: git push origin v1.2.0
3. GitHub Actions will run the publish-playstore.yml workflow and upload to the default track (or use workflow_dispatch to select a different track).

Notes
-----
- Do NOT commit keystore files or the Play service account JSON to the repository.
- Keep Play Console screenshots and store listing assets in a secure location for reuse.
