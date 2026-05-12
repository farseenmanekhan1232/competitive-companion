//
//  ViewController.swift
//  Competitive Companion
//
//  Created by Farseen on 18/02/26.
//

import Cocoa
import SafariServices
import WebKit

let extensionBundleIdentifier = "com.competitive-companion.safari.extension"

class ViewController: NSViewController, WKNavigationDelegate, WKScriptMessageHandler {

    @IBOutlet var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.webView.navigationDelegate = self

        self.webView.configuration.userContentController.add(self, name: "controller")

        self.webView.loadFileURL(Bundle.main.url(forResource: "Main", withExtension: "html")!, allowingReadAccessTo: Bundle.main.resourceURL!)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        diagnoseExtensionState()
    }

    private func diagnoseExtensionState() {
        let appBundle = Bundle.main
        print("[DIAG] App bundle path: \(appBundle.bundlePath)")
        print("[DIAG] App bundle identifier: \(appBundle.bundleIdentifier ?? "nil")")

        if let pluginsURL = appBundle.builtInPlugInsURL {
            print("[DIAG] PlugIns directory: \(pluginsURL.path)")
            do {
                let contents = try FileManager.default.contentsOfDirectory(at: pluginsURL, includingPropertiesForKeys: nil)
                for url in contents {
                    print("[DIAG] Found in PlugIns: \(url.lastPathComponent)")
                    if let pluginBundle = Bundle(url: url) {
                        print("[DIAG]   -> Bundle ID: \(pluginBundle.bundleIdentifier ?? "nil")")
                        print("[DIAG]   -> Extension plist: \(pluginBundle.infoDictionary?["NSExtension"] ?? "nil")")
                    }
                }
            } catch {
                print("[DIAG] Failed to read PlugIns directory: \(error.localizedDescription)")
            }
        } else {
            print("[DIAG] builtInPlugInsURL is nil")
        }

        if let extBundle = Bundle(identifier: extensionBundleIdentifier) {
            print("[DIAG] Extension bundle resolved: \(extBundle.bundlePath)")
        } else {
            print("[DIAG] Extension bundle NOT resolved for identifier: \(extensionBundleIdentifier)")
        }

        SFSafariExtensionManager.getStateOfSafariExtension(withIdentifier: extensionBundleIdentifier) { (state, error) in
            DispatchQueue.main.async {
                if let error = error {
                    print("[DIAG] getStateOfSafariExtension ERROR: \(error.localizedDescription)")
                    self.webView.evaluateJavaScript("showError('getState error: \(self.jsEscape(error.localizedDescription))', true)")
                    return
                }

                guard let state = state else {
                    print("[DIAG] getStateOfSafariExtension returned nil state")
                    self.webView.evaluateJavaScript("showError('Extension state is nil', true)")
                    return
                }

                print("[DIAG] Extension state -> isEnabled: \(state.isEnabled)")
                self.webView.evaluateJavaScript("show(\(state.isEnabled), true)")
            }
        }
    }

    private func jsEscape(_ string: String) -> String {
        return string
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "'", with: "\\'")
            .replacingOccurrences(of: "\n", with: "\\n")
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if (message.body as! String != "open-preferences") {
            return;
        }

        SFSafariApplication.showPreferencesForExtension(withIdentifier: extensionBundleIdentifier) { error in
            DispatchQueue.main.async {
                guard error == nil else {
                    print("Error opening Safari preferences: \(error!.localizedDescription)")
                    return
                }
                NSApplication.shared.terminate(nil)
            }
        }
    }

}
