require 'msgmaker'

class KakaoController < ApplicationController
    @@key = Msgmaker::Keyboard.new
    @@msg = Msgmaker::Message.new
    
    @@user = {}
    
    MENU_STEP_INTRO =     "경기 일정"
    MENU_STEP_RESULTS =   "경기 결과"
    MENU_STEP_NEWS =      "최신 뉴스"
    MENU_STEP_PLAYER =    "선수 검색"
    
    @@main_menu = [MENU_STEP_INTRO, MENU_STEP_RESULTS,
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
    
end
