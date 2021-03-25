# RethinkDB

RethinkDB is a JSON store, real-time database, optimized for continuously updating queries when new data is available. As such, it is fantastic for monitoring purposes, interactive data, marketplaces, streaming, and web delivery. As described in their [FAQ](https://rethinkdb.com/faq):

> instead of polling for changes, the developer can tell RethinkDB to continuously push updated query results to applications in realtime

The query language is derivative of NoSQL.

<!--BEGIN TOC-->
## Table of Contents
1. [Overview](#overview)
    1. [Data storage format](#data-storage-format)
2. [RethinkDB with Docker](#rethinkdb-with-docker)
3. [ReQL Query Language](#reql-query-language)
    1. [Examples](#examples)
        1. [Functional](#functional)
        2. [Composable](#composable)
        3. [Subqueries](#subqueries)
        4. [Expressions](#expressions)
        5. [Regex](#regex)
    2. [Connection](#connection)
    3. [More involved concepts](#more-involved-concepts)
4. [Geospatial use and geoemtry](#geospatial-use-and-geoemtry)
    1. [Data types](#data-types)
5. [Users and permissions](#users-and-permissions)

<!--END TOC-->

## Overview
Languages supported

- [JavaScript](https://rethinkdb.com/api/javascript/)
- [Python](https://rethinkdb.com/api/python/)
- [Ruby](https://rethinkdb.com/api/ruby/)
- [Java](https://rethinkdb.com/api/java/)

Client drivers connect to **port 28015**. Web UI present on **port 8080**.

### Data storage format
By default, RethinkDB uses `id` as the attribute for primary keys, which is auto-incremented.

## RethinkDB with Docker
Pull the latest image from the docker hub with 
```bash
docker pull rethinkdb
```

and start the database with a mounted volume for data, and a bound port for access:
```bash
docker run \
	--name rtdb \
	-p 8080:8080 \
  -p 28015:28015 \
  -p 29015:29015 \
	-v data:/data \
	-d \
	rethinkdb
```
You can then connect to [`http://localhost:8080/`](http://localhost:8080/) to access the UI and admin features.

## ReQL Query Language
The [RethinkDB Query Language](https://rethinkdb.com/docs/introduction-to-reql/) is described to differ from other NoSQL languages in the sense that is embedded into a programming language. All queries are **simply constructed**, they are **chainable** and they execute **on the server**. 


### Examples
In the following section, I will include Python examples:

```py
from rethinkdb import RethinkDB # import the RethinkDB package
r = RethinkDB()                 # create a RethinkDB object
conn = r.connect()              # connect to the server on localhost and default port
```

Queries are constructed to be lazy, and to be compatible with parallelism for quicker execution. The laziness is to say a query such as
```py
r.table('songs').has_fields('album').limit(5).run(conn)
```
will only accumulate 5 items before the query execution stops, as opposed to executing the full query and returning 5 items.

Serverside execution means the queries may also be stored for quick reuse:
```py
# get distinct artists
distinct_lastnames_query = r.table('songs').pluck('artist').distinct()

# Send it to the server and execute
distinct_lastnames_query.run(conn)
```

#### Functional
Queries may also be functional, such as
```py
r.table('songs').filter(lambda song: song['duration'] > 60).run(conn)
```

There are limitations to the types of functions that may be passed -- for example, `print` statements cannot be invoked, and `if` and `for` statements must be replaced with a ReQL command
```py
r.table('songs').filter(lambda song:
    r.branch(song['duration'] > 60, True, False)).run(conn)
```

#### Composable
ReQL queries are composable, in the sense that multiple may be combined, and JS code executed

> RethinkDB supports server-side JavaScript evaluation using the embedded V8 engine (sandboxed within outside processes, of course):

For example
```py
r.js('1 + 1').run(conn)
```
would evaluate the JS expression `1 + 1` server side. As such, the functional syntax can be extended to use JS functions

```py
r.table('songs').filter(r.js('(function (song) { return song.duration > 60; })')).run(conn)
```
#### Subqueries
Subqueries are also supported, such as a query to select all songs from artists who are in the `history` table:
```py
r.table('songs').filter(lambda song:
    r.table('history').pluck('artist').contains(song.pluck('artist'))).
    run(conn)
```
This allows for very complex queries to be easily constructed.

#### Expressions
Expressions are also supported. Here is a query which will search the `songs` table for all songs with more up-votes than down-votes, and subsequently increase the rating of the song by 1:
```py
r.table('songs').filter(lambda song: song['upvotes'] - user['downvotes'] > 0)
 .update(lambda song: {'rating': song['rating'] + 1}).run(conn)
```
For more, see the full [Python API reference](https://rethinkdb.com/api/python/).

#### Regex
You can [use regex in queries](https://rethinkdb.com/api/python/match) by using a `.match()` function call in the lambda:
```py
r.table('songs').filter(lambda song:
    song['name'].match(r"ing$")
).run(conn)
```

### Connection
For exploratory and interactive purposes, when creating a connection you can also call `.repl()` to ensure the connection is kept alive, and to avoid calling `.run(conn)` at the end of each query. See [this section of the documentation](https://rethinkdb.com/api/python/repl/).

### More involved concepts
Notes for the future on

- using [map-reduce](https://rethinkdb.com/docs/map-reduce/)
- [table joins](https://rethinkdb.com/docs/table-joins/)
- more on [lambda functions](https://rethinkdb.com/blog/lambda-functions/)

## Geospatial use and geoemtry
Adapted mainly from information in the [JS API on geospatial queries](https://rethinkdb.com/docs/geo-support/javascript/).

RethinkDB has native support for handling geometric data. Geoemtry objects are points mapped onto a sphere. Distances are calculated by RethinkDB as geodesics on a sphere. The data is by default interpreted as **latitude and longitude** (reverse order from e.g. Google maps) points:

> RethinkDB supports the WGS84 World Geodetic System’s reference ellipsoid and geographic coordinate system (GCS)

ReQL objects may be [converted to GeoJSON](https://rethinkdb.com/docs/geo-support/javascript/#using-geojson) and vice-versa.

To specify a table as containing geometric data, we apply an index
```js
r.table('map').indexCreate('locations', {geo: true})

```
The example data format for such a table would then be
```js
r.table('map').insert([
  {
    id: 1,
    name: 'Taunton',
    location: r.point(-3.1349583, 51.021485)
  },
  {
    id: 2,
    name: 'Bristol',
    location: r.point(-3.2307308, 51.0237906,)
  }
])
```

Calculating the distance between these points:
```js
r.table('map').get(1)('location').distance(r.table('geo').get(2)('location'))
```
or finding the nearest location to an arbitrary point
```js
var point = r.point(-3.651051, 51.0234467);  // Stonehenge
r.table('map').getNearest(point, {index: 'location'})
```

### Data types
The data types supported for geospatial queries are
- points
- lines
- polygons (i.e. at least three points)


## Users and permissions
[link to docs](https://rethinkdb.com/docs/permissions-and-accounts/)
