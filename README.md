# Kahvi

```javascript
const toggleButton = document.getElementById('lieksa-toggle-nav');
const navElement   = document.getElementById('lieksa-nav');

toggleButton.addEventListener("click", () => {
  if (navElement.style.display === 'block') {
	navElement.style.display = 'none';
  } else {
	navElement.style.display = 'block';
  }
});
```

Gross. That's just horrible. I had to write that for [Lieksa](https://github.com/Centurion774477/Lieksa) and hated every second of it.

The equivalent French Press CoffeeScript is:

```coffeescript
navElement refers to 'lieksa-nav'

when 'lieksa-toggle-nav' is clicked ->
	toggle_display_of navElement
```

Now that I got your attention, allow me to explain what French Press CoffeeScript is a bit more.

CoffeeScript on its own allows you to write apps much faster than with plain JavaScript, however, you still have to jump over verbose hurdles like `x = document.getElementById 'some-id'` or `x.addEventListener ...`. I wrote Kahvi -- nicknamed French Press CoffeeScript -- to solve these problems.

I believe in Stating The Obvious. We are using CoffeeScript to manipulate the DOM, therefore manipulating the DOM should be painless.

Most of the features of French Press CoffeeScript get straight to the point. Instead of `const someElement = document.getElementById("some-id")`, You can either write `get "some-id"` or `someElement refers to 'some-id'`

Let's get into the actual syntax of French Press CoffeeScript so you can see how FPCS States the Obvious.

```coffeescript
when 'some-button-id' is clicked ->
  console.log "some button was clicked"
```

This is a shorthand for event listeners, but it also pulls down the element implicitly, cutting down on a lot of boilerplate.

Here is the CoffeeScript version:

```coffeescript
document.getElementById('some-button-id').addEventListener 'clicked', () ->
  console.log "some button was clicked"
```

In place of 'clicked', you can also pass these other options:
- submitted
- highlighted/mousedover
- unhighlighted/mouseoff
- Typed/typing
- changed

Another example:

```coffeescript
when 'some-button-id' is mousedover ->
  console.log "some button was moused over"
```

You can also use a variable if you wish:

```
when someButton is changed ->
	console.log "some button was changed"
```

Enforce:

```
enforce 'some-id' as a word
```

This is a bit more magical than the first expression, but it's really just verifying input -- an action that is otherwise extremely tedious.

Code speaks louder than words, however, so let me show you the CoffeeScript equivalent:

```coffeescript
unless document.getElementById 'some-id'.value.match /^[a-zA-Z]+$/
  alert "input rejected: it must be a string."
  return
```

Long story short, it will alert with a default message saying the input was rejected because it must be <type> unless it matches the requirements.
I haven't added it yet, but in the future it will perform a second check for null values or empty inputs to give a more detailed alert.

As of now, there is only one other alternative type: integer/number.

You can also use string as an alias to word.

Refers to:

```coffeescript
someButton refers to 'some-button-id'
```

This is really just assigning someButton to 'some-button-id'. Here's the equivalent CoffeeScript:

```coffeescript
someButton = document.querySelector 'some-button-id'
```

Get

Get is somewhat magical: you don't explicitly declare the variable. Consider this:

```
get 'some-button'
```

Now you can refer to `someButton` as a variable!

It generates:

```
someButton = document.getElementById 'some-button'
```

Hide and display:

`hide x`

Evaluates to

`x.style.display = 'none'`

And its opposite:

`display x`

Evaluates to

`x.style.display = 'block'`

toggle_display_of

If you want the display of an element to be toggled, then use this instead of using `hide` and `display` with a conditional:

`toggle_display_of element`

Right now:

This is a way of easily getting the time. There are four variants:

```
right now in hours
```

Returns only the hours

```
right now in minutes
```

Returns only the minutes

```
right now in seconds
```

Returns only the seconds

```
right now in full
```

This returns the full time formatted like:

hours:minutes:seconds

Get:

this turns a get request into a one line operation.

You write:

```
data = get "http\://localhost3000/fetch"
```

And it compiles into:

```
data = null

getData = (url) ->
try 
	response = await fetch(url)
	
	unless response.ok
		throw new Error "Response status: ${response.status}"

	data = await response.json()

catch (error)
	console.error(error.message)

getData("http\://localhost3000/fetch")
```

## Methods

In addition to keywords, FPCS also has some methods. The only way to access these is to use the generate command. This will copy the methods file into your directory and allow you to use them.

Here are some of the notable methods:

String.either(a, b): `city.either("Helsinki", "Tampere")`

String.character_count: `"Denmark".character_count`

String.blank: `"".blank`

Number.between(a, b): `(1999).between(1704, 2004)`

Array.random: `cities.random`

# Generate

This is the other side of French Press CoffeeScript: it is used to scaffold files.

Right now, the only function is to create a "page" -- which consists of a .frenchpress file,  a .styl (Stylus), and an HTML file.

Here's how it looks:

`fp generate blog`

Outputs:
- blog.html
- blog.styl
- blog.frenchpress

And it appends this to your master script:
```
fp full_send blog.frenchpress
stylus blog.styl
```

Allow me to explain what the master script is.

The problem with preprocessors has always been wrangling the compile scripts; for the equivalent page setup you would have to track the Kahvi command as well as the stylus command, and then write them manually each time, as well as repeating that process for each page. If you generate a page using Kahvi, those commands will automatically be added to your masterscript. Once your app starts to get a bit bigger, this masterscript process should save you a good amount of time.


# Conclusion

Hope you enjoyed. This is in active development so bugs are quite common.
I am working to add new features and fix bugs when I can.

Also see [Mojave](https://github.com/Centurion774477/Mojave), a library to turn localStorage into a psuedo-database and see [Everett](https://github.com/Centurion774477/Everett), a library to make handling configs with sessionStorage easier.

Both of these are part of the French Press CoffeeScript family, but nobody's stopping you from using them on their own.

this README was purified using [Murman](https://github.com/Centurion774477/Murman)

Cheers!
