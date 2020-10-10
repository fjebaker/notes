# Using SWIG with NodeJS
Complete documentation is available on the [SWIG website](http://swig.org/Doc4.0/Javascript.html) (at time of writing, using SWIG 4.0.2), however I am adding notes for the current state and most likely the anticipated future state of using SWIG with NodeJS: **versions are very important**.

Any familiarity with SWIG lends itself to Javascript perfectly, and indeed if using Javascript Core
```bash
swig -javascript -jsc [inteface].i
```
then there is no problem on NodeJS 14. However, when trying to build with `-node` or `-v8`, the SWIG generated wrapper will fail with errors along the lines of:
```
...

../example_wrap.cxx:1277:44: error: expected '(' for function-style cast or type construction
int SwigV8Packed_Check(v8::Handle<v8::Value> valRef) {
                                  ~~~~~~~~~^
../example_wrap.cxx:1277:28: error: no member named 'Handle' in namespace 'v8'
int SwigV8Packed_Check(v8::Handle<v8::Value> valRef) {
                       ~~~~^
../example_wrap.cxx:1277:46: error: use of undeclared identifier 'valRef'
int SwigV8Packed_Check(v8::Handle<v8::Value> valRef) {
                                             ^
../example_wrap.cxx:1277:53: error: expected ';' after top level declarator
int SwigV8Packed_Check(v8::Handle<v8::Value> valRef) {
                                                    ^
                                                    ;
../example_wrap.cxx:1472:17: error: no template named 'Handle' in namespace 'v8'
SWIGRUNTIME v8::Handle<v8::FunctionTemplate> SWIGV8_CreateClassTemplate(const char* symbol) {
            ~~~~^
../example_wrap.cxx:1476:31: error: no viable conversion from 'MaybeLocal<v8::String>' to 'Local<v8::String>'
    class_templ->SetClassName(SWIGV8_SYMBOL_NEW(symbol));
                              ^~~~~~~~~~~~~~~~~~~~~~~~~
../example_wrap.cxx:827:32: note: expanded from macro 'SWIGV8_SYMBOL_NEW'
#define SWIGV8_SYMBOL_NEW(sym) v8::String::NewFromUtf8(v8::Isolate::GetCurrent(), sym)
                               ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

...
```

Keeping a close eye on the [SWIG GitHub Repository](https://github.com/swig/swig) (specifically the issues), it can be a little confusing to discern exactly what the fix for this is, and arguably the documentation is a additionally ambiguous when it says 
> The V8 code that SWIG generates should work with most versions from 3.11.10 up to 3.29.14 and later.

One would expect then forwards compatibility, however this is not the case and will fail with V8 for NodeJS 12 and 14. [This GitHub issue](https://github.com/swig/swig/issues/1520) discusses the problems, and a [recent pull](https://github.com/swig/swig/pull/1746) discusses how a solution surrounding `SWIG_Object` is making development difficult.

So what is the solution? Well... *backdate* to NodeJS 10 with 
```bash
$ node -p process.versions.v8
# 6.8.275.32-node.58
```

- **OSX**
On OSX, with `brew`, it is easy to maintain two (or more) different NodeJS versions using the the linking commands; we install
```bash
brew install node node@10
```
Unlink the version we do not desire
```bash
brew unlink node
```
and link the one we do
```bash
brew link node@10
```
*Note:* for NodeJS 10, this may also require running
```bash
echo 'export PATH="/usr/local/opt/node@10/bin:$PATH"' >> ~/.zshrc
```
which would have to be commented out when unlinking. There's probably an elegant way of automating this when `brew link/unlink` is invoked, but I am yet to properly explore `brew` internals in order to devise how.

## Example
As usual with SWIG, we have our `.cpp` and `.hpp` files (*note* that pure C is not compatible with V8, since it is a [C++ API](https://v8.dev/)), and define an interface file `.i` along the lines of 
```cpp
%module example
%{
    #include "example.hpp"
%}
%include "example.hpp"
```
SWIG with NodeJS requires no additional include statements (*CF:* [SWIG with Python](https://github.com/Dustpancake/Dust-Notes/blob/master/python/cpp-c-swig.md)). We can process and generate the wrapper code with
```bash
swig -c++ -javascript -node example.i
```

To compile the wrapper into a Node module, we may use the [`node-gyp` build tool](https://github.com/nodejs/node-gyp), which we can install with
```bash
npm i --save node-gyp
```

If not installing globally, the executable is located in
```
node_modules/node-gyp/bin/node-gyp.js
```
and may be worth aliasing in the `package.json`, although once configured, a call to `npm i` will invoke the `rebuild` command of `node-gyp`.

To configure `node-gyp`, we define a `binding.gyp` file at the root of our project, with the contents, e.g.
```json
{
  "targets": [
    {
      "target_name": "example",
      "sources": [ "example.cxx", "example_wrap.cxx" ]
    }
  ]
}
```

We then compile the module with
```bash
node-gyp configure build
```
The `configure` command is only required once, or when making changes to the environment. 


Now, the module may be used, by importing it with
```js
const example = require("./build/Release/example");
```
