# Making HTTP requests and parsing in JS and node.js

Web scraping is a very powerful tool, and at the heart of the scraping techniques is the humble GET request. These notes are for specific JS implementations of common idioms

<!--BEGIN TOC-->
## Table of Contents
1. [Making HTTP requests](#making-http-requests)
    1. [HTTP client](#http-client)
    2. [XMLHttpRequest](#xmlhttprequest)
    3. [jQuery Ajax in clients](#jquery-ajax-in-clients)
    4. [Axios](#axios)
    5. [The (deprecated) `request` package](#the-deprecated-request-package)
2. [Parsing response data](#parsing-response-data)
    1. [Cheerio](#cheerio)

<!--END TOC-->

## Making HTTP requests
There are several routes for making HTTP requests in JavaScript. I will cover a few of them here.

### HTTP client
TODO

### XMLHttpRequest
The most traditional of the HTTP modules, XMLHttpRequest is a browser asynchronous library supporting many of the common HTTP methods. For node, we install a wrapper around this library `npm i xmlhttprequest` designed to emulate the browser HTTP client. 
```js
const XMLHttpRequest = require("xmlhttprequest").XMLHttpRequest;

const http = new XMLHttpRequest();

http.open('GET', 'url');
// headers must be set between open() and send()
http.setRequestHeader('someNewHeader', 'value');

http.send();
http.onreadystatechange = (e) => {
	console.log(http.responseText)
};
```
Note that the Ajax specification does not allow **User-Agent** headers to be changed.

### jQuery Ajax in clients
TODO

### Axios
The [`axios` project](https://www.npmjs.com/package/axios) is arguably the de-facto standard for making HTTP/HTTPS requests with JS.

```js
const axios = require('axios');

request('url').then(resp => {
	// handle resp if success
}).catch(err => {
	// handle error
}).then(() => {
	// always executed
})
```

### The (deprecated) `request` package
Similar to the Python `requests` module, [`request`](https://www.npmjs.com/package/request) is a JS wrapper around. The syntax is, likewise, very similar, e.g.
```js
const request = require('request');

request('url', (err, resp, body) => {
	if (!err && resp.statusCode == 200) {
		// good request
	} else {
		// bad request
	}
});
```
Headers and other content can be included in an argument object
```js
const opts = {
	url: 'url',
	headers : {
		'someHeader': 'value',
		'anotherHeader': 'otherValue'
	}
};
request(opts, (err, resp, body) => {
	// ...
});
```
## Parsing response data
My aim here was to find a library similar to Python's BeautifulSoup. From minimal research, I quickly stumbled on a few packages, which I will document here. Additionally, I wanted a library that used the familiar jQuery syntax.

My cookbook of jQuery searches is [here (todo)](), updated as I find new recipes and commands.

### Cheerio
Cheerio provides jQuery like parsing in node. Syntactically, it is very easy to use, e.g.
```js
const cheerio = require('cheerio');

const $ = cheerio.load('some HTML string');

var href = $('searchquery').find('secondary').href;
```
