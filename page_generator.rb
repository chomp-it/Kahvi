# frozen_string_literal: true

require 'fileutils'

# this class handles the scaffolding of pages,
# done through the generate command.
FPCS_METHODS = 'fpcs_methods.js'

class PageGenerator
  def copy_methods(into:)
    path = File.join(into, FPCS_METHODS)

    FileUtils.mkdir_p(into)
    methods = File.read "#{__dir__}/fpcs_methods.js"

    File.open(path, 'w') do |file|
      file.puts methods
    end
  end

  # generate
  def output_page name, directory, flag
    added_methods = false
    unless File.exist? FPCS_METHODS
      puts 'Do you want the French Press methods copied into your directory? [Y/n]'
      print '~>  '
      input = STDIN.gets.chomp

      copy_methods into: directory if input == 'Y'

      added_methods = true
    end

    directory ||= name

    directory = '.' if %w[this here].include?(directory)

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

    FileUtils.touch "#{path}.frenchpress"
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

    FileUtils.touch "#{path}.styl"
    File.open("#{path}.styl", 'w') do |file|
      if flag == 'omakase-style'
        file.puts <<~END
          /*
          Stylus docs: https://stylus-lang.com/docs/
          Happy styling!
          */

          html
            background-color #e3d8f3

          textarea, input
            font-family: Didot,Didot LT STD,Hoefler Text,Garamond,Times New Roman,serif

          h1, h2, h3, h4, h5, h6, p
            color #535e97

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

    master_script_path = File.join(directory, 'french_press_master.sh').freeze

    FileUtils.touch master_script_path
    File.open(master_script_path, 'a') do |file|
      file.puts <<~END
        # Hei! You can run this with 'fp go' or 'bash #{master_script_path}'

        fp full_send #{name}.frenchpress
        stylus #{name}.styl
      END
    end

    puts "Done. Your page #{name} can be seen in the #{directory} folder. I hope you enjoy."
  end
end
