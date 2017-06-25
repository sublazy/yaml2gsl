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

  def to_xml_tree(level = 0)
    self.each {|element| element.to_xml_tree(level) }
  end

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


class Hash

  def to_xml_tree(level = 0)

    self.each{|key, child|
      tag_attributes = child.extract_simple_pairs!
      indent(level); printf "<%s%s>\n", key, xml_attr_str(tag_attributes)
      child.to_xml_tree(level+1)
      indent(level); printf "</%s>\n", key
    }
  end

  def extract_simple_pairs!(node)
    ret = Hash.new
    simple_classes = [String, Integer, Float]

    node.each{|key, val|
      if simple_classes.include?(val.class)
        ret[key] = val
        node.delete(key)
      end
    }
    return ret
  end
end

class String
  def to_xml_tree(level = 0)
      indent(level); printf "<%s/>\n", self
  end
end

def xml_attr_str(hash)
  all = " "
  hash.each {|key, val|
    s = "#{key} = \"#{val}\" "
    all = all + s
  }

  return all.chomp(" ")
end

# Application
# ------------------------------------------------------------------------------
model1= Psych.load_file("model1.yml")
model2= Psych.load_file("model2.yml")
model3= Psych.load_file("model3.yml")

puts "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>"

model3.to_xml_tree
puts "\n\n"
model2.to_xml_tree
puts "\n\n"
model1.to_xml_tree
