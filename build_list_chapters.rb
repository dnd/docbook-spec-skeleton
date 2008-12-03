require "rexml/document"
include REXML

["actors", "data", "models", "rules"].each do |chap|
	puts "Building #{chap}"
	chp_fn = "#{chap}/#{chap}.xml"
	doc = Document.new File.new(chp_fn), {:compress_whitespace => :all}
	doc.root.elements.each do |e|
		next unless e.name == "include"
		#puts "deleting #{e.to_s}"
		doc.root.delete_element e
	end
	
	files = {}
	Dir.glob("#{chap}/*.xml").each do |fn|
		fn.gsub!("#{chap}/", "")
		next if fn =~ Regexp.new("^#{chap}\.xml|^_") 
		item = Document.new File.new("#{chap}/#{fn}")
		files[item.root.attributes['xreflabel']] = fn
	end
	
	sorted = files.sort {|a, b| a[0].casecmp(b[0])}
	sorted.each do |fn| 
		puts fn[1]
		doc.root.add_element Element.new("xi:include"), {"href" => fn[1], "xmlns:xi" => "http://www.w3.org/2001/XInclude"}
	end
	xml = ""
	doc.write xml, 0
	xml.gsub!(/(\n\s){2,}|\n{2}/, "")
	
	File.open(chp_fn, File::TRUNC|File::WRONLY) do |file|
		file.write xml
	end
	puts ""
end

gets

