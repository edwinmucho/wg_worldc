require 'msgmaker'

class KakaoController < ApplicationController
    @@key = Msgmaker::Keyboard.new
    @@msg = Msgmaker::Message.new
    
    @@user = {}
    
    MENU_STEP_INFO    =   "경기 일정"
    MENU_STEP_RESULTS =   "경기 결과"
    MENU_STEP_NEWS    =   "최신 뉴스"
    MENU_STEP_PLAYER  =   "선수 검색"
    
    FUNC_STEP_INIT    =    -1
    
    DEFAULT_MESSAGE   =   "안녕하세요. 월드컵알리미 입니다."
    
    @@main_menu = [MENU_STEP_INFO, MENU_STEP_RESULTS,
                   MENU_STEP_NEWS, MENU_STEP_PLAYER]
                   
    def keyboard
        msg, keyboard = init_state("init_state")
        render json: keyboard
    end
    
    def message
        
        user_msg = params[:content]
        user_key = params[:user_key]
        
        today = Time.now.getlocal('+09:00')        
        temp_msg, temp_key = init_state("init_state")
        
        check_user(user_key)
        
        if temp_key[:buttons].include? user_msg and (@@user[user_key][:fstep][-1] > FUNC_STEP_INIT)
            init_state(user_key)
        end
        
        # menu step 변경 하는 부분.
        if @@user[user_key][:mstep] == "main"
          @@user[user_key][:mstep] = user_msg if temp_key[:buttons].include? user_msg
        end
        
         begin
      # 각 메뉴 진입.
      case @@user[user_key][:mstep]
      
        when MENU_STEP_INFO
          temp_msg, temp_key, ismsgBtn = infotoday(user_key)
        when MENU_STEP_RESULTS
          temp_msg, temp_key, ismsgBtn = game_result(user_key)
        when MENU_STEP_NEWS
          temp_msg, temp_key, ismsgBtn = wc_news(user_key)
        when MENU_STEP_PLAYER
          temp_msg, temp_key, ismsgBtn = whoishe(user_key)

        else
        #   temp_msg, temp_key = init_keybutton
      end
      
      # 에러 발생시 여기로 옴. #에러 로그를 여기서!
      rescue Exception => e
        user_msg = "에러 발생"
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
    def infotoday(user_key)
        temp_msg, temp_key = init_state("오늘 일정 입니다.",user_key)
        
        return temp_msg, temp_key, false
    end
##########################################################    
    def game_result(user_key)
        temp_msg, temp_key = init_state("게임 결과 입니다.",user_key)
        
        return temp_msg, temp_key, false
    end
##########################################################    
    def wc_news(user_key)
        temp_msg, temp_key = init_state("월드컵 뉴스 입니다.",user_key)
        
        return temp_msg, temp_key, false
    end
##########################################################    
    def whoishe(user_key)
        temp_msg, temp_key = init_state("선수 검색 입니다..",user_key)
        
        return temp_msg, temp_key, false
    end    
end
