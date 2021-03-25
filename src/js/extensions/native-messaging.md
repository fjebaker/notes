# Native Messaging for Browser Extensions

I recently reinstalled my machine without properly backing up custom extensions, so had to relearn how to perform native messaging properly. The concept is simple -- it allows browser extensions to communicate with native applications on the host machine (saving e.g. communication to webservices). More information can be found in the [Mozilla Documentation](https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/Native_messaging).

<!--BEGIN TOC-->
## Table of Contents
1. [Problem Description](#problem-description)
2. [Solution:](#solution:)
    1. [Layout and Manifest](#layout-and-manifest)
    2. [Creating a message](#creating-a-message)
    3. [Receiving the message (Python)](#receiving-the-message-(python))
3. [Some additional notes](#some-additional-notes)

<!--END TOC-->

## Problem Description
Say you have a script which scrapes and downloads from a webpage, which you would like to embed into the webpages themselves, so that you can simply press a button whilst browsing to start the scraping process.

## Solution:


### Layout and Manifest
In the extension's `manifest.json` we need to include permissions that allow it to use `nativeMessaging`; we include the line
```JS
"permissions": ["nativeMessaging", "tabs", "<all_urls>"]
```

We also will need to create a script/application capable of receiving the extension's messages (see [Receiving the message (Python)](#toc-sub-tag-4)). This script can only be accessed as described in an application manifest JSON descriptor, located (for Firefox) in:

| System | Scope | Path |
|-|-|-|
| OSX | Global | `/Library/Application Support/Mozilla/NativeMessagingHosts/<name>.json` |
| OSX | User | `~/Library/Application Support/Mozilla/NativeMessagingHosts/<name>.json` |
| \*nix | Global | `/usr/{lib,lib64,share}/mozilla/native-messaging-hosts/<name>.json` |
| \*nix | User | `~/.mozilla/native-messaging-hosts/<name>.json` |


This JSON file, in a simple case, can be formatted with just
```JSON
{
  "name": "<name>",
  "description": "Native messaging example",
  "path": "/path/to/script/or/application",
  "type": "stdio",
  "allowed_extensions": [ "example@extension.org" ]
}
```
These fields should be pretty self explanatory. We have specified which extension is allowed to message this application, and the communication type, i.e. `stdio`, which delivers the message as `stdin`.

### Creating a message
On the page layer of our extension, we create a new button in the DOM with a simple callback
```JS
function callBack() {
	browser.runtime.sendMessage({
		content: "Hello World"
	});
}
```
which passes a JSON object to the background layer of the extension. The reason we do this is we may wish to wait for a response from the application, but if the tab/page is closed, the page layer execution ceases, and the return message is lost. Hence, by raising the message handling to the background layer, we ensure message responses are always received and handled.

In our background script we then add a runtime listener
```JS
browser.runtime.onMessage.addListener(handleMessage);
```
where the `handleMessage` callback is implemented, for example, as:
```JS
function handleMessage(request, sender, sendResponse) {
	browser.runtime.sendNativeMessage(
		"badtube",	// which application to send to, i.e. the name in the application manifest
		{
			url: request.all_urls // message body, a JS object
		}
	).then(
		onResponse,	// signature (resp) => { ... }
		onError		// signature (err) => { ... }
	);
}
```

### Receiving the message (Python)

On the application side, we need a small script to handle the incoming message. In Python, this is very straight forward:
```Python
#!/bin/bash/python3

import json, sys, struct

def read_message():
	length = sys.stdin.buffer.read(4)		# first 4 chars give the message length
	length = struct.unpack('=I', length)[0]	# unpack into integer
	return json.loads(sys.stdin.buffer.read(length).decode("utf-8"))	# read, decode, and load

def return_message(msg):
	msg = json.dumps(msg).encode('utf-8')
	length = struct.pack('=I', len(msg))
	sys.stdout.buffer.write(length)
	sys.stdout.buffer.write(msg)
	sys.stdout.buffer.flush()		# ensure the buffer is sent


msg = read_message()
return_message({"content": "World says Hello back!"})
```

The paradigm applies to all other languages the same.

## Some additional notes
Different aspects of this process are logged to different consoles all over the place; the background layer logs to the console in `about:debugging`, when inspecting the specified extension, whereas errors occurring at the native messaging layer themselves are logged to the browser console (Shift + Cmd + J on Mac, else Firefox Menu -> Web Developer -> Browser Console), and messages on the page layer are logged to the conventional console.