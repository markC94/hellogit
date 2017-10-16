SocketSTATE = {
	close = 0,
	connected = 1,
}

MessageType = {
	socket_open = 2,
	socket_message = 3,
	socket_error = 4,
	socket_close = 5,
	download = 6,
	enter_background = 7,
	enter_foreground = 8,

    EVENT_BLMESSAGE = 10001,
}


Socket = {}


function Socket:create()
	self.state = SocketSTATE.close

	self.cmdMap = {}
    self.delegates = {}
    self.stopSecondRecords = {}

	self.socket = cc.BLSocket:getInstance()
	local function callback(t, data)
		self:recv(t, data)
	end
	ScriptHandlerMgr:getInstance():registerScriptHandler(self.socket, callback, MessageType.EVENT_BLMESSAGE)

    local function appEnterBackgroundCallback()
        bole.pause_time = os.time()
    end
    ScriptHandlerMgr:getInstance():registerScriptHandler(cc.AppInfo:getInstance(), appEnterBackgroundCallback, MessageType.enter_background)

    local function appEnterForegroundCallback()
        if bole.pause_time then
            bole.resume_time = os.time() - bole.pause_time
        end
    end
    ScriptHandlerMgr:getInstance():registerScriptHandler(cc.AppInfo:getInstance(), appEnterForegroundCallback, MessageType.enter_foreground)
end

function Socket:isEmptyDelegate()
    local flag = true
    for _, v in pairs(self.delegates) do
        flag = false
        break
    end
    return flag
end

function Socket:registerCmd(id, callback, param)
	if callback then
		self.cmdMap[id] = {callback, param}
	end
end

function Socket:unregisterCmd(id)
	if self.cmdMap[id] then
		self.cmdMap[id] = nil
	end
end

function Socket:connect()
    release_print("Socket:connect")
    self.socket:init(SERVER_IP, SERVER_PORT)
end

function Socket:isConnected()
	return self.state == SocketSTATE.connected
end

function Socket:send(...)
    local data = {...}
    dump(data, "Socket:send")
	if self.state == SocketSTATE.connected then
        local msgId = data[1]
        local isNeedToCheck = data[3]
        if isNeedToCheck then
            data[3] = nil
        end

        if self.stopSecondRecords[msgId] then
            return
        end

		self.socket:sendTable(data)

        if isNeedToCheck then
            self.stopSecondRecords[msgId] = true
        end
	end
end

function Socket:oncmd(data)
    local id = data[1]
	if self.cmdMap[id] then
		local func = self.cmdMap[id][1]
		local param = self.cmdMap[id][2]
		if param then 
			func(param, id, data[2])
		else
			func(id, data[2])
		end
	end

    if id == "error" then
        self.stopSecondRecords = {}
        if bole.postEvent then
            bole:postEvent("sendMsgError")
        end
    else
        self.stopSecondRecords[id] = nil
    end
end

function Socket:onStateChange(id, data)
    self.stopSecondRecords = {}
	for k, v in pairs(self.delegates) do
		v(k, id, data)
	end
end

function Socket:recv(t, data)
    if dump then
        dump(data, "socketRecvData cmd=" .. t, 3)
    end

    if t == MessageType.socket_message then
		self:oncmd(data)
	else
		if t == MessageType.socket_open then
			self.state = SocketSTATE.connected
		else
			self.state = SocketSTATE.close
		end
		self:onStateChange(t, data)
	end
end

function Socket:registerDelegate(id, callback)
	self.delegates[id] = callback
end

function Socket:unregisterDelegate(id)
	if self.delegates[id] then
		self.delegates[id] = nil
	end
end

function Socket:close()
	self.socket:closeSkt()
end








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