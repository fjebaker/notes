# Jupyter and iPython cheat sheet
A few recipes and commands for Jupyter/iPython.

## Matplotlib
Use the magic command
```py
%matplotlib
```
to enable the backend, and in jupyter
```py
%matplotlib inline
```

## Jupyter Config
Generate a default configuration file with
```
juypter notebook --generate-config
```

### Passwords
You can enable and set password protection with
```
jupyter notebook password
```

### Accept all IP
For a public notebook, use
```
jupyter notebook --ip=* --no-browser
```
