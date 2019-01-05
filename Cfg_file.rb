module Cfg_file
    def load_reg()
        Reg::load_reg_db("/App/file")
    end
    
    def get_Cfg_module(url)
        file = Logfile.new(url,"A")
    end
    
    def get_reg_name()
        return $reg_base["file"]["cp_flag"].names
    end
    
    def index_table(tag,vlan_tag = nil)
        x_index = Hash.new
        @cp_flag["#{tag}"].each do |key_here,value_here|
            x_index[value_here] = []
        end
        @cp_flag["#{tag}"].each do |key_here,value_here|
            if vlan_tag.eql?(nil)
                x_index[value_here] << key_here
            else
                x_index[value_here] << @cp_flag["#{vlan_tag}"][key_here].to_i
            end
        end
        return x_index
    end
    
    def default_value(res)
        if res.eql?(nil)
            return "default"
        else
            return res
        end
    end
end


class Cfg
    def initialize(url)
        self.load_reg()
        @file = self.get_Cfg_module(url)
        @file_all_content = @file.rall
        @output_file_name = get_match(@file_all_content,"file","file_name")
        
        if @output_file_name.eql?(nil)
            @output_file_name = self.default_value(@output_file_name)
            @file_body = @file_all_content
        else
            file_here = @file_all_content.split(';')
            @file_body = file_here[1].gsub(/^\n/,'')+"\r\n"
        end
        
        @output_file_url = "#{$path_this}/App/Output/#{@output_file_name}"
        @cp_flag = Hash.new
        @output_file = Logfile.new("#{$path_this}/App/Output/#{@output_file_name}","O")
        
        self.get_reg_name.each do |flag|
            @cp_flag[flag] = Hash.new
        end
    end
    
    def output_file_refresh()
        @output_file.close
        @output_file = Logfile.new("#{$path_this}/App/Output/#{@output_file_name}","O")
    end
    
    def cp_flag_refresh(file_base = @file_body)
        i = 1
        get_match(file_base,"file","cp_flag")[1].each do | flag_here |
            key_index = 0
            @cp_flag.each_key do |key|
                @cp_flag[key][i] = flag_here[key_index]
                key_index = key_index + 1
            end
            i = i + 1
        end
        log "cp_flag had been refresh as #{@cp_flag}",1
        return @cp_flag
    end
    
    def cp_to_file(file_base = @file_body)
        base_content = file_base
        begin_here = Hash.new
        content_to_w = ""
        self.cp_flag_refresh(file_base)
        begin_here = @cp_flag["begin"]
        tag_index = self.index_table("cp_tag")
        times_index = self.index_table("cp_tag","times")
        cover_content = Hash.new
        tag_index.each_key do |tag_here|
            cover_content[tag_here] = Hash.new
            
            last_index = 0
            
            (1..times_index[tag_here].max).each do |times_in_tag|
                
                base_content = file_base
                
                cover_content[tag_here][times_in_tag] = Hash.new
                
                
                tag_index[tag_here].each do |index_here|
                    log "In #{tag_here}[#{index_here}], #{get_match(base_content,"file","cp_flag")[1].count} tag to be sub #{begin_here[index_here]}",1
                    #tag_index[tag_here].each do |index_here|
                    cover_content[tag_here][times_in_tag][index_here] = base_content.gsub("#{@cp_flag["cp_flag"][index_here]}","#{begin_here[index_here]}")
                    #log cover_content
                    #begin_here[index_here] = (begin_here[index_here].to_i + @cp_flag["step"][index_here].to_i)%( @cp_flag["step"][index_here].to_i*@cp_flag["times"][index_here].to_i) + begin_here[index_here].to_i
                    begin_here[index_here] = begin_here[index_here].to_i + @cp_flag["step"][index_here].to_i
                    if begin_here[index_here].to_i >= (@cp_flag["begin"][index_here].to_i + @cp_flag["step"][index_here].to_i*@cp_flag["times"][index_here].to_i)
                        begin_here[index_here] = @cp_flag["begin"][index_here].to_i
                    end
                    
                    if tag_index[tag_here].count > 1
                        base_content = cover_content[tag_here][times_in_tag][index_here]
                        
                    else
                    end
                    last_index = index_here
                end
            end
            base_content = ""
            (1..times_index[tag_here].max).each do |times_in_tag|
                #p cover_content[tag_here][times_in_tag][last_index]
                base_content = base_content + cover_content[tag_here][times_in_tag][last_index]
                
            end
            file_base = base_content
        end
        content_to_w = base_content
        @output_file.w content_to_w.gsub(/\r/,"")
        return content_to_w.gsub(/\r/,"")
    end
    
    def cp_to_file_iteration()
        res = self.cp_to_file()
        res_count = get_match(res,"file","cp_flag")[1].count
        iteration_times = 0
        while res_count > 1
            self.output_file_refresh
            res = self.cp_to_file(res)
            res_count = get_match(res,"file","cp_flag")[1].count
            iteration_times = iteration_times + 1
        end
        return res
    end
    
    def show_cfg
        log @output_file_name
        log @file_all_content
        log @file_body
    end
end