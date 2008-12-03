require "rexml/document"
include REXML

def label()
	dirs = ["actors", "data", "models", "rules", "uc"]
	
	dirs.each do |dir_name|
		puts "Modifying \"#{dir_name}\" directory..."
		label_dir dir_name
	end
	
	puts "Done."
	
	gets
end

def label_dir(dir_name)
	Dir["#{dir_name}/*"].each do |fn|
		next unless fn =~ /\.xml$/
		doc = Document.new File.new("#{fn}")		
		title = doc.root.elements["title"].text		
		doc.root.attributes['xreflabel'] = title
		
		File.open(fn, File::TRUNC|File::WRONLY) do |file|
			file.write doc.to_s
		end
	end
end

label