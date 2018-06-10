require 'msgmaker'

class KakaoController < ApplicationController
    @@key = Msgmaker::Keyboard.new
    @@msg = Msgmaker::Message.new
    
    @@user = {}
    
    MENU_STEP_INFO =      "경기 일정"
    MENU_STEP_RESULTS =   "경기 결과"
    MENU_STEP_NEWS =      "최신 뉴스"
    MENU_STEP_PLAYER =    "선수 검색"
    
    @@main_menu = [MENU_STEP_INFO, MENU_STEP_RESULTS,
                   MENU_STEP_NEWS, MENU_STEP_PLAYER]
                   
    def keyboard
        msg, keyboard = init_keybutton
        render json: keyboard
    end
    
    def message
        
        user_msg = params[:content]
        user_key = params[:user_key]
        
        today = Time.now.getlocal('+09:00')        
        temp_msg, temp_key = init_keybutton
        
        if temp_key[:buttons].include? user_msg and (@@user[user_key][:fstep][-1] > FUNC_STEP_INIT)
            init_state(user_key)
        end
        
        # menu step 변경 하는 부분.
        if @@user[user_key][:mstep] == "main"
          @@user[user_key][:mstep] = user_msg if @next_keyboard[:buttons].include? user_msg
        end
        
         begin
      # 각 메뉴 진입.
      case @@user[user_key][:mstep]
      
        when MENU_STEP_INFO
        #   temp_msg, temp_key, ismsgBtn = infotoday
        when MENU_STEP_RESULTS
        #   temp_msg, temp_key, ismsgBtn = game_result
        when MENU_STEP_NEWS
        #   temp_msg, temp_key, ismsgBtn = wc_news
        when MENU_STEP_PLAYER
        #   temp_msg, temp_key, ismsgBtn = whoishe

        else
        #   temp_msg, temp_key = init_keybutton
      end
      
      # 에러 발생시 여기로 옴. #에러 로그를 여기서!
      rescue Exception => e
        user_msg = "에러 발생"
    end
        
        
        result={
            message:{
                text: user_msg
            },
            keyboard: temp_key
        }
        
        render json: result
    end
    
    def friend_add
        user_key = params[:user_key]
    end
    
    def friend_del
        user_key = params[:user_key]
    end
    
    def chat_room
        user_key = params[:user_key]
    end
    
    def init_keybutton
        return "init", @@key.getBtnKey(@@main_menu)
    end
    
    def init_state(user_key)

    if user_key != "init_status"
      @@user[user_key] = 
      {
        :mstep => @mstep = "main",
        :fstep => @fstep = [FUNC_STEP_INIT]
      }
    end

  end
end
