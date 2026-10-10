
# returns an array containing the first n amount of elements
Array::first = (amount) ->
  if amount is 1 then @[0] else @.slice(0, amount)

# returns an array containing the last n amount of elements
Array::last = (amount) ->
  if amount is 1 then @[@.length - 1] else @.slice(-amount)

# returns a random element from your array
Array::random = ->
  return @[Math.floor(Math.random() * @.length)]

# really just an easter egg; not practical at all
Array::ninety_sixth = ->
  @[95]

# alias for join
Array::reunite = ->
  @.join()

# returns true if the array is empty, false otherwise
Array::empty = ->
  @.length is 0

# returns true if the array is not empty, false otherwise
Array::full = ->
  @.length isnt 0

Array::includes = (needle) ->
  if needle in @ then true else false

# convert seconds to milliseconds
Number::in_milliseconds = ->
  @ * 1000

# a more natural alias for Number.in_milliseconds. Similar to Number.seconds
Number::milliseconds = ->
  return @.in_milliseconds()


# convert milliseconds to seconds
Number::in_seconds = ->
  Math.floor(@ / 1000)

# set a timeout for the amount of milliseconds given
Number::wait_for = (callback) ->
  setTimeout(callback, @)

# executes a callback x amount of times.
# example:
# (3).times -> log "Savo"
Number::times = (callback) ->
  callback(i) for i in [0...@]

# returns true if the given number is zero
Number::zero = ->
  if @ is 0 then return true else return false

# doesn't do anything but makes some statements sound better
# such as every (3).seconds -> console.log "something"
Number::seconds = ->
  @valueOf()

# (96).through(1704) -- returns an array of all numbers between 96 and 1704
Number::through = (number) ->
  array = []
  for iterator in [@..number]
    array.push(iterator)

  return array

# returns true if the number is even, false otherwise
Number::is_even = ->
  if @ % 2 is 0 then true else false

# returns true if the number is odd, false otherwise
Number::is_odd = ->
  if @.is_even() isnt true then true else false

# checks if a number is between two numbers -- (1999).between(1704, 2004)
Number::between = (min, max) ->
  if @ >= min and @ <= max then return true else return false

# checks if a number is less than another number
Number::less_than = (number) ->
  if @ < number then return true else return false

# checks if a number is greater than another number
Number::greater_than = (number) ->
  if @ > number then return true else return false

# returns an array of the characters in the string
String::characters = ->
  @.split("")

# get the lines from a string; split by newlines.
# best when you just read a file and want to iterate over it by each line.
String::lines = ->
  @.split "\n"

# alias for length
String::character_count = ->
  return @.length

# hide an element
String::hide = ->
  document.getElementById(@).style.display = 'none'

# display an element
String::display = ->
  document.getElementById(@).style.display = 'block'

# shorthand for document.getElementById
String::get = ->
  document.getElementById(@)

# alias for console.log
String::print = ->
  console.log(@)

# capitalize a string
String::upcase = ->
  @.toUpperCase()

# lowercase a string
String::downcase = ->
  @.toLowerCase()

# returns true if the string is blank, false otherwise
String::blank = ->
  if @.trim() is "" then return true else return false

# returns true if a string is either of two given options.
# usage: city.either("Helsinki", "Lahti")
String::either = (option_a, option_b) ->
  if @ is option_a or @ is option_b then  return true else return false

# the opposite of String.either; returns true if the string is not either of the given options.
String::isnt_either = (option_a, option_b) ->
  if @ isnt option_a and @ isnt option_b then return true else return false

# returns a random nordic city from Finland, Denmark, Sweden, Norway, or Iceland.
window.nordicCity = ->
  cities = [
    "Helsinki",
    "Tampere",
    "Lapland",
    "Malmö",
    "Örebro",
    "Sundsvall",
    "Trondheim",
    "Harstad",
    "Bergen",
    "Aarhus",
    "Holstebro",
    "Hirtshals",
    "Akureyri",
    "Reykjavik",
    "Selfoss"
  ]

  return cities.random()

# alias for console.log
window.log = (message) ->
  console.log message

# executes a callback every x seconds.
# it is by no means required, but it is suggested to use it like this:
# every (3).seconds -> log "Tampere"
window.every = (time, callback) ->
  return setInterval(callback, time)