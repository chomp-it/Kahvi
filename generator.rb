# frozen_string_literal: true

# code generation
class Generator
  def generate_event_listener token
    event_type = token[:event_type]
    coffeescript_event = translate_event event_type
    <<~END
      #{token[:indent]}document.getElementById('#{token[:id]}').addEventListener '#{coffeescript_event}', ->
    END
  end

  # TODO: REWRITE THIS!!!!!!!!!!!!
  def generate_enforcement token
    case token[:enforcement_type]
    when 'string', 'word'
      <<~END
        if document.getElementById('#{token[:id]}').value == '' or document.getElementById('#{token[:id]}').value == null
          alert "Input rejected: input is empty."
          return
        unless document.getElementById('#{token[:id]}').value == /^[a-zA-Z]+$/
          alert "input rejected: it must be a word."
          return
      END
    when 'integer', 'number'
      <<~END
        if document.getElementById('#{token[:id]}').value == '' or document.getElementById('#{token[:id]}').value == null
          alert "Input rejected: input is empty."
          return
        unless document.getElementById('#{token[:id]}').value == /^[0-9]+$/
          alert "Input rejected: it must be a number."
          return
      END
    end
  end

  def generate_element_assignment token
    <<~END
      #{token[:indent]}#{token[:variable]} = document.getElementById #{token[:id]}
    END
  end

  def generate_hide_element token
    <<~END
      #{token[:indent]}#{token[:variable]}.style.display = 'none'
    END
  end

  def generate_display_element token
    <<~END
      #{token[:indent]}#{token[:variable]}.style.display = 'block'
    END
  end

  def generate_type_mutation token
    <<~END
      #{token[:indent]}#{token[:new_var]} = #{token[:new_type].capitalize}(#{token[:variable]})
    END
  end

  def generate_aint_condition token
    <<~END
      #{token[:indent]}if #{token[:condition_one]} isnt #{token[:condition_two]}
    END
  end

  def generate_perform token
    $inFunction = true
    $lastFunctionName = token[:label]
    <<~END
      #{token[:indent]}#{token[:label]} = () ->
    END
  end

  def generate_end token
    unless $inFunction
      puts 'Unexpected end'; exit
    end

    if $lastFunctionName.nil?
      puts 'Something went wrong'; exit
    end

    $inFunction = false

    snippet = <<~END
      #{token[:indent]}#{$lastFunctionName}()
    END

    $lastFunctionName = nil
    snippet
  end

  def generate_kahvi_confirm token
    <<~END
      #{token[:indent]}unless confirm(#{token[:message]})
        #{token[:indent]}  return
    END
  end

  # TODO: eventually add a way to add arguments to these functions
  def generate_alternate_function token
    <<~END
      #{token[:indent]}#{token[:name]} = () ->
    END
  end

  # get saveButton
  def generate_get_element token
    variable = token[:element]

    clean_variable = variable.gsub("'", '').gsub('-', '_') # remove quotes and replace hyphens with underscores

    element_id = variable.gsub(/([A-Z])/, '-\1').downcase
    <<~END
      #{token[:indent]}#{clean_variable} = document.getElementById #{element_id}
    END
  end

  def generate_right_now token
    case token[:time]
    when 'hours'
      <<~END
        now = new Date()
        #{token[:variable]} = now.getHours()
      END
    when 'minutes'
      <<~END
        now = new Date()
        #{token[:variable]} = now.getMinutes()
      END
    when 'seconds'
      <<~END
        now = new Date()
        #{token[:variable]} = now.getSeconds()
      END
    when 'full'
      <<~END
        now = new Date()
        hours = now.getHours()
        minutes = now.getMinutes()
        seconds = now.getSeconds()
        #{token[:variable]} = "\#{hours}:\#{minutes}:\#{seconds}"
      END
    end
  end

  def generate_get_request token
    function_name = camelize(token[:variable])
    <<~END
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

  def generate_oris_conditional token
    <<~END
      #{token[:indent]}if #{token[:variable]} is #{token[:first_check]} or #{token[:variable]} is #{token[:second_check]}
    END
  end

  def generate_boolean_flip token
    variable = token[:variable]
    <<~END
      #{token[:indent]}#{variable} = !#{variable}
    END
  end

  def generate_wait token
    # convert seconds into milliseconds
    unit = if %w[ second seconds ].include? token[:unit]
             token[:time] * 1000
           end

    <<~END
      #{token[:indent]}await new Promise(wait => setTimeout(wait, #{unit}))
    END
  end

  def generate_do_after_cooldown token
    # convert seconds into milliseconds
    unit = if %w[second seconds].include? token[:unit]
             token[:time] * 1000
           end

    <<~END
      #{token[:indent]}setTimeout (->
        #{token[:indent]}  #{token[:action]}
      #{token[:indent]}), #{unit}
    END
  end

  def generate_variable_event_listener token
    event = translate_event token[:event_type]
    <<~END
      #{token[:indent]}#{token[:variable]}.addEventListener "#{event}", ->
    END
  end

  def generate_toggle_display token
    variable = token[:variable]
    indentation = token[:indent]

    # if the variable is an ID
    # REVISIT THIS
    if variable.include?("'") || variable.include?('"')
      # TODO: this
    else
      <<~END
        #{indentation}if #{variable}.style.display is 'block'
          #{indentation}  #{variable}.style.display = 'none'
        #{indentation}else
          #{indentation}  #{variable}.style.display = 'block'
      END
    end
  end

  def handle_coffeescript value
    if value.end_with? ';'
      <<~END
        #{indentation}`
        #{indentation}#{value}
        #{indentation}`
      END
    else
      value
    end
  end
end
