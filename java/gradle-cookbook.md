# Gradle build-tool cookbook

## Table of Contents
1. [Gradle configuration](#config)
2. [A worked example](#worked-example)
	1. [Declaring dependencies](#example-dependencies)
	2. [Specifying JAR artifact](#example-jar)
	3. [Building with gradle wrapper](#example-wrapper)
	4. [Running as an application](#example-app)
3. [Flushing wrapper cache](#wrapper-cache)

#### Notes on installation
Working on OSX, I installed gradle from brew
```
brew install gradle
```
which uses `openjdk` as the dependency, since I don't believe I installed any updated JDK previously (like oracle). It also provides this warning
```
openjdk is keg-only, which means it was not symlinked into /usr/local,
because it shadows the macOS `java` wrapper.

If you need to have openjdk first in your PATH run:
  echo 'export PATH="/usr/local/opt/openjdk/bin:$PATH"' >> ~/.zshrc

For compilers to find openjdk you may need to set:
  export CPPFLAGS="-I/usr/local/opt/openjdk/include"
```

Subsequently did I install the Oracle JDK 14 (openjdk is 13 in keg) so caution when assuming the JDK.

## Gradle configuration <a name="config"></a>
Changing the JDK used by gradle can be done in two ways

1. In `gradle.properties` in the `.gradle` directory in home directory, set 
```js
org.gradle.java.home = '/[path_to_jdk_directory]'
```

or

2. In `build.gradle`, add
```js
compileJava.options.fork = true
compileJava.options.forkOptions.executable = '/[path_to_javac]'
```

The second option I would imagine is system dependent (haven't tried).

## A worked example <a name="worked-example"></a>
This example follows the [spring.io tutorial](https://spring.io/guides/gs/gradle/).

We set up a directory structure `mkdir -p src/main/java/hello/`, where we have two classes defined: `HelloWorld.java` and `Greeter.java`, both in the `hello` package. `HelloWorld` implements an instance of `Greeter`.

Gradle can be started by typing `gradle` in a terminal, which defaults to print the help message. Gradle manages different tasks, which for any project can be listed using 
```
gradle tasks
```
The tasks utilize a `build.gradle` file which defines their behaviour and integration into the project. Different plugins can extend the possible tasks gradle can undertake, so it is worth listing them periodically.

For most barebones `build.gradle` file we can write contains a single plugin
```js
apply plugin: 'java'
```
and is located in the root project folder, along side `src`.

We can run this using 
```
gradle build
```
which creates a `build` directory. Gradle understands the project structure, so already has compiled our `.java` files into `.class` files, and created a `MANIFEST.MF` file. It also creates a `.jar` named after the project folder.

Dependencies are stored in the `dependency_cache`, which at this point should be empty, as we do not specify any dependencies in the build file.

The output of the command also includes unit test executions, of which there are none, since none have been defined.

#### Using `joda.time` and declaring dependencies <a name="example-dependencies"></a>
Suppose`HelloWorld.java` used the `joda.time` library. We would need to specify in the build file where this library can be found. We add a repository for these external libraries
```js
repositories {
	mavenCentral()
}
```
and declare new dependencies as
```js
sourceCompatibility = 1.8
targetCompatibility = 1.8

dependencies {
	compile "joda-time:joda-time:2.2"
	testCompile "junit:junit:4.12"
}
```
The syntax follows `{group}:{library}:{version}`. We also specified that, e.g., `joda-time` should be a `compile` dependency, i.e. only available during compile time. `testCompile` on the other hand would not be included in build or runtime code, but only used when compiling and execute tests.

#### Specifying JAR artifact <a name="example-jar"></a>
We can provide a simple name and version number for our artifact
```js
jar {
	baseName = 'gs-gradle'
	version = '0.1.0'
}
```
This would create an artifact when `gradle build` is executed with the name `gs-gradle-0.1.0.jar`.

#### Building the example project with a gradle wrapper <a name="example-wrapper"></a>
The gradle wrapper is batch script in Wnidows, and a shell script in `*nix`, allowing gradle builds to be performed even on machines that do not have gradle installed.

To create a wrapper, execute
```
gradle wrapper --gradle-version 2.13
```
which creates a few new files, namely the two OS specific build scripts, and a `gradle/wrapper/` directory, with the wrapper artifact and properties descriptors.

To build now (install agnostic) run 
```
./gradlew build
```
The first time the wrapper runs, it will download and cache gradle binaries for the specified version (this also means that even if you have gradle installed, executing the project specific wrapper ensures you have the correct version for this project).

We can inspect the generated artifact with 
```
jar tvf build/libs/gs-gradle-0.1.0.jar
```
Note that the dependencies are not included here, nor is this `.jar` executable. To amend this, we use the `application` plugin.

#### Making the project executable as an application <a name="example-app"></a>
We add a few lines to define the new plugin and the main class in our build file
```js
apply plugin: 'application'
mainClassName = 'hello.HelloWorld'
```
which then allows us to run the application immediately with 
```
./gradlew run
```

To bundle the dependencies requires a little more work. Suppose we build a WAR file, we could easily use gradle's WAR plugin to fascilitate this. For spring boot, similarly, there is a spring-boot-gradle-plugin to assist this.

## Flushing wrapper cache <a name="wrapper-cache"></a>
The gradle cache is located in
```
~/.gradle/caches/
```
Deleting indivdual caches removes them from the wrapper cache (avoids issues with bad JDK paths and similar).

To completely flush the cache, run
```
rm -rf ~/.gradle/caches/
```
NB: this also wipes dependency cache, so that will have to be redownloaded.