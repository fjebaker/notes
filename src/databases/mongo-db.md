# Using MongoDB

MongoDB is a document-based database storage service.

<!--BEGIN TOC-->
## Table of Contents
1. [Docker](#docker)
    1. [Web GUI with `mongo-express`](#web-gui-with-mongo-express)
2. [Mongo tools](#mongo-tools)
    1. [Compass](#compass)
    2. [Atlas](#atlas)
3. [Storage paradigms](#storage-paradigms)
    1. [Schema versioning](#schema-versioning)
    2. [Bucketing](#bucketing)

<!--END TOC-->

## Docker
The [Docker Hub](https://hub.docker.com/_/mongo/) contains all sorts of relevant information; for the simplest case, the one-liner
```bash
docker run --rm \ # delete after use
  --name mongo \
  -e MONGO_INITDB_DATABASE="development" \
  -v /path/to/storage:/data/db \
  -p 27017:27017 \
  -d \
  mongo
```

### Web GUI with `mongo-express`
[Mongo-Express](https://github.com/mongo-express/mongo-express)

## Mongo tools
Tools to make life easier with Mongo.

### Compass
Link to [compass](https://www.mongodb.com/try/download/compass)

### Atlas
All-in-one cloud storage solution, with a minimal version of compass.

Free for up to 512 MB of storage, and hosted through AWS for geographic redundancy.

[Link to Atlas](https://www.mongodb.com/cloud/atlas).

## Storage paradigms

Useful talks related to properly organising and planning mongo databases:

- Data Modeling with MongoDB by Yulia Genkina: [YouTube link](https://www.youtube.com/watch?v=yuPjoC3jmPA)

Covers everything you really need to know in getting started with Mongo and related paradigms.


### Schema versioning
As the data may evolve with the application lifetime, it is a good practice to include a `schema` version in the document, so that different schemas may be processed differently.

Consider a model storing contact information
```js
{
  "_id": 1,
  "schema_version": 1,

  "name": "Glen Cowan",
  "contact": {
    "email": "glen@cowan.co.uk",
    "office": "261"
  }
}
```
The way we contact an individual may evolve, and require new or different information to be stored. We can use the flexibility of the document storage model to create a new schema
```js
{
  "_id": 1,
  "schema_version": 2,

  "name": "Glen Cowan",
  "contact": {
    "email": "glen@cowan.co.uk",
    "office": {
      "building": "tolansky",
      "room": "421"
    },
    "www": "gcowan"
  }
}
```
By including the `schema_version`, our processing code can dispatch how the information is to be used depending on the schema provided; this way old and new data can coexist without compromising normalization.


### Bucketing
Data that shares a degree of similarity *could be* bucketed together into documents.

The example from Genkina's talk related to IoT measurements; instead of having a single document per measurements, one may anticipate the use case of the data. For example, since we may wish to calculate time series averages, or similar, another way of organising the data is into buckets:

```js
db.iot.updateOne(

  {
    "sensor": reading.sensor,
    "measurement_count": {"$lt": 200} // bucket size
  },

  {
    "$push": {
      "readings": {"v": value, "t": time}
    },
    "$inc": {"measurement_count": 1} // increment counter
  },

  {upsert: true} // create if doesn't exist

);
```

The document model now adopted is a bucket of similar measurements for a given sensor.

We may also anticipate that we will be calculating a lot of averages, and thus could simplify our work using a *computed pattern*, of performing calculations during write steps (a form of caching). In the above snippet, we could adjust the `$inc` command to also increment a total for that bucket:
```js
    "$inc": {"measurement_count": 1, "total": value}
```

so that averages of buckets can quickly be performed.
