------------------------------------------------------------------------
local AudioManage = class("AudioManage")

local AUDIO_STOP = "stop"
local AUDIO_PAUSE = "pause"
local AUDIO_RESUME = "resume"
local AUDIO_UNCACHE = "uncache"
local AUDIO_CHANGE = "volumeChange"

function AudioManage:ctor()
    self.ids = { }
    self.spin_list = { }
    self.isSpinLoop = false
    self.node = nil
    self.theme_id = 0
    self:initThemeAudio(1)
    self._music=true
    self._sound=true
    self._musicVolume=1.0
    self._soundVolume=1.0
    self.idsAche={}
end

function AudioManage:initListener()
    bole:addListener("audio_win", self.playWin, self, nil, true)
    bole:addListener("audio_play_spin", self.playSpin, self, nil, true)
    bole:addListener("audio_stop_spin", self.stopSpin, self, nil, true)
    bole:addListener("audio_link", self.playLink, self, nil, true)
    bole:addListener("audio_reel_stop", self.playReels, self, nil, true)
    bole:addListener("audio_stop_all_spin", self.stopAllSpin, self, nil, true)
    bole:addListener("audio_prompt", self.audioPrompt, self, nil, true)
    bole:addListener("audio_prompt_success", self.audioPromptSuccess, self, nil, true)
end
function AudioManage:removeListener()
    bole:getEventCenter():removeEventWithTarget("audio_win", self)
    bole:getEventCenter():removeEventWithTarget("audio_play_spin", self)
    bole:getEventCenter():removeEventWithTarget("audio_stop_spin", self)
    bole:getEventCenter():removeEventWithTarget("audio_link", self)
    bole:getEventCenter():removeEventWithTarget("audio_reel_stop", self)
    bole:getEventCenter():removeEventWithTarget("audio_stop_all_spin", self)
    bole:getEventCenter():removeEventWithTarget("audio_prompt", self)
    bole:getEventCenter():removeEventWithTarget("audio_prompt_success", self)
end
function AudioManage:initThemeAudio(theme_id)
    self.theme_id =theme_id
    local data = self:getConfigByName("theme", self.theme_id)

    self.playSpinFile = "oz_spin"
    self.playWinFile = data.win_sound
    self.playReelsFile = data.stop_sound
    --self:loadAudio({"sound/oz_success.ogg"})
end

function AudioManage:isMusic()
    return self._music
end

function AudioManage:isSound()
    return self._sound
end

function AudioManage:setMusic(music)
    self._music = music
    for key_id, _ in pairs(self.ids) do
        if music then
            self:resumeAudio(key_id)
        else
            self:stopAudio(key_id)
        end
    end
end

function AudioManage:setSound(sound)
    self._sound=sound
end

function AudioManage:setMusicVolume(music)
    self._musicVolume=music
    for key_id, _ in pairs(self.ids) do
        self:volumeSliderChangedEvent(key_id,music)
    end
end

function AudioManage:setSoundVolume(sound)
    self._soundVolume=sound
end

function AudioManage:getMusicVolume()
    return self._musicVolume
end

function AudioManage:getSoundVolume()
    return self._soundVolume
end

function AudioManage:getFilePatch(file)
    if not file then
        print("getFilePatch error")
        return ""
    end
    return bole:getThemePath(self.theme_id, "sound/" .. file .. ".ogg")
end

function AudioManage:playSpin()
    if not self._music then return end
    self.spin_list = { }
    local file = self.playSpinFile
    self.isSpinLoop = true
    xpcall( function()
        if self.node and self.node:getReferenceCount() > 0 then
            self.node:stopAllActions()
            self.node = nil
        else
            self.node = nil
        end
    end , function()
        self.node = nil
    end )

    if self.ids[file] then
        self:volumeSliderChangedEvent(file, 1)
        return
    end
    self.ids[file] = ccexp.AudioEngine:play2d(self:getFilePatch(file), false, self._musicVolume)
    local function finishCallback(audioID, filePath)
        print("---------------------filePath" .. filePath)
        self.ids[file] = nil
        if self.isSpinLoop then
            self:playSpin(file)
        end
    end
    print("---------------------self.ids[file]" .. file)
    ccexp.AudioEngine:setFinishCallback(self.ids[file], finishCallback)
end

function AudioManage:stopSpin()
    for _, v in pairs(self.spin_list) do
        self:stopAudio(v)
    end

    local file = self.playSpinFile
    if not self.isSpinLoop then return end
    self.isSpinLoop = false
    if not self.ids[file] then
        print("playDelAudio-not audio file:" .. file)
        return
    end
    local volume = 1.0
    local function callback()
        volume = volume - 0.1
        self:volumeSliderChangedEvent(file, volume)
    end
    --    local curTime = ccexp.AudioEngine:getDuration(self.ids[file])
    --    local lenTime = ccexp.AudioEngine:getCurrentTime(self.ids[file])
    --    print("time="..curTime.."/"..lenTime)
    local sequence = cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(callback))
    local act1 = cc.Repeat:create(sequence, 10)
    local act2 = cc.Sequence:create(cc.DelayTime:create(3), act1)
    if self.node and self.node:getReferenceCount() > 0 then
        self.node:stopAllActions()
        self.node:runAction(act2)
    else
        self.node = cc.Node:create()
        display.getRunningScene():addChild(self.node)
        self.node:runAction(act2)
    end
end
function AudioManage:stopAllSpin()
    self.isSpinLoop = false
    self:volumeSliderChangedEvent(self.playSpinFile, 0)
    if self.node and self.node:getReferenceCount() > 0 then
        self.node:stopAllActions()
        self.node = nil
    else
        self.node = nil
    end
end
function AudioManage:changeSpin()

end
function AudioManage:isFreeSipn()

end
function AudioManage:playWin(event)
    local theme_id = event.result.themeId
    local win_lines = event.result.win_lines
    self:playPraise(win_lines)
end

function AudioManage:playPraise(winLines)
    local theme = bole:getSpinApp():getTheme()
    local name = theme:getThemeName()
    local praise = self:getPraise(winLines)
    local data = self:getConfigByName(name.."_praise")
    local len = 100
    for i = 1, len do
        local min = data[tostring(i)]
        local max = data[tostring(i + 1)]
        if min then
            -- 没有达到最小值
            if praise < min.praise then
                return
            end
            -- 超过最大值
            if not max then
                self:playEff(min.sound)
                return
            end
            -- 正常范围
            if praise > min.praise and praise < max.praise then
                self:playEff(min.sound)
                return
            end
        else
            return
        end
    end
end
-- 获取赞叹值和判断是否播放胜利音效
function AudioManage:getPraise(winLines)
    local theme = bole:getSpinApp():getTheme()
    local name = theme:getThemeName()
    local praise = 0
    print("-----------------name:"..name)
    local data = self:getConfigByName(name.."_praise_value")
    local isPlayWin = false
    for _, v in ipairs(winLines) do
        for nk, nv in pairs(data) do
            if v.feature == 0 and #v.icons == nv.number then
                isPlayWin = true
                praise = praise + nv.praise_value
            end
        end
    end

    if isPlayWin then
        -- 打断背景音乐
        if self:isFreeSipn() then
            self:volumeSliderChangedEvent(self.playSpinFile, 0.7)
        else
            self:stopAllSpin()
        end
        -- 胜利音效
        self:playEff(self.playWinFile)
    end

    return praise
end

function AudioManage:playLink(event)
    print("-----------------------------event.result:" .. event.result)
    local theme = bole:getSpinApp():getTheme()
    local name = theme:getThemeName()
    local data = self:getConfigByName(name.."_link", event.result)
    if data then
        self:playEff(data.symbol_resource)
    end
end
function AudioManage:playReels()
    self:playEff(self.playReelsFile)
end

function AudioManage:audioPrompt(event)
    local data = event.result
    if not data then return end
    for _, v in ipairs(data) do
        self:playMusic(v, false)
        self.spin_list[v] = self.ids[v]
    end
end

function AudioManage:audioPromptSuccess(event)
    local data = event.result
    if not data then return end
    self:playMusic(data, false)
    self.spin_list[data] = self.ids[data]
end

-- 保存id
function AudioManage:saveId(file, audio_id)
    if self.ids[file] then
        local isInit = false
        if type(self.ids[file]) == "table" then
            for _, v in pairs(self.ids[file]) do
                if v then
                    isInit = true
                end
            end
        end
        if isInit then
            if type(self.ids[file]) == "number" then
                -- 第一次number转成table
                local old_id = self.ids[file]
                self.ids[file] = { }
                self.ids[file][old_id] = true
            end
            self.ids[file][audio_id] = true
        else
            -- 空table转会number
            self.ids[file] = audio_id
        end
    else
        self.ids[file] = audio_id
    end
end
-- 播放需要记录状态的音乐音效
function AudioManage:playMusic(file, isloop)
    if not self._music then return end
    local audio_id = ccexp.AudioEngine:play2d(self:getFilePatch(file), isloop, self._musicVolume)
    self:saveId(file, audio_id)
    local function finishCallback(audioID, filePath)
        if type(self.ids[file]) == "number" then
            self.ids[file] = nil
        elseif type(self.ids[file]) == "table" then
            if audio_id and self.ids[file][audioID] then
                self.ids[file][audioID] = nil
            end
        end
    end

    if not isloop then
        ccexp.AudioEngine:setFinishCallback(self.ids[file], finishCallback)
    end
end
-- 简易播放音效
function AudioManage:playEff(file)
    if not self._sound then return end
    ccexp.AudioEngine:play2d(self:getFilePatch(file),false,self._soundVolume)
end
function AudioManage:stopAudio(file)
    self:toAction(file, AUDIO_STOP)
end

function AudioManage:pauseAudio(file)
    self:toAction(file, AUDIO_PAUSE)
end

function AudioManage:resumeAudio(file)
end
function AudioManage:uncache(file)
    self:toAction(file, AUDIO_UNCACHE)
end

function AudioManage:volumeSliderChangedEvent(file, volume)
    self:toAction(file, AUDIO_CHANGE, volume)
end

function AudioManage:toAction(file, act, data)
    if not self.ids[file] then
        print("AudioManage:toAction not audio file:" .. file .. "--action=" .. act)
        return
    end

    if type(self.ids[file]) == "number" then
        if act == AUDIO_STOP then
            ccexp.AudioEngine:stop(self.ids[file])
        elseif act == AUDIO_PAUSE then
            ccexp.AudioEngine:pause(self.ids[file])
        elseif act == AUDIO_RESUME then
            ccexp.AudioEngine:resume(self.ids[file])
        elseif act == AUDIO_UNCACHE then
            ccexp.AudioEngine:uncache(self.ids[file])
        elseif act == AUDIO_CHANGE then
            ccexp.AudioEngine:setVolume(self.ids[file], data)
        end

    elseif type(self.ids[file]) == "table" then
        for key_id, value_init in pairs(self.ids[file]) do
            if value_init then
                if act == AUDIO_STOP then
                    ccexp.AudioEngine:stop(key_id)
                elseif act == AUDIO_PAUSE then
                    ccexp.AudioEngine:pause(key_id)
                elseif act == AUDIO_RESUME then
                    ccexp.AudioEngine:resume(key_id)
                elseif act == AUDIO_UNCACHE then
                    ccexp.AudioEngine:uncache(key_id)
                elseif act == AUDIO_CHANGE then
                    ccexp.AudioEngine:setVolume(key_id, data)
                end
            end
        end
    end
    if act == AUDIO_STOP then
        self.ids[file] = nil
    elseif act == AUDIO_UNCACHE then
        self.ids[file] = nil
    end
end
function AudioManage:uncacheAll()
    ccexp.AudioEngine:uncacheAll()
    self.ids = nil
    self.ids = { }
end

function AudioManage:loadAudio(...)
    for _, v in ipairs(...) do
        ccexp.AudioEngine:preload(v)
    end
end
function AudioManage:getConfigByName(name, id, key)
    return bole:getConfigCenter():getConfig(name, id, key)
end
return AudioManage