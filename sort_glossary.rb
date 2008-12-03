require "rexml/document"
include REXML

def sort(gloss)
	puts "Loading glossary."
	terms = get_terms(gloss)
	puts "Sorting..."
	terms = terms.sort {|a, b| a[0].casecmp(b[0])}
	puts "Sorted"
	terms
end

def get_terms(gloss)
	terms = Hash.new
	gloss.root.elements.each("//glossentry") do |entry|
		term = entry.elements["glossterm"].text
		terms[term] = entry
	end
	terms
end

def build_glossary(gloss_path, gloss, terms)
	puts "Writing glossary..."
	#remove existing glossentries
	glossdiv = gloss.root.elements["glossdiv"]
	glossdiv.elements.each do |e|
		next unless e.name == "glossentry"
		glossdiv.delete_element e
	end 
	
	terms.each do |term, entry|
		gloss.root.elements["glossdiv"].add_element entry
	end
	xml = ""
	gloss.write xml, 0
	xml.gsub!(/(\n\s){2,}|\n{2}/, "")
	#puts xml
	File.open(gloss_path, File::TRUNC|File::WRONLY) do |file|
		file.write xml
	end
	puts "Written"
end

path = "glossary.xml"
glossary = Document.new File.new(path)
sorted_terms = sort glossary
build_glossary(path, glossary, sorted_terms)