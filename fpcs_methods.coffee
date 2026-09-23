
# returns an array containing the first n amount of elements
Array::first = (amount) ->
  if amount is 1 then @[0] else @.slice(0, amount)

# returns an array containing the last n amount of elements
Array::last = (amount) ->
  if amount is 1 then @[@.length - 1] else @.slice(-amount)

# returns a random element from your array
Array::random = ->
  @[Math.floor(Math.random() * @.length)]

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

# convert seconds to milliseconds
Number::in_milliseconds = ->
  @ * 1000

# convert milliseconds to seconds
Number::in_seconds = ->
  Math.floor(@ / 1000)

# set a timeout for the amount of milliseconds given
Number::wait_for = (callback) ->
  setTimeout(callback, @)

# returns an array of the characters in the string
String::characters = ->
  @.split("")

# alias for length
String::character_count = ->
  @.length

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

# returns a random nordic city from Finland, Denmark, Sweden, Norway, or Iceland.
nordicCity = ->
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
log = (message) ->
  console.log message