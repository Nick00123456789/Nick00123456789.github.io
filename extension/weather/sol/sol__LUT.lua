local pow   = math.pow
local lerp  = math.lerp
local min   = math.min
local max   = math.max
local i
local ii

LUT = {}
function LUT:new(data, colors, sunbased)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.data = data
    o.color_positions = colors or {}
    o.curve = 1
    o.sun_based = sunbased or false

    o.buffer = {}
    o.cppLUT = nil

    o:generate()

    return o
end

function LUT:setColorPositions(colors)
    self.color_positions = colors or {}
end
function LUT:setCurve(curve)
    self.curve = curve or 1
end
function LUT:setSunbased(b)
    self.sun_based = b
end

function LUT:convertOldSunAngles()

    if self.data then
        if self.data[1][1] and self.data[#self.data][1] then
            if self.data[1][1] == -180 and self.data[#self.data][1] == 0 then
                for i=1, #self.data do
                    if self.data[i][1] then
                        self.data[i][1] = self.data[i][1] + 90
                    end
                end
            end
        end
    end
end

function LUT:convertHSVtoRGB()
    
    if self.data and self.color_positions and #self.color_positions>0 then
        local color
        for i=1, #self.data do
            for ii=1, #self.color_positions do
                color = hsv(self.data[i][self.color_positions[ii] + 1],
                            self.data[i][self.color_positions[ii] + 2],
                            self.data[i][self.color_positions[ii] + 3]
                            ):toRgb()
                self.data[i][self.color_positions[ii] + 1] = color.r
                self.data[i][self.color_positions[ii] + 2] = color.g
                self.data[i][self.color_positions[ii] + 3] = color.b
            end
        end
    end
end

function LUT:convertRGBtoHSV_Buffer()

    if self.buffer and self.color_positions and #self.color_positions>0 then
        local color
        for ii=1, #self.color_positions do
            color = rgb(self.buffer[self.color_positions[ii] + 0],
                        self.buffer[self.color_positions[ii] + 1],
                        self.buffer[self.color_positions[ii] + 2]
                        ):toHsv()
            self.buffer[self.color_positions[ii] + 0] = color.h
            self.buffer[self.color_positions[ii] + 1] = color.s
            self.buffer[self.color_positions[ii] + 2] = color.v
        end
    end
end

function LUT:generate()

    if self.data then
        
    else
        ac.debug("LUT", "no data given!!!")
        return
    end


    if self.sun_based then
        self:convertOldSunAngles()
    end

    if __CSP_version >= 1655 then -- CSP 1.76p38 (1655)
        -- build new cppLUT
        if self.data then
            local str = ""

            for i=1, #self.data do
                str = str..self.data[i][1].."|"
                for ii=2, #self.data[i] do
                    str = str..self.data[i][ii]
                    if ii<#self.data[i] then
                        str = str..","
                    else
                        str = str.."\n"
                    end
                end
            end

            self.cppLUT = ac.LutCpp(str, self.color_positions)
        else
            ac.debug("LUT", "no data given!!!")
        end
    else
        self:convertHSVtoRGB()
    end

end


function LUT:interpolateLUA(index, curve)
    
    if self.data == nil then return nil end
    
    local pos = 0
    
    local entries = #self.data[1] - 1 -- first entry is index
    
    curve = curve or self.curve
    
    if #self.data == 0 then
        ac.debug("plan: no entries!")
        return nil;
    end
    
    for i=1, #self.data-1 do
        if self.data[i][1] <= index and self.data[i+1][1] >= index then
            pos = i
            break
        end
    end
    
    if pos==0 then
        ac.debug("plan: entries out of range!")
        return nil
    end
    
    --interpolating position
    local offset = pow( (index - self.data[pos][1]) / max(0.01, self.data[pos+1][1] - self.data[pos][1]), curve )
    
    if offset < 0 then
        offset = 0
        ac.debug("Interpolate error | warning="..offset)
    elseif offset > 1 then
        offset = 1
        ac.debug("Interpolate error | warning="..offset)
    end
    
    for i=1, entries do
        self.buffer[i] = lerp(self.data[pos][i+1], self.data[pos+1][i+1], offset) 
    end
    
    return self.buffer
end

function LUT:get(index)

    index = index or __sun_angle

    if self.cppLUT then
        self.cppLUT:calculateTo(self.buffer, index)
        --self.buffer = self.cppLUT:calculate(index)
        return self.buffer
    else
        if self.data then
            self:interpolateLUA(index)
            self:convertRGBtoHSV_Buffer()
            return self.buffer
        end
    end
end