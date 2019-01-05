$dir_here = Dir::pwd
puts "now process is working in #{$dir_here}"
if $dir_here == $path_this

else
    $dir_here = $path_this
    puts "now process change to #{$dir_here}"
end

$debug_enable = 0
@Source_type = ["Configure","Log"]
@Target_type = ["Output"]
@Source_Inner_filter = ["source","temporary"]

module Log
    #require "fileutils"
    #require "find"
    #require "pathname"
    #########analysis == A,output == O////O+  continue add message#########
    begin
        $logfile = File.open("#{$path_this}/my_process_#{$main_file_name.gsub("#{$path_this}","").gsub(/\.|\//,"_")}_logfie_#{Time.now.mon}_#{Time.now.day}_#{Time.now.hour}_#{Time.now.min}.log","a+")
    rescue
        $logfile = File.open("#{$path_this}/my_process_wetest_logfie_#{Time.now.mon}_#{Time.now.day}_#{Time.now.hour}_#{Time.now.min}.log","a+")
    end
    
    def filter_create(filter_name,url = $dir_here)
            begin
                Dir::mkdir("#{url}/#{filter_name}")
                return 1
            rescue
                puts("#{url}/#{filter_name} is exist")
                return 0
            end
    end
    def filter_delete(filter_name,url = $dir_here)
            begin
                FileUtils.rm_r("#{url}/#{filter_name}") 
                return 1
            rescue
                puts("#{url}/#{filter_name} is no exist")
                return 0
            end
    end
    def log(message,level = 0)
        message_to_send = "#{Time.now} #{message}"
        case level
            when 0
                $logfile.puts message_to_send  
                puts message_to_send
            when 1
                #puts message_to_send
                $logfile.puts message_to_send
        end
    end
    def com_cube(filter_name,filter_name_output,file_name_tocreate,url = $dir_here)
        file_name = []
        part = 0
        filter_create(filter_name_output)
        dir_filter = Dir::new("#{url}/#{filter_name}")
        list = dir_filter.entries
        list.each do |l|
            if false == File::directory?(l)
                file_name << l
                #puts "#{file_name}"
                part = part + 1
            end
        end
        begin
            match_res = /(?<name>(\W|\.|\s)*_)[0-9]*$/.match(file_name[0])
        rescue
            log "Catch nothing about file_name"
        end
        file_prefix = match_res[:name]
        File.open("#{url}/#{filter_name_output}/#{file_name_tocreate}","a+") do |file_this|
            (1..file_name.length).each do |index_here|
                file_this.puts File.open("#{url}/#{filter_name}/#{file_prefix}#{index_here-1}","r").read
            end
        end
        log "Com file #{file_name_tocreate} with #{part} from #{url}/#{filter_name}"
        return "#{url}/#{filter_name_output}/#{file_name_tocreate}"
    end
    #Logfile::com_cube()

end

class Logfile
    include Log
    @@no_of_Logfile=0
    def initialize(url = $path_this ,operation = "r")
        @name = url
        case operation
        
        when "A"
            begin
            @file = File.open("#{url}","r")
            rescue
                puts "#{url} File no exist"
            end
        when "O"
            @file = File.open("#{url}","w+")
        when "O+"
            @file = File.open("#{url}","a+")
        end
    end
    def div_cube_nowrite(gap = "#")
        cube_file = @file.read.force_encoding("utf-8").split(/^#{gap}$/)
        log "#{@name} div in #{cube_file.count}",1
        return cube_file
    end
    def div_cube(filter_name,gap = "#",url = "{$dir_here}/Configure/temporary")
        list_file = Hash.new
        part = 0
        line_number = 0
        flag_filter = filter_create(filter_name,url)
        if(flag_filter == 0 )
            dir_filter = Dir::new("#{url}/#{filter_name}")
            list = dir_filter.entries
            list.each do |l|
                if false == File::directory?(l)
                    list_file[part] = url+"/"+filter_name+"/"+l
                    #puts "#{file_name}"
                    part = part + 1
                end
            end
            #log list_file
            return list_file
        else
            line_this = @file.gets
            while( false == (line_this.eql?(nil)) )
                file_url = "#{url}/#{filter_name}/#{gap}_#{part}"
                list_file["#{part}"] = file_url
                File.open(file_url,"a+") do |file_this|
                    file_this.puts "#{line_this}"
                    line_this = @file.gets
                    line_number = line_number + 1
                    #puts "#{line_number}:#{line_this}"
                    #puts false == (line_this =~ /^.?#{gap}\s*/).eql?(nil)
                    if( false == (line_this =~ /^#{gap}\s*/).eql?(nil))
                        part = part + 1
                        file_this.close
                        next
                    else
                    end
                end
            end
            #puts "div file in #{part+1} in #{url}/#{filter_name}"
            return list_file
        end
    end
    def w(value)
        @file.puts "#{value}"
    end
    def rall
        @file.read
    end
    def rline
        @file.gets
    end
    def close
        @file.close
    end
end
