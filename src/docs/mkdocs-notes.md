# Notes on mkdocs
`mkdocs` is a python tool for compiling and deploying markdown documents as the familiar HTML documentation web pages. The [`mkdocs` website](https://www.mkdocs.org/) provides a self-explanatory overview of how to use this tool. In these notes, I will just elaborate and detail my own use cases as they come along.

<!--BEGIN TOC-->
## Table of Contents
1. [Installation and setup](#installation-and-setup)
2. [Basic use](#basic-use)
    1. [Adding navigation](#adding-navigation)
    2. [Linking images](#linking-images)
3. [Plugins](#plugins)
4. [Styling](#styling)

<!--END TOC-->

## Installation and setup
Installing `mkdocs` is as simple as
```
pip install mkdocs
```

You can then create a new project with
```
mkdocs new [project_name]
```
which will create a new folder `project_name` with the directory structure of `mkdocs` within.

## Basic use
The overall documentation is controlled by the `mkdocs.yml` file, which also acts as the configuration for the site. You then add your normal markdown documents in the `docs` directory. You can also add new directories, as explained in the [writing your docs](https://www.mkdocs.org/user-guide/writing-your-docs/) guide, and this will be mapped to new endpoints of the docs site, with the usual nesting: e.g. a file in
```
about/version1/about_v1.md
```
would be mapped to
```
http://[hostname]/about/version1/about_v1
```
in the build site.

### Adding navigation
You can add a basic navigation by creating the `nav` section in `mkdocs.yml`. The most bare bones version would be simply:
```
nav:
    - 'index.md'
    - 'about.md'
```
However complex nesting, and named pages, is also possible
```
nav:
    - Home: 'index.md'
    - 'User Guide':
        - 'Writing your docs': 'writing-your-docs.md'
        - 'Styling your docs': 'styling-your-docs.md'
    - About:
        - 'License': 'license.md'
        - 'Release Notes': 'release-notes.md'
```

### Linking images
You can easily link images by relative paths with a project like
```
mkdocs.yml
docs/
    about.md
    img/
        some_image.png
```
with markdown in `about.md`
```md
...
![Some Image](img/some_image.png)
```

## Plugins
You can view a lot of the supported plugins on the [`mkdocs` github wiki](https://github.com/mkdocs/mkdocs/wiki/MkDocs-Plugins).

## Styling
For information on styling, see [the official how-to](https://www.mkdocs.org/user-guide/styling-your-docs/).
