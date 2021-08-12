# Scrapy

[Scrapy](https://docs.scrapy.org/en/latest/index.html) is an incredible tool for writing web crawlers.

<!--BEGIN TOC-->
## Table of Contents
1. [Quick setup](#quick-setup)
2. [Useful recipes](#useful-recipes)
    1. [`follow` and `follow_all`](#follow-and-follow_all)
    2. [Downloading images](#downloading-images)
3. [Command line arguments](#command-line-arguments)

<!--END TOC-->


## Quick setup
```bash
scrapy startproject [name]
```

Use the scrapy shell to test out selectors
```bash
scrapy shell [URL]
```

Storing the output, e.g. as JSON
```bash
scrapy crawl [spidername] -O output.json
```

Creating new spiders can be done easily with
```bash
scrapy genspider spidername domain.com
```

## Useful recipes

### `follow` and `follow_all`
Tie additional requests together using 
```py
response.follow(url, callback=handler)
```
or a list of urls with
```py
response.follow_all(urls, handler)
```
Note, these do not have to explicitly be URLs, but any tag with a `href` will also work.

Example use:
```py
import scrapy


class AuthorSpider(scrapy.Spider):
    name = 'author'
    # ... 
    def parse(self, response):
        author_page_links = response.css('.author + a')
        yield from response.follow_all(author_page_links, self.parse_author)

    def parse_author(self, response):
        # handle page
        ...
```

### Downloading images
Images require the definition of an `Item` class, and the use of the [Images Pipeline](https://docs.scrapy.org/en/latest/topics/media-pipeline.html#using-the-images-pipeline).

In brief, enable the pipeline by modifying `settings.py` and adding
```py
ITEM_PIPELINES = {'scrapy.pipelines.images.ImagesPipeline': 1}
```

Next, define a location for the images to be stored with
```py
IMAGES_STORE = '/path/to/directory`
```
These stores may even be an FTP server, Amazon's S3, or Google Cloud.

After the pipeline has been enabled, create a class in `items.py`
```py
import scrapy

class ImageItem(scrapy.Item):
    # ... other relevant fields 
    image_urls = scrapy.Field()
    images = scrapy.Field()
```

To download an image, your spider then merely needs to return an instance of this item:
```py
from project.items import ImageItem
# ... 

class ImageSpider(scrapy.Spider):
    # ... 

    def parse_image(self, response):
        image_url = response.xpath("//img")[0].attrib["src]

        image = ImageItem()
        image["image_urls"] = [image_url]
        return image 
```


## Command line arguments
You can read in command line arguments in a spider class, e.g. in the `__init__` method:
```py
class QuotesSpider(scrapy.Spider):
    name = 'quotes'
    # ...
    def start_requests(self):
        # ...
        page = int(getattr(self, 'page', 1))
```
If the `page` attribute is not set, the value is set to the default, in this case `1`.

When launching the spider from the command line, we can now pass in the argument with
```py
scrapy crawl [spidername] -a page=10
```
