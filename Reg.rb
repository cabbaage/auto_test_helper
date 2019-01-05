$Reg_file_name = "Reg_store.rexdb"
$reg_base = Hash.new
$reg_attribute = Hash.new
$reg_properties = Hash.new


module Reg
    def module_patch(module_name)
        path_rexdb = "#{$path_this}/Bin/Rexdb"
        url = "#{path_rexdb}/#{module_name}_module.rexdb"
        return url
    end
    def show_all
        log("**********Now Reg_db begin*********")
        $reg_base.each do |reg_here|
            log reg_here
        end
        log("**********Now Reg_db end  *********")
    end
    ###############################################################
    #
    #rexdb:
    #    tag,attribute,regexp(may be inner_tag),properties
    #
    #    attribute:
    #    1->one tag a line, which only once in cube;
    #    n->one tag a line, which multitimes in cube;
    #    s->multi_tag_a_line,which_multitimes_in_cube;
    #    properties:
    #    line->may get some array, list linely
    ###############################################################
    def load_reg_db(url)
        begin
            url = self.module_patch(url)
            index_reg = 0
            File.open("#{url}","r") do | reg |
                line = reg.gets
                key_tag = ""
                while(false == (line.eql?(nil)))
                    reg_key = line.split(',')
                    if index_reg == 0
                        key_tag = "#{reg_key[0]}"
                        $reg_base["#{key_tag}"] = Hash.new
                        $reg_attribute["#{key_tag}"] = Hash.new
                        $reg_properties["#{key_tag}"] = Hash.new
                        #$reg_base["#{key_tag}"]["#{reg_key[0]}"] = Regexp.new("#{reg_key[2].gsub(/\n/,'')}",Regexp::IGNORECASE)
                    end
                    $reg_base["#{key_tag}"]["#{reg_key[0]}"] = Regexp.new("#{reg_key[2].gsub(/\n/,'')}",Regexp::IGNORECASE)
                    if($reg_base["#{key_tag}"]["#{reg_key[0]}"].eql?(nil))
                        log "#{reg_key[0]} cannot created regexp",1
                    end
                    $reg_attribute["#{key_tag}"]["#{reg_key[0]}"] = "#{reg_key[1]}"
                    if reg_key[3].eql?(nil)
                        $reg_properties["#{key_tag}"]["#{reg_key[0]}"] = ""
                    else
                        $reg_properties["#{key_tag}"]["#{reg_key[0]}"] = "#{reg_key[3].gsub(/\n/,'')}"
                    end
                    #puts $reg_base.size
                    line = reg.gets
                    index_reg = index_reg + 1
                end
            end
            log("loading regexp datebase #{url} success",1)
        rescue
            log("loading regexp datebase #{url} failed")
            self.show_all
        end
        
    end
    def unlink_reg_db(url)
        begin
            url = self.module_patch(url)
            File.open("#{url}","r") do | reg |
                line = reg.gets
                while(false == (line.eql?(nil)))
                    reg_key = line.split(',')
                    $reg_base.delete("#{reg_key[0]}")
                    $reg_attribute.delete("#{reg_key[0]}")
                    #puts $reg_base.size
                    line = reg.gets
                end
            end
            log("unlink regexp datebase #{url} success",1)
        rescue
            log("unlink regexp datebase #{url} failed")
            self.show_all
        end
    end
    def get_scan_base(reg,src)
        res_here = src.scan(reg)
        #log res_here
        begin
            return res_here
        rescue
            log "#{reg} cannt scan anything"
            return "#{reg} cannt match anything"
        end
    end
    def get_match_base(reg,src)
        res_here = reg.match(src)
        #puts res_here
        begin
            return res_here
        rescue
            puts "#{reg} cannt match anything"
            return "#{reg} cannt match anything"
        end
    end
    def get_match(src,type,tag,inner_tag = "")
        reg_here = $reg_base["#{type}"]["#{tag}"]
        case $reg_attribute["#{type}"]["#{tag}"]
            when "1"
                res_here = get_match_base(reg_here,src)
                begin
                    if "" == inner_tag
                    #log "#{src} match #{type} get #{res_here}",1
                        return res_here["#{tag}"]
                    else
                        return res_here["#{inner_tag}"]
                    end
                rescue
                    return res_here
                end
            when "n"
                res = []
                index_match = 0
                src.split(/\n/).each do | lines_here |
                    #puts "#{reg_here}::#{lines_here}"
                    #p lines_here
                    res_here = get_match_base(reg_here,lines_here)
                    
                    if(res_here.eql?(nil))
                    else
                        if inner_tag == "all"
                            return reg_here
                        else
                            if inner_tag == ""
                                inner_tag = tag
                            end
                            begin
                                if res_here["#{inner_tag}"].eql?(nil)
                                else
                                    res[index_match] = res_here["#{inner_tag}"]
                                    index_match = index_match + 1
                                end
                            rescue
                                res << "#{inner_tag} cannt match anything"
                            end
                        end
                    end
                end
                #puts reg_here.match(src_lines)
                #log "#{src} match #{type} get #{res}",1
                if index_match == 0
                    return
                else
                    return res
                end
            when "s"
                res = []
                res[0] = reg_here.names
                res << get_scan_base(reg_here,src)
                
                return res
        end
    end
    
end
