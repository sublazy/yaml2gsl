#!/usr/bin/ruby

require 'psych'

OUT_INDENT_SIZE = 4

# Methods
# ------------------------------------------------------------------------------
def indent(level)
  (OUT_INDENT_SIZE*level).times {putc ' '}
end

# TODO Not used anymore. Remove.
def has_simple_children?(hash)
  if hash.simple?
    return false
  end

  hash.each_value{|sequence|
    if sequence.class != Array
      puts "error! We expect only arrays."
      return true
    end

    if sequence.any?{|hash| hash.simple?}
      #puts "hash has simple children"
      return true
    else
      #puts "hash has no simple children"
      return false
    end
  }
end

class Array

  def simple?
      if self.any?{|element| !element.simple?}
        return false
      else
        return true
      end
  end

  def to_xml_tree(level = 0)
    # puts "to_xml_tree: array: " + self.to_s
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

  def simple?
    if self.any? {|key, val| (val.class == Array || val.class == Hash)}
      return false
    else
      return true
    end
  end

  def to_xml_tree(level = 0)
    # puts "to_xml_tree: hash: " + self.to_s

    self.each{|key, child|
      tag_attributes = child.extract_simple_pairs!
      formatted_attr = xml_attr_str(tag_attributes)

      if self.has_complex_children?
        indent(level); printf "<%s%s>\n", key, formatted_attr
        child.to_xml_tree(level+1)
        indent(level); printf "</%s>\n", key
      else
        indent(level); printf "<%s%s />\n", key, formatted_attr
      end
    }
  end

  def extract_simple_pairs!
    ret = Hash.new
    simple_classes = [String, Integer, Float]

    self.each{|key, val|
      if simple_classes.include?(val.class)
        ret[key] = val
        self.delete(key)
      end
    }
    return ret
  end

  def has_complex_children?
    return false if self.simple?
    return self.any?{|key, value| !value.simple?}
  end
end

class String
  def to_xml_tree(level = 0)
      indent(level); printf "<%s/>\n", self
  end

  def simple?
    return true
  end

  def has_complex_children?()
    return false
  end

  def extract_simple_pairs!
    # puts "extracting simple pairs in string"
    ret = Hash.new
    return ret
  end
end

class Integer
  def simple?
    return true
  end

  def has_complex_children?()
    return false
  end

  def extract_simple_pairs!
    # puts "extracting simple pairs in integer"
    ret = Hash.new
    return ret
  end
end

def xml_attr_str(hash)
  all = ""
  hash.each {|key, val|
    s = " #{key} = \"#{val}\""
    all = all + s
  }

  return all
end

# Application
# ------------------------------------------------------------------------------
model1= Psych.load_file("model1.yml")
model2= Psych.load_file("model2.yml")
model3= Psych.load_file("model3.yml")
model4= Psych.load_file("model4.yml")

puts "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>"

model4.to_xml_tree
puts "\n\n"
model3.to_xml_tree
puts "\n\n"
model2.to_xml_tree
puts "\n\n"
model1.to_xml_tree
