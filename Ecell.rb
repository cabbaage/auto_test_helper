module Ecell
    def row(i)
        #puts "i = #{i}\n"
        i_mod = (i-1)%26
        row_here = ""
        i_here = (i-1)/26
        while i_here > 0
            row_here << self.row(i_here)
            i_here = (i_here-1)/26
        end
        row_here << ( 65 + i_mod ).chr
        #puts "row_here = #{row_here}\n"
        return row_here
    end

class Book
    @@no_of_Ecell = 0
    def initialize(url)
        @excel = WIN32OLE::new('excel.Application') #for using api#
        @sheet = Hash.new
        begin
            @book = @excel.Workbooks.open(url)
            log("Open the #{url}",1)
            log self.list_sheets,1
            
        rescue
            #p url
            @book = @excel.Workbooks.Add
            @book.saveas url.gsub(/\//,"\\")
            log("A new Excell created at #{url}",1)
        end
    end
    ####loc##Location  of the cell in the Book##[location of the cell@location of the sheets]##
    def list_sheets
        number_of_sheets = @book.Sheets.Count
        case number_of_sheets
        when 1
            @sheet[1] = @book.Worksheets(1).name
        else
            (1..number_of_sheets).each do |no_s|
                @sheet[no_s] = @book.Worksheets(no_s).name
            end
        end
        return @sheet.values()
        #return @b
    end
    def delete_sheet(name_of_sheet)
        name_of_sheet_here = "#{name_of_sheet}".gsub(/\"/,"").gsub(/[\[|\]]/,"")
        log( "now begin to delete sheet #{name_of_sheet_here}",1)
        #puts "active sheet is #{@book.activesheet.name}"
        begin
            #puts "#{name_of_sheet_here}"
            if(@book.activesheet.name == name_of_sheet_here)
                #puts "deleting the act sheet"
                no_of_sheet = @book.Sheets.count
                sheet_unselected = "Sheet1"
                (1..no_of_sheet).each do |index_sheet|
                    name_here = @book.sheets(index_sheet).name
                    if(name_here == name_of_sheet_here)
                    else
                        sheet_unselected = name_here
                    end
                end
                
                @book.Sheets(sheet_unselected).select
                #puts "Change to select #{@book.Sheets(sheet_unselected).name}"
                #p name_of_sheet_here
                
                #@book.Sheets(name_of_sheet_here).delete(true)
            else
                
            end
            @book.Application.DisplayAlerts = false
            #@book.Sheets(name_of_sheet_here).delete
            if(@book.Worksheets(name_of_sheet_here).delete)
                #puts "#{name_of_sheet_here} had been deleted"
            end
            @book.Application.DisplayAlerts = true
        rescue
            log "Some error happen while deleting sheet #{name_of_sheet_here}",1
            
        end
    end
    def add_sheet(name_of_sheet)
        list_before = self.list_sheets
        log "Before created a new sheet, it has:#{list_before}",1
        if(list_before.include?(name_of_sheet))
            log( "The name of #{name_of_sheet} had been already used",1)
        else
            @book.Sheets.add
            list_after = self.list_sheets
            log "A new sheet created,now sheets has #{list_after}",1
            list_created = list_after
            list_created = list_after - list_before
            log "A new sheet created,now sheets has #{list_after}, and #{list_created} is the new one",1
            the_name_created = list_created
            #name_created_one = the_one_created.to_s
            #log("The sheet of #{@book.Worksheets(1).name} had created",1)
            begin
                #log("#{name_created_one} named #{@book.Worksheets(1).name}",1)
                @book.Worksheets(the_name_created[0]).name = name_of_sheet
                log "#{name_of_sheet} created success",1
            rescue
                #@book.Application.DisplayAlerts = false
                #@book.Sheets(1).Delete
                self.delete_sheet(the_name_created_value.to_s)
                #@book.Application.DisplayAlerts = true
                log "The_name of #{name_of_sheet} named failed"
            end
        end
        log "now the book has the follewing sheet :#{self.list_sheets}",1
    end
    def location_of_cell(loc)
        if(loc.include? "@")
            location = loc.split('@')
            #@sheet_here = @book.Worksheets("#{location[1]}")
            @sheet_here = @book.Worksheets("#{location[1]}")
            #@sheet_here.Range("#{location[0]}").NumberFormatLocal = "@"
            return @sheet_here.Range("#{location[0]}")
        else
            #@sheet_sl.Range("#{loc}").NumberFormatLocal = "@"
            return @sheet_sl.Range("#{loc}")
        end
    end
    #######################################################
    def get_value(loc)
        return location_of_cell("#{loc}").value
    end
    def get_list(sheet,list)
        list_array = []
        i=1
        @sheet_sl = @book.Worksheets(sheet)
        while @sheet_sl.Range("#{list}#{i}").value != nil
            list_array<<@sheet_sl.Range("#{list}#{i}").value
            i = i+1 
        end
        return list_array
    end
    def get_title(sheet)
        row_length = 0
        row_array = []
        i = 1
        @sheet_sl = @book.Worksheets(sheet)
        while @sheet_sl.Range("#{self.row(i)}1").value != nil
            row_length = row_length + 1
            row_array<<@sheet_sl.Range("#{self.row(i)}1").value
            i = i + 1
        end
        return row_array
    end
    def get_row(sheet,row)
        title = self.get_title(sheet)
        row_length = title.count
        row_array = Array.new(row_length)
        @sheet_sl = @book.Worksheets(sheet)
        (1..row_length).each do |i|
            #row_length = row_length + 1
            row_array[i-1] = @sheet_sl.Range("#{self.row(i)}#{row}").value
        end
        return row_array
    end
    def put_value(loc,value_to_set,format = "@")
        #log "#{loc} set #{value_to_set}",1
        #location_of_cell(loc).NumberFormatLocal = "@"
        cell_here = location_of_cell(loc)
        case format
            when "@"
                cell_here.NumberFormatLocal = "@"
            when "num"
        end
        cell_here.value = value_to_set.to_s
    end
    def Quit
        @book.Close("False")
        @excel.Quit
    end
    def Save
        @book.Save
    end
    def SaveandQuit
        @book.Save
        @book.Close("False")
        @excel.Quit
    end
end

end