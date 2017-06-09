-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local THEMENAME = 
{
    "OZ",
    "Farm",
    "Love",
    "Mermaid",
    "Sea",
    "Gorilla",
    "Jones"
}

local SpinApp = class("SpinApp", cc.load("mvc").AppBase)
function SpinApp:ctor()
end

function SpinApp:startTheme(themeId)
    local themeTag = THEMENAME[themeId]
    self.theme = bole:getEntity(string.format("app.theme.Theme_%s", themeTag), themeId, self)
    self.theme:run()
end

function SpinApp:enterThemeData(data)
    self.theme:setThemeData(data)
end

function SpinApp:getTheme()
    return self.theme
end

function SpinApp:isThemeAlive()
    if self.theme and not self.theme.isDead then
        return true
    else
        return false
    end
end

function SpinApp:getThemeName()
    return self.theme:getThemeName()
end

function SpinApp:addMiniGame(view)
    self.theme:addMiniGame(view)
end

function SpinApp:addDialog()
    self.theme:addDialog(view)
end

return SpinApp
-- endregion
