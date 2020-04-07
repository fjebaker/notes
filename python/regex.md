# Using the `re` library in Python 
The regex implementation in Python comes with a unique set of commands for facilitating matches, searches, substitutions, and other operations.

### Extracting groups
For some regex pattern `ptrn`, we can extract the matches from `data` using
```python
matches = re.findall(ptrn, data)
``` 
In this case, `matches` is a list containing all matches groups.