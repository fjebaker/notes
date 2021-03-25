# Making a project available on pypi

The Python Package Index (pypi) is one of the most straight forward to use package managers; distributing your project on pypi makes it easy for anyone to use.

We need `setuptools` and `wheel` to create the distribution, and `twine` to upload to the package index. First ensure you have them installed, and are using the latest versions
```bash
# source venv/bin/activate
pip install --upgrade setuptools wheel
pip install --upgrade twine
```

`wheel` and `egg` are both packaging formats; `wheel` is the 'new' format and considered the standard. You can read more about the two formats [here](https://packaging.python.org/discussions/wheel-vs-egg/).

<!--BEGIN TOC-->
## Table of Contents
1. [Configuring the project](#configuring-the-project)
2. [Uploading to pypi](#uploading-to-pypi)

<!--END TOC-->

## Configuring the project
We need to correctly describe and package our project in order to comply with the pypi format. To do this, we create a `setup.py` in the root of the project directory. In this file, we configure
```python
from setuptools import setup, find_packages

setup(
	name='Project Name',
	version='1.0.0',
	description='Brief description of your project',
	long_description='Normally read in from a text or md file, such as README.md',
	long_description_content_type='text/markdown',
	author='Author',
	url='http://project.url',
	packages=find_packages(),
	install_requires=[
		'dependency==version' # usually get this from requirements.txt
	],
	classifiers=[
		"Programming Language :: Python :: 3",
		"License :: OSI Approved :: MIT License",
		"License :: OSI Approved :: GNU General Public License v3 (GPLv3)",
	],
	zip_safe=False
)
```
Instead of using `find_packages()`, you can also manually add a list, e.g.
```
[
	'Package',
	'Package.subpackage'
]
```
if you require complex exclusion rules. `find_packages` doesn't have the most reliable documentation, and I would recommend researching [`MANIFEST.in` files](https://packaging.python.org/guides/using-manifest-in/) if you need to ship more than regular `.py` files, as `find_packages`, and related keywords, are notoriously [dirty-lies](https://stackoverflow.com/a/14159430).

We can then create the project `dist/` for uploading to pypi. To do this, we run
```bash
python setup.py sdist bdist_wheel
```
Our project is now ready to upload. Note if you change any files, you'll have to run the above command again to repackage them. This command creates a [source distribution](https://docs.python.org/3/distutils/sourcedist.html).

## Uploading to pypi
Uploading is a simple one-liner
```
python -m twine upload -u USERNAME -p PASSWORD dist/*
```
where you use the username and password of your pypi account (create one [here](https://pypi.org/)).

This will upload to the default repository, which is
```
https://test.pypi.org/legacy/
```
You can specify other repositories using the `--repository-url` flag.
