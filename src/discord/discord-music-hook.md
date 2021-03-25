
# Creating a Discord music feed using webhooks

This is more of an exercise in web-scraping than in creating webhooks. I'll include some detail at the end at what the webhook api is wrapping over when I find the motivation. We'll be scraping from the fantastic music review website [Sputnik Music](https://www.sputnikmusic.com/), and sourcing the music videos as YouTube urls.

<!--BEGIN TOC-->
## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Scraping Sputnik Music](#scraping-sputnik-music)
    1. [Querying YouTube](#querying-youtube)
    2. [Attaching to a webhook](#attaching-to-a-webhook)

<!--END TOC-->

## Prerequisites
We'll be using Python3 built-in virtual-environments, so you can install all of the prerequisites and recreate the environment with
```
python3 -m venv venv
source venv/bin/activate
pip install requests bs4 discord_webhooks
```

## Scraping Sputnik Music
There's loads of ways of sourcing a random album on [Sputnik Music](https://www.sputnikmusic.com/), but the method I settled on was also aiming to pick albums most likely to have a written review. For some reason, call it a false sense of intuition, I opted to use their user lists to find albums.

The album reviews themselves follow a URL format
```
/review/[some-numeric-id]/[album-name]
```
often a redirect from
```
/album/[some-different-numeric-id]/[the-same-album-name]/
```

Although we can guess random numeric ids, since they are sequential, it's really hard to know what album got attributed to it. Simply querying `/review/[numeric-id]/` yields a 404 (**Edit:** turns out `/album/[numeric-id]/` would have worked fine). So instead, if we examine user lists, they have URL structure
```
/list.php?listid=[list-id]&memberid=[creator-member-id]
```
which doesn't need the `memberid` query tag in order to find the correct site, and similarly uses sequential `[list-id]`. Perfect! We can then just generate a random number, query the id, and if we get content, continue, else try again with a different id.

My personal flavour for making `GET` requests is to use the `requests` module, and I always tend to follow the idiom of
```python
resp = requests.get(url, headers=headers, follow_redirect=True)
```
I like leaving `follow_redirect` on, because it's then more likely to reproduce exactly what the user experiences in their browser. 

Incidentally, the headers I pretty much always use to make my request look authentic are
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
For some websites, you might need to keep track if you're hoping links and put the last visited site in `Referer` or risk having your request denied.

For scraping through the dredges of HTML code, `BeautifulSoup` is a perfect library with many methods and search formats. So, using the inspector in the web browser, we see that the albums links in a list are contained in
```
<a href="/album/[id]/[name]" ... >
```
so we'll be lazy and scrape the correct tags with
```python
bs = bs4.BeautifulSoup(resp.text, 'html.parser')
albums = bs.find_all(lambda tag: tag.name=='a' and tag.has_attr('href') and bool(re.match(r"/album/\d*/", tag.get('href'))))
```

The review page is then found using the automatic redirect from performing the `GET` on
```python
url = "https://www.sputnikmusic.com" + albums[i]['href']
```

We perform the same reconnaissance on the review page and discover one of the governing tags for the review text itself is
```
<div id="leftColumn" ... >
```
Performing the same scrape as above with beautiful soup, now specialized for this tag, we then want to further restrict the format of our result to be a paragraph (some reviews will include the artist names before the review starts), which, to me, naive in the ways of computational linguistics and syntax classifications, is just a line of text with more than, say, 13 words.

We can extract these *paragraphs* with simple list comprehension
```python
review = bs.find(lambda tag: tag.name=='div' and tag.has_attr('id') and "leftColumn" in tag.get('id'))
paragraph = [i for i in review.text.split("\n") if len(i.split(' ')) > 13]
```
To further annoy the linguists, a *word* to me is anything separated by `0x20` ;).

As web pages can be quite unpredictable, we wrap all of this in some try-catch-else statements, ensure that if anything goes wrong it just skips that album in the list, or tries a new list if no albums are left, and then returns the paragraph and the `[album-name]` section of the review URL.

### Querying YouTube
There's plenty of YouTube APIs and wrappers out there for you to use if you want to query YouTube (and for any google product, for that matter), but since what we're doing is rather simple, we can minimize the effort and just write a handful of lines.

We know what the search query will be to try and find the correct album for the review we scraped from Sputnik, as it's just the `[album-name]` portion of the review page URL. To convert that easily to a HTTP friendly flavour, we can use `urllib` and search YouTube with
```python
query = urllib.parse.quote(album_name.replace('-', ' ')) # since the URL uses '-' instead of '%20'
url = "https://www.youtube.com/results?search_query=" + query
```
If you inspect the search page, you'll see everything nice and organized using standard and familiar HTML, but the response from `requests` doesn't parse with `BeautifulSoup`. Dumping it to a file for inspection, we see the site is dynamically rendered with JS, and all the fire content is delivered as a JSON object. We can extract this into a python dictionary really easily -- we note, the JSON content is delivered after `window["ytInitialData"] = ` from the file dump, so perform
```python
jsonstring = resp.text.split('window["ytInitialData"] = ')[1].split(";\n")[0]
webcontent = json.loads(jsonstring)
```
We'll dump this to a file too using the JSON pretty print formatting options
```python
json.dumps(text, indent=4, sort_keys=True)
```
and can start examining where the video `href`s are kept.

The resulting `webcontent` is a very, very nested dictionary. To obtain the list containing some of the search results, we need to index
```python
webcontent = webcontent["contents"]["twoColumnSearchResultsRenderer"]["primaryContents"]["sectionListRenderer"]["contents"]
```

We can then extract just the `/watch?v=` by traversing this list
```python
candidates = []
for item in webcontent:
	for i in item:
		try:
			watch = i["videoRenderer"]["navigationEndpoint"]["commandMetadata"]["webCommandMetadata"]["url"]
		except:
			pass
		else:
			candidates.append(watch)
```
Unfortunately, it seems to me we have to traverse with two for loops, as the playlist items are sorted seperately from plain videos, and since I want to include both, need both loops. I didn't bother remembering which loop is for which, but that's why they are there.

We can select a random (or in my case, the first) item from the `candidates` list and append it to `https://www.youtube.com` to finalize our video URL.

### Attaching to a webhook
Fortunately, the embedding in Discord is already pretty savvy, so there isn't too much processing left to undertake.

On a server, create a webhook and get the associated `url`; then the entire webhook posting script is simply
```
from discord_webhook import DiscordWebhook, DiscordEmbed
import sputnik
import youtube

URL = "your-webhook-url"

content, album = sputnik.get_new_review()
youtubeURL = youtube.get_url(album)

content += "\n\n{}".format(youtubeURL)

wh = DiscordWebhook(url=URL, content=content)
resp = wh.execute()
```
![Louis Theroux does Sputnik](https://github.com/Dustpancake/Dust-Notes/blob/master/webhooks/louis-theroux-does-sputnik.jpg "Louis Theroux does Sputnik")
