
# Templating HTML pages with jinja

By default, Flask will look for templated HTML pages in the `templates` directory of the project. You can write a simple GET endpoint for a template with
```py
from flask import Flask, render_template
app = Flask(__name__)

@app.route("/")
def root():
    return render_template("home.html", **options)
```
which will replace keys in `options` present in `home.html` with the respective values. Flask will render using the templating engine [Jinja2](https://palletsprojects.com/p/jinja/).


- Full documentation available [here](https://jinja.palletsprojects.com/en/2.11.x/).

Jinja uses `{% %}` to denote its syntax specific instructions, and `{{ }}` for substitution rules.

<!--BEGIN TOC-->
## Table of Contents
1. [Replacement rules](#replacement-rules)
2. [Components](#components)
3. [Conditional Rendering](#conditional-rendering)

<!--END TOC-->

## Replacement rules
Jinja will replace any double bracketed key with the respective python value; e.g., a html document with
```html
<h2> {{title}} </h2>
```

returned with `render_template("home.html", title="Hello World")`, will render
```html
<h2> Hello World </h2>
```

## Components
We can specify block containers in jinja which are substituted, allowing us to construct a complex hierarchy if needed. For example, in a `base.html` we could have
```html
<!-- templates/base.html -->
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
  </head>
  <body>
    <div class="container">
      {% block container %}{% endblock %}
    </div>
    <script src="some/delivery/path"></script>
  </body>
</html>
```
and return `render_template("home.html")`, with the contents
```html
{% extends 'base.html' %}

{% block container %}
  <h2> Hello World </h2>
{% endblock %}
```
which would paste the `block container` into the respective location of `base.html`.

## Conditional Rendering
Passing a python iterable to jinja allows us to render mutliple object as needed; for example, for a quick table we can use
```html
<table>
  {% for i, j in table_data %}
      <tr>
        <td>{{ i }}</td> <td>{{ j }}</td>
      </tr>
  {% endfor %}
</table>
```

We can also use `if` directives, such as
```html
{% if len(data) > 1 %}
  <!-- do something -->
{% endif %}
```

For more on this, see the [documentation on filters](https://jinja.palletsprojects.com/en/2.11.x/templates/#filters).
