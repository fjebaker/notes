# Python `requests` cookbook
For easy automated access to the internet.

### Sessions
Sessioning is an easy way to ensure that metadata like cookies, or referer headers are maintained when scraping a website. They also provide an 'environment' for request conditions.

We can define a session, and mount transport adapters with
```python
session = requests.Session()
adapter = requests.adapters.HTTPAdapter(pool_connections=10, pool_maxsize=10, max_retries=10)
session.mount('https://', adapter)	# example, but http and https are included in HTTPAdapter
session.mount('http://', adapter)
```

#### Headers in sessions
So that headers are dynamically updates when visiting different pages during a session, the `requests` library includes a special method to add new and update old headers without annihilating those received organically
```python
session.headers.update({
		'old header' 		: 'updated value', 
		'some new header' 	: 'new value'
})
```
As always, my commonly used headers are
```python
headers = {
    'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:70.0) Gecko/20100101 Firefox/70.0',
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
    'Accept-Language': 'en-US,en;q=0.5',
    'DNT': '1',
    'Connection': 'keep-alive',
    'Referer': '',
    'Upgrade-Insecure-Requests': '1',
}
```

### Streaming file content
In order to stream bytes instead of downloading the full file we can use the `stream` kwarg. An example implementation is
```python
with requests.get(url, stream=True) as r:
	r.raise_for_status()		# raises if bad status code
	with open(filename, 'wb') as f:
		for chunk in r.iter_content(chunk_size=8192):	# 2^13
			if chunk:			# ensures content available, not just keep alive resp
				f.write(chunk)
```
Combining this stream idiom with the sessioning can provide very fast downloads.