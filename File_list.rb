module File_list
	def get_filter_list(url)
		filter_list = []
		dir_filter = Dir::new("#{url}")
		list = dir_filter.entries
		#log list
		list.each do |l|
			if true == File::directory?("#{url}/#{l}")
				#log l
				if false == l.include?(".")
					filter_list << l
				end
				#puts "#{file_name}"
				#part = part + 1
			end
		end
		
		if(filter_list[0].eql?(nil))
			log "source filter had no filter, So source filter list is source",1
			return ["source"]
		else
			log "source filter list is #{filter_list}",1
			return filter_list
		end
		
	end
	def get_file_list(url)
		file_list = []
		dir_filter = Dir::new("#{url}")
		list = dir_filter.entries
		#log list
		list.each do |l|
			if false == File::directory?(l)
				file_list << l
				#puts "#{file_name}"
				#part = part + 1
			end
		end
		log "#{file_list} is in #{url}",1
		return file_list
	end
	def get_file_url(url)
		file_list = []
		dir_filter = Dir::new("#{url}")
		list = dir_filter.entries
		#log list
		list.each do |l|
			if false == File::directory?(l)
				file_list << "#{url}/#{l}"
				#puts "#{file_name}"
				#part = part + 1
			end
		end
		log "#{file_list} is in #{url}",1
		return file_list
	end
	def get_all_file_url(url)
		source_file_list = []
		source_file_url = []
		path_source = ""
		source_list = self.get_filter_list("#{url}")
		last_key = url.split('/')
		index_file_list = 0
		index_folder_list = 0
		source_list.each do |source_filter|
			if(source_filter.eql?("#{last_key[-1]}"))
				path_source = url
				source_file_list = self.get_file_url(path_source)
			else
			##############################获取子文件夹中的文件列表
				path_source = "#{url}/#{source_filter}"
				
				self.get_file_url(path_source).each do | url_in_folder |
					source_file_list[index_file_list] = url_in_folder
					index_file_list = index_file_list + 1
				end
				index_folder_list = index_folder_list + 1
			end
		end
		log "#{url} own #{index_folder_list} folder and #{index_file_list} files"
		return source_file_list
	end

end