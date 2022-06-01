# Vue Overview

[Vue](https://vuejs.org/) is a framework for building single page web pages, and provides a very wide range of functionality. 

In these notes are common idioms and recipes that I find I keep having to look up.

<!--BEGIN TOC-->
## Table of Contents
1. [Setting up a new project](#setting-up-a-new-project)
    1. [Adding Bootstrap](#adding-bootstrap)
2. [Compontents](#compontents)
3. [Conditional rendering](#conditional-rendering)
    1. [`v-for`](#v-for)
4. [Buttons](#buttons)
    1. [Registering callbacks](#registering-callbacks)

<!--END TOC-->

## Setting up a new project
Requires `@vue/cli`, which is npm installable.

Using the binary (if not in path, can be found under `node_modules/.bin/vue`)

```bash
vue create [project-name]
```

### Adding Bootstrap
For the auto-configuration, simply use:
```bash
vue add bootstrap-vue
```

## Compontents
Components are modularised section of the webpage, analagous to a class in object orientated languages.

The component must at it's minimal define
```vue
<template>
    <div>
        Hello World
    </div>
</template>
```
Properties and data from the scripts may be inserted using `{{someProperty}}` escapes.

Components may include an optional script section; common usage may look like
```vue
<script>

export default {
    name: "Component Name",
    props: {
        someProperty: String
    },

    methods: {
        myFunction() {
            return this.someProperty;
        }
    },

    data() {
        return {
            someKey: "Some Data"
        }
    }

}
</script>
```

Components may also include scoped style tags:
```vue
<style scoped>
/* style definitions */
</style>
```

## Conditional rendering
Vue includes ways of conditionally including and exluding components, aswell as facilitating control flow with loops.

### `v-for`
We can define a component for each item in a javascript list with
```vue
<template>
    <b-row>
        <b-col v-for="i in propList" :key="i.id">
            <!-- using scoped i -->
        </b-col>
    </b-row>
</template>
```

Note the use of `:key="i.id"`; the key is used as a trigger for updating the item. That is, if `i.id` is modified, the `<b-col>` tag is redrawn, with the updated values in `i`.


## Buttons
Buttons are usually redefined in different frameworks, such as [Vuetify](https://vuetifyjs.com/en/components/buttons/) or [Vue Bootstrap](https://bootstrap-vue.org/docs/components/button), and will offer their own methods and behaviours. There are some features that behave identically in most of these implementations.

I frequently use Vue Bootstrap, so will make my code examples relevant to that specific syntax.

### Registering callbacks
We do this with the `@click` directive
```vue
<template>
    <b-btn @click="myMethod">
    </b-btn>
</template>


<script>
export default {
    methods: {
        myMethod() {
            console.log("Click!");
        }
    }
}
</script>
```

Arguments may be passed by, for example, wrapping the `@click` with an anonymous function, leveraging JS closures.
