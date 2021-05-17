# Bash reference

Reference notes for all things related to the Bourne Again Shell, and derivatives.

<!--BEGIN TOC-->
## Table of Contents
1. [Redirections](#redirections)
    1. [I/O redirection](#i/o-redirection)
        1. [Output operators](#output-operators)
        2. [Input operators](#input-operators)
        3. [Opening and closing file descriptors](#opening-and-closing-file-descriptors)
    2. [Operation ordering](#operation-ordering)
    3. [Here documents](#here-documents)
2. [Operators](#operators)
    1. [Numerical comparison operators](#numerical-comparison-operators)
    2. [String comparison operators](#string-comparison-operators)
    3. [File test operators](#file-test-operators)
3. [Special variables](#special-variables)
    1. [Positional parameters](#positional-parameters)
4. [POSIX character classes](#posix-character-classes)
5. [IFS](#ifs)
6. [Environment contexts](#environment-contexts)
7. [Parameter manipulation](#parameter-manipulation)
    1. [Default](#default)
        1. [Use default](#use-default)
        2. [Set to default](#set-to-default)
        3. [Error](#error)
    2. [Replace](#replace)
    3. [Trimming](#trimming)
    4. [String length](#string-length)
    5. [Substring extraction](#substring-extraction)
8. [`find`](#find)
    1. [`not` conditional](#not-conditional)
    2. [`-exec` options](#-exec-options)
        1. [Piping](#piping)
9. [Useful resources](#useful-resources)

<!--END TOC-->

## Redirections

### I/O redirection
The following are commonly used redirection operators. These operations work on file descriptors:
```
0   - stdin
1   - stdout
2   - stderr
``` 

#### Output operators

Example use:
```bash
# write "Some Text" to the file `output.txt`
echo "Some text" > output.txt
```

- `> FILENAME` pipe to file, will overwrite if present
- `>> FILENAME` pipe to file, appends if present

Specific output operators; note, for each there exists the `>>` variant:

- `1> FILENAME` pipe *only* `stdout`
- `2> FILENAME` pipe *only* `stderr`
- `&> FILENAME` pipe *both* `stdout` and `stderr`
- `J> FILENAME` pipe file descriptor `J` (default 1 if not present) to file
- `J>&K` pipe file descriptor `J` to file descriptor `K`

#### Input operators

Example use:
```bash
# same as `cat logfile | grep Error`
grep Error < logfile.txt
```

- `< FILENAME` accept input as coming from file, sometimes also `0<`
- `<&J` accept input as coming from file descriptor `J`

#### Opening and closing file descriptors

Example use: 
```bash
echo "Hello World" > file.txt
exec 3<> file.txt                   # open `file.txt` and assign file descriptor 3 to it

read -n 5 <&3                       # read 4 characters of the file
echo -n , >&3                       # write a ,
exec 3>&-                           # close file descriptor

cat file.txt
# Hello, World
```

- `J<> FILENAME` open file for reading and writing assigned to file descriptor `J`. `J` defaults to `0` if not present. If `FILENAME` does not exist, then it will be created
- `J<&-` close input file descriptor `J`. `J` defaults to 0 if not given
- `J>&-` close output file descriptor `J`

### Operation ordering
The order in which I/O operations are used can affect their behaviour. Consider the following examples
```bash
exec 3>&1                               # open fd 3 to `stdout`
ls -l >&3 3>&- | grep bad >&3           # close fd 3 for `grep` but not for `ls` 
exec 3>&- 
```

### Here documents
Full examples and documentation is available [here](https://tldp.org/LDP/abs/html/here-docs.html). The basic use replaces `stdin` in the preceding command:
```bash
cat <<EOF
...
EOF
```
*Note:* the symbol need not be `EOF`, but any unique character string, and the terminating symbol must exist on a new line with no preceding characters (whitespace, or otherwise).

Supressing tabs (output will be flush left)
```bash
cat <<-EOF
    ...
EOF
```

By default, here documents support parameter substitution. To disable it
```bash
cat <<'EOF' # alternatively \EOF or "EOF"
...
EOF
```

Here documents create temporary files that are deleted after opening, and not available to other processes: this can be demonstrated
```bash
bash -c 'lsof -a -p $$ -d0' << EOF
EOF

# COMMAND  PID    USER   FD   TYPE DEVICE SIZE/OFF    NODE NAME
# lsof    4375 aelfric    0r   REG   8,18        0 9962257 /tmp/zshc3dfTh (deleted)
```

## Operators

The following operators use single square bracket notation (unless otherwise indicated), as in the example:
```bash
if [ $a -eq $b ]; then
    echo "a and b are numerically equal!"
fi
```
As they are presented, these operators are true when the accompanying statement is true. In general, any given operator may be reversed with the `!` (not) operator:

```bash
if ! [ $a -eq $b ]; then
    echo "a and b are *not* numerically equal!"
fi
```

### Numerical comparison operators


- `-eq` is equal to
- `-ne` is not equal to
- `-gt` is greater than, alternatively `>` in double parentheses
- `-ge` is greater than or equal to, alternatively `>=` in double parentheses
- `-lt` is less than, alternatively `<` in double parentheses
- `-le` is less than or equal to, alternatively `<=` in double parentheses


### String comparison operators

It is a good practice to always quote a tested string, unless the pattern matching behaviours are desired.

- `=` is equal to
- `==` is equal to, with different behaviour when framed in double brackets
```bash
[[ $a == b* ]]   # pattern matching, with wildcard
[[ $a == "b*" ]] # literal matching, i.e. `$a` equal to exactly z*
```
- `!=` is not equal to
- `<` is less than in ASCII alphabetical ordering
- `>` is greater than in ASCII alphabetical ordering
- `=~` regex match, requires double brackets. Uses [POSIX character classes](#posix-character-classes).

The following are unary operators:

- `-z` string is null (zero length)
- `-n` string is not null

### File test operators
These operators act on file paths, either as strings or on expanded variables. They are all unary operators, unless otherwise stated.

- `-e` exists
- `-f` is regular (not a directory or device file)
- `-s` is non-zero size
- `-d` is a directory
- `-h` is a symbolic link, alternatively `-L`
- `-S` is a socket
- `-g` sgid (set-group-id) flag is set -- file belongs to the group that owns the directory
- `-u` suid (set-user-id) flag is set -- file will execute as root (provided owned by root); shows an `s` in permissions.


The following are evaluated in the context of the script's executing user

- `-r` has read permissions
- `-w` has write permissions
- `-x` has execute permissions
- `-O` user owns this file
- `-G` GID of file is the same as user's

The following are binary operators

- `-nt` left file is newer than right file
- `-ot` left file is older than right file
- `-ef` left file and right file are hard links to the same file

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

## POSIX character classes

POSIX character classes are groups of similar characters used in POSIX regex expressions, amongst other places. They may be typed in either completely lower or uppercase; that is, `[:alpha:]` and `[:ALPHA:]` are equivalent.


POSIX Class | Meaning
-|-
`[:lower:`] | lowercase letters
`[:upper:`] | uppercase letters
`[:alpha:`] | alphabetic characters 
`[:alnum:`] | alphanumeric characters 
`[:digit:`] | digits 
`[:xdigit:`] | hex digits 
`[:blank:`] | spaces and tabs 
`[:space:`] | all white space characters, incl. `\n` 
`[:cntrl:`] | control characters 
`[:punct:`] | punctuation symbols   
`[:print:`] | visible characters and spaces
`[:graph:`] | visible characters
`[:ascii:`] | ASCII characters
`[:word:`] | alphanumeric and underscore (i.e. regex `\w`)

There are two special classes for denoting the beginning `[:<:]` and end `[:>:]` of a word.

*Link:* for more information, see [regular expressions info](http://www.regular-expressions.info/posixbrackets.html).

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
```


#### Error
To print an error message if a variable is not set, use
```bash
${var?err_message}
${var:?err_message}
```

### Replace
For a local replacement
```bash
${var/pattern/replacement}
```
Or globally
```bash
${var//pattern/replacement}
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

## `find`
The [`find` command](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/find.html) has numerous very useful features.

### `not` conditional
To find files not matching a certain predicate, `find` supports the `-not` argument: for example,
```bash
find . -name "*.md" -not -name "index.md"
```
to find files ending in `.md` but not files called `index.md`.

### `-exec` options
The `-exec` flag supports two terminations:

- serial


```bash
find . -exec echo {} \;
```
to execute, in this case, `echo` on each file, calling the command once per file.


- group

```bash
find . -exec echo {} +
```
to execute echo on all of the output combined together as words, calling the command once per file.

#### Piping
If `-exec` needs to pipe the output of a command to another, there are two useful ways of achieving this.

The first is by (ab)using `sh`
```bash
find . -exec sh -c "cat {} | grep Example" \;
```
Or otherwise by piping the output through `xargs` seperated by new lines:
```bash
find . | xargs -d\\n cat | grep Example
```

## Useful resources

Resources for writing bash scripts, and general bash guides:

- Mendel Cooper's *Advanced Bash-Scription Guide* (site, available [here](https://tldp.org/LDP/abs/html/index.html)).