require 'nokogiri'
require 'open-uri'
require 'rest-client'
require 'awesome_print'
require "json"

module Jsonmaker
    class Crawling
        def schedule
            url = "https://sports.news.naver.com/wfootball/schedule/index.nhn?category=russia2018&date=20180615"
            doc = getdata(url)
            raw_data = doc.css('body').to_s
            
            data = raw_data.scan(/event.russia2018.schedule.SchedulePage(?>[^$])*[^\']}}/)[0]
            data = data.scan(/monthlyScheduleModel: {(?>[^$])*[^\']/)[0]
            data = data.scan(/{(?>[^$])*[^\']}}/)[0]
            
            # data 있는지 확인 필요.
            parsed = JSON.parse(data)
            
            return parsed
        end
        
        def group
            url = "https://sports.news.naver.com/wfootball/schedule/russia2018GroupSchedule.nhn"        
            doc = getdata(url)
            raw_data = doc.css('p').to_s

            data = raw_data.gsub(/<\/?p>/,"")
            parsed = JSON.parse(data)
            
            return parsed
        end

        # private
        def getdata(url)
            uri = URI.encode(url)
            doc = Nokogiri::HTML(open(uri),nil,'utf-8')
            return doc
        end
    end
end