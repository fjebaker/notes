# Using Python Flask

[Flask](https://flask.palletsprojects.com/en/1.1.x/) is a huge HTTP web library build on [Werkzeug](https://palletsprojects.com/p/werkzeug/) (a [WSGI](https://wsgi.readthedocs.io/en/latest/) library), with a tonne of features and additional packages. In these notes, I'll include common solutions to problems, project architectures, and useful packages.

<!--BEGIN TOC-->
## Table of Contents
1. [Basic setup](#basic-setup)
    1. [File serving](#file-serving)
2. [Configuration](#configuration)
    1. [Using `config.py`](#using-config-py)
    2. [The `FLASK_ENV` environment variable](#the-flask_env-environment-variable)
3. [Blueprints](#blueprints)
4. [Application Contexts](#application-contexts)
    1. [`request` object](#request-object)
    2. [The request context](#the-request-context)
    3. [`current_app`](#current_app)
5. [HTTP Endpoints](#http-endpoints)
    1. [Parsing Forms](#parsing-forms)
6. [Logging](#logging)
7. [Flask CLI](#flask-cli)
8. [Flask-Restful](#flask-restful)
    1. [Response marshaling](#response-marshaling)
    2. [Argument parsing](#argument-parsing)
9. [Databases](#databases)
    1. [Flask MongoEngine](#flask-mongoengine)
    2. [RethinkDB](#rethinkdb)
    3. [SQLAlchemy](#sqlalchemy)
    4. [Postgres](#postgres)
10. [Additional](#additional)
    1. [Enabling CORS](#enabling-cors)

<!--END TOC-->

## Basic setup
A good guide is [this quick-start](https://flask-restplus.readthedocs.io/en/stable/quickstart.html#a-minimal-api); I elaborate here and leave out other information.

The minimal setup for flask is to initialize an app context in an `app.py` or a `run.py`. 

```python
# app.py
from flask import Flask 
app = Flask(__name__)

# register routes here
@app.route('/')
def index():
    return "Hello World"

if __name__ == '__main__':
    app.run()
```

Although the server can be started using a direct call `python app.py`, for environment variable utilization, and general ease of practice, it is more convenient to use `flask run`.

URL endpoints can be registered in different way, but the decorator method is a common practice.

### File serving

## Configuration
Configuration in Flask can be quite daunting. Fortunately, there are numerous guides, such as [this one by Pythonise](https://pythonise.com/series/learning-flask/flask-configuration-files) that clarify the process.

The default config variables are
```py
{
    'APPLICATION_ROOT': '/',
    'DEBUG': True,
    'ENV': 'development',
    'EXPLAIN_TEMPLATE_LOADING': False,
    'JSONIFY_MIMETYPE': 'application/json',
    'JSONIFY_PRETTYPRINT_REGULAR': False,
    'JSON_AS_ASCII': True,
    'JSON_SORT_KEYS': True,
    'MAX_CONTENT_LENGTH': None,
    'MAX_COOKIE_SIZE': 4093,
    'PERMANENT_SESSION_LIFETIME': datetime.timedelta(days=31),
    'PREFERRED_URL_SCHEME': 'http',
    'PRESERVE_CONTEXT_ON_EXCEPTION': None,
    'PROPAGATE_EXCEPTIONS': None,
    'SECRET_KEY': None,
    'SEND_FILE_MAX_AGE_DEFAULT': datetime.timedelta(seconds=43200),
    'SERVER_NAME': None,
    'SESSION_COOKIE_DOMAIN': None,
    'SESSION_COOKIE_HTTPONLY': True,
    'SESSION_COOKIE_NAME': 'session',
    'SESSION_COOKIE_PATH': None,
    'SESSION_COOKIE_SAMESITE': None,
    'SESSION_COOKIE_SECURE': False,
    'SESSION_REFRESH_EACH_REQUEST': True,
    'TEMPLATES_AUTO_RELOAD': None,
    'TESTING': False,
    'TRAP_BAD_REQUEST_ERRORS': None,
    'TRAP_HTTP_EXCEPTIONS': False,
    'USE_X_SENDFILE': False
}
```
which are accessible, extendable and modifiable with 
```py
app.config["key"] = "value"
```
We can configure configuration in [numerous different ways](https://flask.palletsprojects.com/en/1.1.x/config/):

- environment variables
- from dictionaries
- from Python class objects
- from Python `.cfg` files

### Using `config.py`
The file `config.py`, located at the same level as `app.py` should be used to create configuration classes for Flask. This could involve reading from a more conventional file, taking in environment variables, or reading from a bitestream -- or just holding named variables; consider this simple configuration file
```py
# config.py

class Config:
    DATABASE_ADDR = "some address"
    FILE_DIRECTORY = "/path/to/files"

class Development(Config):
    DEBUG = True
    TESTING = True 

class Production(Config):
    FILE_DIRECTORY = "/some/other/directory"

```
here we have specified three configurations, which we can load into flask with
``` py
app.config.from_object("config.Development")
```
for e.g. development. Note that you do not need to explicitly `import config` as Flask with handle the import so that code in `config.py` does not arbitrarily execute more than once.

Link to the API for [the application object](https://flask.palletsprojects.com/en/1.0.x/api/#flask.cli.AppGroup.command).

### The `FLASK_ENV` environment variable
The environment variable `FLASK_ENV` gets mapped into `app.config["ENV"]` and controls some additional features in the environment to use. Good practice is to use this variable in your own application configuration
```py
if app.config["ENV"] == "development":
    app.config.from_object("config.Development")
else:
    app.config.from_object("config.Production")
```


## Blueprints

## Application Contexts
[documentation](https://flask.palletsprojects.com/en/1.1.x/appcontext/)
[api](https://flask.palletsprojects.com/en/1.1.x/api/#flask.session)

### `request` object

### The request context
`@app.before_request` and `@app.teardown_request` decorators

### `current_app`
[`current_app`](https://flask.palletsprojects.com/en/1.1.x/api/#flask.current_app)

## HTTP Endpoints

### Parsing Forms

## Logging
There is a lot of information available [in the docs](https://flask.palletsprojects.com/en/1.1.x/logging/), however for most use cases, it is sufficient to know that the Flask logger is accessible with `app.logger` or `current_app.logger`. The handler is available and modifiable
```py
from flask.logging import default_handler
default_handler.setFormatter(formatter)
```
## Flask CLI
The Flask CLI comes with a few built-in commands
```
(venv) ophelia: asteroid-flask $ flask
Usage: flask [OPTIONS] COMMAND [ARGS]...

  A general utility script for Flask applications.

  Provides commands from Flask, extensions, and the application. Loads the
  application defined in the FLASK_APP environment variable, or from a
  wsgi.py file. Setting the FLASK_ENV environment variable to 'development'
  will enable debug mode.

    $ export FLASK_APP=hello.py
    $ export FLASK_ENV=development
    $ flask run

Options:
  --version  Show the flask version
  --help     Show this message and exit.

Commands:
  routes  Show the routes for the app.
  run     Run a development server.
  shell   Run a shell in the app context.
```

You can, however, for your application, provide additional commands with the [`flask.cli`](https://flask.palletsprojects.com/en/1.1.x/cli/#custom-commands) module. This module is itself built on top of [click](https://click.palletsprojects.com/en/7.x/).
```py
import click
from flask import Flask

app = Flask(__name__)

@app.cli.command("new-table")
@click.argument("name")
def add_table_to_database(name):
    ...
```
Commands can also be added through blueprints. There is also a [note about application context](https://flask.palletsprojects.com/en/1.1.x/cli/#application-context), which discusses how you can hoist and/or sink the context for the CLIcommands.

## Flask-Restful

### Response marshaling
The data returned by an endpoint or rest resource may contain additional or too few fields for what the expected response ought to contain -- Flask Restful includes a convenience decorator `@marshal_with()` to graft the response into an expected format. Consider this example for returning user information
```py
from flask_restful import marshal_with, fields, Resource

user_model = {
    "name": fields.String,
    "uid": fields.Int,
    "data": fields.Nested({
        "full_name": fields.String,
        "created": fields.String,
        "links": fields.List(fields.String)
    })
}

@app.route("/user/<int:id>")
class Users(Resource):

    @marshal_with(user_model)
    def get(self, _id):
        # database lookup
        user = fetch_from_database(_id)
        if user:
            return user, 200
        else:
            return {}, 400
```
Now, irrespective of the fields returned from the database, `@marshal_with()` guarantees that the fields we specified will be in the response.

In the [documentation](https://flask-restx.readthedocs.io/en/latest/marshalling.html) it is explained that `@marshal_with()` takes the optional keyword `envelope="some_field"`, which acts to put the marshalled response into a JSON structure under `some_field`.

There is also `marshal()`, which is the non-decorator version, which returns a dictionary structure in cohesion with the model
```py
marshal(data, model)
```

### Argument parsing
Behaving in much the same way as the built-in `argparse` library, Flask Restful includes
```py
from flask_restplus import reqparse

parser = reqparse.RequestParser()
parser.add_argument('rate', type=int, help='Rate to charge for this resource')
args = parser.parse_args()
```
However here `args` is now a dictionary.

Another good note is to include the `strict=True` flag in `.parse_args()` so that an error is thrown if additional fields are sent.

The search order for argsparse delves all the way through query structure, request data, and any json information.

## Databases

### Flask MongoEngine
[API](http://docs.mongoengine.org/apireference.html?highlight=save#mongoengine.DynamicDocument.save)
[documentation](https://flask.palletsprojects.com/en/1.1.x/patterns/mongoengine/#creating-data)
[more documentation](http://docs.mongoengine.org/projects/flask-mongoengine/en/latest/)

[raspi fix](https://stackoverflow.com/questions/48060354/configurationerror-server-at-127-0-0-127017-reports-wire-version-0-but-this-v)

### RethinkDB
See my [writeup](https://github.com/febk/notes/blob/master/python/flask/rethink-db-with-flask.md).

### SQLAlchemy
A heavy handed and verbose `sqlite3` approach can be seen in [the documentation](https://flask.palletsprojects.com/en/1.1.x/tutorial/database/). A more elegant way to use SQL based databases is using SQLAlchemy.

### Postgres
There is a very comprehensive guide [on Medium](https://medium.com/better-programming/cookiecutter-template-to-build-and-deploy-your-flask-api-with-postgres-database-20ad99b8dae4) for creating a Flask API with Postgres.

## Additional

### Enabling CORS
Found in [this SO answer](https://stackoverflow.com/questions/25594893/how-to-enable-cors-in-flask), the trick here is
```py
from flask import Flask
from flask_cors import CORS, cross_origin

app = Flask(__name__)
cors = CORS(app)
app.config['CORS_HEADERS'] = 'Content-Type'

@app.route("/")
@cross_origin()
def helloWorld():
  return "Hello, cross-origin-world!"
```
