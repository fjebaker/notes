
# JavaScript language reference
Series of notes adapted from different books and blogs so that I can easily refer back to new concepts until they become old.

<!--BEGIN TOC-->
## Table of Contents
1. [Functions](#toc-sub-tag-0)
	1. [Functions as objects](#toc-sub-tag-1)
	2. [Function declarations](#toc-sub-tag-2)
	3. [Parameters and arguments](#toc-sub-tag-3)
	4. [The `this` implicit argument](#toc-sub-tag-4)
<!--END TOC-->

## Functions <a name="toc-sub-tag-0"></a>
The following mostly stems from Secrets of the JavaScript Ninja (Resig, Bibeault and Maras).
### Functions as objects <a name="toc-sub-tag-1"></a>
Functions are first-class objects, and behave just as any other JS object. As such, they may even have stored state
```js
var someFunc = () => {};
someFunc.property = "value";
```
This allows function caching or memoization to be easily implemented
```js
var fibbonaci = (n) => {
	// create cache
	if (!fibbonaci._cache) {
		fibbonaci._cache = [1, 1];
	}
	if (fibbonaci._cache.length >= n) {
		return fibbonaci._cache[n-1];
	} else {
		fibbonaci._cache.push(fibbonaci(n-1) + fibbonaci(n-2));
		return fibbonaci(n);
	}
};
```
If the cache were an object, we check the existence of an index of in lieu of the array length
```js
if (fibbonaci._cache[n] === undefined) {
	// ...
} 
```
### Function declarations <a name="toc-sub-tag-2"></a>
There are multiple ways to define functions, simplest of which is the function literal `() => {}` (here in arrow notation). There are four groups of declarations in JS

- **`function` declaration and expression**, to the analogy of declaration and implementation in C-type languages
```js 
function name() { return true; }
```

- **arrow function** or **lambda functions**, which are syntactically succinct
```js
someArg => someArg * someArgs;
(arg1, arg2) => { return ar1 + arg2; }
```

- **`Function` constructors**, allowing new functions to be constructed with help of the `new` keyword, even dynamically
```js
new Function('a', 'b', 'return a + b');
```
For more information on function constructors, see [here](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Function).

and finally

- **generator functions**, much like Pythonic generators, and expressed
```js
function* generator() { yield true; }
```

There are also immediate one use functions, which can be declared with
```js
(/* function implementation */)(args);
```
These types of evaluations are sometimes known as *immediately invoked function expressions* (IIFE). They are idiomatically also seen in unitary operations on functions, which here take the role of an expression
```js
+function(){}();
-function(){}();
!function(){}();
~function(){}();
```

### Parameters and arguments <a name="toc-sub-tag-3"></a>
JS does not throw errors on function calls with more or fewer arguments than accepted parameters. Instead, those arguments are not assigned to any namespace values in the function scope, or the parameters left `undefined`
```js
function someFunc(arg1, arg2) { /* ... */ }  

someFunc("hello", "there", "world");	// OK! no errors
someFunc("hello");						// OK! but arg2 is undefined
```
JS provides the keyword `argument` which stores the function argument details as an array. For the above case, the `argument` array is
```js
[Arguments] { '0': 'hello', '1': 'there', '2': 'world' }
[Arguments] { '0': 'hello' }
```
respectively.

Similar to variadics in C++, JS has *rest parameters*, which stores all unnamed arguments in an array. Syntactically, this is expressed
```js
function someFunc(arg, ...otherArgs) { /* ... */ } 
```

In lieu of overloading functions, JS has a method for providing succinct function defaults
```js
// Wordy solution
function someFunc(arg) {
	arg = typeof arg === "undefined" ? "default" : arg;
	/* ... */
} 
// ES6+
function someFunc(arg = "default") {
	/* ... */
}
```

### The `this` implicit argument <a name="toc-sub-tag-4"></a>
Functions may be invoked on their own, as a method (`obj.func()`), through a constructor, as in `new Func()`, or through `apply` and `call` prototype methods.

The `this` object provides the function context at face value. For example
```js
function loose() {
	return this;		// returns window
}

function strict() {
	"use strict";
	return this;		// returns undefined
}
```

If the function were a method of an object, the context becomes the object itself, as we are familiar with from other ObjOrtd languages.

Arrow functions do not have an implicit `this`, but instead use the context at the point of definition, making them very suitable as callback functions
```js
function Button() {
	this.clicked = false;		// context is Button
	this.click = () => {
		this.clicked =  true;	// context is still Button
	};
}

var button = new Button();
```
This has the caveat that if `Button`'s constructor were never called, as such were not instantiated to an object, the context of the lambda would default to global. To mitigate this, we define our button instead 
```js
var button = {
	clicked: false,
	click: function() {
		this.clicked = true;
	}
};
```
and execute a script
```js
// button.clicked == false
button.click();
// button.clicked == true
```
Note we can also use `bind` to create a *new* function, with its context bound to the object passed to it, e.g. trivially
```js
button.clicked.bind(button);	// context of this is now button
```
