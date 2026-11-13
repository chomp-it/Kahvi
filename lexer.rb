# frozen_string_literal: true

class Lexer
  def self.lex line
    case line
    when /(?<indent>\s*)flip\s+(?<variable>.*)$/
      {
        type: :flip,
        variable: $~[:variable],
        indent: $~[:indent]
      }
    when /(?<indent>\s*)toggle_display_of (?<variable>.*)$/
      {
        type: :toggle_display,
        variable: $~[:variable],
        indent: $~[:indent]
      }
    when /(?<indent>\s*)(?<variable>.*)\s+=\s+get(?<url>.*)$/
      {
        type: :get_request,
        variable: $~[:variable],
        url: $~[:url],
        indent: $~[:indent]
      }
    when /(?<indent>\s*)wait\s+for\s+(?<time>\d+)\s+(?<unit>\w+)/
      {
        type: :wait,
        time: $~[:time],
        unit: $~[:unit],
        indent: $~[:indent]
      }
    when /(?<indent>\s*)after\s+(?<time>\d+)\s+(?<unit>\w+)\s+(?<action>.*)/
      {
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

      {
        type: :input_enforcement,
        id: $~[:id],
        enforcement_type: $~[:type],
        indent: $~[:indent]
      }
    when /(?<indent>\s*)if\s+(?<variable>.*)\s+is\s+(?<first_check>.*)\s+oris\s+(?<second_check>.*)$/
      {
        type: :oris_conditional,
        variable: $~[:variable],
        first_check: $~[:first_check],
        second_check: $~[:second_check],
        indent: $~[:indent]
      }
    when /(?<indent>\s*)(?<variable>.*)\s+refers\s+to\s+(?<id>.*)$/
      {
        type: :element_assignment,
        variable: $~[:variable],
        id: $~[:id],
        indent: $~[:indent]
      }
    when /(?<indent>\s*)hide\s+(?<variable>.*)$/
      {
        type: :hide,
        variable: $~[:variable],
        indent: $~[:indent]
      }
    when /(?<indent>\s*)display\s+(?<variable>.*)$/
      {
        type: :display,
        variable: $~[:variable],
        indent: $~[:indent]
      }
    when /(?<indent>\s*)(?<new_var>.*)\s+=\s+(?<variable>.*)\s+as\s+(a|an)\s+(?<type>.*)$/
      {
        type: :type_mutation,
        variable: $~[:variable],
        new_type: $~[:type],
        new_var: $~[:new_var],
        indent: $~[:indent]
      }
    when /(?<indent>\s*)if\s+(?<part_1>.+?)\s+aint\s+(?<part_2>.+)$/
      {
        type: :aint_condition,
        condition_one: $~[:part_1],
        condition_two: $~[:part_2],
        indent: $~[:indent]
      }
    when /(?<indent>\s*)perform\s+(?<label>\w+)$/
      {
        type: :perform,
        label: $~[:label],
        indent: $~[:indent]
      }
    when /(?<indent>\s*)end$/
      {
        type: :end,
        indent: $~[:indent]
      }
    when /(?<indent>\s*)kahvi_confirm\s+(?<message>.*)$/
      {
        type: :kahvi_confirm,
        message: $~[:message],
        indent: $~[:indent]
      }
    when /(?<indent>\s*)(?<function_name>.*)\s+does$/
      {
        type: :alternate_function,
        name: $~[:function_name],
        indent: $~[:indent]
      }
    when /(?<indent>\s*)get\s+(?<element>.*)/
      {
        type: :get_element,
        element: $~[:element],
        indent: $~[:indent]
      }
    when /(?<indent>\s*)(?<variable>.*)\s+=\s+right\s+now\s+in\s+(?<type>(hours|minutes|seconds|full))/
      {
        type: :right_now,
        time: $~[:type],
        variable: $~[:variable],
        indent: $~[:indent]
      }
    else
      {
        type: :coffeescript,
        value: line
      }
    end
  end
end
