
# JavaScript language reference
Series of notes adapted from different books and blogs so that I can easily refer back to new concepts until they become old.

<!--BEGIN TOC-->
## Table of Contents
1. [Functions](#toc-sub-tag-0)
	1. [Functions as objects](#toc-sub-tag-1)
	2. [Function declarations](#toc-sub-tag-2)
	3. [Parameters and arguments](#toc-sub-tag-3)
	4. [The `this` implicit argument](#toc-sub-tag-4)
	5. [Closures](#toc-sub-tag-5)
		1. [Mimicking private variables](#toc-sub-tag-6)
		2. [Closures in callbacks](#toc-sub-tag-7)
2. [Generators and promises](#toc-sub-tag-8)
	1. [Generators](#toc-sub-tag-9)
	2. [Promises](#toc-sub-tag-10)
	3. [Combining generators with promises](#toc-sub-tag-11)
3. [Object orientation and prototypes](#toc-sub-tag-12)
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

### Closures <a name="toc-sub-tag-5"></a>
The concept of *closure* allows a function to access the namespace in the scope of the function definition. The closure encompasses variables and definitions in the scope and ensures they are available if needed, even once program execution has left the scope.

#### Mimicking private variables <a name="toc-sub-tag-6"></a>
Let us suppose we wanted to create read only access to a variable in a definition
```js
function Counter() {
	var count = 0;						// scoped variable
	this.getCount = function() {
		return count;
	};
	this.nudge = function() {
		count++;
	};
}

var c = new Counter();
console.log(c.getCount());				// 0
c.nudge();								// c.count++;
console.log(c.getCount());				// 1
```
Note, `Counter.getCount` and `Counter.nudge` could also be defined with arrow notation. It is crucial to use the function constructor, so that a new context for the object is created.

#### Closures in callbacks <a name="toc-sub-tag-7"></a>
Were a function called at an unspecified time later on, closures provide a intuitive way of avoiding nasty pitfalls.

For example, were we to use the built-in `setInterval` to periodically call some callback function, we can use closure to provide the necessary control statements as to give the periodic function a simple interface
```js
function periodicLog() {
	var tick = 1;
	var timer = setInterval(function () {
		if (tick <= 10) {
			console.log(`- tick number ${tick++}`)
		} else {
			clearInterval(timer);
		}
	}, 100);
}
periodicLog();	// outputs a tick every 100 ms
```
Or creating unique instances of the function also provides each instance with its own set of parameters, allowing complex properties to easily be abstracted.

## Generators and promises <a name="toc-sub-tag-8"></a>
Leading into the notion of asynchronous programming, JS is a single threaded language, thus any waiting will deactivate the UI until the function call ends. Asynchronous function calls and callbacks can extend the function and interaction of our program considerably.

### Generators <a name="toc-sub-tag-9"></a>
Much like Pythonic generators, JS generators are state yielding functions
```js 
function* generator() {
	for (var i = 1; i <= 10; i++) {
		yield "+".repeat(i);
	}
}

for (let val of generator()) {
	console.log(val);
}
```
The generator can be controlled through an iterator object
```js
const plusCount = generator();
const item1 = plusCount.next();
```
The `plusCount` iterator instance includes several properties, an important one is `plusCount.done` which returns `true` if the generator yields have been expired. Generators may also then be traversed with
```js
let item;
while(!(item = plusCount.next()).done) {
	console.log(item);
}
```
Here `item` is a JS object, with a `value` and a `done` attribute. The for-of loops are syntactic sugar over the above, in the same fashion as Python for-in loops, or C++ `for (int i : array)`.

Yield statements in JS can also be used to yield another generator. Consider the example
```js
function* generator() {
	for (var i = 1; i <= 10; i++) {
		yield "+".repeat(i);
	}
	yield* backGenerator();
}

function* backGenerator() {
	for (var i = 10; i >= 1; i--) {
		yield "+".repeat(i)
	}
}
```
Now, once `generator` has completed the for loop, it yields an instance of `backGenerator` which allows the iteration to continue seamlessly.

Generators have great application for streaming data, yielding unique identification codes, or traversing the DOM.

Generators may also have data send back to them, just like with Python's `x = yield` statement and `send()` method.

The sending syntax in JS is
```js
function* generator() {
	for (var i = 1; i <= 10; i++) {
		i += yield "+".repeat(i);
	}
}

let plusCount = generator();
let item;
while(!(item = plusCount.next(3)).done) {	// here we send 3
	console.log(item);
}
```

Or we can use `.throw(/* what */)` to throw an exception in the iterator at `yield`.

Note that generators still have access to the `return` keyword, allowing them to give a value to their instance upon completion.

### Promises <a name="toc-sub-tag-10"></a>
Promises are the main driver behind writing succinct asynchronous code. They provide an implementation for allowing function chains to be established off of the basis of a result or error case. A promise may be defined
```js 
const p = new Promise((resolve, reject) => {
	/* ... */
});

p.then(
	(/* results of Promise lambda */) => { /* ... */},
	(/* error case */) => { /* ... */}
);
```
The error callback of `p` may also be chained instead with `.catch(callback)` instead of providing a second argument to `.then()`.

Promises also allow multiple asynchronous tasks to be fed together, using the `.all()` method. For, e.g. parallel gathering of information, we can write 
```js
Promise.all([
		makeRequest(url1),
		makeRequest(url2),
		//...,
		makeRequest(urlN)
	])
	.then(results => {
		console.log("url1 : " + results[0])
		/* etc */
	})
	.catch(error => {
		/* error handle */
});
```

Similar syntax is also used to obtain the first result of a series of asynchronous tasks using `.race()`. The `result` argument is now just the result of a single function, instead of the list of inputs.

### Combining generators with promises <a name="toc-sub-tag-11"></a>
We can combine generators with promises and the concept of closure to write strong asynchronous code. Note, this is **not** a production grade implementation, and indeed the `async()` demonstrated has default language implementations

```js
async(function*() {
	try {
		const key = yield somePromise();
		const val = yield someIndex(key);
		// all information received
	} catch (e) {
		// error handling
	}
});

function async(generator) {
	var itt = generator();

	function handle(ittResult) {
		if (ittResult.done) return;

		const ittVal = ittResult.value;
		if (ittVal instanceof Promise)
			ittVal.then(res => handle(itt.next(res)))
				  .catch(err => itt.throw(err));
	}
	try {
		handle(itt.next())
	} catch (e) { itt.throw(err); }
}
```
JS introduces the `async` and `await` keywords to help integrate promises and generators, such that our above code may be rewritten using the new syntax 
```js
(async function() {
	try {
		const key = await somePromise();
		const val = await someIndex(key);
		// all information received
	} catch (e) {
		// error handling
	}
})();
```

## Object orientation and prototypes <a name="toc-sub-tag-12"></a>