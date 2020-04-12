# High performance Python techniques and paradigms
Python is a language that I find is easy to learn, but difficult to master. These notes are part of my ongoing task of becoming as proficient at this language as I can.

<!--BEGIN TOC-->
## Table of Contents
1. [Advanced collections](#toc-sub-tag-0)
	1. [`collections.ChainMap`](#toc-sub-tag-1)
	2. [`collections.Counter`](#toc-sub-tag-2)
	3. [`collections.deque`](#toc-sub-tag-3)
	4. [`collections.defaultdict`](#toc-sub-tag-4)
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
It's trivial to see how a `Counter` could be implemented with `defaultdict`, but the version included in `collections` is far more extensive.

