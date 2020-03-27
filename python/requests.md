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
Combining this stream idiom with the Sessioning can provide very fast downloads.