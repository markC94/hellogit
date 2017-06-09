--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local  languageControl =class("languageControl")
local LANGUAGE_EN=0
local LANGUAGE_CH=1
function  languageControl:ctor()
    self.languageDatas={}
    self.language=LANGUAGE_EN
end
--设置当前语言
function languageControl:setLanguage(language)
    self.language=language
end
--获取当前语言
function languageControl:getLanguage()
    return self.language
end
--实时修改语言发送通知
function languageControl:postUpdateLanguage()
    bole:postEvent("update_language",self.language)
end
--绑定UI控件与多语言
function languageControl:toBinding(node,id)
    if not node then return end
    if tolua.type(node)=="ccui.Text" then
        if not id then
            id=node:getString()
        end
        node:setString(self:getContent(id))
    elseif tolua.type(node)=="ccui.Button" then
         if not id then
            id=node:getTitleText()
        end
        node:setTitleText(self:getContent(id))
    elseif tolua.type(node)=="ccui.TextBMFont" then
        
    elseif tolua.type(node)=="ccui.TextField" then
        
    end
end
--获取多语言内容ln
function languageControl:getContent(id)
    if not self.languageDatas[id] then
        return id
    else
        return self.languageDatas[id]
    end
end
--递归自动绑定
function languageControl:autoConvert(node)
    local childs=node:getChildren()
    for _,v in ipairs(childs) do
        self:autoConvert(v)
    end
    self:toBinding(node)
end
return languageControl
--endregion
