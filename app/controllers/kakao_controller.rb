require 'msgmaker'
require "jsonmaker"

class KakaoController < ApplicationController
    @@key = Msgmaker::Keyboard.new
    @@msg = Msgmaker::Message.new
    
    @@user = {}
    
    MENU_STEP_MYTEAM  =     "[ 내 응원팀 보기 ]"
    MENU_STEP_INFO    =     "오늘 경기 일정"
    MENU_STEP_HIGHLIGHT =   "어제 경기 하이라이트"
    MENU_STEP_NEWS    =     "월드컵 최신 뉴스"
    MENU_STEP_RANKING =     "월드컵 조별 순위"
    MENU_STEP_PLAYER  =     "선수 검색"
    MENU_STEP_BATTING =     "[테스트]승패 맞추기"
    
    FUNC_STEP_INIT    =    0
    FUNC_STEP_STAY    =    -1
    FUNC_STEP_SELECT  =    99
    
    FUNC_STEP_MYTEAM_SET1 = " ▶이 버튼을 눌러 응원팀을 설정!◀"
    FUNC_STEP_MYTEAM_HELP = " 헬프! 참가국이 궁금햇!"
    FUNC_STEP_MYTEAM_SET2 = "응원팀 변경하기"
    FUNC_STEP_MYTEAM_SAVE = "저장중"
    FUNC_STEP_MYTEAM_SCHE = "경기일정"
    FUNC_STEP_MYTEAM_HILI = "하이라이트"
    FUNC_STEP_MYTEAM_RANK = "현재순위"
    FUNC_STEP_MYTEAM_NEWS = "최신뉴스"
    FUNC_STEP_MYTEAM_CURR = "현재 응원팀:"
    
    FUNC_STEP_HOME        = "[ 처음으로 가기 ]"
    FUNC_STEP_SAVE        = "저장중"
    
    DEFAULT_MESSAGE       = "(아잉)\n\"안녕하세요. 월드컵알리미 입니다.\""
    DEFAULT_MYTEAM_MSG    = "(우와)\n\"어디 한번 골라 볼까용?\"" 

    BATTING_POINT = 10
    ALPHA_POINT   = 5
    
    SEPERATE          = "-"*10
    FUNC_STEP_BATTING = "승패 예측 하러가기"
    FUNC_STEP_RESULT  = "승패 예측 결과 확인"
    FUNC_STEP_RANK    = "전체 예측 순위"
    
    NEXT_STEP_GUESS_HOME = 0
    NEXT_STEP_GUESS_AWAY = 1
    NEXT_STEP_GUESS_CALC = 2
    
    @@main_menu = [MENU_STEP_BATTING, MENU_STEP_MYTEAM, MENU_STEP_INFO, MENU_STEP_HIGHLIGHT, MENU_STEP_NEWS, MENU_STEP_RANKING]

    def keyboard
        msg, keyboard = init_state("init_state")
        render json: keyboard
    end
    
    def message
        
        user_msg = params[:content]
        user_key = params[:user_key]
        
        # 시간 설정
        today = Time.zone.now#.getlocal('+09:00')
        date = today.strftime("%Y%m%d")
        time = today.strftime("%H:%M")
# ap "Time >>>>>"        
# ap date
# ap time
# ap User.find(1).updated_at.strftime("%Y%m%d %H:%M")
        temp_msg, temp_key = init_state("init_state")

        check_user(user_key)
# ap "User Check >>>>>"        
# ap @@user[user_key]
        if temp_key[:buttons].include? user_msg and (@@user[user_key][:fstep][-1] != FUNC_STEP_INIT)
            init_state(user_key)
        end
        
        # menu step 변경 하는 부분.
        if @@user[user_key][:mstep] == "main"
            @@user[user_key][:mstep] = user_msg if temp_key[:buttons].include? user_msg
        end
        
        # begin
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
            when MENU_STEP_RANKING
                temp_msg, temp_key, ismsgBtn = wc_rank(user_key)
            when MENU_STEP_BATTING
                temp_msg, temp_key, ismsgBtn = check_batting(user_key, time, date)
                # temp_msg, temp_key, ismsgBtn = wc_batting(time, date)
            # when MENU_STEP_PLAYER
            #     temp_msg, temp_key, ismsgBtn = whoishe(user_key)
            else
            #   temp_msg, temp_key = init_keybutton
            end
      
          # 에러 발생시 여기로 옴. #에러 로그를 여기서!
        #   rescue Exception => e
        #     err_msg = "#{e.message} ( #{e.backtrace.inspect.scan(/\/[a-zA-Z_]+\/[a-zA-Z_.:0-9]+in /)[0]} )"
        #     Buglist.create(user_key: user_key, err_msg: err_msg, usr_msg: user_msg, mstep: @@user[user_key][:mstep], fstep: @@user[user_key][:fstep])
        #     temp_msg, temp_key = init_state("(흑흑)\n\"불편을 드려 죄송합니다.\n신속한 수정이 이뤄지도록 하겠습니다.\n감사합니다.\"",user_key)
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
        data = Msgmaker::Data.new

        @myteam_menu = [FUNC_STEP_MYTEAM_SET1, FUNC_STEP_MYTEAM_HELP, FUNC_STEP_HOME]
        
        # 2~5 번째 메뉴만 순서 바꿀 수 있음. (첫번째, 여섯번째, 일곱번째는 메뉴 순서 변경 불가!)
        t_menu = [FUNC_STEP_MYTEAM_CURR, # 위치 변경 안됨.
                  FUNC_STEP_MYTEAM_SCHE, FUNC_STEP_MYTEAM_HILI, FUNC_STEP_MYTEAM_NEWS, 
                  FUNC_STEP_MYTEAM_SET2, # 위치 변경 안됨.
                  FUNC_STEP_HOME         # 위치 변경 안됨.
                  ]
        user = User.find_by(user_key: user_key)
        
        if user.nil?
            user_msg = FUNC_STEP_HOME
        else
            unless user.country_id.nil? or user.country_id.eql? ""
                @myteam_menu = data.getTeamMenu(user,t_menu)
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
        elsif user_msg.include? "헬프" or user_msg.include? "500원"
            c = Country.all
            nation = Array.new
                          
            ("A".."H").to_a.each do |g|
               nation.push("<<#{g}조>>\n #{c.where(group: g).pluck(:name).join(",")}")
            end
            
            if user_msg.eql? FUNC_STEP_MYTEAM_HELP
                tmp_msg = "#{nation.join("\n\t\t\n")}"
                tmp_key = @@key.getBtnKey(@myteam_menu)
            else                
                tmp_msg = "#{nation.join("\n\t\t\n")}\n\n(찡긋)\n\"다음 참가국 중에서 응원하고픈 국가는 어딘가요?\"\n[이전/홈]"
                tmp_key = @@key.getTextKey
            end
        else
            
            if fstep == FUNC_STEP_INIT
                tmp_msg = user.country_id.nil? ? "(감동)\n\"응원팀을 등록해 주세요.\"": DEFAULT_MYTEAM_MSG
                tmp_key = @@key.getBtnKey(@myteam_menu)
                @@user[user_key][:fstep].push(FUNC_STEP_SELECT)
            elsif fstep == FUNC_STEP_SELECT

                if [FUNC_STEP_MYTEAM_SET1, FUNC_STEP_MYTEAM_SET2].include? user_msg
                    # 팀 설정하기 누른 경우
                    # 어떤팀을 받을 건지 메세지 전송.
                    # 키입력 타입.
                    tmp_msg = "(하하)\n\"어느 나라를 등록할까요?\"\n(심각)\n\"참가국이 궁금하면 \"헬프\"\n이전 메뉴로 갈려면 \"이전\"\n처음으로 갈려면 \"홈\"을\n 적어주쎄요~\""
                    tmp_key = @@key.getTextKey
                    @@user[user_key][:fstep].pop
                    @@user[user_key][:fstep].push(FUNC_STEP_MYTEAM_SAVE)
                elsif user_msg.include? FUNC_STEP_MYTEAM_SCHE
                    text = "(신나)\n\"TEAM #{user.country.name} 경기 일정을 안내해 드릴게요.\""
                    label = "#{user.country.name} 일정"
                    url = "http://m.sports.media.daum.net/m/sports/wc/russia/team/#{user.country.code}/schedule"
                    
                    tmp_msg=[text,label,url]
                    tmp_key = @@key.getBtnKey(@myteam_menu)
                    ismsgBtn = true
                elsif user_msg.include? FUNC_STEP_MYTEAM_HILI
                    text = "(흥)\n\"TEAM #{user.country.name} 경기 숨막히는 하이라이트 다시 한번 볼까요?\""
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

                    temp = ["(발그레) \"#{user.country.group}조 순위입니다.\""]
                    text= temp.push(rank).join("\n-----------------\n")
                    label = "전체 순위"
                    url = "http://m.sports.media.daum.net/m/sports/wc/russia/schedule/groupstage"
                    tmp_msg = [text, label, url]
                    tmp_key = @@key.getBtnKey(@myteam_menu)
                    ismsgBtn = true
                elsif user_msg.include? FUNC_STEP_MYTEAM_NEWS
                    text = "(좋아)\n\"TEAM #{user.country.name} 최신 뉴스를 모아모아!\""
                    label = "#{user.country.name} 최신 뉴스"
                    url = "http://m.sports.media.daum.net/m/sports/wc/russia/team/#{user.country.code}/news"
                    
                    tmp_msg=[text,label,url]
                    tmp_key = @@key.getBtnKey(@myteam_menu)
                    ismsgBtn = true
                elsif user_msg.include? FUNC_STEP_MYTEAM_CURR
                    data = Msgmaker::Data.new
                    tmp_msg = data.getCheerMsg(user.country.name)
                    tmp_key = @@key.getBtnKey(@myteam_menu)
                else
                    tmp_msg = user_msg
                    tmp_key = @@key.getBtnKey(@myteam_menu)
                end
            elsif fstep == FUNC_STEP_MYTEAM_SAVE
                # 받은 키값을 다음에서 찾아서 제대로된 값으로 변환 후 유저에 아이디 등록.
                # 정상 저장이면 다음 스텝 아니면 한번더 
                nation_id = findcountry(user_msg)
                
                if nation_id.nil? or nation_id.eql? ""
                    tmp_msg = "(흑흑)\n\"#{user_msg}는 월드컵 출전국이 아닙니다\n 응원하고 싶은 국가를 다시 입력해 주세요.\"\n [헬프/이전/홈]"
                    tmp_key = @@key.getTextKey
                else                    
                    user.country_id = nation_id
                    user.save
                    tmp_msg = DEFAULT_MYTEAM_MSG
                    
                    menu = data.getTeamMenu(user, t_menu)
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
        data = Msgmaker::Data.new
        nation_flag = data.getFlagEmoji
        high_data = data.getHighlight

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
        temp_text = ["(굿) \"오늘의 경기 일정~Yo!\"\n"]
        schedule.each do |g|
        
            playstatus = "⚽#{g["state"]}⚽"
            cmt = "문자중계"
            if g["gameStatus"].eql? "BEFORE"
                playstatus = "(꺄아)\"경기 전!\""            
                cmt = "전력분석"
            elsif g["gameStatus"].eql? "RESULT"
                playstatus = "(컴온)\"경기 끝남\""
                cmt = "하이라이트"
            end
            temp_text.push "#{g["tournamentGameText"]} #{g["stadium"]}\n\
[#{g["gameStartDate"].to_date.strftime("%d")}일 #{g["gameStartTime"]}] #{playstatus}\n\
#{nation_flag[g["homeTeamName"]]}#{g["homeTeamName"]} #{g["homeTeamScore"]} vs #{g["awayTeamScore"]} #{g["awayTeamName"]}#{nation_flag[g["awayTeamName"]]}\n\
#{cmt}:[bit.ly/#{high_data[g["homeTeamName"]][g["awayTeamName"]]}]\n"
                    
        end
        
        text = temp_text.join("\n")        
        label = "전체 경기 일정"
        url = "http://m.sports.media.daum.net/m/sports/wc/russia/schedule?tab=day"
        
        temp_msg = [text,label,url]
        
        return temp_msg, temp_key, true
    end
##########################################################    
    def game_highlight(user_key, time, date)
       
        temp_msg, temp_key = init_state(user_key)
        high_data = Msgmaker::Data.new
        jm_sch = Jsonmaker::Crawling.new
        yesterday = (date.to_i-1).to_s
        schedule = Array.new
        ttl_sch = jm_sch.schedule["dailyScheduleListMap"]
        
        high_info = ttl_sch[yesterday].concat(ttl_sch[date])
        
        gameresult = []
        high_info.each do |h|
            if not h["gameStatus"].eql? "BEFORE" and not ((h["gameStartTime"] < "05:00" and time > "05:00" ) and h["gameStartDate"].eql? yesterday)
                # ap "#{h["tournamentGameText"]} #{h["homeTeamName"]} #{h["awayTeamName"]}"
                
                tmp_url = "bit.ly/#{high_data.getHighlight[h["homeTeamName"]][h["awayTeamName"]]}"
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

        text = "(굿)\n\"2018 러시아 월드컵🏆 따끈따끈한 최신 뉴스입니다.\"\n"
        label = "오늘의 최신 뉴스"
        url = "http://m.sports.media.daum.net/m/sports/wc/russia/news/breaking"

        temp_msg = [text,label,url]
        return temp_msg, temp_key, true
    end
##########################################################    
    def wc_rank(user_key)
        temp_msg, temp_key = init_state(user_key)

        user = User.where(user_key:user_key)[0]
        
        if user.country_id.nil? or user.country_id.eql? ""
            text = "(수줍)\n\"2018 러시아 월드컵🏆 전체 순위를 알아볼까요?\"\n"
        else
            mkjs = Jsonmaker::Crawling.new
            groupdata = mkjs.group["Group#{user.country.group}"]
            rank = Array.new
            groupdata.each do |g|
                teamname = (user.country.name.eql? g["teamName"]) ? "#{g["teamName"]} ❤️": "#{g["teamName"]}"
                rank.push("#{g["rank"]}위 #{teamname}\n#{g["win"]}승 #{g["draw"]}무 #{g["lose"]}패 #{g["goalDifference"]}(#{g["own"]}/#{g["against"]})골 #{g["point"]}점")
            end

            temp = ["(발그레) \"#{user.country.group}조 순위입니다.\""]
            text= temp.push(rank).join("\n-----------------\n")
        end
        label = "전체 조별 순위"
        url = "http://m.sports.media.daum.net/m/sports/wc/russia/schedule/groupstage"

        temp_msg = [text, label, url]        

        return temp_msg, temp_key, true
    end
##########################################################    
    def whoishe(user_key)
        temp_msg, temp_key = init_state("선수 검색 입니다..",user_key)
        
        return temp_msg, temp_key, false
    end    
##########################################################
    def check_batting(user_key, time, date)
        user = User.find_by(user_key: user_key)
        ismsgBtn = false
        
        menu = [FUNC_STEP_BATTING, FUNC_STEP_RESULT, FUNC_STEP_RANK, FUNC_STEP_HOME]
        if user.nick.nil? or user.nick.size.eql? 0
            tmp_msg, tmp_key = set_nickname(user_key, menu)
        else
            tmp_msg, tmp_key, ismsgBtn = wc_batting(menu, time, date)
        end
        return tmp_msg, tmp_key, ismsgBtn
    end
##########################################################
    def wc_batting(menu, time, date)
        user_key = params[:user_key]
        user_msg = params[:content]
        ismsgBtn = false
        
        
        # tmp_msg, temp_key = init_state(user_key)

        fstep = @@user[user_key][:fstep][-1] # 최신 fstep 
        user = User.find_by(user_key: user_key)

        if user_msg.eql? FUNC_STEP_HOME
            tmp_msg, tmp_key = init_state(user_key)
        elsif user_msg == "이전" or user_msg == "메뉴로"
        # Nstep 이전 처리해야함. 배팅에서 이전으로 오는 경우도 있음.
            tmp_msg = "메뉴를 골라주세요."
            tmp_key = @@key.getBtnKey(menu)
            @@user[user_key][:fstep].pop
        else
            # 배팅 펑션 메뉴 위치
            if fstep == FUNC_STEP_INIT
                # 현재 Game DB Update
                game = Game.all
                update_gamestate(game, date, time)
                update_foreresult(game, date, time)
                update_userpoint(game, date, time)
                # 메뉴 버튼식 / 코멘트
                # Next Function 으로 Push 필요.
                tmp_msg = "메뉴를 골라주세요."
                tmp_key = @@key.getBtnKey(menu)
                @@user[user_key][:fstep].push(FUNC_STEP_SELECT)
            elsif fstep == FUNC_STEP_SELECT
                # user_msg 어떤 메뉴 선택 했는지 확인.
                if user_msg == FUNC_STEP_BATTING
                    # Game 에 경기 상태 업데이트/버튼 목록 가져오기.
                    tmp_btn = check_game(date, time).push("이전")
                    
                    @@user[user_key][:fstep].push(FUNC_STEP_BATTING)
                    @@user[user_key][:nstep] = [NEXT_STEP_GUESS_HOME]
                    tmp_msg = "어느 경기를 예측해 볼랑가요?"
                    tmp_key = @@key.getBtnKey(tmp_btn)                
                elsif user_msg == FUNC_STEP_RESULT
                    # 유저 정보 불러와서 배팅 상황 카톡 혹은 웹 구현
                    # 최신 3개 정보만 확인.
                    temp = Array.new
                    user.forecast.last(3).reverse.each do |fore|
                        time = "#{fore.game.game_date.to_date.strftime("%d일")} #{fore.game.game_time} "
                        title = fore.game.title
                        guess = (fore.f_guess.eql? "Home") ? "#{fore.f_home}팀 승리" : (fore.f_guess.eql? "Away") ? "#{fore.f_away}팀 승리" : "무승부"
                        predict = "예상 : #{fore.f_hs} : #{fore.f_as} #{guess}"
                        if fore.game.game_state.eql? "BEFORE"
                            time.concat "경기 전"
                            point = SEPERATE
                        elsif fore.game.game_state.eql? "RESULT"
                            time.concat "경기 종료"
                            real = (fore.game.result.eql? "Home") ? "#{fore.f_home}팀 승리" : (fore.game.result.eql? "Away") ? "#{fore.f_away}팀 승리" : "무승부"
                            result = "결과 : #{fore.game.r_hs} : #{fore.game.r_as} #{real}"
                            point = "획득 : 승부(#{fore.get_point}p) 골보너스(#{fore.get_alpha}p)\n"
                            if fore.get_point == 0
                                point.concat "참가자 전원이 맞췄습니다." 
                            end
                            point.concat "#{SEPERATE}"
                        else 
                            js = Jsonmaker::Crawling.new
                            js.schedule["dailyScheduleListMap"][fore.game.game_date].each do |game|
                                if game["gameStartTime"].eql? fore.game.game_time
                                    result = "(#{game["state"]})\n #{game["homeTeamName"]} #{game["homeTeamScore"]} : #{game["awayTeamScore"]} #{game["awayTeamName"]}"
                                    break
                                end
                            end
                            time.concat "경기 중"
                            point = SEPERATE
                        end
                        temp.push([time,title,predict,result,point].join("\n"))
                    end
                    # 메뉴 버튼식(같은 레벨단) / 코멘트
                    tmp_msg = temp.join("\n")
                    tmp_key = @@key.getBtnKey(menu)
                elsif user_msg == FUNC_STEP_RANK
                    # 전체 정보 불러와서 순위 구현 (카톡 or 웹)
                    # 메뉴 버튼식 (같은 레벨단) / 코멘트
                    text = ["예언가 TOP 10"]
                    User.all.order(point: :desc).first(10).to_enum.with_index.each do |rank, i|
                        text.push "#{i+1} #{rank.nick} | #{rank.point}"
                    end
                    tmp_msg = text.join("\n")
                    tmp_key = @@key.getBtnKey(menu)
                else
                    tmp_msg, tmp_key = init_state(user_key)
                end
                
            elsif fstep == FUNC_STEP_BATTING
                nstep = @@user[user_key][:nstep][-1]
                user = User.find_by(user_key: user_key)
                btn = ('0'..'9').to_a.unshift("메뉴로")

                if nstep == NEXT_STEP_GUESS_HOME
                    # user_msg = 경기 목록이 될 예정.
                    @@user[user_key][:title] = user_msg.gsub(/ (?<num>[0-9]{2})일 \g<num>:\g<num>/,"")
                    home = @@user[user_key][:title].split[2]
                    tmp_msg = "#{home}팀은 몇골 넣을거 같음?"
                    tmp_key = @@key.getBtnKey(btn)
                    @@user[user_key][:nstep].push(NEXT_STEP_GUESS_AWAY)
                elsif nstep == NEXT_STEP_GUESS_AWAY
                    # user_msg = 홈틸 골 수
                    @@user[user_key][:hs] = user_msg.to_i
                    # 원정팀이 몇골 넣을 건지 예측.
                    away = @@user[user_key][:title].split[4]
                    tmp_msg = "#{away}팀은 몇골 넣을거 같음?"
                    tmp_key = @@key.getBtnKey(btn)
                    @@user[user_key][:nstep].push(NEXT_STEP_GUESS_CALC)
                elsif nstep == NEXT_STEP_GUESS_CALC
                    # user_msg = 원정팀 골 수
                    # 홈이 이길지 원정이 이길지 Check
                    title = @@user[user_key][:title]
                    home_score = @@user[user_key][:hs].to_i
                    away_score = user_msg.to_i
                    home = @@user[user_key][:title].split[2]                    
                    away = @@user[user_key][:title].split[4]
                    isdraw = false
                    
                    guess = (home_score > away_score) ? "Home" : (away_score > home_score) ? "Away" : "Draw"
                    
                    user_game = user.games.find_by(title: title)
                    if not user_game.nil?
                        user.forecast.find_by(game_id: user_game.id)
                                     .update(f_guess: guess, f_hs: home_score, f_as: away_score)
                    else
                        game_id = Game.find_by("? like title", title).id
                        Forecast.create(user_id: user.id, game_id: game_id,f_home: home, f_away: away,\
                                         f_guess: guess, f_hs: home_score, f_as: away_score, isapply: false, corr_count: 0)
                    end

                    tmp_msg = "등록이 완료 되었습니다.\n 경기 종료 후 확인이 가능합니다.\n 예상은 경기 시작전 까지 수정이 가능합니다."
                    tmp_key = @@key.getBtnKey(menu)
                    @@user[user_key].delete(:nstep)
                    @@user[user_key].delete(:title)
                    @@user[user_key].delete(:hs)
                    @@user[user_key][:fstep].pop
                else
                    # 기타 에러 처림.. 
                end

            else
                # 기타.. 에러 처리
            end
        end

        
        return tmp_msg, tmp_key, ismsgBtn
    end
##########################################################
    def check_game(date, time)

        btn = Array.new
        game = Game.all

        if game.exists?
            # update_gamestate(game, date, time)
            btn = get_gamebtn(game, date, time)
        else
            btn = ["이전"]
        end

        return btn
    end
##########################################################
    def update_gamestate(game, date, time)

        js = Jsonmaker::Crawling.new

        yest = (date.to_i - 1).to_s
        data = js.schedule["dailyScheduleListMap"][yest]
        data.push(js.schedule["dailyScheduleListMap"][date])
        data = data.flatten(1)

        # 현재 데이터를 기반으로 DB 업데이트
        data.each do |d|
            # 경기 중이거나 경기 끝난 부분 업데이트

            unless d["gameStatus"].eql? "BEFORE"
                result = d["homeTeamWon"] ? "Home" : d["awayTeamWon"] ? "Away" : "Draw"
                ActiveRecord::Base.transaction do
                    # need_update = game.find_by("game_date = ? AND game_time = ?", yest, d["gameStartTime"]) if need_update.nil?
                    need_update = game.find_by("game_date = ? AND game_time = ?", d["gameStartDate"], d["gameStartTime"])
                    if not need_update.nil?
                        need_update.update(game_state: d["gameStatus"], result: result, r_hs: d["homeTeamScore"].to_i, r_as: d["awayTeamScore"].to_i)
                    end
                end
            end
            
        end
    end
#########################################################
    def get_gamebtn(game, date, time)

        list = Array.new
        tomor = (date.to_i + 1).to_s
        
        if time < "05:00"
            list.push(game.where("game_date = ? AND game_state = \"BEFORE\"", date).pluck(:title, :game_date, :game_time))
        else
            list.push(game.where("(game_date = ? AND game_time > \"05:00\" AND game_state = \"BEFORE\")", date).pluck(:title, :game_date, :game_time))
            list.push(game.where("(game_date = ? AND game_time <= \"05:00\" AND game_state = \"BEFORE\")", tomor).pluck(:title, :game_date, :game_time))
        end
        
        btn = Array.new
        list.flatten(1).each do |title, date, time|
            btn.push("#{title} #{date.to_date.strftime("%d일")} #{time}")
        end

        return btn
    end
#########################################################
    def update_foreresult(game, date, time)
        # 어제 전체 경기와 오늘 현재시간 이전의 경기 기준.
        game_list = game.where("game_date = ? OR (game_date = ? AND game_time < ?)",(date.to_i - 1).to_s, date, time)
        # 각 경기별 유저의 forecast를 update
        game_list.each do |g|
            # 예측한 경기 결과
            g.forecast.each do |f|
                f.ispredict = (g.result.eql? f.f_guess)? true : false
                f.save!
            end
        end
    end
########################################################
    def update_userpoint(game, date, time)
        # 어제 게임 / 오늘 현시간 이전 게임 리스트
        game_list = game.where("game_date = ? OR (game_date = ? AND game_time < ?)",(date.to_i - 1).to_s, date, time)
        game_list.each do |game|
# ap game.users            
            if game.game_state == "RESULT"
                guess_total = game.forecast.count

                game.forecast.each do |fore|
                    if fore.ispredict
                        corr_guess = game.forecast.where(ispredict: true).count
# ap "guess total : #{guess_total}"
# ap "corr guess : #{corr_guess}"
# ap ((BATTING_POINT * guess_total) / corr_guess) - BATTING_POINT                        
                        fore.get_point = ((BATTING_POINT * guess_total) / corr_guess) - BATTING_POINT
# ap fore
                        fore.corr_count+=1
# ap "corr guess : #{corr_guess}"
                    else
                        fore.get_point = -BATTING_POINT                        
                    end
                    fore.get_alpha = ALPHA_POINT * (((game.r_hs.eql? fore.f_hs)? 1 : 0) + ((game.r_as.eql? fore.f_as)? 1 : 0))

                    fore.user.point = 0 if fore.user.point.nil?
                    fore.user.point = fore.user.point + fore.get_point + fore.get_alpha
                    
                    unless fore.isapply?
                        fore.isapply = true
                        fore.save!
                        fore.user.save! 
                    end
                end
                
            end
        end
    end
#######################################################
    def set_nickname(user_key, menu)
        user_msg = params[:content]
        
        fstep = @@user[user_key][:fstep][-1]
        user = User.all
# ap "set nickname>>>"        
# ap fstep
# ap user_msg
        if user_msg == "홈" or user_msg == "이전"
            tmp_msg, tmp_key = init_state(user_key)
        else
            if fstep.eql? FUNC_STEP_INIT
                tmp_msg = "별명을 먼저 설정하고 가시겠습니다."
                tmp_key = @@key.getTextKey
                @@user[user_key][:fstep].push(FUNC_STEP_SAVE)
            elsif fstep.eql? FUNC_STEP_SAVE
                if user.where(nick: user_msg).exists?
                    tmp_msg = "이미 있는 별명입니다."
                    tmp_key = @@key.getTextKey
                else
                    user.find_by(user_key: user_key).update(nick: user_msg)
                    tmp_msg = "#{user_msg} 로 별명이 설정되었습니다."
                    tmp_key = @@key.getBtnKey(menu)
                end
            else
                # 잘못 누른 경우.
                
            end
        end
        
        
        return tmp_msg, tmp_key, false
    end

end
