
# JavaScript language reference
Series of notes adapted from different books and blogs so that I can easily refer back to new concepts until they become old.

<!--BEGIN TOC-->
## Table of Contents
1. [Functions](#functions)
    1. [Functions as objects](#functions-as-objects)
    2. [Function declarations](#function-declarations)
    3. [Parameters and arguments](#parameters-and-arguments)
    4. [The `this` implicit argument](#the-this-implicit-argument)
    5. [Closures](#closures)
        1. [Mimicking private variables](#mimicking-private-variables)
        2. [Closures in callbacks](#closures-in-callbacks)
2. [Generators and promises](#generators-and-promises)
    1. [Generators](#generators)
    2. [Promises](#promises)
    3. [Combining generators with promises](#combining-generators-with-promises)
3. [Object orientation and prototypes](#object-orientation-and-prototypes)
    1. [Inheritance with `.setPrototypeOf()`](#inheritance-with--setprototypeof)
    2. [Constructors](#constructors)
        1. [Instance prototype properties](#instance-prototype-properties)
        2. [Object typing with constructors](#object-typing-with-constructors)
    3. [Achieving inheritance](#achieving-inheritance)
    4. [Configuring object properties](#configuring-object-properties)
    5. [JS `class` keyword](#js-class-keyword)
    6. [Getters and setters](#getters-and-setters)
    7. [Proxies and access control](#proxies-and-access-control)
4. [Array methods](#array-methods)
    1. [`.forEach()`](#foreach)
    2. [`.map()`](#map)
    3. [Logical checks](#logical-checks)
    4. [Searching](#searching)
    5. [Sorting arrays](#sorting-arrays)
    6. [`.reduce()`](#reduce)

<!--END TOC-->

## Functions
The following mostly stems from Secrets of the JavaScript Ninja (Resig, Bibeault and Maras).
### Functions as objects
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
### Function declarations
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

### Parameters and arguments
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

### The `this` implicit argument
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

### Closures
The concept of *closure* allows a function to access the namespace in the scope of the function definition. The closure encompasses variables and definitions in the scope and ensures they are available if needed, even once program execution has left the scope.

#### Mimicking private variables
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

#### Closures in callbacks
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

## Generators and promises
Leading into the notion of asynchronous programming, JS is a single threaded language, thus any waiting will deactivate the UI until the function call ends. Asynchronous function calls and callbacks can extend the function and interaction of our program considerably.

### Generators
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

### Promises
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

### Combining generators with promises
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

## Object orientation and prototypes
Prototypes in JS are objects to which the property lookup is delegated, allowing properties and functionality to automatically be accessible to other objects. They can be thought of as classes in other object orientated languages. Prototypes allow for inheritance within JS.

### Inheritance with `.setPrototypeOf()`
We can mimic inheritance using the `Object.setPrototypeOf()` method
```js
const assert = require('assert')

const athlete = { instruct: true };
const scientist = { research: true };
const politican = { lie: true };

assert("research" in scientist, "Scientist can research.");
assert(!("research" in athlete), "Athlete cannot research.");
// set prototype
Object.setPrototypeOf(athlete, scientist);

assert("research" in athlete, "Athlete can now research.");

Object.setPrototypeOf(athlete, politican);
assert("lie" in athlete, "Athlete can now lie.");
```
The calling order in the case of same identifier is always the inheriting object's attribute/method, then that of the prototype, and further up the chain.

### Constructors
We can prototype methods using a function constructor and the `new` keyword
```js
function SomeObject() {}	// no implementation
SomeObject.prototype.action = function() {
	console.log("Hello World"); 
};

const instance = new SomeObject();
instance.action();
```

#### Instance prototype properties
Here is an example of initialization precedence
```js
function SomeObject() {
	this.acted = false;
	this.action = function() {
		console.log(!this.acted);
	};
}

SomeObject.prototype.action = function() {
	console.log(this.acted);
};

const instance = new SomeObject();
instance.action();					
```
In this case, `.action()` will result in `true` being printed. 

Since JS is a dynamic language, prototype changes defined or altered after an object has been instantiated still apply to that instance. Consider the snippet following on from the last
```js
SomeObject.prototype.action = () => {
	console.log("Altered action!");
};

instance.action();		// Altered action!

// Completely override the prototype object
SomeObject.prototype = {
	action : () => {
		console.log("New prototype, who this?")
	}
}

instance.action();		// still Altered action!

// New instance has the new prototype
(new SomeObject())		// New prototype, who this?
	.action();
```
The `instance` still holds reference to the old prototype, but once the prototype has been overridden, becomes inaccessible.

#### Object typing with constructors
Prototypes also store information on how the instance was constructed. For instance, we can access the constructor function using the `.constructor` property of the instance
```js
function SomeObject() {}
const instance = new SomeObject();
console.log(instance.constructor);			// [Function: SomeObject]
```
The instance also returns true for `ininstanceof SomeObject` calls. We can also create new instances of `SomeObject` by calling
```js
const newInstance = new instance.constructor();
console.log(newInstance === instance)		// false
```

### Achieving inheritance
We already saw how inheritance can be mimicked using the `.setPrototypeOf()` method, but we can also achieve inheritance with objects or instances. The common idiom is to write
```js
function Super() {}
Super.prototype.action = function() { console.log("Action from Super.") };

function SomeObject() {}
SomeObject.prototype = new Super();
(new SomeObject).action();				// Action from Super.
```
Note if the `new` keyword were not used, the prototype is not properly endowed into Super, and similarly, as the constructor is an empty function, the prototype of the instance would be `undefined`.

The problem with this implementation is that the check
```js
(new SomeObject).constructor === SomeObject;
```
will fail, as it will yield Super instead. We will come back to a solution to this later, but for now we need to examine the JS object properties in order to find an appropriate solution.

### Configuring object properties
JS describes every object property with a descriptor, which is controlled with the keys

- `configurable`: if `true`, property's descriptor can be changed or deleted. else cannot do either
- `enumerable`: if `true`, property show up during `for-in` loops
- `value`: specifies the value of the property (default is `undefined`)
- `writable`: if `true`, property can be changed using an assignment
- `get`: defines getter function (cannot be defined in conjunction with `value` and `writable`)
- `set`: defines a setter function (same restrictions as `get`)

A default property, such as
```js
someInstance.prop = "someValue";
```
has `configurable`, `enumerable`, and `writable` set to `true`, the `value` is `someValue`, and the getter and setter functions would be `undefined`. We can fine tune properties using the `Object.defineProperty` method; for example
```js
var SomeObject = {};
Object.defineProperty(SomeObject, "prop", {
	configurable: false,
	enumerable: false,
	value: "someValue",
	writable: true
});
```
To solve the issue of losing the original prototype (i.e. the constructor property), we can instead define the `constructor` value after altering the prototype; as above, we have
```js
function Super() {}
function SomeObject() {}
SomeObject.prototype = new Super();
```
but now add
```js
Object.defineProperty(SomeObject.prototype, "constructor", {
	enumerable: false,
	value: SomeObject,
	writable: true
});

var someInstance = new SomeObject();
```
Now the check
```js
(new SomeObject).constructor === SomeObject;
```
will pass.

### JS `class` keyword
Recent versions of JS also include the familiar `class` keyword to abstract a lot of the inheritance features. A traditional class may then be defined 
```js
class SomeClass {
	constructor(someProperty) {
		this.prop = someProperty;
	}

	someMethod() {
		return this.prop;
	}

}
```
Here, the `class` keyword acts to abstract the syntax of defining prototype attributes, i.e., the above is equivalent to
```js
function SomeClass (someProperty) {
	this.prop = someProperty;
}
SomeClass.prototype.someMethod = function() {
	return this.prop;
};
```
The JS classes open up use of `static` methods. We can declare a method as `static` by simply using it as a keyword
```js
class SomeClass {
	constructor (prop) {
		this.prop = prop;
	}
	static someStaticMethod(instance1, instance2) {
		return instance1.prop - instance2.prop;
	}
}
```
In JS, `static` methods are not 'known' by class instances, but instead accessed through the class object
```js
var someInstance = new SomeClass(2);
var someOtherInstance = new SomeClass(1);

var diff = SomeClass.someStaticMethod(someInstance, someOtherInstance);	// 1
```
Additionally, inheritance is a lot easier to implement. We can use the familiar Java `extends` keyword, such as
```js
class SomeExtendedClass extends SomeClass {
	constructor(prop, newprop) {
		super(prop);
		this.newprop = newprop;
	}
}
```
### Getters and setters
Also included in modern JS version are the keywords `get` and `set` used to define getters and setters for object properties. We can use them
```js
const someCollection = {
	anArray = ["value1", "value2", "value3"],
	get firstItem() {
		return this.anArray[0];
	}

	set firstItem(val) {
		this.anArray[0] = val;
	}
};
```
This implementation also works for the `class` method. An alternative way to define getters and setters uses the `Object.defineProperty` method
```js
function SomeObject() {
	let _counter = 0;

	Object.defineProperty(this, 'counter', {
		get: () => {
			return _counter;
		},
		set: (val) => {
			_counter += val;
		}
	});
}
```

### Proxies and access control
Proxies allow us to execute additional routines when interacting with an object. They are, in many ways, generalizations of getters and setters. There exist many traps we can set up using the `Proxy` built in, such as

- `apply`, activated when calling a function
- `construct`, activated when using the new operator
- `get` and `set`, used as surrogates for getters and setters
- `getPrototypeOf`, `setPrototypeOf`, which are pretty self-explanatory
- `enumerate`, activated in `for-in` statements.

A full list of traps can be found in the [Mozilla reference](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Proxy).
For example, using the `apply` trap, we can write
```js
const sum = function(arg1, arg2) { return arg1 + arg2; };
const proxySum = new Proxy(sum, {
	apply: (target, thisArg, argumentsList) => {
		return 0;
	}
});
console.log(proxySum);			// [Function: sum]
console.log(proxySum(1, 2));	// 0
```
Proxies are a fantastic way of implementing logging or performance checking code. The cost of proxies is performance, however, and can incur a considerable speed decrease for the additional control.

## Array methods
Manipulating data in JS is facilitated by the extensive `Array` object. An array object may be manipulated dynamically with

- `.push(item)`: add `item` to the end of the array
- `.unshift(item)`: add `item` to the start of the array
- `.pop()`: returns and removes the last item of array
- `.shift()`: returns and removes first item in array

### `.forEach()`
Iterating over arrays is also made easy with several built-in methods. A simple for loop, such as
```js
for (let i = 0; i < array.length; i++) {
	var item = array[i];
	// operator on item
}
```
is more elegantly expressed with the asynchronous
```js
array.forEach((item, i) => {
	// operate on item
	});
```
Full documentation can be found [here](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/forEach).

### `.map()`
Creating a new array from properties in an array of objects is a common idiom, known as a 'map'. Verbosely, a map is equivalent to
```js
const newArray = [];
array.forEach(item => {
	newArray.push(item.prop);
});
```
or, using the built-in
```js
const newArray = array.map(i => i.prop);
```
Full documentation can be found [here](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/map).

### Logical checks
Checking if **every** item in `array` has some specific property
```js
const allHaveProperty = array.ever(i => 'prop' in i);
// true only if every i has i.prop
```
Checking if **some** items in `array` have a specific property
```js
const someHaveProperty = array.some(i => 'prop' in i);
// true if at least one i has i.prop
```
Not that `.some()` will act the callback on each item until some true case is found, and then return `true`.

### Searching
To find one and return one item with a given property, use
```js
const item = array.find(i => 'prop' in i);
// returns undefined if no i with i.prop
```
To find all items with a given property
```js
const items = array.filter(i => 'prop' in i);
```

### Sorting arrays
Arrays can be sorted by returning numerical values, for example
```js
array.sort((a, b) => a - b);
```
If

- `a - b` > 0, `a` should come after `b`
- `a - b` < 0, `a` should come before `b`
- `a - b` = 0, `a` and `b` are on equal footing

This means we can easily implement a reversal algorithm
```js
array.sort((a, b) => b - a);
// [1, 2, 3] -> [3, 2, 1]
```

### `.reduce()`
Aggregating, e.g., a sum, would be conventionally expressed through
```js
const sum = 0;
array.forEach(i => {
	sum += i.value;
});
```
or, using the built-in method
```js
const sum = array.reduce((aggr, i) => {
	return aggr += i;
}, 0);
```
Here, `0` passed as the second argument is the starting value of the aggregate variable `aggr`.
