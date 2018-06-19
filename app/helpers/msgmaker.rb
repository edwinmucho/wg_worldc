module Msgmaker
     class Keyboard

        def getTextKey

            json = {
                "type": "text"
            }
            return json
        end
        
        def getBtnKey(*arg)

            json = {
              "type": "buttons",
                "buttons": []
            }

            arg.each do |a|
                json[:buttons] = a
            end

            return json

        end


    end

    class Message

        def getMessage(text)
            json = {
                "text": "#{text}"
            }
            return json
        end

        def getPicMessage(text,photo_url)

            json = {
                "text": text,
                "photo": {
                    "url": photo_url,
                    "width": 960,
                    "height": 960

                }
            }

            return json

        end

        def getLinkBtn(label, url)
            json = {
                "message_button":{
                    "label": label,
                    "url": url
                }
            }
        end
        
        def getMessageBtn(text,label,url)
            json = {
                "text": text,
                "message_button":{
                    "label": label,
                    "url": url
                }
            }
        end
        
        def getPictureBtn(photo_url,label,url)
            json = {
                "photo":{
                    "url": photo_url,
                    "width": 640,
                    "height": 480
                },
                "message_button":{
                    "label": label,
                    "url": url
                }
            }
        end
        
        def getMsgPicBtn(text,photo_url,label,url)
            json = {
                "text": text,
                "photo":{
                    "url": photo_url,
                    "width": 640,
                    "height": 480
                },
                "message_button":{
                    "label": label,
                    "url": url
                }
            }
        end
    end

    class Data
        def getHighlight
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
            return daum_highlight
        end
        
        def getCheerMsg(team)
            msg = [
                "(꺄아)\n\"#{team}팀의 선전을 기원합니다아아!\"",
                "(빠직)\n\"나는 #{team}의 월드컵 탈락은 반댈세!!\"",
                "(감동)\n\"#{team}팀 우승은 운명의 데스티니!\"",
                "(하트뿅)\n\"우승 트로피를 든 #{team} 모습! 내맘 속에 저~ 장~!\"",
                "(푸하하)\n\"따르릉 따르릉~ 전화와써여~ \n#{team} 이겼다고 전화와써여~\"",
                "(컴온)\n\"#{team} 우승 오져따리~\"",
                "(심각)\n\"#{team}! 열심히 디벨롭 하고 어레인지 하고 우승을 개런티 할수 있게 각자 자기 위치에서 인볼브 하도록!!\"",
                "(씨익)\n\"지난 일은 잊고 Team #{team}만 생각해!"
            ]
            return msg.sample(1)[0]
        end
        
        def getFlagEmoji
            nation_flag = {"러시아"=>"🇷🇺",    "우루과이"=>"🇺🇾",  "이집트"=>"🇪🇬",    "사우디아라비아"=>"🇸🇦",
                     "이란"=>"🇮🇷",      "스페인"=>"🇪🇸",    "포르투갈"=>"🇵🇹",  "모로코"=>"🇲🇦",
                     "프랑스"=>"🇫🇷",    "덴마크"=> "🇩🇰",   "호주"=> "🇦🇺",     "페루"=>"🇵🇪",
                     "크로아티아"=>"🇭🇷","아르헨티나"=>"🇦🇷","아이슬란드"=>"🇮🇸","나이지리아"=>"🇳🇬",
                     "브라질"=>"🇧🇷",    "스위스"=>"🇨🇭",    "코스타리카"=>"🇨🇷","세르비아"=>"🇷🇸",
                     "독일"=>"🇩🇪",      "멕시코"=>"🇲🇽",    "스웨덴"=>"🇸🇪",    "대한민국"=>"🇰🇷",
                     "벨기에"=>"🇧🇪",    "파나마"=>"🇵🇦",    "잉글랜드"=>"🏴",    "튀니지"=>"🇹🇳",
                     "폴란드"=>"🇵🇱",    "세네갈"=>"🇸🇳",    "콜롬비아"=>"🇨🇴",  "일본"=>"🇯🇵"
            }  
            return nation_flag
        end
        
        def getTeamMenu(user, btn)
            nation_flag = getFlagEmoji
            
            menu_btn = ["#{btn[0]} #{user.country.name} #{nation_flag[user.country.name]}",
                  "[#{user.country.name}] #{btn[1]}",
                  "[#{user.country.name}] #{btn[2]}", 
                  "[#{user.country.name}] #{btn[3]}", 
                  btn[4], 
                  btn[5]]
            return menu_btn
        end
    end

end
