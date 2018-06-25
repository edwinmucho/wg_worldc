require "jsonmaker"
require "awesome_print"

class SavedbController < ApplicationController
    
    def loginpage
        session.clear
    end

    def check_pw
        if params[:pw] == ENV["ADMIN_PW"]
            session[:login] = true
            redirect_to '/db/mainpage'
        else
            redirect_to '/db/loginpage'
        end
    end
    
    def mainpage    
        if !session[:login]
            redirect_to '/db/loginpage'
        end
        @country_cnt = Country.all.count
        @game_cnt = Game.all.count
    end
    
    def destroypage
        if !session[:login]
            redirect_to '/db/loginpage'
        end
        @country_cnt = Country.all.count
        @game_cnt = Game.all.count
    end
    
    def destroy_db
        # ap params[:target]
        begin
            if params[:target] == "country"
                Country.delete_all
            elsif params[:target] == "game"
                Game.delete_all
            # elsif params[:target] == "emd"
            #     Emd.delete_all
            else
            end
        
        rescue
            flash[:notice] = '뽀린키 때매 읍면동 1빠/구시군 2빠/시도 3빠로 지우게나!'
        end

        redirect_to '/db/destroypage'        
    end

    def savecountry
        if !session[:login]
            redirect_to '/db/loginpage'
        end
        
        jm_sch = Jsonmaker::Crawling.new
        data = jm_sch.group
        code = csvread("country_code.csv")
        ("A".."H").to_a.each do |c|
            data["ScheduleListGroup#{c}"].each do |key,value|
                ap c
                if value.size.eql? 2
                    value.each do |v|
                        Country.create(name: v["homeTeamName"], group: v["groupName"], flag_url: v["homeTeamEmblem64URI"].gsub("amp;",""), code: code[v["homeTeamName"]])
                        Country.create(name: v["awayTeamName"], group: v["groupName"], flag_url: v["awayTeamEmblem64URI"].gsub("amp;",""), code: code[v["awayTeamName"]])
                    end
                    break     
                end
            end
        end
        redirect_to '/db/mainpage'
    end
    
    def csvread(file)
        require "csv"
        code = Hash.new
        
        CSV.foreach(file) do |n, c|
            code[n] = c
        end
        return code
    end
    
    def makegamelist
        js = Jsonmaker::Crawling.new
        data = js.schedule
        
        data["dailyScheduleListMap"].each do |date, game|
            game.each do |g|
                if g["phaseName"].eql? "조별예선"
                    title = "#{g["tournamentGameText"]} #{g["homeTeamName"]} vs #{g["awayTeamName"]}"
                    Game.create(title: title, home: g["homeTeamName"], away: g["awayTeamName"],\
                                game_date: g["gameStartDate"], game_time: g["gameStartTime"], game_state: g["gameStatus"])
                else
                    ap "토너먼트는 아직 저장 안함."
                end
            end            
            
        end
        redirect_to '/db/mainpage'
    end
end
