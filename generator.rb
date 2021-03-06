#!/usr/bin/env ruby

load 'symbolset.rb'

# This Ruby script generates random words using prabability-weighted symbols,
# and grammar rules from a given .lang file as input.
#
class LangInterpreter
  # Constructor
  def initialize(lang_file, words_count = 30)
    # Check file extension.
    raise "File \"#{lang_file}\" is not a .lang file" unless lang_file.match(/.*\.lang/)

    # Check if files exist
    raise "File \"#{lang_file}\" was not found." unless File.exist?(lang_file)
    @lang_file = lang_file

    # Default output file name
    @output_file = "output-#{lang_file.split(".")[0]}.txt"

    # Quantity of words to be generated.
    @words_count = words_count.to_i

    # Bindings for SymbolSets and a variable 
    # to save the grammatical expression string.
    @bindings = {}
    @full_expression = ""

    # Parse .lang file
    parse_lang_file

    # Parse grammatical expression
    eval_expression

    # Generate output .txt file of list of words
    generate_output_file
  end

  # This method reads a .lang file to parse it.
  # It parses the symbols and then copies the full
  # grammatical expression to evaluate it later.
  def parse_lang_file
    # Open .lang file and parse it, then copy 
    # its the full grammatical expression.
    File.open(@lang_file, "r:UTF-8") do |file|
      lines_count = 1
      on_expression = false

      # Evaluating lines
      while (line = file.gets)
        # Parsing .lang file
        case line
        when /(^\s*$)|(^\s*#.*$)/
          # Ignore blank lines or comments
        when /^\s*symbols\s*for\s*(\w*)?\s*(\w*)\s*:\s*(#.*)?$/
          # Create new symbol set
          captured = line.scan(/\s*(\w*)\s*:/)
          #p captured[0][0]
          current_binding = captured[0][0]
          @bindings[current_binding] = SymbolSet.new

        when /^\s*expression\s*:\s*(#.*)?$/
          # Start of grammatical expression
          #puts "Evaluating expression:"
          on_expression = true

        when /^\s*(\w*)\s*[:=]\s*(\d*)\s*(#.*)?$/
          # Add a symbol to the last binding
          @bindings[current_binding].add_pair($1, $2.to_i)

        else
          if on_expression
            # Copying expression
            @full_expression += line.strip
          else
            puts "Runtime error when evaluating " +
                 "\"#{@lang_file}\" at line #{lines_count}."
            break
          end
        end

        #Counting lines
        lines_count += 1
      end
    end
  end

  # This method evaluates the grammatical expression to construct
  # a grammatical tree and generate random words.
  def eval_expression
    load 'expr_interpreter.rb'

    @evaluated_expression = run_expression(@full_expression, @bindings)
  end

  # This method generates the output file.
  def generate_output_file
    File.open(@output_file, 'w') do |file|  
      # use "\n" for two lines of text  

      @words_count.times do 
        file.puts  @evaluated_expression.sample + "\n"
      end
    end 

    puts "File '#{@output_file}' has been generated." 
  end
end


#Parse .lang file (filename, count)
instance = LangInterpreter.new(ARGV[1], ARGV[0])
