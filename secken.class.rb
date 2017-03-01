require 'uri'
require 'digest/sha1' 
require 'net/http'
require 'openssl'
class Secken
	@@app_id = ""
	@@app_key =""
	BASE_URL="https://api.sdk.yangcong.com/"
	QRCODE_FOR_AUTH ="qrcode_for_auth"
	EVENT_RESULT="event_result"
	REALTIME_AUTH="realtime_authorization"
	CHECK_AUTHTOKEN="query_auth_token"

	def initialize(app_id,app_key)
        @@app_id=app_id
        @@app_key=app_key
	end	

	def getQrCode(auth_type=1,action_type='',action_details='',callback='')
		@data={}
		@data['app_id']         = @@app_id
        @data['auth_type']      = auth_type
        @data['action_type']    = URI.escape(action_type) if !action_type.empty?
        @data['action_details'] = URI.escape(action_details) if !action_details.empty?
        @data['callback']       = URI.escape(callback) if !callback.empty?
		
		@data['signature'] = getSignature(@data)
	    #puts @param['signature']
		@url = createGetUrl(QRCODE_FOR_AUTH,@data)
		request(@url)
        
	end

	def askPushAuth(uid, auth_type = 1,action_type = '',action_details = '',callback='')
        data={}
        data['app_id']    = @@app_id
        data['uid']       = uid
		data['auth_type'] = auth_type
        data['action_type']=action_type  if !action_type.empty?
		data['action_details']=action_details if !action_details.empty?
		data['callback']= URI.escape(callback)
		data['signature']=getSignature(data)
        url=createGetUrl(REALTIME_AUTH,data)
		request(url,'POST',data)
	end	

	def getSignature(params)
		@str    = ''
		@params = params.sort
		@params.each{|key,val|
			#puts "#{key}:#{val}"
		    @str="#{@str}#{key}=#{val}" 
		}
	    Digest::SHA1.hexdigest("#{@str}#{@@app_key}")
	end

	private

	def createGetUrl(action_url,data)
		@encode_str = URI.encode_www_form(data)
        "#{BASE_URL}#{action_url}?#{@encode_str}"
	end	

	def request(url,mothod='GET',data={})
		#puts url
        return false if mothod!='GET' and mothod!='POST'
		uri = URI.parse(url)
        #uri.query = URI.encode_www_form(data)
        _http = Net::HTTP.new uri.host, uri.port
	
		if uri.scheme == 'https'
            _http.verify_mode = OpenSSL::SSL::VERIFY_NONE
            _http.use_ssl = true
        end

        begin
			if mothod=='GET'
                request = Net::HTTP::Get.new(uri.request_uri)
            elsif mothod=='POST'
                request = Net::HTTP::Post.new(uri.request_uri)
				#request.body = data.to_json
				request.set_form_data(data)
			end
            request['Content-Type'] = 'application/json;charset=utf-8'
            request['User-Agent'] = 'Mozilla/5.0 (Windows NT 5.1; rv:29.0) Gecko/20100101 Firefox/29.0'
			#puts request
            response = _http.start { |http| http.request request }
            puts response.body.inspect
            puts JSON.parse response.body
        rescue
			puts 'error'
        end
	end

	
end

app_id="IXgdZ1A7CFUej2ytUbVjFJKS5ICiorw4"
app_key="ELD0DNzMYep7m6Uo1v3v"
sec=Secken.new(app_id,app_key)
#sec.getQrCode(1,'','','')
sec.askPushAuth('37rangers',1,'test1','test2','http://www.37rangers.com/callback/index')
