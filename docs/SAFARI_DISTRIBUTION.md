# Safari Extension Distribution Guide

This guide explains how to build, sign, and publish the Safari extension for Competitive Companion using GitHub Actions.

## Prerequisites

- **Apple Developer Account**: Required for signing and notarizing the application.
- **Xcode**: Required to generate the initial project wrapper and for local testing.

## One-Time Setup

1.  **Xcode Project Generator (Already Completed)**:
    The `safari` directory has already been generated using `xcrun` and committed to the repository. You do **not** need to run `xcrun` again.

2.  **Configure Signing in Xcode (Required)**:
    Open `safari/Competitive Companion.xcodeproj` in Xcode.
    - Select the "Competitive Companion" target (the app wrapper).
    - Go to the **Signing & Capabilities** tab.
    - Under "Team", select your **Apple Development Team**.
    - Repeat this step for the "Competitive Companion Extension" target.
    - **Verify**: click the "Run" button (Play icon) in Xcode to build and launch the app locally. It should open a macOS window and offer to open Safari Preferences.

## GitHub Secrets Setup

To enable the GitHub Action to sign your app, you need to add the following secrets to your repository (Settings > Secrets and variables > Actions):

| Secret Name | Description |
| :--- | :--- |
| `MACOS_CERTIFICATE` | The Base64 encoded `.p12` file of your Apple Distribution Certificate. |
| `MACOS_CERTIFICATE_PWD` | The password for the `.p12` file. |
| `PROVISIONING_PROFILE_BASE64` | The Base64 encoded `.mobileprovision` file. |
| `KEYCHAIN_PASSWORD` | A random strong password used to unlock the temporary keychain on the runner. |

### How to Export Credentials
1.  **Certificate**: Open Keychain Access, find your "Apple Distribution" certificate. Right-click > Export. Save as `.p12` with a password.
2.  **Base64 Encode**:
    ```bash
    base64 -i certificate.p12 | pbcopy
    ```
    Paste into `MACOS_CERTIFICATE`.
3.  **Provisioning Profile**: Download from Apple Developer Portal. Base64 encode it similarly and paste into `PROVISIONING_PROFILE_BASE64`.

## Fork Maintenance

### Automatic Sync
This fork is configured with a `Sync Upstream` workflow that runs daily. It fetches changes from `jmerle/competitive-companion` and updates your `master` branch.

### Handling Conflicts
If the upstream repository modifies files that conflict with your Safari-specific changes (e.g., deeply conflicting changes in `package.json` or `scripts/build`), the sync workflow might fail. In that case:
1.  Fetch upstream manually: `git fetch upstream`
2.  Merge: `git merge upstream/master`
3.  Resolve conflicts locally.
4.  Push: `git push origin master`
