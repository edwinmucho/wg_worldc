require 'msgmaker'
require "jsonmaker"

class KakaoController < ApplicationController
    @@key = Msgmaker::Keyboard.new
    @@msg = Msgmaker::Message.new
    
    @@user = {}
    
    MENU_STEP_INFO    =   "경기 일정"
    MENU_STEP_HIGHLIGHT =   "어제 하이라이트"
    MENU_STEP_NEWS    =   "최신 뉴스"
    MENU_STEP_PLAYER  =   "선수 검색"
    
    FUNC_STEP_INIT    =    -1
    
    DEFAULT_MESSAGE   =   "안녕하세요. 월드컵알리미 입니다."
    
    @@main_menu = [MENU_STEP_INFO, MENU_STEP_HIGHLIGHT, MENU_STEP_NEWS]

    @@nation_flag = {"러시아"=>"🇷🇺",    "우루과이"=>"🇺🇾",  "이집트"=>"🇪🇬",    "사우디아라비아"=>"🇸🇦",
                     "이란"=>"🇮🇷",      "스페인"=>"🇪🇸",    "포르투갈"=>"🇵🇹",  "모로코"=>"🇲🇦",
                     "프랑스"=>"🇫🇷",    "덴마크"=> "🇩🇰",   "호주"=> "🇦🇺",     "페루"=>"🇵🇪",
                     "크로아티아"=>"🇭🇷","아르헨티나"=>"🇦🇷","아이슬란드"=>"🇮🇸","나이지리아"=>"🇳🇬",
                     "브라질"=>"🇧🇷",    "스위스"=>"🇨🇭",    "코스타리카"=>"🇨🇷","세르비아"=>"🇷🇸",
                     "독일"=>"🇩🇪",      "멕시코"=>"🇲🇽",    "스웨덴"=>"🇸🇪",    "대한민국"=>"🇰🇷",
                     "벨기에"=>"🇧🇪",    "파나마"=>"🇵🇦",    "잉글랜드"=>"🏴",    "튀니지"=>"🇹🇳",
                     "폴란드"=>"🇵🇱",    "세네갈"=>"🇸🇳",    "콜롬비아"=>"🇨🇴",  "일본"=>"🇯🇵"
    }                   
    def keyboard
        msg, keyboard = init_state("init_state")
        render json: keyboard
    end
    
    def message
        
        user_msg = params[:content]
        user_key = params[:user_key]
        
        today = Time.now.getlocal('+09:00')
        date = today.strftime("%Y%m%d")
        time = today.strftime("%H:%M")
        temp_msg, temp_key = init_state("init_state")
# ap "DateTime >>>>>>>>>"
# ap today
# ap date
# ap time
        check_user(user_key)
        
        if temp_key[:buttons].include? user_msg and (@@user[user_key][:fstep][-1] > FUNC_STEP_INIT)
            init_state(user_key)
        end
        
        # menu step 변경 하는 부분.
        if @@user[user_key][:mstep] == "main"
          @@user[user_key][:mstep] = user_msg if temp_key[:buttons].include? user_msg
        end
        
        # begin
      # 각 메뉴 진입.
            case @@user[user_key][:mstep]
            
            when MENU_STEP_INFO
                temp_msg, temp_key, ismsgBtn = infotoday(user_key, time, date)
            when MENU_STEP_HIGHLIGHT
                temp_msg, temp_key, ismsgBtn = game_highlight(user_key, date)
            when MENU_STEP_NEWS
                temp_msg, temp_key, ismsgBtn = wc_news(user_key)
            when MENU_STEP_PLAYER
                temp_msg, temp_key, ismsgBtn = whoishe(user_key)
            
            else
            #   temp_msg, temp_key = init_keybutton
            end
      
      # 에러 발생시 여기로 옴. #에러 로그를 여기서!
        #   rescue Exception => e
        #     temp_msg = "에러 발생"
        # end
        
        
    if ismsgBtn
      result = {
        message: @@msg.getMessageBtn(temp_msg[0],temp_msg[1], temp_msg[2]),
        keyboard: temp_key
      }
    else
      result = {
        message: @@msg.getMessage(temp_msg.to_s),
        keyboard: temp_key
      }
    end
        
        render json: result
    end
##########################################################    
    def friend_add
        user_key = params[:user_key]
    end
##########################################################    
    def friend_del
        user_key = params[:user_key]
    end
##########################################################    
    def chat_room
        user_key = params[:user_key]
        
    end
##########################################################    
    def init_state(text="", user_key)
    
        default_msg = (text == "") ? DEFAULT_MESSAGE : text + "\n\n" + DEFAULT_MESSAGE  # "메뉴를 골라 주세요."
        default_key = @@key.getBtnKey(@@main_menu)
        
        if user_key != "init_status"
            @@user[user_key] = 
            {
            :mstep => @mstep = "main",
            :fstep => @fstep = [FUNC_STEP_INIT]
            }
        end

        return default_msg, default_key
    end
##########################################################    
    def check_user(user_key)
        
        if @@user[user_key].nil?
            @@user[user_key] = 
            {
                :mstep => @mstep = "main",
                :fstep => @fstep = [FUNC_STEP_INIT]
            }
            
            res = User.where(user_key: user_key)[0]
            # ap "Check user >>>>>>>"      
            # ap res      
            if res.nil?
              User.create(user_key: user_key, chat_room: 1)
            end
        end
    end
##########################################################    
    def infotoday(user_key, time, date)
        
        temp_msg, temp_key = init_state(user_key)
        
        jm_sch = Jsonmaker::Crawling.new
        tomorrow = (date.to_i+1).to_s
        schedule = Array.new
        ttl_sch = jm_sch.schedule["dailyScheduleListMap"]
        
        today_info = ttl_sch[date]
        tomor_info = ttl_sch[tomorrow]

        today_info.each do |t|
            if t["gameStartTime"] > "05:00"
                schedule.push(t)
            end
        end
        
        tomor_info.each do |t|
            if t["gameStartTime"] < "05:00"
                schedule.push(t)
            end
        end
        
        temp_text = ["오늘의 경기 일정 (굿)\n"]
        schedule.each do |g|
        
        playstatus = "#{g["gameStatus"]} (제발)"
        if g["gameStatus"].eql? "BEFORE"
            playstatus = "아직 경기전 (꺄아)"            
        elsif g["gameStatus"].eql? "RESULT"
            g["gameStatus"] = "경기 끝남 (컴온)"
        end
            temp_text.push "#{g["tournamentGameText"]} #{g["stadium"]}\n\
#{g["gameStartDate"].to_date.strftime("%d")}일 #{g["gameStartTime"]} #{playstatus}\n\
#{@@nation_flag[g["homeTeamName"]]}#{g["homeTeamName"]} #{g["homeTeamScore"]} vs #{g["awayTeamScore"]} #{g["awayTeamName"]}#{@@nation_flag[g["awayTeamName"]]}\n"
        end
        temp = []
        text = temp_text.join("\n")        
        label = "전체 경기 일정"
        url = "http://m.sports.media.daum.net/sports/wc/russia/schedule?tab=day"
        
        temp.push(text)
        temp.push(label)
        temp.push(url)
        
        temp_msg = temp
        
        return temp_msg, temp_key, true
    end
##########################################################    
    def game_highlight(user_key, today)
        daum_highlight = 
        {
            #A
            "러시아"=>{"사우디아라비아"=>"80016579","이집트"=>"80016581"},
            "이집트"=>{"우루과이"=>"80016580"},
            "우루과이"=>{"사우디아라비아"=>"80016582","러시아"=>"80016583"},
            "사우디아라비아"=>{"이집트"=>"80016584"},
            #B
            "모로코"=>{"이란"=>"80016585"},
            "포르투갈"=>{"스페인"=>"80016586","모로코"=>"80016587"},
            "이란"=>{"스페인"=>"80016588","포르투갈"=>"80016589"},
            "스페인"=>{"모로코"=>"80016590"},
            #C
            "프랑스"=>{"호주"=>"80016591","페루"=>"80016594"},
            "페루"=>{"덴마크"=>"80016592"},
            "덴마크"=>{"호주"=>"80016593","프랑스"=>"80016595"},
            "호주"=>{"페루"=>"80016596"},
            #D
            "아르헨티나"=>{"아이슬란드"=>"80016597","크로아티아"=>"80016599"},
            "크로아티아"=>{"나이지리아"=>"80016598"},
            "나이지리아"=>{"아이슬란드"=>"80016600","아르헨티나"=>"80016601"},
            "아이슬란드"=>{"크로아티아"=>"80016602"},
            #E
            "코스타리카"=>{"세르비아"=>"80016603"},
            "브라질"=>{"스위스"=>"80016604","코스타리카"=>"80016605"},
            "세르비아"=>{"스위스"=>"80016606","브라질"=>"80016607"},
            "스위스"=>{"코스타리카"=>"80016608"},
            #F
            "독일"=>{"멕시코"=>"80016609","스웨덴"=>"80016612"},
            "스웨덴"=>{"대한민국"=>"80016610"},
            "대한민국"=>{"멕시코"=>"80016611","독일"=>"80016613"},
            "멕시코"=>{"스웨덴"=>"80016614"},
            #G
            "벨기에"=>{"파나마"=>"80016615","튀니지"=>"80016617"},
            "튀니지"=>{"잉글랜드"=>"m80016616"},
            "잉글랜드"=>{"파나마"=>"80016618","벨기에"=>"80016619"},
            "파나마"=>{"튀니지"=>"80016620"},
            #H
            "콜롬비아"=>{"일본"=>"80016621"},
            "폴란드"=>{"세네갈"=>"80016622","콜롬비아"=>"80016624"},
            "일본"=>{"세네갈"=>"80016623","폴란드"=>"80016625"},
            "세네갈"=>{"콜롬비아"=>"80016626"}
        }
        temp_msg, temp_key = init_state(user_key)
        
        jm_sch = Jsonmaker::Crawling.new
        yesterday = (today.to_i-1).to_s
        schedule = Array.new
        ttl_sch = jm_sch.schedule["dailyScheduleListMap"]
        
        high_info = ttl_sch[yesterday].concat(ttl_sch[today])
        
        gameresult = []
        high_info.each do |h|
            if not h["gameStatus"].eql? "BEFORE" and not (h["gameStartTime"] < "06:00" and h["gameStartDate"].eql? yesterday)
                # ap "#{h["tournamentGameText"]} #{h["homeTeamName"]} #{h["awayTeamName"]}"
                tmp_url = "bit.ly/#{daum_highlight[h["homeTeamName"]][h["awayTeamName"]]}"
                tmp_text = "#{h["tournamentGameText"]} #{h["gameStartDate"].to_date.strftime("%d")}일 #{h["gameStartTime"]}\n#{h["homeTeamName"]} #{h["homeTeamScore"]} vs #{h["awayTeamScore"]} #{h["awayTeamName"]}\n하이라이트보기 (좋아)\n[#{tmp_url}]\n"
                gameresult.push(tmp_text)
            end
        end
        temp_msg = gameresult.join("\n")
        # temp_msg = "예선B조\n모로코 0 vs 1 이란\n하이라이트 보기\n[bit.ly/m80016616]\n\n예선B조\n모로코 0 vs 1 이란\n하이라이트 보기\n[bit.ly/80016582]"
        return temp_msg, temp_key, false
    end
##########################################################    
    def wc_news(user_key)
        temp_msg, temp_key = init_state(user_key)
        temp = []
        text = "⚽월드컵 최신 뉴스 알아보기🏆\n"
        label = "오늘의 최신 뉴스"
        url = "http://m.sports.media.daum.net/sports/wc/russia/news/breaking"
        
        temp.push(text)
        temp.push(label)
        temp.push(url)
        
        temp_msg = temp
        return temp_msg, temp_key, true
    end
##########################################################    
    def whoishe(user_key)
        temp_msg, temp_key = init_state("선수 검색 입니다..",user_key)
        
        return temp_msg, temp_key, false
    end    
end
