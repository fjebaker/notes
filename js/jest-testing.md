# Using Jest testing framework
[Jest](https://jestjs.io/) is a JavaScript testing framework, with intuitive structuring and extensibility. These notes document details and recipes involving Jest that I have used.

## Quick-start overview
Jest has [comprehensive guides](https://jestjs.io/docs/en/getting-started) on how to use Jest in pretty much any javascript project. I will amalgamate a few of the guides into a [webpack](https://webpack.js.org/) with [babel](https://babeljs.io/) quickstart:

### Project setup
There are a few contradictory ways as to how to best set up a project with Jest -- since the framework is somewhat un-opinionated about which practice is best, I will stick to a commonly seen idiom:

```
project/
 - node_modules/
 - build/
    - index.html
    - static/
       - some_static_resource.png
 - src/
    - index.js
    - some_class.js
 - test/
    - mocks/
       - fileMock.js
    - some_class.test.js
 - package.json
 - .babelrc
```

In the official guides, there is reference and generally an indication that the `test` directory should be inside `src` as `src/__test__/*.test.js`. I have reservations about using double underscores in files, since I usually add such files to my `.gitignore`, coming from a Python background.

We then install our requirements with
```bash
npm i --save-dev \
    webpack \
    webpack-cli \
    webpack-dev-server \
    @babel/core \
    @babel/preset-env \
```
and the testing dependencies 
```bash
npm i --save-dev \
    babel-jest \
    jest \
    identity-obj-proxy
```
Note that most of these packages are my personal flavour for setting up a project, and can be cherry picked as appropriate. The `identity-obj-proxy` is used to mock certain static assets in Jest, specifically `.css` and `.less` files.

### Configuring Jest
As cited in the [getting-started](https://jestjs.io/docs/en/getting-started) guide
> babel-jest is automatically installed when installing Jest and will automatically transform files if a babel configuration exists in your project. To avoid this behavior, you can explicitly reset the transform configuration option

Configuring Jest to use Babel is then as simple as configuring Babel with a `.babelrc`
```js
// .babelrc
{
    "presets": [
        "@babel/preset-env"
    ]
}
```
You can alter babel's settings to be Jest aware by using `babel.config.js` or `.babelrc.json` and using the process environment variable `NODE_ENV`, which Jest sets to `'test'` to have a more discerning configuration. As a side note, babel has a [very complete overview](https://babeljs.io/setup#installation) of installation instructions for different environments.

We can create a Jest configuration file with
```bash
jest --init
```
which will run an interactive setup, or, alternatively, write our configuration directly into `package.json`. Either way, for webpack we need to configure Jest to mock out static assets
```js
// package.json
{
    // ...
    "jest": {
        "moduleFileExtensions": ["js", "jsx"],
        "moduleDirectories": ["node_modules"],

        "moduleNameMapper": {
            "\\.(jpg|jpeg|png|gif|eot|otf|webp|svg|ttf|woff|woff2|mp4|webm|wav|mp3|m4a|aac|oga)$": "<rootDir>/test/mocks/fileMock.js",
            "\\.(css|less)$": "identity-obj-proxy"
        }
  }
}
```
We use `identitiy-obj-proxy` as an [ES6 Proxy](https://github.com/keyz/identity-obj-proxy) CSS mocker. We also added lines to help Jest find files, similar to webpack's configuration with `moduleDirectories` and `extensions`.

We can create a stub for the `fileMock.js` with
```js
// test/mocks/fileMock.js

module.exports = 'test-file-stub';
```

Finally we add a command for `npm`, which is simply
```js
// package.json
{
    // ...

    "scripts": {
        "test": "jest",
    // ...
    }
}
```
and with that the project setup is complete. By default, Jest will scour the `test` directory for files that and with `.test.js` or `.jsx` and execute those.

### Writing a simple test


## Using Jest with Vue.js
Following [this guide](https://alexjover.com/blog/write-the-first-vue-js-component-unit-test-in-jest/).

## Using Jest with React Apps
Follow this guide [here](https://jestjs.io/docs/en/tutorial-react), as indicated by [reactjs website](https://reactjs.org/docs/testing.html).

React [testing library](https://testing-library.com/docs/react-testing-library/intro), to assist with writing Jest tests.


## Other links

- [React, TypeScript, Webpack & Jest](https://medium.com/@maxpolski/react-typescript-webpack-jest-93a58c8458e5)

- [How to setup Jest in a TypeScript, Babel and Webpack project](https://www.wisdomgeek.com/development/web-development/how-to-setup-jest-typescript-babel-webpack-project/)
This article has a good comment on compiling with babel and Jest
```
   /*
    * Specifying what module type should the output be in.
    * For test cases, we transpile all the way down to commonjs since jest does not understand TypeScript.
    * For all other cases, we don't transform since we want Webpack to do that in order for it to do
    * dead code elimination (tree shaking) and intelligently select what all to add to the bundle.
    */
    
modules: isTest ? 'commonjs' : false
```
