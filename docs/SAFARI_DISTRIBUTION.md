# Safari Extension Distribution Guide

This guide explains how to build, sign, and publish the Safari extension for Competitive Companion using GitHub Actions.

## Prerequisites

- **Apple Developer Account**: Required for signing and notarizing the application.
- **Xcode**: Required to generate the initial project wrapper and for local testing.

## One-Time Setup

1.  **Generate the Xcode Project Wrapper**:
    Run the following command in the root of the repository:
    ```bash
    mkdir -p safari
    xcrun safari-web-extension-converter build-safari --project-location safari --app-name "Competitive Companion" --bundle-identifier com.yourname.competitive-companion
    ```
    *Note: Replace `com.yourname.competitive-companion` with your actual Bundle ID.*

2.  **Commit the Project**:
    Commit the generated `safari` directory to the repository. This project serves as the container for the extension.

3.  **Configure Signing in Xcode**:
    Open `safari/Competitive Companion.xcodeproj`.
    - Select the "Competitive Companion" target.
    - Go to "Signing & Capabilities".
    - Select your Team.
    - Repeat for the "Competitive Companion Extension" target.
    - Ensure both targets build and run locally.

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

## Running the Workflow

The release workflow runs automatically when you push a tag starting with `v*` (e.g., `v2.63.0`). You can also trigger it manually from the "Actions" tab.
