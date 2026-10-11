#!/usr/bin/env ruby

require 'fileutils'

def lex line
    case line
    when /(?<indent>\s*)flip\s+(?<variable>.*)$/
      return {
        type: :flip,
        variable: $~[:variable],
        indent: $~[:indent]
      }
    when /(?<indent>\s*)toggle_display_of (?<variable>.*)$/
      return {
        type: :toggle_display,
        variable: $~[:variable],
        indent: $~[:indent]
      }
    when /(?<indent>\s*)(?<variable>.*)\s+=\s+get(?<url>.*)$/
      return {
        type: :get_request,
        variable: $~[:variable],
        url: $~[:url],
        indent: $~[:indent]
      }
    when /(?<indent>\s*)wait\s+for\s+(?<time>\d+)\s+(?<unit>\w+)/
      return {
        type: :wait,
        time: $~[:time],
        unit: $~[:unit],
        indent: $~[:indent]
      }
    when /(?<indent>\s*)after\s+(?<time>\d+)\s+(?<unit>\w+)\s+(?<action>.*)/
      return {
        type: :do_after_cooldown,
        time: $~[:time],
        unit: $~[:unit],
        action: $~[:action],
        indent: $~[:indent]
      }
    when /(?<indent>\s*)when\s+(\'|\")\s*(?<id>[^'"]*)\s*(\'|\")\s+is\s+(?<type>\w+)\s+->$/
        unless %w|clicked submitted highlighted mousedover unhighlighted mouseoff typed typing changed|.include?($~[:type])
          puts "Invalid type assigned to an event listener: #{$~[:type]}"
          exit
        end

        {
        type: :event_listener,
        id: $~[:id],
        event_type: $~[:type],
        indent: $~[:indent]
        }
    when /(?<indent>\s*)when\s+(?<variable>.*)\s+is\s+(?<type>\w+)\s+->$/
      unless %w|clicked submitted highlighted mousedover unhighlighted mouseoff typed typing changed|.include?($~[:type])
          puts "Invalid type assigned to an event listener: #{$~[:type]} "
          exit
      end

      {
        type: :variable_event_listener,
        variable: $~[:variable],
        event_type: $~[:type],
        indent: $~[:indent]
      }
    when /(?<indent>\s*)enforce\s+\'(?<id>.*)\'s\s+input\s+as\s+(a|an)\s+(?<type>.*)$/
        unless %w|string word integer number|.include?($~[:type])
          puts "Invalid type assigned to an enforce statement: #{$~[:type]} "
          exit
        end

        return {
        type: :input_enforcement,
        id: $~[:id],
        enforcement_type: $~[:type],
        indent: $~[:indent]
        }
    when /(?<indent>\s*)if\s+(?<variable>.*)\s+is\s+(?<first_check>.*)\s+oris\s+(?<second_check>.*)$/
      return {
        type: :oris_conditional,
        variable: $~[:variable],
        first_check: $~[:first_check],
        second_check: $~[:second_check],
        indent: $~[:indent]
      }
    when /(?<indent>\s*)(?<variable>.*)\s+refers\s+to\s+(?<id>.*)$/
      return {
        type: :element_assignment,
        variable: $~[:variable],
        id: $~[:id],
        indent: $~[:indent]
      }
    when /(?<indent>\s*)hide\s+(?<variable>.*)$/
      return {
        type: :hide,
        variable: $~[:variable],
        indent: $~[:indent]
      }
    when /(?<indent>\s*)display\s+(?<variable>.*)$/
    return {
        type: :display,
        variable: $~[:variable],
        indent: $~[:indent]
    }
    when /(?<indent>\s*)(?<new_var>.*)\s+=\s+(?<variable>.*)\s+as\s+(a|an)\s+(?<type>.*)$/
      return {
        type: :type_mutation,
        variable: $~[:variable],
        new_type: $~[:type],
        new_var: $~[:new_var],
        indent: $~[:indent]
      }
    when /(?<indent>\s*)if\s+(?<part_1>.+?)\s+aint\s+(?<part_2>.+)$/
      return {
        type: :aint_condition,
        condition_one: $~[:part_1],
        condition_two: $~[:part_2],
        indent: $~[:indent]
      }
    when /(?<indent>\s*)perform\s+(?<label>\w+)$/
      return {
        type: :perform,
        label: $~[:label],
        indent: $~[:indent]
      }
    when /(?<indent>\s*)end$/
      return {
        type: :end,
        indent: $~[:indent]
      }
    when /(?<indent>\s*)kahvi_confirm\s+(?<message>.*)$/
      return {
        type: :kahvi_confirm,
        message: $~[:message],
        indent: $~[:indent]
      }
    when /(?<indent>\s*)(?<function_name>.*)\s+does$/
      return {
        type: :alternate_function,
        name: $~[:function_name],
        indent: $~[:indent]
      }
    when /(?<indent>\s*)get\s+(?<element>.*)/
      return {
        type: :get_element,
        element: $~[:element],
        indent: $~[:indent]
      }
    when /(?<indent>\s*)(?<variable>.*)\s+=\s+right\s+now\s+in\s+(?<type>(hours|minutes|seconds|full))/
      return {
        type: :right_now,
        time: $~[:type],
        variable: $~[:variable],
        indent: $~[:indent]
      }
    else
      return {
        type: :coffeescript,
        value: line
      }
    end
end


def camelize(string, first_letter_upper: false)
  words = string
    .gsub(/([a-z\d])([A-Z])/, '\1 \2')
    .scan(/[a-zA-Z0-9]+/)

  return "" if words.empty?

  # Capitalize each word
  capitalized_words = words.map(&:capitalize)

  # Lowercase the very first word if lower camelCase is required
  capitalized_words[0] = capitalized_words[0].downcase unless first_letter_upper

  capitalized_words.join
end

def translateEvent oldEvent
  return case oldEvent
  when 'clicked'                   then 'click'
  when 'submitted'                 then 'submit'
  when 'highlighted', 'mousedover' then 'mouseover'
  when 'unhighlighted', 'mouseoff' then 'mouseout'
  when 'typed', 'typing'           then 'input'
  when 'changed'                   then 'change'
  else oldEvent
  end
end

def generateEventListener token
  event_type = token[:event_type]
  coffeescript_event = translateEvent event_type
  return <<~END
    #{token[:indent]}document.getElementById('#{token[:id]}').addEventListener '#{coffeescript_event}', ->
  END
end

# REWRITE THIS!!!!!!!!!!!!
def generateEnforcement token
    snippet = case token[:enforcement_type]
    when "string", "word"
        <<~END
        if document.getElementById('#{token[:id]}').value == '' or document.getElementById('#{token[:id]}').value == null
          alert "Input rejected: input is empty."
          return
        unless document.getElementById('#{token[:id]}').value == /^[a-zA-Z]+$/
          alert "input rejected: it must be a word."
          return
        END
    when "integer", "number"
        <<~END
        if document.getElementById('#{token[:id]}').value == '' or document.getElementById('#{token[:id]}').value == null
          alert "Input rejected: input is empty."
          return
        unless document.getElementById('#{token[:id]}').value == /^[0-9]+$/
          alert "Input rejected: it must be a number."
          return
        END
    end
  return snippet
end


def generateElementAssignment token
  return <<~END
    #{token[:indent]}#{token[:variable]} = document.getElementById #{token[:id]}
  END
end

def generateHideElement token
  return <<~END
    #{token[:indent]}#{token[:variable]}.style.display = 'none'
  END
end

def generateDisplayElement token
  return <<~END
    #{token[:indent]}#{token[:variable]}.style.display = 'block'
  END
end

def generateTypeMutation token
  return <<~END
    #{token[:indent]}#{token[:new_var]} = #{token[:new_type].capitalize}(#{token[:variable]})
  END
end

def generateAintCondition token
  return <<~END
    #{token[:indent]}if #{token[:condition_one]} isnt #{token[:condition_two]}
  END
end

def generatePerform token
  $inFunction = true
  $lastFunctionName = token[:label]
  return <<~END
    #{token[:indent]}#{token[:label]} = () ->
  END
end

def generateEnd token
  unless $inFunction
    puts "Unexpected end"
    exit
  end

  if $lastFunctionName.nil?
    puts "Something went wrong"
    exit
  end

  $inFunction = false

  snippet = <<~END
    #{token[:indent]}#{$lastFunctionName}()
  END

  $lastFunctionName = nil
  return snippet
end

def generateKahviConfirm token
  return <<~END
    #{token[:indent]}unless confirm(#{token[:message]})
      #{token[:indent]}  return
  END
end

# eventually add a way to add arguments to these functions
def generateAlternateFunction token
  return <<~END
    #{token[:indent]}#{token[:name]} = () ->
  END
end

# get saveButton
def generateGetElement token
  variable = token[:element]

  clean_variable = variable.gsub("'", "").gsub("-", "_") # remove quotes and replace hyphens with underscores

  element_id = variable.gsub(/([A-Z])/, '-\1').downcase
  return <<~END
    #{token[:indent]}#{clean_variable} = document.getElementById #{element_id}
  END
end

def generateRightNow token
  case token[:time]
  when 'hours'
    return <<~END
      now = new Date()
      #{token[:variable]} = now.getHours()
    END
  when 'minutes'
    return <<~END
      now = new Date()
      #{token[:variable]} = now.getMinutes()
    END
  when 'seconds'
    return <<~END
      now = new Date()
      #{token[:variable]} = now.getSeconds()
    END
  when 'full'
    return <<~END
      now = new Date()
      hours = now.getHours()
      minutes = now.getMinutes()
      seconds = now.getSeconds()
      #{token[:variable]} = "\#{hours}:\#{minutes}:\#{seconds}"
    END
  end
end

def generateGetRequest token
  function_name = camelize(token[:variable])
  return <<~END
    #{token[:variable]} = null
    
    #{function_name} = (url) ->
      try
        response = await fetch(url)

        unless response.ok
          throw new Error "Response status: \#{response.status}"
        
        #{token[:variable]} = await response.json()
        
      catch error
        console.error(error.message)
          
    #{function_name}(#{token[:url].lstrip})
  END
end

def generateOrisConditional token
  return <<~END
    #{token[:indent]}if #{token[:variable]} is #{token[:first_check]} or #{token[:variable]} is #{token[:second_check]}
  END
end

def generateBooleanFlip token
  variable = token[:variable]
  return <<~END
  #{token[:indent]}#{variable} = !#{variable}
  END
end

def generateWait token
  # convert seconds into milliseconds
  unit = if %w|second seconds|.include? token[:unit]
    token[:time] * 1000
  end

  return <<~END
    #{token[:indent]}await new Promise(wait => setTimeout(wait, #{unit}))
  END
end

def generateDoAfterCooldown token
  # convert seconds into milliseconds
  unit = if %w|second seconds|.include? token[:unit]
    token[:time] * 1000
  end

  return <<~END
    #{token[:indent]}setTimeout (->
      #{token[:indent]}  #{token[:action]}
    #{token[:indent]}), #{unit}
  END
end

def generateVariableEventListener token
  event = translateEvent token[:event_type]
  return <<~END
    #{token[:indent]}#{token[:variable]}.addEventListener "#{event}", ->
  END
end

def generateToggleDisplay token
  variable = token[:variable]
  indentation = token[:indent]

  # if the variable is an ID
  # REVISIT THIS
  if variable.include?("'") || variable.include?('"')
  else
    <<~END
      #{indentation}if #{variable}.style.display is 'block'
        #{indentation}  #{variable}.style.display = 'none'
      #{indentation}else
        #{indentation}  #{variable}.style.display = 'block'
    END
  end
end


def handleCoffeeScript value
  if value.end_with?(';')
    return <<~END
    #{indentation}`
    #{indentation}#{value}
    #{indentation}`
    END
  else
    return value
  end
end

$lastFunctionName = nil
$inFunction       = false

def generate token
    snippets = []

    snippet = case token[:type]
    when :event_listener     then generateEventListener token
    when :input_enforcement  then generateEnforcement token
    when :element_assignment then generateElementAssignment token
    when :hide               then generateHideElement token
    when :display            then generateDisplayElement token
    when :type_mutation      then generateTypeMutation token
    when :aint_condition     then generateAintCondition token
    when :perform            then generatePerform token
    when :end                then generateEnd token
    when :kahvi_confirm      then generateKahviConfirm token
    when :alternate_function then generateAlternateFunction token
    when :get_element        then generateGetElement token
    when :right_now          then generateRightNow token
    when :get_request        then generateGetRequest token
    when :oris_conditional   then generateOrisConditional token
    when :flip               then generateBooleanFlip token
    when :variable_event_listener then generateVariableEventListener token
    when :wait                    then generateWait token
    when :do_after_cooldown       then generateDoAfterCooldown token
    when :toggle_display          then generateToggleDisplay token
    when :coffeescript            then handleCoffeeScript token[:value]
    end

    snippets << snippet
end

def generateCoffeeScript file_to_read_from, file_to_write_to
  unless File.exist?(file_to_read_from)
    puts <<~END
    Failed to locate #{file_to_read_from} in this directory.
    Perhaps you forgot the file extension, or maybe you are in the wrong directory.
    END
    exit
  end

  lines    = File.readlines(file_to_read_from)
  tokens   = lines.map { |line| lex line.chomp }
  snippets = tokens.map { |token| generate token }

  if file_to_write_to.nil?
    puts "You must provide an output file."
    exit
  end

  File.open(file_to_write_to, 'w') do |file|
    file.puts "# Generated by French Press CoffeeScript"
    snippets.each do |snippet|
      file.puts snippet
    end
  end
end

# compile
def outputCoffeeScript file_in, file_out
  generateCoffeeScript file_in, file_out
  puts "Done brewing. Enjoy your CoffeeScript."
end

# full_send
def outputJavaScript file_in, file_out
  generateCoffeeScript file_in, file_out

  `coffee --compile #{file_out}`

  unless $?.success?
    puts "Something went wrong with the coffeescript compilation process."
    exit
  end
end

FPCS_METHODS = "fpcs_methods.js"

def copyMethods(into:)
  path = File.join(into, FPCS_METHODS)

  FileUtils.mkdir_p(into)
  methods = File.read "#{__dir__}/fpcs_methods.js"

  File.open(path, 'w') do |file|
    file.puts methods
  end
end

# generate
def outputPage name, directory, flag
  added_methods = false
  unless File.exist? FPCS_METHODS
    puts "Do you want the French Press methods copied into your directory? [Y/n]"
    print "~>  "
    input = STDIN.gets.chomp

    if input == "Y" then copyMethods into: directory end
    
    added_methods = true
  end

  directory ||= name

  if %w|this here|.include?(directory) then directory = "." end

  path = File.join(directory, name).freeze

  if File.exist? path
    puts "The file #{path} already exists. Would you like to overwrite it? [Y/n]"
    input = STDIN.gets.chomp
    
    return unless input.downcase == 'y'
  end

  Dir.mkdir directory unless Dir.exist? directory

  FileUtils.touch "#{path}.html"
  File.open("#{path}.html", 'w') do |file|
    file.puts <<~END
      <!DOCTYPE html>
      <html lang="en">
      <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">

          <link rel="stylesheet" href="#{name}.css">
          <title>#{name.capitalize}</title>
      </head>
      <body>

      <!--Hyvää koodausta, veli! - French Press CoffeeScript-->

      <h1>#{name.capitalize}</h1>


    END

    if added_methods
      file.puts <<~END
        <script src="#{FPCS_METHODS}"></script>
      END
    end

    file.puts <<~END
    <script src="#{name}.js"></script>
    </body>
    </html>
    END
  end

  FileUtils.touch("#{path}.frenchpress")
  File.open("#{path}.frenchpress", 'w') do |file|
    file.puts <<~END
      # Hei! Here are some of the features of FPCS you should know:
      #
      # use `hide x` to hide an element; x.style.display = 'none'
      # the opposite `display x` displays an element; x.style.display = 'block'
      #
      # use `get someElement` to fetch an html element. It compiles to: someElement = document.getElementById 'some-element'
      # use kahvi_confirm "message" to stop the execution of a function if the user doesn't confirm.
      #
      # Also remember the commands used to parse this file into JavaScript or CoffeeScript respectively:
      # fp full_send #{name}.frenchpress
      #
      # fp compile #{name}.frenchpress
      #
      # Happy programming! Hei Hei!
    END
  end

  FileUtils.touch("#{path}.styl")
  File.open("#{path}.styl", 'w') do |file|
    if flag == 'omakase-style'
      file.puts <<~END
        /*
        Stylus docs: https://stylus-lang.com/docs/
        Happy styling!
        */

        html
          background-color: #e3d8f3

        textarea, input
          font-family: Didot,Didot LT STD,Hoefler Text,Garamond,Times New Roman,serif
        
        h1, h2, h3, h4, h5, h6, p
          color: #535e97;

      END
    else
      file.puts <<~END
        /*
        Stylus docs: https://stylus-lang.com/docs/
        Happy styling!
        */
      END
    end
  end

  master_script_path = File.join(directory, "french_press_master.sh").freeze

  FileUtils.touch(master_script_path)
  File.open(master_script_path, 'a') do |file|
    file.puts <<~END
      # Hei! You can run this with 'fp go' or 'bash #{master_script_path}'

      fp full_send #{name}.frenchpress
      stylus #{name}.styl
    END
  end

  puts "Done. Your page #{name} can be seen in the #{directory} folder. I hope you enjoy."
end

# what-is-kahvi
def outputInformation
  information = <<~END
    Kahvi -- French Press CoffeeScript -- is a CoffeeScript preprocessor.

    I'm not going to explain the syntax here, but you can see it in the GitHub repo: https://github.com/Centurion774477/Kahvi
    If you generate a page using the generate command, you will get a couple examples included.


    The other features of French Press CoffeeScript are these commands:
    what-is-kahvi ~> you should know this one -- it's what got you here!

    generate <page> <directory> ~> scaffold a "page"; page.frenchpress, page.html, page.styl; the compilation commands are added to a masterscript

    typecheck/proofread <your_file> ~> check for any possible typos in your French Press CoffeeScript. Note that this may not be very accurate.

    full_send <your_file> <new_file> ~> compile a .frenchpress file into JavaScript

    compile <your_file> <new_file> ~> compile a .frenchpress file into CoffeeScript.

    
    I hope French Press CoffeeScript can make coding a bit more fun for you. Cheers!
  END
  
  puts information
end


def doubleCheck line
  if [
    line.include?("enforce"),
    line.include?("when"),
    line.include?("get"),
    line.include?("refers"),
    line.include?("kahvi_confirm")
  ].any? then return true else return false end
end

# proofread / typecheck
def outputProofReading file_in
  if file_in.nil?
    puts "Please provide a file to proofread."
    exit
  end

  begin
    lines = File.readlines file_in
  rescue
    puts "An error occured while trying to read from #{file_in}".
    exit
  end
  
  lines.each do |line|
    token = lex line.chomp
    
    if token[:type] == :coffeescript
      if doubleCheck(line) == true
        puts <<~END
        There appears to be a typo on line #{line}.
        This may be a mistake, but a Kahvi keyword was detected in this line.
        END
        exit
      end
    end
  end
  puts "Your file appears to be fine. This doesn't mean its perfect, but it's something."
  exit
end

master_script = "french_press_master.sh"
# go
def runMasterScript master_script
  unless File.exist? master_script
    puts "You need a master script in order to use the go command.\nYou could make one manually, or use 'generate' to scaffold one."
    exit
  end

  `bash #{master_script}`
end


def compileFrenchView file
  begin
    lines = File.readlines file
  rescue Errno::ENOENT
    puts "failed to read file: #{file}"
    exit
  end


  inside_script = false
  new_lines = []

  lines.each do |line|
    inside_script = true if line =~ /<frenchpress>/

    if line =~ /<\/frenchpress>/
      inside_script = false
    elsif inside_script
      line = lex
    else
      new_lines << line
    end
  end
end

command           = ARGV[0]
file_to_read_from = ARGV[1]
file_to_write_to  = ARGV[2]

if command.nil?
  puts "You must provide a command. Use what-is-kahvi to get help."
  exit
end

def checkFileToReadFrom(file_to_read_from, command)
  if file_to_read_from.nil?
    if command == "generate"
      puts "You must provide a name for the page.\n Structure the command like this: generate <page> <directory> (optionally:) omakase-style"
      exit
    elsif command == "what-is-kahvi"
      return
    else
      puts "You must provide an input file."
      exit
    end
  end
end

checkFileToReadFrom(file_to_read_from, command)

case command
when 'full_send'
  if file_to_write_to.nil?
    puts "No output file was provided."
    exit
  end

  unless File.extname(file_to_write_to) == '.js'
    puts "Your file extension must be .js -- you passed #{File.extname(file_to_write_to)}"
    exit
  end

  outputJavaScript file_to_read_from, file_to_write_to
when 'compile'
  if file_to_write_to.nil?
    puts "No output file was provided."
    exit
  end

  unless File.extname(file_to_write_to) == '.coffee'
    puts "Your file extension must be .coffee -- you passed #{File.extname(file_to_write_to)}"
    exit
  end

  outputCoffeeScript file_to_read_from, file_to_write_to
when 'generate'
  if file_to_write_to.nil? || file_to_write_to == "omakase-style"
    puts "You forgot to add a directory to create this page under."
    puts "Add a directory between #{file_to_read_from} and 'omakase-style'" if file_to_write_to == "omakase-style"
    exit
  end
  
  outputPage file_to_read_from, file_to_write_to, ARGV[3]
when 'what-is-kahvi'          then outputInformation
when 'typecheck', 'proofread' then outputProofReading(file_to_read_from)
when 'go' then runMasterScript(master_script)
else
  puts "Invalid command: #{command}. Type 'what-is-kahvi' for help"
  exit
end


