Note From Guide 2.0

<h1 id="introduction">Introduction</h1>

Vue: /vju:/. Focus on the VIEW layer only. 
Include in html: `<script src="https://unpkg.com/vue"></script>`

<h2 id="declarative-rendering">Declarative Rendering</h2>

- Render data to DOM
```html
<div id="app">
    {{ message }}
</div>
```
```js
var app = new Vue({
    el: '#app', 
    data: {
        message: 'Hello Vue!'
    }
})
```

- Bind element attributes
```html
<div id="app-2">
    <span v-bind:title="message">Hover your mouse over here, see title</span>
</div>
```

```js
var app2 = new Vue({
    el: '#app-2',
    data: {
        message: 'You load this page on' + new Date()
    }
})
```

*attention the time is showing when the Vue created, not you hover over it.*

<h2 id="conditional-and-loops">Conditionals and Loops</h2>

- if 
```html
<div id="app-3">
    <p v-if="seen">Now you see me</p>
</div>
```
```js
var app3 = new Vue({
    el: '#app-3',
    data: {
        seen: true
    }
})
```
- for 
```html
<div id="app-4">
    <ol>
        <li v-for="todo in todos">
            {{ todo.text }}
        </li>
    </ol>
</div>
```
```js
var app4 = new Vue({
    el: '#app-4',
    data: {
        todos: [
            {text: 'Learn JS'},
            {text: 'Learn Vue'},
            {text: 'Learn Html'}
        ]
    }
})
```

*also use `app4.todos.push({text: 'New item'})`*

<h2 id="interact-with-user">Interact With User</h2>

- Bind event
```html
<div id="app-5">
    <p>{{ message }}</p>
    <button v-on:click="reverseMessage">Reverse Message</button>
</div>
```
```js
var app5 = new Vue({
    el: '#app-5',
    data: {
        message: 'Hello Vue.js'
    },
    methods: {
        reverseMessage: function() {
            this.message = this.message.split('').reverse().join('')
        }
    }
})
```
- Bind with `v-model` between input and app
```html
<div id="app-6">
    <p>{{message}}</p>
    <input v-model="message">
</div>
```
```js
var app6 = new Vue({
    el: '#app-6',
    data: {
        message: 'Hello Vue!'
    }
})
```

<h2 id="components">Components</h2>

- Register a simple component
```js
Vue.component('todo-item', {
    template: '<li>This is a todo</li>'
})
```
```html
<ol>
    <!-- Create an instance -->
    <todo-item></todo-item>
</ol>
```

- Component with `prop`
```js
Vue.component('todo-item', {
    props: ['todo'],
    template: '<li>{{todo.text}}</li>'
})

var app7 = new Vue({
    el: '#app-7',
    data: {
        groceryList: [
            {text: 'Vegetables'},
            {text: 'Cheese'},
            {text: 'Meat'}
        ]
    }
})
```
```html
<div id="app-7">
    <ol>
        <todo-item v-for="item in groceryList" v-bind:todo="item"></todo-item>
    </ol>
</div>
```
- A complex template seems like
```html
<div id="app">
    <app-nav></app-nav>
    <app-view>
        <app-sidebar></app-sidebar>
        <app-content></app-content>
    </app-view>
</div>
```

<h1 id="the-vue-instance">The Vue Instance</h1>

<h2 id="constructor">Constructor</h2>

```js
var vm = new Vue({
    // options
})
```
`vm` means 'ViewModel', refering to our Vue instances.
The `vue` constructor can be extended to create reusable component constructors:
```js
var MyComponent = Vue.extend({
    // extension options
})
var myComponentInstance = new MyComponent()
```

<h2 id="properties-and-methods">Properties And Mothods</h2>

- Each Vue instance proxies all properties in `data` object:
```js 
var data = { a: 1} 
var vm = new Vue({
    data: data
})
vm.a === data.a // -> true

vm.a = 2 
data.a // -> 2

data.a = 3
vm.a // -> 3

// but failed if you add new fields after newing Vue()
```
- Use prefixed `$` to get Vue-self own properties
```js
var data = { a: 1 }
var vm = new Vue({
    el: '#example',
    data: data
})

vm.$data === data // ->true
vm.$el === document.getElementById('example') // -> true

// $watch is an instance method
vm.$watch('a', function (newVal, oldVal) {
    // watch variable 'a'
})
```
*Question: There refer to arrow functions(=>), re-see it when you know it. [LINK](!http://vuejs.org/v2/guide/instance.html#Properties-and-Methods)*

<h2 id="lifecycle">Lifecycle</h2>

- There are several lifecycle hooks. Four basic: `beforeCreate` -> `created` -> `beforeMount` -> `mounted` -> `beforeUpdate` -> `updated` -> `beforeDestory` -> `destroyed`
```js
var vm = new Vue({
    data: {
        a: 1
    },
    created: function () {
        // 'this' points to the vm instance
        console.log('a is: ' + this.a)
    }
})
```

- `created`: after the observing data and init events
- `mounted`: after compile template and replace 'el' with '$el'
- `updated`: after updated the DOM when data changes
- `destoryed`: after teardown watchers, child components and event listeners


<h1 id="template-syntax">Template Syntax</h1>

<h2 id="interpolations">Interpolations</h2>

- 'Mustache'(`{{}}`): `<span>Message: {{ msg }}</span>``
- `v-once`: `<span v-once>Message: {{msg}}</span>`
- `v-html`: `<div v-html="rawHtml"></div>`
- Attributes: using `v-bind` without 'Mustache', `<div v-bind:id="dynamicId"></div>`
- JS expressions: Vue.js supports **one single expression** inside all **data bindings**.
    + Successful examples:
        * `{{ message.split('').reverse().join('') }}`
        * `<div v-bind:id="'list' + id"></div>`
    + Failed examples, violate **one single expression**:
        * `{{ var a = 1 }}`
        * `{{ if (ok) { return message} }}`
    + Attention: There is a whitelist which is sandboxed. You don't access user's globals.

<h2 id="directives">Directives</h2>

- Arguments: Denoted by a colon after the directive name. `dir-name:arg-name="doSth"`, such as: `<a v-bind:href="url"></a>`
- Modifiers: Denoted by a dot. `<form v-on:submit.prevent="onSubmit"></form>`. New, see more later.

<h2 id="filters">Filters</h2>

- Only be usable in two places: **mustache interpolations and `v-bind`** with the 'pipe' symbol. (use Computed properties in other places)

```js
new Vue({
    filters: {
        capitalize: function (value) {
            if (!value) return '';
            value = value.toString();
            return value.charAt(0).toUpperCase() + value.slice(1)
        }
    }
})
```

- Take arguments:  `{{ message | filterA('arg1', arg2) }}`, 'arg1' will be second value. The first will always be the data to be filtered.

<h2 id="shorthands">Shorthands</h2>

- `v-bind`: could be omitted. `<a :href="url"></a>`
- `v-on`: could be instead of `@` and don't need `:`. `<a @click="doSth"></a>`

<h1 id="computed-properties-and-watchers">Computed Properties And Watchers</h1>

- Complex logic needs computed property, or you will see the delayed changes.
```html
<div id="example">
  <p>Original message: "{{ message }}"</p>
  <p>Computed reversed message: "{{ reversedMessage }}"</p>
</div>
```
```js
var vm = new Vue({
  el: '#example',
  data: {
    message: 'Hello'
  },
  computed: {
    // a computed property reversedMessage
    reversedMessage: function () {
      // `this` points to the vm instance
      return this.message.split('').reverse().join('')
    }
  }
})
```

- Computed vs Methods: You can use a Method to replace this usage, but **computed properties are cached based on their dependencies**. Method runs frequently underlying (list Digest). 
- Computed vs Watch. Computed can watch the relevant params by itself.
- Computed Setter: when you set the value like `vm.fullName = 'newName'`, it will invoke and update view accordingly.
```js
computed: {
    fullName: {
        get: function() {
            return this.firstName + ' ' + this.lastName
        },
        set: function (newValue) {
            var names = newValue.split(' ');
            this.firstName = names[0];  // the firstName and lastName
            this.lastName = names[names.length - 1];  // will update accordingly
        }
    }
}
```
- Watchers: Most useful when you perform asynchronous or expensive operations.
```js
watch: {
    question: function(newQuestion) {
        this.answer = 'Waiting for you to stop typing...';
        this.getAnswer()
    }
},
methods: {
    getAnswer: _.debounce(function () {
        // _.debounce is from lodash.js, a js to limit how often an expensive operation can be run.
    })
}
```

<h1 id="class-and-style-bindings">Class And Style Bindings</h1>

<h2 id="binding-html-classes">Binding HTML Classes</h2>

`v-bind:class=""`

- Object: `<div v-bind:class="{classA: truthiness, classB: truthiness[, ...]}"></div>`
- Array: all elements of array will be as the class.
- Array and Object mixed or nested.
- With Components: Use class (any form is ok) when using a component.

<h2 id="binding-inline-styles">Binding Inline Styles</h2>

`v-bind:style=""`

- Object: `v-bind:style="{ color: activeColor, fontSize: fontSize + 'px' }"`
- Array: 
