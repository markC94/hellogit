-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成

local ShowFont = class("ShowFont", cc.Node)
local vertDefaultSource = "\n".."\n" ..
                  "attribute vec4 a_position;\n" ..
                  "attribute vec2 a_texCoord;\n" ..
                  "attribute vec4 a_color;\n\n" ..
                  "\n#ifdef GL_ES\n" .. 
                  "varying lowp vec4 v_fragmentColor;\n" ..
                  "varying mediump vec2 v_texCoord;\n" ..
                  "\n#else\n" ..
                  "varying vec4 v_fragmentColor;" ..
                  "varying vec2 v_texCoord;" ..
                  "\n#endif\n" ..
                  "void main()\n" ..
                  "{\n" .. 
                  "   gl_Position = CC_MVPMatrix * a_position;\n"..
                  "   v_fragmentColor = a_color;\n"..
                  "   v_texCoord = a_texCoord;\n" ..
                  "} \n"



--                    "const vec3 u_outlineColor=vec3(1.0, 0.2, 0.3);\n" ..
--                    "const float u_threshold=1.75;\n" ..
--                    "const float u_radius=0.01;\n" ..
--                    "uniform  vec3 u_outlineColor;\n" ..
--                    "uniform  float u_threshold;\n" ..
--                    "uniform  float u_radius;\n" ..

local fshDefaultSource = [[
varying vec4 v_fragmentColor;  
varying vec2 v_texCoord;  
uniform float outlineSize=0.8;  
uniform vec3 outlineColor=vec3(0.1, 1.0, 0.3);  
uniform vec2 textureSize=vec2(0.1, 0.1);  
uniform vec3 foregroundColor=vec3(0.1, 0.3, 0.5);  
  
const float cosArray[12] = {1, 0.866, 0.5, 0, -0.5, -0.866, -0.1, -0.866, -0.5, 0, 0.5, 0.866};  
const float sinArray[12] = {0, 0.5, 0.866, 1, 0.866, 0.5, 0, -0.5, -0.866, -1, -0.866, -0.5};  
  
int getIsStrokeWithAngelIndex(int index)  
{  
    int stroke = 0;  
    float a = texture2D(CC_Texture0, vec2(v_texCoord.x + outlineSize * cosArray[index] / textureSize.x, v_texCoord.y + outlineSize * sinArray[index] / textureSize.y)).a;  
    if (a >= 0.5)  
    {  
        stroke = 1;  
    }  
  
    return stroke;  
}  
  
void main()  
{  
    vec4 myC = texture2D(CC_Texture0, vec2(v_texCoord.x, v_texCoord.y));  
    myC.rgb *= foregroundColor;  
    if (myC.a >= 0.5)  
    {  
        gl_FragColor = v_fragmentColor * myC;  
        return;  
    }  
  
    int strokeCount = 0;  
    strokeCount += getIsStrokeWithAngelIndex(0);  
    strokeCount += getIsStrokeWithAngelIndex(1);  
    strokeCount += getIsStrokeWithAngelIndex(2);  
    strokeCount += getIsStrokeWithAngelIndex(3);  
    strokeCount += getIsStrokeWithAngelIndex(4);  
    strokeCount += getIsStrokeWithAngelIndex(5);  
    strokeCount += getIsStrokeWithAngelIndex(6);  
    strokeCount += getIsStrokeWithAngelIndex(7);  
    strokeCount += getIsStrokeWithAngelIndex(8);  
    strokeCount += getIsStrokeWithAngelIndex(9);  
    strokeCount += getIsStrokeWithAngelIndex(10);  
    strokeCount += getIsStrokeWithAngelIndex(11);  
  
    bool stroke = false;  
    if (strokeCount > 0)  
    {  
        stroke = true;  
    }  
  
    if (stroke)  
    {  
        myC.rgb = outlineColor;  
        myC.a = 1.0;  
    }  
  
    gl_FragColor = v_fragmentColor * myC;  
} 
]]


function ShowFont:ctor()
    local names = {
        "AppleGothic","HiraKakuProN-W6","HiraKakuProN-W3","MarkerFelt-Thin","STHeitiK-Medium","STHeitiK-Light","TimesNewRomanPSMT","Helvetica-Oblique",
        "Helvetica","Helvetica-Bold","TimesNewRomanPS-BoldMT","TimesNewRomanPS-BoldItalicMT","TimesNewRomanPS-ItalicMT","Verdana-Bold","Verdana-BoldItalic",
        "Verdana","Verdana-Italic","Georgia-Bold","Georgia","Georgia-BoldItalic","Georgia-Italic",
        "ArialRoundedMTBold","TrebuchetMS-Italic","TrebuchetMS","Trebuchet-BoldItalic","TrebuchetMS-Bold","STHeitiTC-Light","STHeitiTC-Medium","Aril"
    }

    for i, v in ipairs(names) do
        local test1 = cc.Label:createWithSystemFont(v, v, 20)
        local col =(i - 1) % 5
        local raw = math.floor((i - 1) / 5)
        test1:setPosition(cc.p(100 +col* 200 ,100+raw * 30))
        self:addChild(test1)
    end
    --local label = cc.Label:createWithBMFont("font/west_england-64.fnt", "NI  O  H   A")

    local label = cc.Label:createWithSystemFont("Aril", "Aril", 40)
    label:setTextColor(  { r = 200, g = 0, b = 0 })
    local act=cc.RepeatForever:create(cc.Sequence:create(cc.TintTo:create(1, 0, 255, 0),cc.TintTo:create(1, 200, 0, 0)))
    label:runAction(act)
    label:setAnchorPoint(cc.p(0.5, 0.5))
    label:setPosition(cc.p(100 +300 ,100+400))
    label:enableShadow( { r = 110, g = 110, b = 110, a = 255 }, { width = 2, height = - 2 }, 0)
    self:addChild(label,10)
--    local test=label:getTextSprite()s
--    test:setScale(0.5)
    --self:darkNode(label)
end

function ShowFont:tryPath(node, vertDefaultSource, pszFragSource)
    local pProgram = cc.GLProgram:createWithFilenames(vertDefaultSource, pszFragSource)
    if not pProgram then return false end
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION, cc.VERTEX_ATTRIB_POSITION)
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR, cc.VERTEX_ATTRIB_COLOR)
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD, cc.VERTEX_ATTRIB_FLAG_TEX_COORDS)
    pProgram:link()
    pProgram:updateUniforms()
    node:setGLProgram(pProgram)
    return true
end

function ShowFont:darkNode(node)
    local pProgram = cc.GLProgram:createWithByteArrays(vertDefaultSource, fshDefaultSource)
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION, cc.VERTEX_ATTRIB_POSITION)
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR, cc.VERTEX_ATTRIB_COLOR)
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD, cc.VERTEX_ATTRIB_FLAG_TEX_COORDS)
    pProgram:link()
    pProgram:updateUniforms()
    node:setGLProgram(pProgram)
end


--function ShowFont:createShaderEffect(node)
--        local program = cc.GLProgram:createWithByteArrays(vertDefaultSource,fshDefaultSource)
--        program:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION, cc.VERTEX_ATTRIB_POSITION) 
--        program:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD, cc.VERTEX_ATTRIB_TEX_COORD)
--        program:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR, cc.VERTEX_ATTRIB_COLOR)
--        program:link()
--        program:updateUniforms()
--        node:setGLProgram( program )
--        local radius=0.01
--        local threshold=1.75
--        local glProgramState = cc.GLProgramState:getOrCreateWithGLProgram(program)
--        local param1 = gl.getUniformLocation(glprogram,"u_radius");
--        glProgramState:setUniformFloat(param1,radius);
--        local param2 = gl.getUniformLocation(glprogram,"u_threshold");
--        glProgramState:setUniformFloat(param2,threshold);
--        local param3 = gl.getUniformLocation(glprogram,"u_outlineColor");
--        glProgramState:setUniformVec3(param3, { r = 0, g = 0, b = 0 });
--end


return ShowFont
--local cell=cc.loadLua("app.command.ShowFont"):create()
--cell:setPosition(cc.p(1334/6,750/6))
--self:addChild(cell,10)
-- endregion
