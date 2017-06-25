#!/usr/bin/ruby

require 'psych'

OUT_INDENT_SIZE = 4

# Methods
# ------------------------------------------------------------------------------
def indent(level)
  (OUT_INDENT_SIZE*level).times {putc ' '}
end

def simple?(hash)
  if hash.any? {|key, val| (val.class == Array || val.class == Hash)}
    #puts "hash is complex"
    return false
  else
    #puts "hash is simple"
    return true
  end
end

def has_complex_children?(hash)
  if simple?(hash)
    return false
  end

  hash.each_value{|sequence|
    if sequence.class != Array
      puts "error! We expect only arrays."
      return true
    end

    if sequence.any?{|hash| !simple?(hash)}
      #puts "hash has complex children"
      return true
    else
      #puts "hash can be a one-liner"
      return false
    end
  }
end

def has_simple_children?(hash)
  if simple?(hash)
    return false
  end

  hash.each_value{|sequence|
    if sequence.class != Array
      puts "error! We expect only arrays."
      return true
    end

    if sequence.any?{|hash| simple?(hash)}
      #puts "hash has simple children"
      return true
    else
      #puts "hash has no simple children"
      return false
    end
  }
end

class Array
  def extract_simple_pairs!
    ret = Hash.new
    simple_classes = [String, Integer, Float]
    indexes_to_delete = Array.new

    self.each_index{|i|
      element = self[i]
      #puts "processing: " + element.to_s
      if element.class == Hash && element.length == 1
        key = element.to_a[0][0]
        val = element.to_a[0][1]
        #printf "%s : %s\n", key, val
        if simple_classes.include?(val.class)
          ret[key.to_s] = val.to_s
          #puts ret.to_s
          indexes_to_delete.push(i)
          #puts "idx to rm: " + i.to_s
        end
      end
    }

    indexes_to_delete.reverse.each{|i|
      #puts "deleting at " + i.to_s
      self.delete_at(i)
      #puts "arr after rm: " + self.to_s
    }
    #puts "arr after extraction: " + self.to_s

    return ret
  end
end

def extract_simple_pairs!(node)
  ret = Hash.new
  simple_classes = [String, Integer, Float]

  if node.class == Array
    node.each{|element|
      #puts "processing: " + element.to_s
      if element.class == Hash && element.length == 1
        element = element.to_a[0]
        key = element[0]
        val = element[1]
        if simple_classes.include?(val.class)
          ret[key] = val
          node.delete(key)
        end
      end
    }
  end

  node.each{|key, value|
    if simple_classes.include?(value.class)
      ret[key] = value
      node.delete(key)
    end
  }
  return ret
end

def is_simple_hash(node)
  if node.class == Hash
  end
end

def print_attributes(arr)
  arr.each {|hash|
    hash.each {|key, val| printf("%s=\"%s\" ", key, val)}
  }
end

def traverse(node, level)
  # puts "traversing node: " + node.class.to_s + "\n"
  traverse_array(node, level) if node.class == Array
  traverse_hash(node, level)  if node.class == Hash
end

def traverse_array(node, level)
  node.each {|element| traverse(element, level) }
end

def traverse_hash(node, level)
  node.each{|key,child|
    #printf "# found hash `%s` whose child is an %s\n", key, child.class.to_s
    #printf "child length before extracting simple pairs: %d\n", child.length
    tag_attributes = Hash.new()
    if child.class == Array
      tag_attributes = child.extract_simple_pairs!
    else
      tag_attributes = extract_simple_pairs!(child)
    end
    indent(level)
    printf "<%s %s>\n", key, tag_attributes.to_s
    #printf "child length after extracting simple pairs: %d\n", child.length
    traverse(child, level+1)
    indent(level)
    printf "</%s>\n", key
  }
end

# Application
# ------------------------------------------------------------------------------
model1 = { "scene" => [
  {"creature"=>[{"name"=>"Bat"}, {"hp"=>"20"}]},
  {"creature"=>[{"name"=>"Fox"}, {"hp"=>"30"}]},
  {"creature"=>[{"name"=>"Eel"}, {"hp"=>"40"}]},
]}
model2 = { "name"=>"bat", "hp"=>20, "effects"=>["haste", "curse", "hunger"] }
model3 = [ { "name"=>"bat" }, {"hp"=>20}, {"effects"=>["haste", "curse", "hunger"]} ]
model4= Psych.load_file("model1.yml")

model = model4
model.display
puts "\n"

level = 0
traverse(model, level)

