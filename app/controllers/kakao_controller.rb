require 'msgmaker'
require "jsonmaker"

class KakaoController < ApplicationController
    @@key = Msgmaker::Keyboard.new
    @@msg = Msgmaker::Message.new
    
    @@user = {}
    
    MENU_STEP_MYTEAM  =     "내 응원팀 보기"
    MENU_STEP_INFO    =     "월드컵 경기 일정"
    MENU_STEP_HIGHLIGHT =   "어제 경기 하이라이트"
    MENU_STEP_NEWS    =     "월드컵 최신 뉴스"
    MENU_STEP_PLAYER  =     "선수 검색"
    
    FUNC_STEP_INIT    =    0
    FUNC_STEP_STAY    =    -1
    FUNC_STEP_SELECT  =    99
    
    FUNC_STEP_MYTEAM_SET1 = " ▶이 버튼을 눌러 응원팀을 설정!◀"
    FUNC_STEP_MYTEAM_HELP = " 헬프! 참가국이 궁금햇!"
    FUNC_STEP_MYTEAM_SET2 = "응원팀 변경하기"
    FUNC_STEP_MYTEAM_SAVE = "저장중"
    FUNC_STEP_MYTEAM_SCHE = "일정은요?"
    FUNC_STEP_MYTEAM_HILI = "하이라이트! 뚜둔!"
    FUNC_STEP_MYTEAM_RANK = "순위는 과연?"
    FUNC_STEP_MYTEAM_NEWS = "뉴스 보여주세요."
    
    FUNC_STEP_HOME        = "[ 처음으로 가기 ]"
    
    DEFAULT_MESSAGE       = "안녕하세요. 월드컵알리미 입니다."
    DEFAULT_MYTEAM_MSG    = "어디 한번 골라 볼까?" 
    
    @@main_menu = [MENU_STEP_MYTEAM, MENU_STEP_INFO, MENU_STEP_HIGHLIGHT, MENU_STEP_NEWS]

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
        
        # 시간 설정
        today = Time.now.getlocal('+09:00')
        date = today.strftime("%Y%m%d")
        time = today.strftime("%H:%M")
        
        temp_msg, temp_key = init_state("init_state")

        check_user(user_key)
# ap "User Check >>>>>"        
# ap @@user[user_key]
        if temp_key[:buttons].include? user_msg and (@@user[user_key][:fstep][-1] > FUNC_STEP_INIT)
            init_state(user_key)
        end
        
        # menu step 변경 하는 부분.
        if @@user[user_key][:mstep] == "main"
            @@user[user_key][:mstep] = user_msg if temp_key[:buttons].include? user_msg
        end
        
        begin
    #   각 메뉴 진입.
            case @@user[user_key][:mstep]
            
            when MENU_STEP_MYTEAM
                temp_msg, temp_key, ismsgBtn = myteaminfo(user_msg, date)
            when MENU_STEP_INFO
                temp_msg, temp_key, ismsgBtn = infotoday(user_key, time, date)
            when MENU_STEP_HIGHLIGHT
                temp_msg, temp_key, ismsgBtn = game_highlight(user_key, time, date)
            when MENU_STEP_NEWS
                temp_msg, temp_key, ismsgBtn = wc_news(user_key)
            when MENU_STEP_PLAYER
                temp_msg, temp_key, ismsgBtn = whoishe(user_key)
            else
            #   temp_msg, temp_key = init_keybutton
            end
      
          # 에러 발생시 여기로 옴. #에러 로그를 여기서!
          rescue Exception => e
            err_msg = "#{e.message} ( #{e.backtrace.inspect.scan(/\/[a-zA-Z_]+\/[a-zA-Z_.:0-9]+in /)[0]} )"
            Buglist.create(user_key: user_key, err_msg: err_msg, user_msg: user_msg, mstep: @@user[user_key][:mstep], fstep: @@user[user_key][:fstep])
            temp_msg, temp_key = init_state("불편을 드려 죄송합니다.\n 다시 시도해 주세요.",user_key)
        end
        
        
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
# ap result            
        render json: result
    end
    
##########################################################    
    def friend_add
        user_key = params[:user_key]
        if user_key != "test"
          res = User.where(user_key: user_key)[0]
  
          if res.nil?
            User.create(user_key: user_key, chat_room: 0)
          end

          @@user[user_key] = 
          {
            :mstep => @mstep = "main",
            :fstep => @fstep = [FUNC_STEP_INIT]
          }
        end
    end
##########################################################    
    def friend_del
        user_key = params[:user_key]
        
        user = User.where(user_key: user_key)[0]
        user.user_key = "서비스 탈퇴!"
        user.save
    end
##########################################################    
    def chat_room
        user_key = params[:user_key]
        
        user = User.find_by(user_key: user_key)
        if not user.nil?
            user.chat_room += 1
            user.save
        end
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
  
            if res.nil?
              User.create(user_key: user_key, chat_room: 1)
            end
        end
    end
##########################################################    
    def myteaminfo(user_msg, date)
        user_key = params[:user_key]
        ismsgBtn = false

# ap "myteam >>>>>"
# ap @@user[user_key]
# ap user_msg
        @myteam_menu = [FUNC_STEP_MYTEAM_SET1, FUNC_STEP_MYTEAM_HELP, FUNC_STEP_HOME]

        user = User.find_by(user_key: user_key)
        
        if user.nil?
            user_msg = FUNC_STEP_HOME
        else
            unless user.country_id.nil? or user.country_id.eql? ""
                @myteam_menu = ["응원팀 #{@@nation_flag[user.country.name]}#{user.country.name} 일정은요?", 
                            "#{user.country.name} #{FUNC_STEP_MYTEAM_HILI}", "#{user.country.group}조 #{FUNC_STEP_MYTEAM_RANK}", 
                            "#{user.country.name} #{FUNC_STEP_MYTEAM_NEWS}", FUNC_STEP_MYTEAM_SET2, FUNC_STEP_HOME]
            end
        end

        fstep = @@user[user_key][:fstep][-1]

        if user_msg.eql? FUNC_STEP_HOME or user_msg.include? "홈"
            tmp_msg, tmp_key = init_state(user_key)
        elsif user_msg.include? "이전"

            tmp_msg = DEFAULT_MYTEAM_MSG
            tmp_key = @@key.getBtnKey(@myteam_menu)
            @@user[user_key][:fstep].pop
            @@user[user_key][:fstep].push(FUNC_STEP_SELECT)
        elsif user_msg.include? "헬프"
            c = Country.all
            nation = Array.new
                          
            ("A".."H").to_a.each do |g|
               nation.push("<<#{g}조>>\n #{c.where(group: g).pluck(:name).join(",")}")
            end
            
            if user_msg.eql? FUNC_STEP_MYTEAM_HELP
                tmp_msg = "#{nation.join("\n\t\t\n")}"
                tmp_key = @@key.getBtnKey(@myteam_menu)
            else                
                tmp_msg = "#{nation.join("\n\t\t\n")}\n\n위 국가중에서 응원하고픈 국가는 어딘가요?"
                tmp_key = @@key.getTextKey
            end
        else
            
            if fstep == FUNC_STEP_INIT
                tmp_msg = user.country_id.nil? ? "응원팀을 등록해 주세요.": DEFAULT_MYTEAM_MSG
                tmp_key = @@key.getBtnKey(@myteam_menu)
                @@user[user_key][:fstep].push(FUNC_STEP_SELECT)
            elsif fstep == FUNC_STEP_SELECT

                if [FUNC_STEP_MYTEAM_SET1, FUNC_STEP_MYTEAM_SET2].include? user_msg
                    # 팀 설정하기 누른 경우
                    # 어떤팀을 받을 건지 메세지 전송.
                    # 키입력 타입.
                    tmp_msg = "어느 나라를 등록할까요?\n참가국이 궁금하면 \"헬프\"\n이전 메뉴로 갈려면 \"이전\"\n처음으로 갈려면 \"홈\"을\n 적어주쎄요~"
                    tmp_key = @@key.getTextKey
                    @@user[user_key][:fstep].pop
                    @@user[user_key][:fstep].push(FUNC_STEP_MYTEAM_SAVE)
                elsif user_msg.include? FUNC_STEP_MYTEAM_SCHE
                    text = "#{user.country.name} 앞으로의 일정 입니다."
                    label = "#{user.country.name} 일정"
                    url = "http://m.sports.media.daum.net/m/sports/wc/russia/team/#{user.country.code}/schedule"
                    
                    tmp_msg=[text,label,url]
                    tmp_key = @@key.getBtnKey(@myteam_menu)
                    ismsgBtn = true
                elsif user_msg.include? FUNC_STEP_MYTEAM_HILI
                    text = "응원하는 #{user.country.name}의 하이라이트 입니다."
                    label = "#{user.country.name} 하이라이트"
                    url = "http://m.sports.media.daum.net/m/sports/wc/russia/team/#{user.country.code}/vod"
                    
                    tmp_msg=[text,label,url]
                    tmp_key = @@key.getBtnKey(@myteam_menu)
                    ismsgBtn = true
                elsif user_msg.include? FUNC_STEP_MYTEAM_RANK
                    mkjs = Jsonmaker::Crawling.new
                    
                    groupdata = mkjs.group["Group#{user.country.group}"]
                    rank = Array.new
                    groupdata.each do |g|
                        rank.push("#{g["rank"]}위 #{g["teamName"]}\n#{g["win"]}승 #{g["draw"]}무 #{g["lose"]}패 #{g["goalDifference"]}(#{g["own"]}/#{g["against"]})골 #{g["point"]}점")
                    end

                    text = ["#{user.country.group}조 순위\n"]

                    tmp_msg= text.push(rank).join("\n-----------------\n")
                    tmp_key = @@key.getBtnKey(@myteam_menu)
                    
                elsif user_msg.include? FUNC_STEP_MYTEAM_NEWS
                    text = "#{user.country.name} 최신 뉴스 입니다."
                    label = "#{user.country.name} 최신 뉴스"
                    url = "http://m.sports.media.daum.net/m/sports/wc/russia/team/#{user.country.code}/news"
                    
                    tmp_msg=[text,label,url]
                    tmp_key = @@key.getBtnKey(@myteam_menu)
                    ismsgBtn = true
                else
                    
                end
            elsif fstep == FUNC_STEP_MYTEAM_SAVE
                # 받은 키값을 다음에서 찾아서 제대로된 값으로 변환 후 유저에 아이디 등록.
                # 정상 저장이면 다음 스텝 아니면 한번더 
                nation_id = findcountry(user_msg)
                
                if nation_id.nil? or nation_id.eql? ""
                    tmp_msg = "#{user_msg}는 월드컵 출전국이 아닙니다.\n 다시 입력해 주세요."
                    tmp_key = @@key.getTextKey
                else                    
                    user.country_id = nation_id
                    user.save
                    tmp_msg = DEFAULT_MYTEAM_MSG
                    menu = ["응원팀 #{@@nation_flag[user.country.name]}#{user.country.name} 일정은요?", 
                            "#{user.country.name} #{FUNC_STEP_MYTEAM_HILI}", "#{user.country.group}조 #{FUNC_STEP_MYTEAM_RANK}", 
                            "#{user.country.name} #{FUNC_STEP_MYTEAM_NEWS}", FUNC_STEP_MYTEAM_SET2, FUNC_STEP_HOME]
                    tmp_key = @@key.getBtnKey(menu)
                    @@user[user_key][:fstep].pop
                    @@user[user_key][:fstep].push(FUNC_STEP_SELECT)
                end
            end
        
        end
        return tmp_msg, tmp_key, ismsgBtn
    end

##########################################################
    def findcountry(user_msg)
        url = "https://m.search.daum.net/search?nil_profile=btn&w=tot&DA=SBC&q=#{user_msg}"
        uri = URI.encode(url)
        doc = Nokogiri::HTML(open(uri),nil,'utf-8')

        data = doc.css("#sgrColl > div.coll_cont.cont_worldcup > div.wrap_top > div > div.top_info > a")
        data = doc.css('#spelSch > div.coll_cont > div > a > span.f_emph') if data.size.eql? 0
        country = data.to_s.scan(/[가-힣]+/)[0]
        
# ap "FindCountry >>>>>"        
# ap user_msg
# ap country
# ap Country.where(name: country)
# ap Country.where(name: country).exists?
        nation_id = Country.where(name: country).pluck(:id)[0]
        
        return nation_id
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

        if time < "05:00"
            today_info.each do |t|
                schedule.push(t)
            end
        else
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
        end
        temp_text = ["오늘의 경기 일정 (굿)\n"]
        schedule.each do |g|
        
        playstatus = "⚽#{g["state"]}⚽"
        if g["gameStatus"].eql? "BEFORE"
            playstatus = "경기 전 (꺄아)"            
        elsif g["gameStatus"].eql? "RESULT"
            playstatus = "경기 끝남 (컴온)"
        end
            temp_text.push "#{g["tournamentGameText"]} #{g["stadium"]}\n\
[#{g["gameStartDate"].to_date.strftime("%d")}일 #{g["gameStartTime"]}] #{playstatus}\n\
#{@@nation_flag[g["homeTeamName"]]}#{g["homeTeamName"]} #{g["homeTeamScore"]} vs #{g["awayTeamScore"]} #{g["awayTeamName"]}#{@@nation_flag[g["awayTeamName"]]}\n"
        end
        
        text = temp_text.join("\n")        
        label = "전체 경기 일정"
        url = "http://m.sports.media.daum.net/m/sports/wc/russia/schedule?tab=day"
        
        temp_msg = [text,label,url]
        
        return temp_msg, temp_key, true
    end
##########################################################    
    def game_highlight(user_key, time, date)
        
        daum_highlight = 
        {
            #A
            "러시아"=>{"사우디아라비아"=>"m_80016579","이집트"=>"m_80016581"},
            "이집트"=>{"우루과이"=>"m_80016580"},
            "우루과이"=>{"사우디아라비아"=>"m_80016582","러시아"=>"m_80016583"},
            "사우디아라비아"=>{"이집트"=>"m_80016584"},
            #B
            "모로코"=>{"이란"=>"m_80016585"},
            "포르투갈"=>{"스페인"=>"m_80016586","모로코"=>"m_80016587"},
            "이란"=>{"스페인"=>"m_80016588","포르투갈"=>"m_80016589"},
            "스페인"=>{"모로코"=>"m_80016590"},
            #C
            "프랑스"=>{"호주"=>"m_80016591","페루"=>"m_80016594"},
            "페루"=>{"덴마크"=>"m_80016592"},
            "덴마크"=>{"호주"=>"m_80016593","프랑스"=>"m_80016595"},
            "호주"=>{"페루"=>"m_80016596"},
            #D
            "아르헨티나"=>{"아이슬란드"=>"m_80016597","크로아티아"=>"m_80016599"},
            "크로아티아"=>{"나이지리아"=>"m_80016598"},
            "나이지리아"=>{"아이슬란드"=>"m_80016600","아르헨티나"=>"m_80016601"},
            "아이슬란드"=>{"크로아티아"=>"m_80016602"},
            #E
            "코스타리카"=>{"세르비아"=>"m_80016603"},
            "브라질"=>{"스위스"=>"m_80016604","코스타리카"=>"m_80016605"},
            "세르비아"=>{"스위스"=>"m_80016606","브라질"=>"m_80016607"},
            "스위스"=>{"코스타리카"=>"m_80016608"},
            #F
            "독일"=>{"멕시코"=>"m_80016609","스웨덴"=>"m_80016612"},
            "스웨덴"=>{"대한민국"=>"m_80016610"},
            "대한민국"=>{"멕시코"=>"m_80016611","독일"=>"m_80016613"},
            "멕시코"=>{"스웨덴"=>"m_80016614"},
            #G
            "벨기에"=>{"파나마"=>"m_80016615","튀니지"=>"m_80016617"},
            "튀니지"=>{"잉글랜드"=>"m_80016616"},
            "잉글랜드"=>{"파나마"=>"m_80016618","벨기에"=>"m_80016619"},
            "파나마"=>{"튀니지"=>"m_80016620"},
            #H
            "콜롬비아"=>{"일본"=>"m_80016621"},
            "폴란드"=>{"세네갈"=>"m_80016622","콜롬비아"=>"m_80016624"},
            "일본"=>{"세네갈"=>"m_80016623","폴란드"=>"m_80016625"},
            "세네갈"=>{"콜롬비아"=>"m_80016626"}
        }
        
        temp_msg, temp_key = init_state(user_key)
        
        jm_sch = Jsonmaker::Crawling.new
        yesterday = (date.to_i-1).to_s
        schedule = Array.new
        ttl_sch = jm_sch.schedule["dailyScheduleListMap"]
        
        high_info = ttl_sch[yesterday].concat(ttl_sch[date])
        
        gameresult = []
        high_info.each do |h|
            if not h["gameStatus"].eql? "BEFORE" and not ((h["gameStartTime"] < "05:00" and time > "05:00" ) and h["gameStartDate"].eql? yesterday)
                # ap "#{h["tournamentGameText"]} #{h["homeTeamName"]} #{h["awayTeamName"]}"
                tmp_url = "bit.ly/#{daum_highlight[h["homeTeamName"]][h["awayTeamName"]]}"
                tmp_text = "#{h["tournamentGameText"]} #{h["gameStartDate"].to_date.strftime("%d")}일 #{h["gameStartTime"]}\n\
#{h["homeTeamName"]} #{h["homeTeamScore"]} vs #{h["awayTeamScore"]} #{h["awayTeamName"]}\n🎥 하이라이트보기\n[#{tmp_url}]\n"
                gameresult.push(tmp_text)
            end
        end
        label = "전체 경기 하이라이트"
        url = "http://m.sports.media.daum.net/m/sports/wc/russia/schedule?tab=day"
        temp_msg = [gameresult.join("\n"),label,url]
        # temp_msg = "예선B조\n모로코 0 vs 1 이란\n하이라이트 보기\n[bit.ly/m80016616]\n\n예선B조\n모로코 0 vs 1 이란\n하이라이트 보기\n[bit.ly/80016582]"
        return temp_msg, temp_key, true
    end
##########################################################    
    def wc_news(user_key)
        temp_msg, temp_key = init_state(user_key)

        text = "⚽월드컵 최신 뉴스 알아보기🏆\n"
        label = "오늘의 최신 뉴스"
        url = "http://m.sports.media.daum.net/m/sports/wc/russia/news/breaking"

        temp_msg = [text,label,url]
        return temp_msg, temp_key, true
    end
##########################################################    
    def whoishe(user_key)
        temp_msg, temp_key = init_state("선수 검색 입니다..",user_key)
        
        return temp_msg, temp_key, false
    end    
end
