# Using FastAPI

[FastAPI](https://fastapi.tiangolo.com/) is a framework for quickly creating REST (and other) services, based on a Asynchronous Server Gateway Interface (ASGI), the colloquial spiritual successor to WSGI. As a result, it uses the Python3.x `asyncio` syntax to quickly craft API services.

Additionally, FastAPI ships with [Swagger](https://swagger.io/) and [ReDoc](https://swagger.io/blog/api-development/redoc-openapi-powered-documentation/), using JSON schemas, and the [OpenAPI](https://www.openapis.org/) standard.

Useful pre-fab endpoints are
- `/docs`: Swagger endpoint
- `/redoc`: ReDoc


<!--BEGIN TOC-->
## Table of Contents
1. [Defining an endpoint](#toc-sub-tag-0)
	1. [Exception handling](#toc-sub-tag-1)
	2. [Alternative status codes](#toc-sub-tag-2)
	3. [Alternative response types](#toc-sub-tag-3)
2. [Using `pydantic` schemas](#toc-sub-tag-4)
	1. [Request data](#toc-sub-tag-5)
	2. [Marshalling](#toc-sub-tag-6)
3. [Scaling with `APIRouter`](#toc-sub-tag-7)
4. [CORS](#toc-sub-tag-8)
5. [Deploying with `uvicorn`](#toc-sub-tag-9)
<!--END TOC-->

## Defining an endpoint <a name="toc-sub-tag-0"></a>
We define a simple endpoint with
```py
from fastapi import FastAPI, Request

app = FastAPI()

@app.get('/')
async def home():
    return {"message": "home"}
```

All standard (and some exotic) HTTP methods are supported. See the [docs](https://fastapi.tiangolo.com/tutorial/first-steps/#operation) for more.

### Exception handling <a name="toc-sub-tag-1"></a>
As is explained in the [docs](https://fastapi.tiangolo.com/tutorial/handling-errors/#install-custom-exception-handlers), we can install a custom exception handler to control the flow of a request a little clearer.

For example
```py
from fastapi import FastAPI, Request

app = FastAPI()

class CustomException(Exception):
    def __init__(self, name:str):
        self.name = name


@app.exception_handler(CustomException)
async def handle(request: Request, exc: CustomException):
    ... # handle and return 4xx

@app.get("/item/{oid}")
async def get_item(oid: str):
    # illustrative
    raise CustomException("Bad Endpoint")

```

### Alternative status codes <a name="toc-sub-tag-2"></a>
[Returning additional status codes](https://fastapi.tiangolo.com/advanced/additional-status-codes/) is achieved by instancing the `JSONResponse` object:
```py
from fastapi.responses import JSONResponse

@app.get("/")
async def get():
    return JSONResponse(
        status=400,
        content={"message":"bad request"}
    )
```

This can also be done by [modifying the response instance](https://fastapi.tiangolo.com/advanced/response-change-status-code/#use-a-response-parameter) that can be obtained at the endpoint:
```py
@app.get("/item/{oid}", status_code=200)
def get_item(oid: str, response: Response):
    # check if exists
    if item_exists(oid):
        return get_item(oid)

    else: # else return 400
        response.status_code = 400
        return response
```
Note, there are better ways of crating a CRUD rest service; the above is only to illustrate modifying the `response.status_code`.

Another way of changing the status code is with [exceptions](https://fastapi.tiangolo.com/tutorial/handling-errors/); for example:
```py
@app.get("/items/{oid}")
async def get_item(oid: str):
    if item_exists(oid):
        return {"item": items[item_id]}
    else:
        raise HTTPException(
            status_code=404,
            detail="Item not found"
        )
```

### Alternative response types <a name="toc-sub-tag-3"></a>
FastAPI provides an interface for [custom-responses](https://fastapi.tiangolo.com/advanced/custom-response/). These include

- `fastapi.responses.HTMLResponse`
- `fastapi.responses.JSONResponse`
- `fastapi.responses.ORJSONResponse`
- `fastapi.responses.PlainTextResponse`
- `fastapi.responses.RedirectResponse`
- [`fastapi.responses.StreamingResponse`](https://fastapi.tiangolo.com/advanced/custom-response/#streamingresponse)
- `fastapi.responses.FileResponse`


All inherit from the `fastapi.Response` class, which you can instance to create additional response types.


The default response class can be set for the entire application with e.g.
```py
app = FastAPI(default_response_class=PlainTextResponse)
```
for a specific endpoint with
```py
@app.get("/", response_class=HTMLResponse)
async def get():
    ...
```


More information available in the [docs](https://fastapi.tiangolo.com/advanced/additional-responses/).


## Using `pydantic` schemas <a name="toc-sub-tag-4"></a>
Useful information in the [docs](https://fastapi.tiangolo.com/tutorial/schema-extra-example/). In brief, we define a `pydantic` schema by extending `pydantic.BaseModel`, with a type declaration (i.e. annotations). Optional arguments are set to `None`, and example or defaults can be set using `pydantic.Field`. Implicitly, every annotated field will have `Field(...)` unless specified.

For example
```py
from pydantic import BaseModel, Field

from typing import List

class MyModel(BaseModel):
    name:str # this field is not optional
    description: str = None # optional

    items: List[Items] = [] # default value

    # read from env
    api_key: str = Field(..., env='my_api_key')
```

See the [pydantic documentation](https://pydantic-docs.helpmanual.io/usage/types/) for more information.

Note, [forward-references](https://www.python.org/dev/peps/pep-0484/#forward-references) can be useful in self-referential schemas.

### Request data <a name="toc-sub-tag-5"></a>
We can graft data in the request into a pydantic model using the python typing syntax, as explained in [the docs](https://fastapi.tiangolo.com/tutorial/body/).

This can then be used simply with
```py
@app.post("/items/")
async def create_item(item: Item): # type here
    return item
```

Note that this can be easily included in the fingerprints of more involved methods:

```py
@app.put("/items/{item_name}")
async def put_item(itemname: str, item: Item):
    ...
```

### Marshalling <a name="toc-sub-tag-6"></a>
The equivalent to `flask_restful`'s [`marshal_with`](https://flask-restplus.readthedocs.io/en/stable/api.html#flask_restplus.marshal_with) is the `response_model` keyword of [the route decorator](https://fastapi.tiangolo.com/tutorial/response-model/). The paradigm here is then to have an input and output model of the database schema.

An example from the docs:
```py
@app.post("/user/", response_model=UserOut)
async def create_user(user: UserIn):
    return user
```

## Scaling with `APIRouter` <a name="toc-sub-tag-7"></a>
[Larger projects](https://fastapi.tiangolo.com/tutorial/bigger-applications/) may wish to separate different resources or schema, so that the project is more modular. This approach is facilitated by using `fastapi.APIRouter`, analogous to the `blueprints` of Flask. For example, we can define
```py
# some_routes.py
from fastapi import APIRouter

router = APIRouter()

@router.get("/hello")
async def get():
  return {"hello": "world"}
```

and attach the router to the application
```py
# main.py
from fastapi import FastAPI

import some_routes

app = FastAPI()

app.include_router(
    some_routes.router,
    prefix="/someroot", tags=["Some Root"]
)
```
The tags organise the endpoints in the interactive views. The route `/someroot/hello` will now map to the `get()` function defined in `some_routes.py`.

## CORS <a name="toc-sub-tag-8"></a>
To enable CORS, a simple recipe is
```py
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], # modify as needed
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"]
)
```

## Deploying with `uvicorn` <a name="toc-sub-tag-9"></a>
[Uvicorn](https://www.uvicorn.org/) is the "lightning-fast ASGI server", built on [`uvloop`](https://github.com/MagicStack/uvloop), a drop-in replacement for `asyncio`, and `httptools`.

We can create a startup script with dynamic reloading using
```py
import uvicorn

if __name__ == "__main__":
    uvicorn.run(
        "package.main:app",
        host="127.0.0.1",
        port=8000,
        reload=True
    )
```
where the FastAPI instance is created in `package/main.py` and called `app`, e.g.
```py
from fastapi import FastAPI

app = FastAPI()
```
Alternatively, instead of passing a package string, you can directly use the `app` instance as the argument.

Note that the logging handles can be modified with
```py
log_config = uvicorn.config.LOGGING_CONFIG
# ... modify ...
uvicorn.run("package.main:app", log_config=log_config)
```
or similar.
