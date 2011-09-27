# search for all references to partials and make a reference tree

class PartialReference
  attr_accessor :filename
  attr_accessor :whole_line
  attr_accessor :raw_partial
  
  def partial
    if(!(raw_partial =~ /^["'].*["'][,]?$/))
      return "# " + raw_partial
    end
    
    partial_string = raw_partial.scan(/^["'](.*)["'][,]?$/)[0][0]
    
    if(partial_string =~ /\//)
      return partial_string
    end
    
    path = nil
    if(filename =~ /^app\/controllers\/.*_controller.rb/)
      path = filename.scan(/app\/controllers\/(.*)_controller.rb/)[0][0]
    end
    if(filename =~ /^app\/helpers/)
      # I think this is right but perhaps the helper will take the current controller inorder to figure out 
      # the path
      path = ''
    end
    if(filename =~ /^app\/views/)
      path = filename.scan(/app\/views\/(.*)\/[^\/]*/)[0][0]
    end
    path + '/' + partial_string
  end
  
  def refering_partial
    return nil if !(filename =~ /^app\/views.*\/_[^\/]*/)
    
    file = filename.sub(/^app\/views/, '')
    file = file.sub(/\/_/, '/')
    file = file.sub(/\..*$/, '')
    file.sub(/^\//, '')
  end
end

referers = {}

# start with the app folder
Dir.glob("app/**/*") do |filename|
  next unless File.file?(filename)
  File.open(filename) do |file|
    text = file.read
    text.scan(/render :partial.*/) do |line|
      match = line.scan(/render :partial\s*=>\s*([^\s%]*).*/)
      reference = PartialReference.new
      reference.filename = filename
      reference.whole_line = line
      reference.raw_partial = match[0][0]
      referers[filename] ||= []
      referers[filename] << reference
    end
  end
end

referer_files = referers.keys.sort

@partials = partials = {}

referers.each do |key, references|
  references.each do |ref|
    partial = ref.partial
    partials[partial] ||= []
    partials[partial] << ref
  end
end

partial_files = partials.keys.sort

def list_partial_references(references)
  references.map do |ref|
    result = "<li><a href='#'>#{ref.filename} -- #{ref.whole_line} -- #{ref.refering_partial}</a>\n"
    if (refering_partial = ref.refering_partial) && (references2 = @partials[refering_partial])
      result += "<ul>\n"
      result += list_partial_references(references2) 
      result += "\n</ul>\n"
    end
    result += "</li>\n"
  end.join('')
end

require 'erb'

text = File.read(File.dirname(__FILE__) + "/templates/partial-ref-tree.html.erb")

template = ERB.new text
html = template.result
File.open("partial-refs.html", 'w') do |f|
  f.write html
end