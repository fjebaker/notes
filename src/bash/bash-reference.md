# Bash reference

Reference notes for all things related to the Bourne Again Shell, and derivatives.

<!--BEGIN TOC-->
## Table of Contents
1. [Special variables](#special-variables)
    1. [Positional parameters](#positional-parameters)
2. [IFS](#ifs)
3. [Useful resources](#useful-resources)

<!--END TOC-->

## Special variables
Most of these are taken from [an advanced scripting guide](https://tldp.org/LDP/abs/html/internalvariables.html).

- **`$$`**: process ID, often the same as `$BASHPID`, contextually of the executing script.
- **`$MACHTYPE`**: machine hardware type (i386, x86_64, ...).
- **`$_`**: set to the final argument of the previously executed command.

For `$_`, consider
```bash
du > /dev/null
echo $_
# du

ls -l > /dev/null
echo $_
# -l
```

### Positional parameters
Only avaible in function calls

- **`$#`**: the number of arguments passed.
- **`$*`**: all positional parameters as a single word.
- **`$@`**: `$*` but with each parameter being seen as a seperate word.


The `$@` variable responds to `shift` calls, which removes `$1` and decrements the positional index of every remaining variable by one.

For example, a script which is passed `1 2 3 4 5` as input:
```bash
echo "$@"    # 1 2 3 4 5
shift
echo "$@"    # 2 3 4 5
shift
echo "$@"    # 3 4 5
```

## IFS
The *internal field seperator* is used by many shell commands to work out how to do word splitting in the input.

A useful case to remember is that *new-line* characters are escaped
```bash
IFS=$'\n'
```

The first character in the IFS definition also marks how common shell commands will bind words together. For example
```bash
IFS=":;-"
```
and
```bash
IFS="-:;"
```
will both split words on any of `:`, `;`, or `-` characters -- but when used with the `$*` special variable have a different effect:
```bash
bash -c 'set a b c d; IFS=":;-"; echo "$*" '
# a:b:c:d
bash -c 'set a b c d; IFS="-:;"; echo "$*" '
# a-b-c-d
```

## Environment contexts
Environment variables set during the context of a command may be passed with
```bash
SOME_VAR=some_val ./script.sh
```
or using `exec` and `env` to run the program in a modified environment
```bash
exec env SOME_VAR=some_val ./script.sh
```


## Parameter manipulation
Reference for manipulating parameters/variables with bash; for more, see [parameter substitution](https://tldp.org/LDP/abs/html/parameter-substitution.html#EXPREPL1).

### Default
When accessing a variable `$var`, which may or may not be set.

Note, in all of these, the modification `:` in the syntax will also use apply the default value *if* `$var` is declared, but set to `null`.


#### Use default
For default values, there are two syntax options
```bash
${var-$var2}
${var:-$var2}
```
which can also be used with command substitutions
```bash
${var-`pwd`}
```


#### Set to default
```bash
${var=default_value}
${var:=default_value}


### Replace
For a local replacement
```bash
${var/pattern/replacement}
```
Or globally
```bash
${var//pattern/replacement}
```

#### Error
To print an error message if a variable is not set, use
```bash
${var?err_message}
${var:?err_message}
```

### Trimming
Example for trimming *known characters* from the end of a string
```bash
${var%.mp4}   # removes .mp4
${var%.*}     # removes any filename suffix
```

The `%` operator removes a suffix, and the `#` operator removes a prefix.

### String length
For a character count, use
```bash
${#var}
```

### Substring extraction
For all but the last 4 characters:
```bash
${var:0:${#var}-4}
# note the 0 is implicit; the above is equivalent to
${var::${#var}-4}
# and on many bash derivatives, the string length is also implicit
${var::-4}
```

## Useful resources

Resources for writing bash scripts, and general bash guides:

- Mendel Cooper's *Advanced Bash-Scription Guide* (site, available [here](https://tldp.org/LDP/abs/html/index.html)).