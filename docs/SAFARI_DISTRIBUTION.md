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

## App Store Submission

### Manual (via Xcode)
To submit to the App Store, it is easiest to use Xcode locally:

1.  **Prepare the Project**:
    Run this command to build the extension and copy files into the Xcode project:
    ```bash
    pnpm build:safari:xcode
    ```

2.  **Open in Xcode**:
    Open `safari/Competitive Companion/Competitive Companion.xcodeproj`.

3.  **Archive & Upload**:
    - Select **Product** > **Archive**.
    - In the Organizer, click **Distribute App**.
    - Select **App Store Connect** > **Upload**.
    - Follow the prompts (Xcode handles certificates and signing automatically).

### Next Steps in App Store Connect

Once the upload is complete:

1.  **Log in**: Go to [App Store Connect](https://appstoreconnect.apple.com).
2.  **My Apps**: Click the "+" to create a new App (if you haven't already).
    - **Platform**: macOS.
    - **Name**: Competitive Companion.
    - **Language**: English (US).
    - **Bundle ID**: `com.competitive-companion.safari`.
    - **SKU**: `competitive-companion-safari`.
3.  **Prepare for Submission**:
    - **Screenshots**: Upload screenshots of the extension in action (Mac size).
    - **Description**: Add a description of what the extension does.
    - **Keywords**: competitive programming, cp, parser, codeforces, etc.
    - **Support & Marketing URL**: Link to the GitHub repository.
    - **Privacy Policy URL**: Link to `https://github.com/farseenmanekhan1232/competitive-companion/blob/master/PRIVACY.md` (once pushed).
    - **Build**: Scroll down to "Build" and click (+). Select the build you just uploaded via Xcode.
4.  **Copyright**: `2026 Farseen` (or your name).
5.  **Review Information**:
    - **Sign-in required**: Uncheck (no login needed).
    - **Notes**: "This is a Safari Web Extension for parsing competitive programming problems."
6.  **Submit for Review**: Click "Add for Review" and then "Submit".
