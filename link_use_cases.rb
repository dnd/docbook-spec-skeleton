require "rexml/document"
include REXML


def linkify()
	actor_uc = Hash.new
	rule_uc = Hash.new
	
	puts "Finding use cases"
	Dir["uc/*"].each do |fn| 
		next if fn =~ /use_cases\.xml$|\.xml~$|\.rb$/
		uc_name = fn.gsub!(/^uc\/|\.xml$/, "")
		doc = Document.new File.new("uc/#{uc_name}.xml")
		uc_id = doc.root.attributes['id']
		if not uc_id.nil?
			uc_id.gsub!(/^uc\./, "")
			find_actors uc_id, doc, actor_uc
			find_rules uc_id, doc, rule_uc
		end
	end

	puts "Linking actors"
	link_entity("actors", actor_uc)
	
	puts "Linking Rules"
	link_entity("rules", rule_uc)
end


def find_actors(uc_id, doc, actor_uc)
	actor_list = doc.root.elements["//*[@id='uc.#{uc_id}.actors']"]
	if actor_list.nil?
		puts "No actors for #{uc_id}"
		return
	end

	actor_list.elements.each("*/xref") do |link|
		actor_id = link.attributes['linkend'].gsub(/actors\./, "")
		actor_uc[actor_id] = Array.new if actor_uc[actor_id].nil?
		actor_uc[actor_id] << uc_id
	end
end

def find_rules(uc_id, doc, rule_uc)
	doc.root.elements.each("//xref") do |ref|
		next unless ref.attributes["linkend"] =~ /^rules\./
		rule_id = ref.attributes["linkend"].gsub(/rules\./, "")
		rule_uc[rule_id] = Array.new if rule_uc[rule_id].nil?
		rule_uc[rule_id] << uc_id if rule_uc[rule_id].index(uc_id).nil?
	end
end

def link_entity(entity_type, uc_hash)
	uc_hash.each do |entity, use_cases|
		entity_file = "#{entity_type}/#{entity}.xml"
		entity_doc = Document.new File.new(entity_file)
		uclist_id = "#{entity_type}.#{entity}.uc"
		uc_list = get_uc_list entity_doc, uclist_id

		puts "Adding use case links for #{uclist_id}"
		uc_list.elements.delete_all "listitem"
		use_cases.each do |use_case|
			uc_list.add_element("listitem").add_element("para").add_element("xref").attributes["linkend"] = "uc.#{use_case}"
		end

		File.open(entity_file, File::TRUNC|File::WRONLY) do |file|
			file.write entity_doc.to_s
		end
	end
end

def get_uc_list(doc, uclist_id)
	uc_list = doc.root.elements["//*[@id='#{uclist_id}']"]
		
	if uc_list.nil?
		#Check if there is an element titled Use Cases to use
		uc_list = doc.root.elements["./itemizedlist[title='Use Cases']"]
		
		if uc_list.nil?
			puts "Creating use case list #{uclist_id}..."
			uc_list = Element.new("itemizedlist")
			uc_list.add_element("title").text = "Use Cases"
			doc.root.add_element uc_list
		end
		
		uc_list.attributes['id'] = uclist_id
	end
	
	uc_list
end

linkify