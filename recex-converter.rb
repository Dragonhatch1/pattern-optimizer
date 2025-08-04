require 'json'

class RecexConverter
  attr_reader :input, :output

  def initialize(input, output)
    @input = input
    @output = output
  end

  def write
    hash = Hash.new
    hash["machines"] = machines
    hash["smelting"] = smelting

    File.write(output, hash.to_json)
  end

  def machines
    parsed["sources"].each do |source|
      if source.key?("machines")
        return fix_dur(source["machines"])
      end
    end

    raise StandardError, "Key `machines` not found"
  end

  def fix_dur(machines)
    [].tap do |array|
      machines.each do |machine|
        hash = Hash.new
        hash["n"] = machine["n"]
        hash["recs"] = machine["recs"].map do |recipe|
          new_recipe = recipe.clone
          new_recipe["dur"] = recipe["dur"] * -1 if recipe["dur"] < 0
          new_recipe
        end

        array << hash
      end
    end
  end

  def smelting
    parsed["sources"].each do |source|
      if source["type"] == "smelting"
        return source["recipes"]
      end
    end

    raise StandardError, "smelting type not found"
  end
  
  private def parsed
    @parsed ||= JSON.parse(File.read(input))
  end
end

if ARGV.length != 2
  abort "Usage: #{$0} in.json out.json"
end

converter = RecexConverter.new(ARGV[0], ARGV[1])
converter.write



