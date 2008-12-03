require "rexml/document"
include REXML

def linkify
	Dir.glob("models/*.xml").each do |fn|
		next if fn.gsub("models/", "") =~ Regexp.new("^models\.xml|^_") 
		
		doc = Document.new File.new(fn)
		doc_label = doc.root.attributes['xreflabel']
		doc_id = doc.root.attributes['id']
		
		puts fn
		
		table = doc.root.elements["table"]
		#Rename table
		table.elements["title"].text = "#{doc_label} Definition"
		
		#label fields
		table.elements['tgroup/tbody'].elements.each do |e|
			#first entry is the field name
			entry = e.get_elements('entry')[0]
			field_name = entry.text.strip
			entry.attributes['id'] = "#{doc_id}.#{field_name.downcase.gsub(' ', '_')}"
			entry.attributes['xreflabel'] = "&quot;#{doc_label}.#{field_name}&quot;"
		end
		
		File.open(fn, File::TRUNC| File::WRONLY) do |file|
			file.write doc.to_s
		end	
	end
end

linkify