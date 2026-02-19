# Privacy Policy for Competitive Companion

Competitive Companion extracts problem data from online judges. This only happens when the user triggers the page action. The extracted problem data does not contain personal data.

The extracted problem data is shared with various ports on `localhost`. These are port 4243, the ports in [this file](https://github.com/farseenmanekhan1232/competitive-companion/blob/master/src/hosts/hosts.ts) and any custom ports specified by the user in the extension's settings. Extracted problem data is never sent to non-localhost hosts.

To enable/disable the page action based on whether the pages you are visiting are supported by a parser, the extension listens for navigation changes. This data is only used to determine whether the extension has a problem or a contest parser that can run on the URL and is not shared in any way.
