## Important Notice
This repository is slated for deletion, perhaps as soon as June 1, 2016.  Please find other solutions.  
There will be no future updates or support. 


RZPoseurWebView
===============

####RZPoseurWebView is a library to simplify migrating from UIWebView to WKWebview.####

**Features:**

- Near drop-in replacement for `UIWebView`, backed by `WKWebView`.
- If `WKWebView` is not available, `RZPoseurWebView` falls back on `UIWebView`.
- `RZPoseurWebView` smooths over the differences between `WKWebView` and `UIWebView` so you can migrate with ease:
  - `RZPoseurWebView` is delegate-compatible with `UIWebViewDelegate`, aside from types.
  - Supports native alerts, which `WKWebView` doesn't handle by default.
  - Matches `UIWebView` new window behavior by opening `target="_blank"` links in place.
