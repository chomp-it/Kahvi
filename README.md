# Kahvi
CoffeeScript on its own allows you to write apps much faster than with plain JavaScript, however, you still have to jump over verbose hurdles like `x = document.getElementById 'some-id'` or `x.addEventListener ...`. I wrote Kahvi -- nicknamed French Press CoffeeScript -- to solve these problems. And yes, the name is inspired by Ruby on Rails.

French Press CoffeeScript doesn't get in your way for your actual app logic; it only helps you get there faster; there are no magical conventions over things, just faster and cleaner ways. Let's get into the actual syntax of French Press CoffeeScript.

I'm just going to go down the line and show you syntax and a brief explanation. In the future, I will record a demo for French Press CoffeeScript which will be more detailed.

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
  console.log “some button was moused over”
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
someButton refers to ‘some-button-id’
```

This is really just assigning someButton to 'some-button-id'. Here's the equivalent CoffeeScript:

```coffeescript
someButton = document.querySelector ‘some-button-id’
```

Hide and display:

`hide x`

Evaluates to

`x.style.display = ‘none’`

And its opposite:

`display x`

Evaluates to

`x.style.display = ‘block’`

Aint:

This is really simple. In place of `isnt` in conditionals, you can use `aint`. It's quite an esoteric feature but you might enjoy it.

```
if x aint "y"
  console.log "x isnt y"
```

As a/an:

This is used for type coercion. Instead of using String(foo), you would use:

```
foo as a string
```

You can also use an instead of a. The compiler won't correct your grammar, but you should do whats right.

```
foo as an integer
```

oris:

This is a shortened way of using or; instead of writing `if x is y or x is z`, you can write:

```
if x is y oris z
```

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

Cheers!
