------------------------------------------------------------------------
local AudioManage = class("AudioManage")

local AUDIO_STOP = "stop"
local AUDIO_PAUSE = "pause"
local AUDIO_RESUME = "resume"
local AUDIO_UNCACHE = "uncache"
local AUDIO_CHANGE = "volumeChange"
-- static void setLoop(int audioID, bool loop);
-- static bool isLoop(int audioID);
-- static bool setCurrentTime(int audioID, float sec);
-- static float getCurrentTime(int audioID);
-- static float getDuration(int audioID);
-- static AudioState getState(int audioID);
-- static void setFinishCallback(int audioID, const std::function<void(int,const std::string&)>& callback);
function AudioManage:ctor()
    self.ids = { }
    self.spin_list = { }
    self.stop_list = { }
    self.only_list = { }
    self.theme_id = 0
    local userDefault = cc.UserDefault:getInstance()
    self._music = userDefault:getBoolForKey("audio_music", true)
    self._sound = userDefault:getBoolForKey("audio_sound", true)
    if self._music then
        self._musicVolume = 1.0
    else
        self._musicVolume = 0
    end
    if self._sound then
        self._soundVolume = 1.0
    else
        self._soundVolume = 0
    end

    self.playSpinVolume = self._musicVolume
    self.idsAche = { }

    self.playLobbyFile = "backgroundmusic"
    self.playLongHurnFile = "w_ mammothrun"
end

function AudioManage:initListener()
    bole:addListener("audio_play_spin", self.onLogicSpin, self, nil, true)
    -- 普通滚轮开始
    bole:addListener("audio_stop_spin", self.stopSpin, self, nil, true)
    -- 全部滚轮
    bole:addListener("audio_reel_stop", self.playReels, self, nil, true)
    -- 每一个滚轮
    bole:addListener("audio_prompt", self.audioPrompt, self, nil, true)
    bole:addListener("audio_prompt_success", self.audioPromptSuccess, self, nil, true)
end 
function AudioManage:removeListener()
    bole:getEventCenter():removeEventWithTarget("audio_play_spin", self)
    bole:getEventCenter():removeEventWithTarget("audio_stop_spin", self)
    bole:getEventCenter():removeEventWithTarget("audio_reel_stop", self)
    bole:getEventCenter():removeEventWithTarget("audio_prompt", self)
    bole:getEventCenter():removeEventWithTarget("audio_prompt_success", self)
end
function AudioManage:initThemeAudio(theme_id)
    self.theme_id = theme_id
    local data = bole:getConfigCenter():getConfig("theme", self.theme_id)
    self.playStopSpinFile = data.stop_sound
    self.playBigWinFile = data.bigwin_soud
    self.playMegaWinFile = data.megawin_sound
    self.playCrazyWinFile = data.crazywin_sound
    self.playAudioSpinFile = data.autospin_sound
    self.playKindFile = data["5ofakind_sound"]
    self.playBigSymbolFile = data.bigsymbol_sound
    self.playEnterThemeFiles = data.title_sound
    self:changeMatrix(101)
    -- self:loadAudio({"sound/oz_success.ogg"})
    self:setThemeUpdate(true)
    self:playEnterTheme()
    self.theme_success_count = 0
    self.theme_fail_count = 0
    if theme_id == 5 or theme_id==7 then
        self.theme_win_file_count = 5
        self.theme_fail_file_count = 3
    elseif theme_id == 6 then
        self.theme_win_file_count = 7
        self.theme_fail_file_count = 3
    elseif theme_id == 8 then
        self.theme_win_file_count = 5
        self.theme_fail_file_count = 0
    else
        self.theme_win_file_count = 0
        self.theme_fail_file_count = 0
    end
end

function AudioManage:setThemeUpdate(isLoop)
    if isLoop then
        if not self.schedulerID then
            local scheduler = cc.Director:getInstance():getScheduler()
            local function update()
                if self.themeUpdate then
                    self:themeUpdate()
                end
            end
            self.schedulerID = scheduler:scheduleScriptFunc(update, 0.1, false)
        end
    else
        if self.schedulerID then
            local scheduler = cc.Director:getInstance():getScheduler()
            scheduler:unscheduleScriptEntry(self.schedulerID)
            self.schedulerID = nil
        end
    end
end

function AudioManage:themeUpdate()
    if self.volumeChange then
        if self.volumeDelay then
            self.volumeDelay = self.volumeDelay - 0.1
            if self.volumeDelay <= 0 then
                self.volumeDelay = nil
            end
            return
        end
        self.playSpinVolume = self.playSpinVolume - self.volumeChange
        if self.playSpinVolume > 0 then
            self:volumeSliderChangedEvent(self.playSpinFile, self.playSpinVolume)
        else
            self.playSpinVolume = 0
            self:volumeSliderChangedEvent(self.playSpinFile, self.playSpinVolume)
            self:stopChangeSpinVolume()
            self:clearSpin()
        end
    end
end

function AudioManage:playLobby()
    self:playMusic(self.playLobbyFile, true)
end

function AudioManage:stopLobby()
    self:stopAudio(self.playLobbyFile)
end

function AudioManage:changeMatrix(matrix_id)
    self.matrix_id = tostring(matrix_id)
end

function AudioManage:playMaxBet()
    local maxbetSoundFile = bole:getSpinApp():getConfig(nil, "matrix", self.matrix_id, "maxbet_sound")
    self:playEff(maxbetSoundFile)
end

function AudioManage:playCommonSpin()
    local commonSpinFile = bole:getSpinApp():getConfig(nil, "matrix", self.matrix_id, "spinbutton_sound")
    self:playEff(commonSpinFile)
end

function AudioManage:playEnterTheme()
    self:stopLobby()
    if not self.playEnterThemeFiles then
        return
    end
    for k, v in ipairs(self.playEnterThemeFiles) do
        self:playMusic(v)
    end
end

function AudioManage:clearEnterTheme()
    if not self.playEnterThemeFiles then
        return
    end
    for k, v in ipairs(self.playEnterThemeFiles) do
        self:stopAudio(v)
    end
end

function AudioManage:playLongHurn()
    self:playMusic(self.playLongHurnFile)
end

function AudioManage:stopLongHurn()
    self:stopAudio(self.playLongHurnFile)
end

function AudioManage:playFeature(data)
    local featrue = data.feature
    if featrue then
        for _, v in ipairs(featrue) do
            self:playFeatureForKey(v, "feature_triggersound")
            break;
        end
    end
end

function AudioManage:playFeatureForKey(feature_id, key)
    local data = bole:getSpinApp():getConfig(nil, "feature")
    if not data then
        print("AudioManage:playFeatureForKey:" .. feature_id .. "---" .. key)
        return
    end
    for k, v in pairs(data) do
        if v.featrue_id == feature_id then
            self:playEff(v[key])
        end
    end
end

function AudioManage:playFeatureForKey(feature_id, key, isLoop)
    local data = bole:getSpinApp():getConfig(nil, "feature")
    if not data then
        print("AudioManage:playFeatureForKey:" .. feature_id .. "---" .. key)
        return
    end
    for k, v in pairs(data) do
        if v.featrue_id == feature_id then
            self:playMusic(v[key], isLoop)
        end
    end
end

function AudioManage:stopFeatureForKey(feature_id, key)
    local data = bole:getSpinApp():getConfig(nil, "feature")
    if not data then
        print("AudioManage:playFeatureForKey:" .. feature_id .. "---" .. key)
        return
    end
    for k, v in pairs(data) do
        if v.featrue_id == feature_id then
            self:stopAudio(v[key])
        end
    end
end

function AudioManage:playAutoSpin()
    self:playEff(self.playAudioSpinFile)
end

function AudioManage:playClickStop()
    self:playEff(self.playStopSpinFile)
end

function AudioManage:playKind()
    self:playEff(self.playKindFile)
end

function AudioManage:playBigWin()
    self:clearSpin()
    self:clearFreeSpin()
    self:playEff(self.playBigWinFile)
end

function AudioManage:playMegaWin()
    self:clearSpin()
    self:clearFreeSpin()
    self:playEff(self.playMegaWinFile)
end

function AudioManage:playCrazyWin()
    self:clearSpin()
    self:clearFreeSpin()
    self:playEff(self.playCrazyWinFile)
end

function AudioManage:setWeild(weild)
    self.isWinWeild = weild
end
function AudioManage:setWin(mult)
    if mult <= 0 then
        return
    end
    self.playMult = mult
end

function AudioManage:playBigSymbol()
    self:clearSpin()
    self:clearFreeSpin()
    local bigsymbolFile = bole:getSpinApp():getConfig(nil, "matrix", self.matrix_id, "bigsymbol_sound")
    local audio_id = self:playEff(bigsymbolFile)
end

function AudioManage:playRandWin()
    self.theme_fail_count = 0
    if self.theme_success_count > 0 then
        self.theme_success_count = 0
        return
    end

    if self.playMult < 3 then
        return
    end

    local flag = math.random(1, 5)
    if flag == 1 then
        self.theme_success_count = 1
        local index = math.random(1, self.theme_win_file_count)
        local str = "n3_" .. index
        self:playEff(str)
    end
end

function AudioManage:playRandFail()
    self.theme_success_count = 0
    self.theme_fail_count = self.theme_fail_count + 1
    if self.theme_fail_count >= 5 then
        self.theme_fail_count = 0
        local index = math.random(1, self.theme_fail_file_count)
        local str = "no_win_" .. index
        self:playEff(str)
    end
end

function AudioManage:tryPlayWin()
    if not self.playMult or self.playMult <= 0 then
        self:playRandFail()
        return false
    end
    self:playRandWin()
    if self.isWinWeild then
        local wildwin_sound = bole:getSpinApp():getConfig(nil, "matrix", self.matrix_id, "wildwin_sound")
        local audio_id = self:playSpinEff(wildwin_sound)
        self.isWinWeild = false
        -- 猩猩主题单独处理
        if self.theme_id ~= 6 then
            self:lowerSpin(audio_id)
            return
        end
    end

    local wins = bole:getSpinApp():getConfig(nil, "matrix", self.matrix_id, "win_sound")
    local win_type = bole:getSpinApp():getConfig(nil, "matrix", self.matrix_id, "winsound_type")
    local win_time = bole:getSpinApp():getConfig(nil, "matrix", self.matrix_id, "win_time")
    local audio_id
    local index = 1
    local file
    if self.playMult < 1 then
        index = 1
    elseif self.playMult >= 1 and self.playMult < 3 then
        index = 2
    elseif self.playMult >= 3 and self.playMult < 6 then
        index = 3
    elseif self.playMult >= 6 then
        index = 4
    end

    if win_type == 1 then
        if wins[index] then
            audio_id = self:playSpinEff(wins[index])
            self:lowerSpin(audio_id)
        end
        self.playMult = nil
    else
        local winTime = win_time[index]
        local win1 = wins[1]
        self.winFile2 = wins[2]
        self:playSpinEff(win1)
        performWithDelay(display.getRunningScene(), function()
            if self.winFile2 then
                self:playEff(self.winFile2)
                self.winFile2 = nil
            end
            self:stopAudio(win1)
        end , winTime)
        self:lowerSpin(nil, winTime)

    end
    return true
end
-- 降低spin音效
function AudioManage:lowerSpin(audio_id, time)
    if self:resumeSpin() then
        self.playSpinVolume = self:getFileVolume(self.playSpinFile) * 0.3
        self:volumeSliderChangedEvent(self.playSpinFile, self.playSpinVolume)
    end
    if self.playFreeSpinFile then
        if self.isFreeSpinPause then
            self.isFreeSpinPause = false
            self:resumeAudio(self.playFreeSpinFile)
        end
        local volume = self:getFileVolume(self.playFreeSpinFile) * 0.3
        self:volumeSliderChangedEvent(self.playFreeSpinFile, volume)
    end

    local function finishCallback(audioID, filePath)
        self:resetLower()
    end
    if audio_id then
        ccexp.AudioEngine:setFinishCallback(audio_id, finishCallback)
    elseif time then
        performWithDelay(display.getRunningScene(), function()
            self:resetLower()
        end , time)
    else

    end
end

function AudioManage:resetLower()
    if self.playSpinFile then
        self.playSpinVolume = self:getFileVolume(self.playSpinFile)
        self:volumeSliderChangedEvent(self.playSpinFile, self.playSpinVolume)
    end
    if self.playFreeSpinFile then
        self:volumeSliderChangedEvent(self.playFreeSpinFile, self:getFileVolume(self.playFreeSpinFile))
    end
end
function AudioManage:playReels()
    self:audioPromptStop()
    local reeldownSoundFile = bole:getSpinApp():getConfig(nil, "matrix", self.matrix_id, "reeldown_sound")
    self:playEff(reeldownSoundFile)
end

function AudioManage:audioPrompt(event)
    local data = event.result
    if not data then return end
    if type(data) == "table" then
        for _, v in ipairs(data) do
            self:playEff(v, 0.3)
        end
    else
        self:playEff(data)
    end

end

function AudioManage:audioPromptSuccess(event)
    local data = event.result
    if not data then return end
    if not self.promptSuccessFile then
        self.promptSuccessFile = data
        self:playMusic(self.promptSuccessFile, false)
    else
        self:volumeSliderChangedEvent(self.promptSuccessFile, self:getFileVolume(self.promptSuccessFile))
        self:resumeAudio(self.promptSuccessFile)
    end
end

function AudioManage:audioPromptStop()
    if self.promptSuccessFile then
        self:volumeSliderChangedEvent(self.promptSuccessFile, 0)
        self:pauseAudio(self.promptSuccessFile)
    end
end

function AudioManage:playFreeSpin()
    self:displaySpinEff()
    self:stopChangeSpinVolume()
    self:clearSpin()
    if self.playFreeSpinFile then
        self:volumeSliderChangedEvent(self.playFreeSpinFile, self:getFileVolume(self.playFreeSpinFile))
        if self.isFreeSpinPause then
            self.isFreeSpinPause = false
            self:resumeAudio(self.playFreeSpinFile)
        end
        return
    end
    local name = bole:getSpinApp():getThemeName()
    self.playFreeSpinFile = bole:getSpinApp():getConfig(nil, "matrix", self.matrix_id, "backgroundmusic")
    print("self.name=" .. name)
    print("self.matrix_id=" .. self.matrix_id)
--    print("self.playFreeSpinFile=" .. self.playFreeSpinFile)
    self:playMusic(self.playFreeSpinFile, true)
end

function AudioManage:clearFreeSpin(isClear)
    if self.playFreeSpinFile then
        if isClear then
            self:stopAudio(self.playFreeSpinFile)
            self.playFreeSpinFile = nil
        else
            self:pauseAudio(self.playFreeSpinFile)
            self.isFreeSpinPause = true
        end
    end
end

function AudioManage:onLogicSpin(event)
    local data = event.result
    local isFreeSpin = data[1]
    local isAutoSpin = data[2]
    self:initSpinData()
    if isFreeSpin then
        self:playFreeSpin()
    else
        if not isAutoSpin then
            self:playCommonSpin()
        end
        self:playSpin()
    end
end


function AudioManage:playAudioOnly(file, factorVolume)
    if self.only_list[file] then
        return
    end
    self.only_list[file] = true
    self:playEff(file, factorVolume)
end
function AudioManage:clearOnly()
    self.only_list = { }
end

function AudioManage:initSpinData()
    self.promptSuccessFile = nil
    self.playMult = nil
    self:clearOnly()
end

function AudioManage:playSpin()
    self:displaySpinEff()
    self:clearFreeSpin(true)
    self:stopChangeSpinVolume()
    if self:resumeSpin() then
        return
    end
    self.playSpinFile = bole:getSpinApp():getConfig(nil, "matrix", self.matrix_id, "backgroundmusic")
    self:playMusic(self.playSpinFile, true)
end

function AudioManage:resumeSpin()
    if self.playSpinFile then
        if self.playSpinVolume ~= self:getFileVolume(self.playSpinFile) then
            self.playSpinVolume = self:getFileVolume(self.playSpinFile)
            self:volumeSliderChangedEvent(self.playSpinFile, self.playSpinVolume)
        end
        if self.isSpinPause then
            self.isSpinPause = false
            self:resumeAudio(self.playSpinFile)
        end
        return true
    end
end

function AudioManage:stopSpin(event)
    self:displayStopnEff()
    if self.playSpinFile then
        self:startChangeSpinVolume()
    end
end

function AudioManage:startChangeSpinVolume(delayTime, speed)
    if self.isSpinPause then
        return
    end
    if self.volumeChange then
        return
    end
    if not delayTime then
        self.volumeDelay = 7
    else
        self.volumeDelay = delayTime
    end
    if not speed then
        speed = 1.0 / 50
    end
    self.volumeChange = self:getFileVolume(self.playSpinFile) * speed
    if self.volumeChange <= 0 then
        self.volumeChange = 0.01
    end
    self.playSpinVolume = self:getFileVolume(self.playSpinFile)
end

function AudioManage:stopChangeSpinVolume()
    self.volumedelay = nil
    self.volumeChange = nil
end

function AudioManage:clearSpin(isClear)
    if self.playSpinFile then
        if isClear then
            self:stopAudio(self.playSpinFile)
            self.playSpinFile = nil
        else
            self:pauseAudio(self.playSpinFile)
            self.isSpinPause = true
        end
    end
end

-- 能被spin打断的音效
function AudioManage:playSpinEff(file)
    if not file then
        return
    end
    local audio_id = self:playMusic(file, false)
    self.spin_list[#self.spin_list + 1] = file
    return audio_id
end

function AudioManage:displaySpinEff()
    for _, v in ipairs(self.spin_list) do
        self:stopAudio(v)
    end
    self.spin_list = { }
    if self.winFile2 then
        self:playEff(self.winFile2)
    end
    self.winFile2 = nil
end

-- 能被stop打断的音效
function AudioManage:playStopnEff(file, factorVolume)
    if not file then
        return
    end
    self:playMusic(file, false, factorVolume)
    self.stop_list[#self.stop_list + 1] = file
end

function AudioManage:displayStopnEff()
    for _, v in pairs(self.stop_list) do
        self:stopAudio(v)
    end
    self.stop_list = { }
    if self.promptSuccessFile then
        self:stopAudio(self.promptSuccessFile)
    end
end

function AudioManage:clearTheme()
    self:clearFreeSpin(true)
    self:clearSpin(true)
    self:displaySpinEff()
    self:displayStopnEff()
    self:clearEnterTheme()
    self:setThemeUpdate(false)
    self:stopAllMusic()
end


-- 简易播放音乐音效
function AudioManage:playAudioOnly(file, factorVolume)
    if self.only_list[file] then
        return
    end
    self.only_list[file] = true
    self:playEff(file, factorVolume)
end
function AudioManage:clearOnly()
    self.only_list = { }
end
-- 简易播放音乐音效
function AudioManage:playEff(file, factorVolume)
    if not self:isAudio(file) then
        return
    end
    if not factorVolume then
        factorVolume = 1
    end
    --    print("--------------------------------------------------------AudioManage:playEff:"..file)
    local audio_id = ccexp.AudioEngine:play2d(self:getFilePatch(file), false, self:getFileVolume(file) * factorVolume)
    return audio_id
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

-- 需要受控制（如：循环、打断、降低调整音量、添加结束回调等操作）的音乐音效播放
function AudioManage:playMusic(file, isloop, factorVolume, func)

    if not self:isAudio(file) then
        return
    end

    if not factorVolume then
        factorVolume = 1
    end
    --    print("--------------------------------------------------------AudioManage:playMusic:"..file)
    local audio_id = ccexp.AudioEngine:play2d(self:getFilePatch(file), isloop, self:getFileVolume(file) * factorVolume)
    self:saveId(file, audio_id)
    local function finishCallback(audioID, filePath)
        if type(self.ids[file]) == "number" then
            self.ids[file] = nil
        elseif type(self.ids[file]) == "table" then
            if audio_id and self.ids[file][audioID] then
                self.ids[file][audioID] = nil
            end
        end
        if func then
            func()
        end
    end

    if not isloop then
        ccexp.AudioEngine:setFinishCallback(audio_id, finishCallback)
    end

    return audio_id
end

function AudioManage:isMusicType(file)
    local s, e = string.find(file, "music")
    if not s or not e then
        return false
    else
        return true
    end
end

function AudioManage:isAudio(file)
    if not file then
        return false
    end
    --    if self:isMusicType(file) then
    --        return self:isMusic()
    --    else
    --        return self:isSound()
    --    end
    return true
end

function AudioManage:getFileVolume(file)
    if self:isMusicType(file) then
        return self:getMusicVolume()
    else
        return self:getSoundVolume()
    end
end

function AudioManage:isMusic()
    return self._music
end

function AudioManage:isSound()
    return self._sound
end

function AudioManage:setMusic(music)
    self._music = music
    if music then
        self:setMusicVolume(1)
    else
        self:setMusicVolume(0)
        self:stopChangeSpinVolume()
    end
    local userDefault = cc.UserDefault:getInstance()
    userDefault:setBoolForKey("audio_music", self._music)
    userDefault:flush()
end

function AudioManage:setSound(sound)
    self._sound = sound
    if sound then
        self:setSoundVolume(1)
    else
        self:setSoundVolume(0)
        self:stopChangeSpinVolume()
    end
    local userDefault = cc.UserDefault:getInstance()
    userDefault:setBoolForKey("audio_sound", self._sound)
    userDefault:flush()
end

function AudioManage:setMusicVolume(music)
    self._musicVolume = music
    for key_id, _ in pairs(self.ids) do
        if self:isMusicType(key_id) then
            self:volumeSliderChangedEvent(key_id, music)
        end
    end
end

function AudioManage:setSoundVolume(sound)
    self._soundVolume = sound
    for key_id, _ in pairs(self.ids) do
        if not self:isMusicType(key_id) then
            self:volumeSliderChangedEvent(key_id, sound)
        end
    end
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
    return bole:getSpinApp():getSound(nil, file)
end

------------------audio_id start
function AudioManage:setCurrentTime(audio_id, sec)
    ccexp.AudioEngine:setCurrentTime(audio_id, sec)
end
function AudioManage:getCurrentTime(audio_id)
    return ccexp.AudioEngine:getCurrentTime(audio_id)
end
function AudioManage:getDuration(audio_id)
    return ccexp.AudioEngine:getDuration(audio_id)
end
function AudioManage:getState(audio_id)
    return ccexp.AudioEngine:getState(audio_id)
end
-------------------audio_id end

-------------------file
function AudioManage:stopAudio(file)
    self:toAction(file, AUDIO_STOP)
end

function AudioManage:pauseAudio(file)
    self:toAction(file, AUDIO_PAUSE)
end

function AudioManage:resumeAudio(file)
    self:toAction(file, AUDIO_RESUME)
end
function AudioManage:uncache(file)
    self:toAction(file, AUDIO_UNCACHE)
end

function AudioManage:stopAllMusic()
    ccexp.AudioEngine:stopAll()
end

function AudioManage:volumeSliderChangedEvent(file, volume)
    self:toAction(file, AUDIO_CHANGE, volume)
end

function AudioManage:toAction(file, act, data)
    if not file then
        print("AudioManage:toAction not audio file:nil")
        return
    end
    if not self.ids[file] then
        print("AudioManage:toAction not audio file:" .. file .. "--action=" .. act)
        return
    end

    if type(self.ids[file]) == "number" then
        if act == AUDIO_STOP then
            ccexp.AudioEngine:setVolume(self.ids[file], 0)
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
                    ccexp.AudioEngine:setVolume(key_id, 0)
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
    return bole:getSpinApp():getConfig(nil, name, id, key)
end
return AudioManage