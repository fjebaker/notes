# Using RethinkDB with Flask

I have already written [some notes on RethinkDB](https://github.com/furges/notes/blob/master/databases/rethink-db.md), and have been using it in a jukebox server project. I believe I came up with quite an elegant instantiation of RethinkDB client driver with Flask. It is similar to [existing solution](https://github.com/rethinkdb/rethinkdb-example-flask-backbone-todo/blob/master/todo.py), but without the need of carting round global functions and obscene imports.

<!--BEGIN TOC-->
## Table of Contents
1. [Setup](#setup)
    1. [`app.py` content](#app-py-content)
    2. [Registering the database connection in the application context](#registering-the-database-connection-in-the-application-context)
    3. [Using the connection](#using-the-connection)
2. [Comments](#comments)

<!--END TOC-->

## Setup
First, we set up the project and get our requirements
```bash
python3 -m venv venv && source venv/bin/activate

pip install flask rethinkdb
```
using a directory structure
```
my_project/
    - __init__.py
    - database.py
requirements.txt
app.py
config.py
```
**NB:** this is not a good layout, but sufficient for this example. We create a configuration for Flask:
```py
# config.py

class Config():
    DEBUG = False
    RDB_HOST = 'localhost'
    RDB_PORT = '28015'

class Development(Config):
    DEBUG = True    # NB seems to be a bug with this not actually enabling debug mode

class Production(Config):
    ...
```
where we provide the host and port of RethinkDB.

### `app.py` content
In `app.py` we initialize, as with any case, our Flask app
```py
# app.py
from flask import Flask

# import from database module to setup database in app context
from my_project.database import init_app_database

app = Flask(__name__)

# use development configuration
app.config.from_object('config.Development')

# register blueprints and endpoints here

init_app_database(app)

if __name__ == '__main__':
    app.run(debug=app.config["DEBUG"]) # fix for debug mode
```

All of this is fairly standard, with the exception of calling this `init_app_database` function. We will implement this in the `my_project/database.py` file:

### Registering the database connection in the application context
It is best to have one database connection per request. The reasons for this is that connections can drop or timeout, can be pooled to be optimized, and in general can be quite fiddly -- so it is best to let the database and the driver handle connection optimization, and we as server architects will just create a connection in a context where we need one.

We will do this by instantiating a connection *only once one is needed*, and have each connection 'unique' to the context in which it is used. I say unique in inverted commas, since under the hood this could be different, but we don't care as implementers; we want a connection per request.

Flask has some handy registration functions to assist with this, such as being able to register a function with `app.before_request()` which gets called *before each request*. We also use `app.teardown_appcontext()` to register a function to be called when a request context is garbage collected.

Additionally, we use [Flask's `g` variable](https://flask.palletsprojects.com/en/1.1.x/api/#flask.g), which is related to the Flask [application context](https://flask.palletsprojects.com/en/1.1.x/appcontext/). It is sufficient to know that the lifetime of `g` is the lifetime of the request.

```py
# my_project/database.py
from flask import current_app, g
from rethinkdb import r 
from rethinkdb.errors import RqlRuntimeError 

def _connect_to_database():
    """ establish and return a connection object """
    return r.connect(
        host=current_app.config["RDB_HOST"],
        port=current_app.config["RDB_PORT"]
    )

def get_db_conn():
    """ creates and/or returns conn object stored in g._db_conn """
    if '_db_conn' not in g:
        g._db_conn = _connect_to_database()

    return g._db_conn

def teardown_db(env):
    """ teardown function to remove g._db_conn if exists """
    conn = g.pop('_db_conn', None)
    
    if conn is not None:
        current_app.logger.info("Disconnecting from database.")
        conn.close()

def register_db_to_context():
    """ registers function to retrieve connection in g.get_conn """
    g.get_conn = get_db_conn

def init_app_database(app):
    """ application init to register database functions """
    app.teardown_appcontext(teardown_db)
    app.before_request(register_db_to_context)
```

The `register_db_to_context()` function essentially makes `g.get_conn` behave a little like a property.

### Using the connection
With this setup, we can now at any point in our program, without any additional imports besides Flask's `g` and RethinkDB's `r` use this connection

```py
r.table("some_table").run(g.get_conn())

```

## Comments
My initial plan was to see if I could dynamically register `g.conn` with `@property`  behaviour, and although it [can be done dynamically](https://stackoverflow.com/questions/1325673/how-to-add-property-to-a-class-dynamically), it cannot be done on instances without modifying `__getattribute__` and the like. I figured using a function call for now is sufficient, but may try and develop a more elegant solution in the future which makes using RethinkDB, and others, more intuitive.
