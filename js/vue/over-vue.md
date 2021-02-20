# Vue Overview

[Vue](https://vuejs.org/) is a framework for building single page web pages, and provides a very wide range of functionality. 

In these notes are common idioms and recipes that I find I keep having to look up.

<!--BEGIN TOC-->
## Table of Contents
1. [Setting up a new project](#toc-sub-tag-0)
	1. [Adding Bootstrap](#toc-sub-tag-1)
2. [Compontents](#toc-sub-tag-2)
3. [Conditional rendering](#toc-sub-tag-3)
	1. [`v-for`](#toc-sub-tag-4)
4. [Buttons](#toc-sub-tag-5)
	1. [Registering callbacks](#toc-sub-tag-6)
<!--END TOC-->

## Setting up a new project <a name="toc-sub-tag-0"></a>
Requires `@vue/cli`, which is npm installable.

Using the binary (if not in path, can be found under `node_modules/.bin/vue`)

```bash
vue create [project-name]
```

### Adding Bootstrap <a name="toc-sub-tag-1"></a>
For the auto-configuration, simply use:
```bash
vue add bootstrap-vue
```

## Compontents <a name="toc-sub-tag-2"></a>
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

## Conditional rendering <a name="toc-sub-tag-3"></a>
Vue includes ways of conditionally including and exluding components, aswell as facilitating control flow with loops.

### `v-for` <a name="toc-sub-tag-4"></a>
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


## Buttons <a name="toc-sub-tag-5"></a>
Buttons are usually redefined in different frameworks, such as [Vuetify](https://vuetifyjs.com/en/components/buttons/) or [Vue Bootstrap](https://bootstrap-vue.org/docs/components/button), and will offer their own methods and behaviours. There are some features that behave identically in most of these implementations.

I frequently use Vue Bootstrap, so will make my code examples relevant to that specific syntax.

### Registering callbacks <a name="toc-sub-tag-6"></a>
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
