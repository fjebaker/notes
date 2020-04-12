# High performance Python techniques and paradigms
Python is a language that I find is easy to learn, but difficult to master. These notes are part of my ongoing task of becoming as proficient at this language as I can.

<!--BEGIN TOC-->
## Table of Contents
1. [Advanced collections](#toc-sub-tag-0)
	1. [`collections.ChainMap`](#toc-sub-tag-1)
	2. [`collections.Counter`](#toc-sub-tag-2)
	3. [`collections.deque`](#toc-sub-tag-3)
	4. [`collections.defaultdict`](#toc-sub-tag-4)
	5. [`collections.namedtuple`](#toc-sub-tag-5)
	6. [`collections.enum`](#toc-sub-tag-6)
	7. [`collections.OrderedDict`](#toc-sub-tag-7)
	8. [`heapq`](#toc-sub-tag-8)
	9. [`bisect`](#toc-sub-tag-9)
2. [Some notes on list comprehension](#toc-sub-tag-10)
<!--END TOC-->

## Advanced collections <a name="toc-sub-tag-0"></a>
Beyond lists, tuples and dicts, python also has several other built-in collections with their own uses and applications.

### `collections.ChainMap` <a name="toc-sub-tag-1"></a>
Useful for combining multiple dictionary mappings. When searching for a variable in the current scope, python first searches `locals()`, then `globals()`, and finally `builtins`. Commonly, the search pattern could be implemented
```python
import builtins

mappings = globals(), locals(), vars(builtins)
for mapping in mappings:
	for key in mapping:
		if key in mapping:
			value = mapping[key]
			break
else:	# only triggers if for loop not exited through break
	raise NameError(f'name {key} is not defined')
```
However, since Python3.3, a more elegant solution is to use `collections.ChainMap`
```python
import builtins
import collections

mappings = collections.ChainMap(globals(), locals(), vars(builtins))
value = mappings[key]
```

### `collections.Counter` <a name="toc-sub-tag-2"></a>
The `Counter` is an excellent way of keeping track of the occurrences of an element
```python
import collections

counter = collections.Counter('abbcd')
for k in 'abbcd':
	print(f'Count for {k}: {counter[k]}')
```
It uses `heapq` implementations for obtaining the most common elements, and as such scales beautifully even with large number of elements
```python
import math
import collections

counter = collections.Counter()
for i in range(100000):
	counter[math.sqrt(i) // 25] += 1

for key, count in counter.most_common(5):
	print(f'{key} : {count}')
```
It also is able to use more complex operations, such as addition, subtraction, intersection, and unions, similar to `set`
```python
import collections

def print_counter(expression, counter):
	sorted_characters = sorted(counter.elements())
	print(expression, ''.join(sorted_characters))

eggs = collections.Counter('eggs')
spam = collections.Counter('spam')

print_counter('eggs:', eggs)	
# eggs: eggs
print_counter('eggs & spam:', eggs & spam)
# eggs & spam: s
print_counter('eggs - smap:', eggs - spam)
# eggs - smap: egg
print_counter('eggs + spam:', eggs + spam)
# eggs + spam: aeggmpss
print_counter('eggs | spam:', eggs | spam)
# eggs | spam: aeggmps
```
### `collections.deque` <a name="toc-sub-tag-3"></a>
Double Ended Queue, or `deque`, is a very low-level collection, equivalent to a double linked list; every item in the list points to the next and the previous, with the list reference pointing to both the first and last elements. Thus, adding and subtracting elements from either side of the `deque` is an O(1) operation
```python
import collections

queue = collections.deque()
queue.append(1)
queue.append(2)

print(queue)		# deque([1, 2])
queue.pop()			# 2
queue.popleft()		# 1
queue.popleft()		# IndexError: pop from an empty deque
```
The `deque` also implements `maxlen` as a kwarg. Consider the example
```python
import collections

looper = collections.deque(maxlen=2)
for i in range(5):
	looper.append(i)
	print(looper)

# deque([0], maxlen=2)
# deque([0, 1], maxlen=2)
# deque([1, 2], maxlen=2)
# deque([2, 3], maxlen=2)
# deque([3, 4], maxlen=2)
```
The threading `queue.Queue` wraps a `deque` but implements locks and checks to make it threadsafe. Similar, `asyncio.Queue` is specialized for asynchronous use, and `multiprocessing.Queue` for multiprocess operations (which I will write notes for later).

### `collections.defaultdict` <a name="toc-sub-tag-4"></a>
To put it simply, a `defaultdict` is a dictionary with a default value. The benefit of such an item prevents having to check if a key exists before accessing it, and has great application in implementing in-memory databases. As an illustration, consider a graph structure
```python
nodes = [
	('a', 'b'),
	('a', 'c'),
	('b', 'a'),
	('b', 'd'),
	('c', 'a'),
	('d', 'a'),
	('d', 'b'),
	('d', 'c')	
]

graph = dict()
for from_, to in nodes:
	if from_ not in graph:
		graph[from_] = []
	graph[from_].append(to)

import pprint
pprint.pprint(graph)

# {'a': ['b', 'c'], 'b': ['a', 'd'], 'c': ['a'], 'd': ['a', 'b', 'c']}
```
This could be implemented more elegantly
```python
import collections

graph = collections.defaultdict(list)
for from_, to in nodes:
	graph[from_].append(to)

pprint.pprint(graph)

# defaultdict(<class 'list'>,
#             {'a': ['b', 'c'],
#              'b': ['a', 'd'],
#              'c': ['a'],
#              'd': ['a', 'b', 'c']})
```
It's trivial to see how a `Counter` could be implemented with `defaultdict`, but the version included in `collections` is far more extensive. Note that the default value must be a callable object (e.g. `int`). This means trees could be very easily defined as
```python
import collections

def tree():
	return collections.defaultdict(tree)
```
and used
```python
import json

colours = tree()
colours['other']['black'] = 0x000000
colours['other']['white'] = 0xFFFFFF
colours['primary']['red'] = 0xFF0000
colours['primary']['red'] = 0x00FF00
colours['primary']['blue'] = 0x0000FF

print(json.dumps(colours, sort_keys=True, indent=4))

# {
#     "other": {
#         "black": 0,
#         "white": 16777215
#     },
#     "primary": {
#         "blue": 255,
#         "red": 65280
#     }
# }
```
Such a data structure is able to generate itself recursively.

### `collections.namedtuple` <a name="toc-sub-tag-5"></a>
This collection is essentially a tuple with field names; it lends itself to describing coordinates well
```python
import collections

Point = collections.namedtuple('Point', ['x', 'y', 'z'])
point_a = Point(1, 2, 3)
print(point_a)
# Point(x=1, y=2, z=3)

point_b = Point(x=4, z=5, y=6)
print(point_b)
# Point(x=4, y=6, z=5)
```
Properties can be accessed by index or by name
```
print(point_a.x == point_a[0])
# True
```

### `collections.enum` <a name="toc-sub-tag-6"></a>
Essentially a Python implementation of Clang familiar `enum`, allowing constants without magic numbers. For example
```python
import enum

class Colour(enum.Enum):
	red = 1
	green = 3
	blue = 2

print(Colour.red == Colour['red'])	# True
print(Colour.red == Colour(1))		# True

print(Colour.red == 1)				# False
print(Colour.red.value == 1)		# True
```
As you might expect, `enums` are iterable 
```python
for colour in Colour:
	print(colour)

# Colour.red
# Colour.green
# Colour.blue
```
and have value as well as text representation
```python
cols = dict()
cols[Colour.green] = 0x00FF00

print(cols)
```
Derived classes also support type inheritance, such as
```python
import enum

class Simple(enum.Enum):
	PROP = 'prop'

print(Simple.PROP == 'prop')	# False

class Derived(str, enum.Enum):
	PROP = 'prop'

print(Derived.PROP == 'prop')	# True
```

### `collections.OrderedDict` <a name="toc-sub-tag-7"></a>
To put simply, a dictionary where the insertion order is important. By contrast, `dict` will return keys in the order of hash, whereas `OrderedDict` returns the keys in order of insertion
```python
import collections
spam = collections.OrderedDict()
spam['a'] = 1
spam['c'] = 3
spam['b'] = 2
print(spam)
# OrderedDict([('a', 1), ('c', 3), ('b', 2)])

print(collections.OrderedDict(sorted(spam.items())))
# OrderedDict([('a', 1), ('b', 2), ('c', 3)])
```
It is implemented by a `dict` in combination with a doubly linked list for keeping track of the order. Another `dict` is used to keep track of reverse relation. Within this, `set` and `get` are O(1) but the object requires more memory than conventional dictionaries, and as such don't scale very efficiently.

### `heapq` <a name="toc-sub-tag-8"></a>
Essentially an ordered list, and very useful for creating priority queues, able to make the smallest (or largest) item in the list easily obtainable
```python
import heapq

heap = [1, 3, 4, 7, 2, 4, 3]
heapq.heapify(heap)
print(heap)
# [1, 2, 3, 7, 3, 4, 4]
```
A heap is a binary tree for which the parent nodes has a value less than or equal to any of its children. We can visualize it by iterating through our object
```python
while heap:
	heapq.heappop(heap), heap

# 1 [2, 3, 3, 7, 4, 4]
# 2 [3, 3, 4, 7, 4]
# 3 [3, 4, 4, 7]
# 3 [4, 4, 7]
# 4 [4, 7]
# 4 [7]
# 7 []
```

### `bisect` <a name="toc-sub-tag-9"></a>
A sorted list; where `heapq` makes obtaining the smallest (or largest) item easy, `bisect` inserts items so that the overall list stays sorted. As such, finding in `bisect` is fast, whereas adding and removing in `heapq` is fast. Adding new elements to a `bisect` is an O(n) operation, and creating a sorted list using bisect takes O(n^2), compared to e.g. `heapq` with O(n log(n)). The primary use of `bisect` is then to extend an already ordered structure, as opposed to creating a new one
```python
import bisect

# regular sort
sorted_list = []
sorted_list.append(5)
sorted_list.append(3)
sorted_list.append(1)
sorted_list.append(2)	# each operation so far is O(1)
sorted_list.sort()		# O(n * log(n)) = O(8)

print(sorted_list)
# [1, 2, 3, 5]

# bisect
sorted_list = []
bisect.insort(sorted_list, 5)	# O(n) = O(1)
bisect.insort(sorted_list, 3)	# O(2)
bisect.insort(sorted_list, 1)	# ...
bisect.insort(sorted_list, 2)	# O(4)

print(sorted_list)
# [1, 2, 3, 5]
```
Searching in such a data structure is likewise very fast; e.g. `bisect_left` finds the position at which a number is supposed to be
```python
import bisect

sorted_list = [1, 2, 3, 5]

def contains(sorted_list, value):
	i = bisect.bisect_left(sorted_list, value)
	return i < len(sorted_list) and sorted_list[i] == value

contains(sorted_list, 2)	# True
contains(sorted_list, 4)	# False
```
The implementation details for such a search is a binary search algorithm.

## Some notes on list comprehension <a name="toc-sub-tag-10"></a>
