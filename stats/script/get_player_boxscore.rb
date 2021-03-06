require 'nokogiri'
require 'open-uri'


class GetPlayerBoxscore

    def initialize

        #delete boxscore file if already exists
        if File.exists?("player_boxscore")
            File.delete("player_boxscore")
        end

        #read from file 
        table=File.read("player_url_name")

        #modify file to read strings correctly
        player_url_name=table.split(/\n/)

        #create variables from file
        player_url_name.each do |a|
            url_name = a
            first_letter = a[0] 
            if match = a.match(/\s*(\w+)\s+(\w+)\s+(\w+)\s*/)
            url_name, first, last = match.captures
            end

        #get data from bball-refernce
            doc = Nokogiri::HTML(open("http://www.basketball-reference.com/players/#{first_letter}/#{url_name}/gamelog/2015"))
            rows = doc.xpath('//table[@id="pgl_basic"]/tbody/tr') 
            details = rows.collect do |row|
              detail = {}
                  [
                    [:name, 'text()'],
                    [:team, 'td[5]/a/text()'],
                    [:date, 'td[3]/a/text()'],
                    [:home, 'td[6]/text()'],
                    [:opponent, 'td[7]/a/text()'],
                    [:mins, 'td[10]/text()'],
                    [:points, 'td[28]/text()'],
                    [:fg_attempts, 'td[12]/text()'],
                    [:fg_percent, 'td[13]/text()'],
                    [:fouls, 'td[27]/text()'],
                    [:rebounds, 'td[22]/text()'],
                    [:assists, 'td[23]/text()'],
                    [:steals, 'td[24]/text()'],
                    [:blocks, 'td[25]/text()'],
                    [:turnovers, 'td[26]/text()']

                  ].each do |name, xpath|
                  detail[name] = row.at_xpath(xpath).to_s.strip
                  end
            detail
            end

        #remove unwanted empty rows
            details.each do |x|
                xname=x[:team]
                    if xname.chomp == ""
                    details.delete x
                end
            end


        #add value into key :name
            details.each{|key| key[:name] = "#{first} #{last}"}

        #change the home/away variables to human readable
            details.each{|key| if key[:home]=="@"
              key[:home] = "AWAY"
            else
              key[:home] = "HOME"
            end
            }

            #change empty percent strings to '0'
            details.each{|key| if key[:fg_percent]== ""
                key[:fg_percent] = "0"
            end
            }   
            
            puts details

        #create data file 
            File.open("player_boxscore", "a+") do |f|
            f.write(details)
            end

        end

        #remove unwanted array characters from file player_boxscore
        boxscore=File.read("player_boxscore")
        remove_bracket=boxscore.gsub("\"\"", "\"0\"").gsub("][", ", ").gsub(",\ ,\ ,", ",").gsub(",\ ,", ",")
        File.open("player_boxscore", "w") do |f|
            f.write(remove_bracket)
        end
    end
end

