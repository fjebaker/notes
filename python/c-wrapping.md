# Wrapping C and C++ into Python
One of the many flexibilities that Python comes with is integration into many other languages. Since Python itself is compiled down into C bytecode, it is seen that Python and Clangs almost go hand-in-hand; indeed, many libraries such as numpy and scipy have primarily a C backend.

The most primitive was of wrapping Clang into Python is using `setuptools` and the [Python/C API](https://docs.python.org/3/c-api/index.html). Other libraries exist to make this task less verbose and more seamless, such as Cython, but here are my notes from reading a section on package-free Clang wrapping.

<!--BEGIN TOC-->
## Table of Contents
1. [Creating the build environment](#toc-sub-tag-0)
2. [Writing Pythonic C code](#toc-sub-tag-1)
	1. [`sum_of_squares` example](#toc-sub-tag-2)
	2. [Making the extension accessible](#toc-sub-tag-3)
3. [Some API notes](#toc-sub-tag-4)
	1. [Using `**kwargs`](#toc-sub-tag-5)
	2. [Raising exceptions](#toc-sub-tag-6)
4. [Using Python objects in Clang](#toc-sub-tag-7)
	1. [Using callbacks](#toc-sub-tag-8)
	2. [Using iterators](#toc-sub-tag-9)
5. [On reference counting](#toc-sub-tag-10)
<!--END TOC-->

## Creating the build environment <a name="toc-sub-tag-0"></a>
Fortunately, very little is required to compile the Clang, as the Python library `setuptools` can take care of a lot of the heavy lifting for us. Using the directory structure
```
root/
	setup.py
	test_module.c
```
we can define our C extension, and the relevant source files in `setup.py`, as such
```python
import setuptools

test_module = setuptools.Extension('test_module', ['test_module.c'])

setuptools.setup(
	name = 'Some ID name',
	version = '1.0.0',
	ext_modules = [test_module]
)
```
To then build / compile our code, we run
```bash
python setup.py build
```
and to install it into our interpreter / environment (note: would recommend highly using venvs)
```
python setup.py build install
```
We can then pop a python shell, or write a python script, and include our module as
```python
import test_module
```

## Writing Pythonic C code <a name="toc-sub-tag-1"></a>
The `setuptools` environment links the `Python.h` header into the path, which itself defines the whole Python/C API. 

### `sum_of_squares` example <a name="toc-sub-tag-2"></a>
For a simple example, we will write a sum of squares function. A python implementation of this would be 
```python
def sum_of_squares(n):
	sum = 0
	for i in range(n):
		sq = i * i
		if sq < n:
			sum += sq
		else:
			break
	return sum
```
To recreate this in C requires a little overhead. We will use pointers to `PyObject` for the majority of our arguments; and indeed, the general practice of writing a Python function in C is to use the definition
```C
static PyObject* function(PyObject* self, PyObject* args, PyObject **kwargs);
```
Note that it isn't necessary to provide args and kwargs in the definition if they are not going to be used in the function.

We could then write our sum of squares function as 
```C
#include <Python.h>

static PyObject* sum_of_squares(PyObject* self, PyObject* args) {
	int n;
	int sum = 0;	// default value

	// parse python arguments
	if (!PyArg_ParseTuple(args, "i", &n)) {	// "i" says we expect an integer
		return NULL; 	// throw error
	}

	for (int sq, i = 0; (sq = i * i) < n; i++) {
		sum += sq;
	}

	return PyLong_FromLong(sum);	// return a python object
}
```
### Making the extension accessible <a name="toc-sub-tag-3"></a>
Our function alone wont be of much use if not included into a module. To define the API of our module, a little extra work in C is required
```C
static PyMethodDef test_methods[] = {	// define the available methods
	{ 
		"sum_of_squares",	// python name
		sum_of_squares,		// pointer to C function
		METH_VARARGS,		// argument types
		"Sum of the perfect squares below some n."	// doc string
	}, 
	{NULL, NULL, 0, NULL},	// list terminator
};
```
Above we have defined the functions we want to make available in our module through a nested array. We will then define a module
```C
static struct PyModuleDef some_test_module = {	// define the module
	PyModuleDef_HEAD_INIT,
	"test_module",	// module name
	NULL,			// documentation
	-1,				// state (-1 is global); used by sub-interpreters
	test_methods	// method array pointer
};
```
which will have these methods available as member functions. Finally, we initialize the module (called upon `import test_module`)
```C
PyMODINIT_FUNC PyInit_test_module(void) {
	return PyModule_Create(&some_test_module);
}
```
And we're done! We can now create a little python script to try it out
```python
import test_module

print(test_module.sum_of_squares(100))
# 285
```

## Some API notes <a name="toc-sub-tag-4"></a>
I've encountered a few additional pieces of information whilst learning this API which I thought I would document here.

### Using `**kwargs` <a name="toc-sub-tag-5"></a>
Using keyword arguments in our C code is fairly intuitive. We can implement a function that uses keywords as
```C
static PyObject* function(PyObject *self, PyObject *args, PyObject *kwargs) {
	int some_var = 0;
	int some_prop = 0;

	static char* keywords[] = {"", "var", NULL};	// empty denote positional only
	if(!PyArg_ParseTupleAndKeywords(
		args, kwargs, "i|i", keywords, &some_prop, &some_var)) { // the | separates optional args
		return NULL;
	}
	// use variables, e.g.
	return PyLong_FromLong(some_var + (2 * some_prop));
}
``` 
We also need to change the `PyMethodDef` index to use `METH_VARARGS | METH_KEYWORDS` instead of just `METH_VARARGS`.

The arguments, if used without a keyword, are read in from left to right; e.g.
```python
function(2, 1)		# 5 -> 2 = some_prop, 1 = some_var
function(1, 2)		# 4 -> 1 = some_prop, 2 = some_var

function(1)			# 2 -> 1 = some_prop, 0 = some_var i.e. default

function(1, var=2)	# 4 -> 1 = some_prop, 2 = some_var
```
A few things to note; empty strings in `keywords[]` denote only positional arguments, and the `|` in the argument type specifier separates required from optional. The default values of optional arguments are the default values assigned to the variables, i.e. 
```C
int some_var = 0;
int some_prop = 0;
```

For full reference on the argument parsing capabilities of the Python/C API, see [here](https://docs.python.org/3/c-api/arg.html#c.PyArg_ParseTupleAndKeywords).

A small technicality arises in specifying the argument types, namely the API introduces a `$`, which, to quote the documentation

> `PyArg_ParseTupleAndKeywords()` only: Indicates that the remaining arguments in the Python argument list are keyword-only. Currently, all keyword-only arguments must also be optional arguments, so | must always be specified before $ in the format string.

So to keep up with the modern implementation details, we should have written our parser as
```C
PyArg_ParseTupleAndKeywords(
		args, kwargs, "i|$i", keywords, &some_prop, &some_var)
```
This helps ensure we don't accidentally use positional arguments as optionals. Note that the parser also implicitly does type conversion and **checks** for overflows! It is therefore important that the specifier matches the variable type exactly.

### Raising exceptions <a name="toc-sub-tag-6"></a>
The Python/C API allows for all sorts of different exceptions to be raised in the Python interpreter. This is preferred over trying to handle them in Clang, since an uncaught exception will cause the entire environment to crash, and error messages are brief, if not cryptic.

The general idiom is to define some error type, and then return `NULL`. For example, a function which throws a runtime error with a custom message could be
```C
static PyObject* throw_error(PyObject *self, PyObject, *args) {
	PyErr_SetString(PyExc_RuntimeError, "Custom error text.");
	return NULL;
}
```
Calling this function in Python results in a pleasant
```
Traceback (most recent call last):
	File "<stdin>", line 1, in <module>
RuntimeError: Custom error text.
```
There are numerous exception manipulating functions in the Python/C Api (see [here](https://docs.python.org/3/c-api/intro.html#exceptions)); some of the more general use cases are

- `PyErr_Clear()`: clears the current exception state so that e.g. a new state may be defined

And common error types to be called in `PyErr_SetString` are

- `PyExc_TypeError`
- `PyExc_RuntimeError`

## Using Python objects in Clang <a name="toc-sub-tag-7"></a>
The malleability of Python can be a little difficult to translate into a strongly type language like C or C++, however the Python/C API helps to smooth out many difficulties.

### Using callbacks <a name="toc-sub-tag-8"></a>
To use a callback in Clang is surprisingly straight forward. Consider a function that just calls the callback on an integer argument; the implementation is
```C
static PyObject* act_callback(PyObject* self, PyObject* args) {	// nb: no kwargs
	int value = 0;
	PyObject* callback = NULL;

	if (!PyArg_ParseTuple(args, "O|i", &callback, &value)) {
		return NULL;
	}

	// check is callback is okay
	if (!PyCallable_Check(callback)) {
		PyErr_SetString(PyExc_TypeError,
			"Callback is not callable.");
		return NULL;
	}

	value = PyLong_AsLong(PyObject_CallFunction(callback, "i", value));
	Py_DECREF(callback);	// reduce reference count so that C doesn't hold on to the object
	return PyLong_FromLong(value);
}
```
We check that the callback is okay, we parse our argument into the callback, and then, since the callback is executing Python code, must cast the return object back into a C object. Since we expect only one return item, we can use the `PyLong_AsLong` to facilitate this conversion (bad conversion throws a `TypeError`).

### Using iterators <a name="toc-sub-tag-9"></a>
A common idiom in python is to pass a list or iterator to a function. We can use these in Clang too; consider a iterator sum accumulator
```C
static PyObject* sum_itt(PyObject* self, PyObject* args) {
	int sum = 0;
	PyObject* iterator;
	PyObject* item;

	if (!PyArg_ParseTuple(args, "O", &iterator)) {
		return NULL;
	}

	if (!PyIter_Check(iterator)) {
		iterator = PyObject_GetIter(iterator);	// make iterator if not already an iterator
		if (iterator == NULL) {
			PyErr_SetString(PyExc_TypeError,
				"Argument is not iterable!");
			return NULL;
		}
	}

	while ((item = PyIter_Next(iterator))) {
		sum += PyLong_AsLong(item);
		Py_DECREF(item);
	}
	Py_DECREF(iterator);
	return PyLong_FromLong(sum);
}

```
Here we check if the object is already iterable, else try to create an iterator from it. We can then cycle calls to `PyIter_Next()`, which by extension is just calling `next()` in python, to cycle through the iterator until depleted. We have to dereference each item after we assign it, as to allow the GC in python to clean up properly.

The above may be used
```python
sum_itt([1, 2, 3, 4, 5])		# 15
sum_itt(iter([1, 2, 3, 4, 5]))	# 15
```

## On reference counting <a name="toc-sub-tag-10"></a>