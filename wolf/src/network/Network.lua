local SocketSTATE = {
	close = 0,
	connected = 1,
}

local SOCKET_EVENT = 11

local MessageType = {
	socket_open = 2,
	socket_message = 3,
	socket_error = 4,
	socket_close = 5,
	download = 6,
	enter_background = 7,
	enter_foreground = 8,

    EVENT_BLMESSAGE = 10001,
}

cc.exports.SocketSTATE = SocketSTATE
cc.exports.MessageType = MessageType

--[[
local ConnectLost = class("ConnectLost")
function ConnectLost:ctor()
    -- body
    self._instance=nil
    self.dialog = nil
end

function ConnectLost:getInstance( ... )
	-- body
	if not self._instance then
		self._instance = ConnectLost.new()
	end
	return self._instance
end

function ConnectLost:show()
	-- body
	log.d("ConnectLost:show")
	if not self.dialog then
		if cc.Director:getInstance():getRunningScene() then
			self.dialog = ConnectLostDialog.new()
			self.dialog:show()
			-- LoginControl:getInstance():addMixPanelLog("10ERROR")

			AddLogControl:getInstance():addLog( 
				{TARGET_STR_MIXPANEL} ,
				{[TARGET_STR_MIXPANEL] = "10ERROR"}
			)

			log.d("new dialog")
		else
			TimerCallFunc:getInstance():addCallFunc(self.show, 0.5, self, self)
		end
    else
        if self.dialog.show then
		    self.dialog:show()
        end
		log.d("show dialog")
	end
end

function ConnectLost:onStateChange( t, data)
	-- body
	log.d("connect state change",t)
	if t == MessageType.socket_open or t == MessageType.socket_message then
		if self.dialog then
			-- if self.dialog.hide then
			-- 	self.dialog:hide()
			-- end
			self.dialog = nil
		end
	elseif t == MessageType.socket_error or t == MessageType.socket_close then
		self:show()
	end
end
--]]


local Socket = {}

function Socket:onCreate(server, port)
	self.server = server
	self.port = port or 80
	self.state = SocketSTATE.close
	self.cmdMap = {}
    self.delegates = {}
    --[[
	self.delegates = {
		[ConnectLost:getInstance()] = ConnectLost:getInstance().onStateChange
	}
    ]]
	self.socket = cc.BLSocket:getInstance()
	local function callback( t, data )
		self:recv(t,data)
	end
    self.stopSecondRecords = {}
	ScriptHandlerMgr:getInstance():registerScriptHandler(self.socket,callback,MessageType.EVENT_BLMESSAGE)
end

function Socket:registerCmd( id, callback, param)
	if callback then
--		if self.cmdMap[id] then
--			--log.i("duplicated cmd ",id)
--		end
		self.cmdMap[id] = {callback,param}
	end
end
function Socket:unregisterCmd( id)
	-- body
	if self.cmdMap[id] then
		self.cmdMap[id] = nil
	end
end

function Socket:connect()
    print("Socket:connect")
    self.socket:init(self.server, self.port)
end

function Socket:isConnected( ... )
	-- body
	return self.state == SocketSTATE.connected
end

function Socket:send(...)
	if self.state == SocketSTATE.connected then
        local data = {...}
        local msgId = data[1]
        local isNeedToCheck = data[3]
        if isNeedToCheck then
            data[3] = nil
        end

        if self.stopSecondRecords[msgId] then
            return
        end

--		if #data == 1 and type(data[1]) == "table" then
--			data = data[1]
--		end
        
		--log.d("socket send", data)
		self.socket:sendTable(data)

        if isNeedToCheck then
            self.stopSecondRecords[msgId] = true
        end
	end
end

function Socket:oncmd(data)
	-- log.d("socket on cmd ",data) --,self.cmdMap[id])
    local id = data[1]
	if self.cmdMap[id] then
		local func = self.cmdMap[id][1]
		local param = self.cmdMap[id][2]
		if param then 
			func(param, id, data[2])
		else
			func(id, data[2])
		end
        --[[
	elseif id == "force_facebook_logout"  then
		FacebookLoginScene.new():run()
		local d = Dialog.new("You were be kicked out by another device")
		d:show()
		-- self.socket:closeSkt()
	else
		log.d("unhandle cmd ",data)
        ]]
	end

    if id == "error" then
        self.stopSecondRecords = {}
    else
        self.stopSecondRecords[id] = nil
    end
end

function Socket:onStateChange( type, data)
	-- body
	--log.d("type, data",type,data)
    self.stopSecondRecords = {}
	for k,v in pairs(self.delegates) do
		v(k, type, data)
	end
end

local MAX_RELOGIN_INTERVAL = 3
function Socket:recv(t, data)
    dump(data, "socketRecvData cmd=" .. t, 3)
	if t == MessageType.enter_background then
		--LoginControl:getInstance():onEnterBackground()
	elseif t == MessageType.enter_foreground then
		--LoginControl:getInstance():onEnterForeground()
	elseif t == MessageType.socket_message then
		self:oncmd(data)
		--ConnectLost:getInstance():onStateChange(t)
	else
		if t==MessageType.socket_open then --open
			self.state = SocketSTATE.connected
		elseif t == MessageType.socket_error then
			self.state = SocketSTATE.close
		elseif t == MessageType.socket_close then
			self.state = SocketSTATE.close
		else
			--log.i("unknow message type",t, data)
		end
        --[[
		local time = LoginControl:getInstance().enterForegroundTime
		if time then
		 	if self.state == SocketSTATE.close and os.time() - time < MAX_RELOGIN_INTERVAL then
		 		LoginControl:getInstance():relogin()
		 		LoginControl:getInstance().enterForegroundTime = nil
		 		return
		 	end
		 	if os.time() - time >= MAX_RELOGIN_INTERVAL then
			 	LoginControl:getInstance().enterForegroundTime = nil
			end
		end
        ]]
		self:onStateChange(t, data)
	end
	
end

function Socket:registerDelegate(id, callback)
	if self.delegates[id] then
		--log.i("duplicated register socket state", id, callback)
	end
	self.delegates[id] = callback
end

function Socket:unregisterDelegate(id)
	if self.delegates[id] then
		self.delegates[id]  = nil
	else
		--log.i("socket delegate already be deleted",id)
	end
end


function Socket:close()
	self.socket:closeSkt()
end

return Socket

