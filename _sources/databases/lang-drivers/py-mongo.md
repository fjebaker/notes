# Using MongoDB and Python
MongoDB provides a Python driver for effectively interacting with the Mongo Daemons. It can be installed easily with 
```
pip install pymongo
```

<!--BEGIN TOC-->
## Table of Contents
1. [Mongo storage paradigm](#mongo-storage-paradigm)
2. [Issuing commands to the server](#issuing-commands-to-the-server)
    1. [Generating sample data](#generating-sample-data)
    2. [CRUD Operations](#crud-operations)
        1. [Create](#create)
        2. [Read](#read)
        3. [Update](#update)
        4. [Delete](#delete)
    3. [A note on mongo predicated](#a-note-on-mongo-predicated)
    4. [Aggregation pipelines](#aggregation-pipelines)
3. [Settings](#settings)
4. [Authentication](#authentication)

<!--END TOC-->

## Mongo storage paradigm
Mongo stores everything as collections of documents, translated as JSON format (specifically BSON, the binary translation of JSON). MongoDB is able to perform all of the usual CRUD operations.

## Issuing commands to the server
A simple script for executing the `serverStatus` command using an instance of the `MongoClient`
```python
from pymongo import MongoClient

client = MonoClient("mongodb-url", port=27017)
db = client.admin
serverStatusResult = db.command("serverStatus")
```

### Generating sample data
Here's a small script for generating test data for a music database, provided you have an established `db`
```python
import random
adj = ["Infernal", "Bloody", "Freak", "Yellow", "Catastrophic", "Sad", "Happy", "Black", "Warm", "Cold"]
noun = ["Moon", "Child", "Graves", "Shake", "Corpse", "Cannibal", "Pig", "Green", "You", "God", "Satan"]
verb = ["Killing", "Saving", "Hating", "Loving", "Marry", "Creating", "Lifting"]

for i in range(500):
	song = {
		"artist": random.choice(adj) + " " + random.choice(noun),
		"song": random.choice(verb) + " " + random.choice(adj) + " " + random.choice(noun),
		"duration": random.randint(0, 360)
	}

	res = db.songs.insert_one(song)
	print("Created {} of 500 as {}".format(i+1, res.inserted_id))
```
which will print
```
# ...
Created 497 of 500 as 5e9d6d641f08210aec1a8790
# ...
```

### CRUD Operations
Here are described the different CRUD operations in the Python driver.

#### Create
Entries into a database can be created using
```python
db.insert_one({ ... })
db.insert_many([{ ... }, ... ])
```
These will return a result type, the documentation for which can be found [here](https://api.mongodb.com/python/current/api/pymongo/results.html#pymongo.results.InsertManyResult).
#### Read
Mongo supports database queries in an intuitive way
```python
res = db.some_collection.find_one({"query":"value"})
ress = db.some_collection.find({"query":"value"})

num = ress.count()
```
The result type `ress` is an instance of the `Cursor` class. Cursors are iterable and support `next()` calls (throwing `StopIteration` when exhausted). The objects returned are analogous to python dictionaries.

#### Update
Updating data in the database is also very straight forward, using methods like `update_one`, `update_many` and [`replace_one`](https://api.mongodb.com/python/current/api/pymongo/collection.html#pymongo.collection.Collection.replace_one), based off of the matches the methods find. We could perform a random update such as
```python
song = db.songs.find_one({})	# match all
print(song)

result = db.songs.update_one({'_id' : song.get('_id')}, {'$inc': {'duration':1}})

print("Number of items modified is {}".format(result.modified_count))

print(db.songs.find_one({'_id' : song.get('_id')}))

```
#### Delete
Deleting documents is as easy as the other operations, following the same `delete_one` and `delete_many` syntax as the other methods. For example
```python
result = db.songs.delete_many({'duration':300})
print(result.deleted_count)
```

### A note on mongo predicated
Regular expressions can be inserted into most matching parameters as a predicate
```python
res = db.songs.find({
		"artist":
			{"$regex": u"God", "$options":"-i"}	# -i ignores case sensitivity
	})
```
Note that the IDs are by default BSON, thus if you want to query them by string, you must use 
```python
from bson.objectid import ObjectId

_id = ObjectId(stringid)
``` 

### Aggregation pipelines
MongoDB allows multiple database requests to be amalgamated into one; consider our test song database, where we want to know the number of count for each duration. This could be either 360 individual database requests, or, more conveniently, a single [aggregated pipeline](https://docs.mongodb.com/manual/aggregation/)
```python
durationgroup = db.songs.aggregate([
	# define group data
	{ '$group':
		{
			'_id':'$duration',
			'count': {'$sum' :1 }
		}
	},
	# then sort data
	{ '$sort':
		{'_id':1}
	}
])

for group in durationgroup:
	print(group)
```

## Settings
TODO

## Authentication
TODO