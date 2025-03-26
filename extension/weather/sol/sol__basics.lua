
function negative_pow(base, exponent)

  if base < 0 then
    return math.pow(base*-1,exponent)*-1
  else
    return math.pow(base, exponent)
  end
end

function math.round(number)
  local _, decimals = math.modf(number)
  if decimals < 0.5 then return math.floor(number) end
  return math.ceil(number)
end

function _toRadians(degrees)
  return math.pi * degrees / 180.0
end

function _toDegrees(radians)
  return  radians * 180.0 / math.pi
end

function sphere2vec3(azi, alti)

  local alpha = _toRadians(azi)
  local beta  = _toRadians(alti)

  x = math.cos(alpha)*math.cos(beta);
  z = math.sin(alpha)*math.cos(beta);
  y = math.sin(beta);

  return vec3(x,y,z)
end

function vec32sphere(vec)

  local alpha = _toDegrees(math.atan2(vec.z,vec.x))

  if alpha < 0 then alpha = alpha + 360 end
  if alpha >= 360 then alpha = alpha - 360 end

  local beta  = _toDegrees(math.asin(vec.y))

  return { alpha, beta }
end

function angle2vec2(azi)

  local alpha = _toRadians(azi)

  x = math.cos(alpha);
  z = math.sin(alpha);

  return vec2(x,z)
end

function vec_diff(vec1, vec2, c)

  c = c or 1.0
  return math.pow(1-(#(vec1-vec2)*0.5), c)
end

function vec_diff_abs(vec1, vec2, c)

  c = c or 1.0
  return math.pow(#(vec1-vec2), c)
end

function angle_diff(a1, a2, c)

  if c==nil then c=1 end

  local r = a1 - a2
  r = (r + 180) % 360 - 180

  return math.pow(math.abs(r)/180,c)
end

function rnd(a, exp)

  local r = 0

  if exp == nil then
    r = math.random()
  else
    r = math.pow(math.random(), exp)
  end

  local x = a * (2 * r - 1)
  
  return x;
end;

function math_sign(x)

  if x == 0 then return 0; end
  return math.abs(x)/x;
end

function math_sign2(x)

  if x < 0 then return -1 end
  return 1
end

function interpolate__value(v1, v2, offset, limit_low, limit_high, mid_point)

  if limit_low == nil or limit_high == nil then

    offset = math.min(1, math.max(0, offset))
    return (v1*(1-offset))+(v2*(offset))
  
  else

    if limit_low == limit_high then return v1 end
    offset = math.min(limit_high, math.max(offset, limit_low))

    if mid_point == nil then mid_point = (limit_low + limit_high)*0.5 end

    local a = 0.5

    if offset <= mid_point then

      if offset == mid_point then a = 0.5 end
      if offset == low_limit then a = 0 end

      a = (offset - limit_low) / math.max(0.01, mid_point - limit_low) * 0.5
    else

      if offset == limit_high then a = 0 end
      
      a = ((offset - mid_point) / math.max(0.01, limit_high - mid_point) * 0.5) + 0.5
    end

    return (v1*(1-a))+(v2*(a))
  end
end;

function correct_angle(a)

  while a < 0 do a = a + 360 end
  while a > 360 do a = a - 360 end

  return a;
end

function interpolate__angle(a1, a2, offset)

  a1 = correct_angle(a1)
  a2 = correct_angle(a2)

  local shortest_angle=((((a1 - a2) % 360) + 540) % 360) - 180;
    local new_a = a1 - (shortest_angle * offset)

    new_a = correct_angle(new_a)

    return new_a;

end;


function __rev_hue(h, v)

  if v < 0 then
  
    h = h - 180 
    if h < 0 then h = h + 360 end
  end
  return h
end

function HSVToRGB( hue, saturation, value )

  hue = hue or 0
  saturation = saturation or 0
  value = value or 1

  if hsv and hsv.new then 
    local rgb = hsv.new(math.max(0, hue), math.max(0, saturation), math.max(0, value)):toRgb() 
    return rgb.r, rgb.g, rgb.b
  else
    return 0,0,0
  end
end

function HSVToRGB__OLD( hue, saturation, value )
--0.0002 ms

  -- https://gist.github.com/GigsD4X/8513963
  
  -- Returns the RGB equivalent of the given HSV-defined color
  -- (adapted from some code found around the web)

  -- If it's achromatic, just return the value
--log("HSVToRGB "..hue.." "..saturation.." "..value)

  --value = math.max(0, value)

  if saturation == 0 then
    return value, value, value;
  end

  while hue >= 360 do hue = hue - 360 end
  while hue < 0 do hue = hue + 360 end

  -- Get the hue sector
  local hue_sector = math.floor( hue / 60 )
  local hue_sector_offset = ( hue / 60 ) - hue_sector

  local p = value * ( 1 - saturation )
  local q = value * ( 1 - saturation * hue_sector_offset )
  local t = value * ( 1 - saturation * ( 1 - hue_sector_offset ) )

  if hue_sector == 0 then
    return value, t, p;
  elseif hue_sector == 1 then
    return q, value, p;
  elseif hue_sector == 2 then
    return p, value, t;
  elseif hue_sector == 3 then
    return p, q, value;
  elseif hue_sector == 4 then
    return t, p, value;
  elseif hue_sector == 5 then
    return value, p, q;
  end
end;


function RGBToHSV(r, g, b)

  if r and g and b then
    local hsv = rgb(r, g, b):toHsv()
    return hsv.h, hsv.s, hsv.v
  end

  return 0, 0, 1
end


function mixHSV(h1, s1, v1, h2, s2, v2, ratio)

  if h1 and s1 and v1 and h2 and s2 and v2 and ratio then
    ratio = math.min(1, math.max(0, ratio))
    return (math.lerp( hsv(h1, s1, v1):toRgb(), hsv(h2, s2, v2):toRgb(), ratio )):toHsv()
  end

  return hsv(0,0,1)
end

function mixHSV2(c1, c2, offset)

  if c1 and c2 and offset then
    offset = math.min(1, math.max(0, offset))
    return (math.lerp( c1:toRgb(), c2:toRgb(), offset )):toHsv()
  end

  return hsv(0,0,1)
end


function getTemperatureOffset(base, mult, low_limit, high_limit, temp)

  if temp == nil then temp = __temperature end

  local f = math.pow(math.abs(temp - base), mult)
  local result
  
  if temp < base then
    f = math.abs(temp - base)/math.max(1, base)
    result = 1.0 - (f*mult)
  elseif temp > base then
    f = math.abs(temp - base)/math.max(1, (36-base))
    result = 1.0 + (f*mult)
  else
    result = 1.0
  end;
  
  return math.max(math.min(result, high_limit), low_limit);
end;

function temp_interpol_unipolar(temp__base, mult_bottom, mult_upper)

  if mult_bottom == nil then mult_bottom = 1 end
  if mult_upper == nil then mult_upper = 1 end

  local tmp = getTemperatureOffset(temp__base, 1.0, 0, 2)

  if tmp > 1 then

    tmp = 1-(tmp-1)*mult_upper
  else

    tmp = 1-(1-tmp)*mult_bottom
  end

  return tmp;
end 

function temp_interpol(temp__base, value1, value2)

  local tmp = getTemperatureOffset(temp__base, 1.0, 0, 2)

  tmp = tmp * 0.5

  --ac.debug("test",tmp)

  return math.lerp(value1,value2,tmp)
end 



function interpolate__plan(plan, HSV__pos, angle, curve)

  if plan == nil then return nil end

  local pos = 0
  local result = {}

  local entries = #plan[1] - 1 --substract the angle
  
  if angle == nil then 
    if plan[1][1]==-90 and plan[#plan][1]==90 then
      angle = __sun_angle
    else
      angle = __sun_angle-90
    end
  end
  if curve == nil then curve = 1; end

  if #plan == 0 then
    ac.debug("plan: no entries!")
    return nil;
  end
  
  for i=1, #plan-1 do

    if plan[i][1] <= angle and plan[i+1][1] >= angle then

      pos = i
      break;
    end
  end

  if pos==0 then
  
    ac.debug("plan: entries out of range!")
    return nil;
  end

  --interpolating
  local offset = math.pow( (angle - plan[pos][1]) / math.max(0.01, plan[pos+1][1] - plan[pos][1]), curve )

  if offset < 0 then

    offset = 0
    ac.debug("Interpolate error | warning="..offset)
  elseif offset > 1 then

    offset = 1
    ac.debug("Interpolate error | warning="..offset)
  end


  local n_hsv = 1
  for j=1, entries do
      
    if HSV__pos ~= nil and #HSV__pos > 0 and n_hsv <= #HSV__pos and j == HSV__pos[n_hsv] then
  
      local rgb_result
      local HSVpos = HSV__pos[n_hsv]

      --if HSV values (mix RGB)
      rgb_result = mixHSV( plan[pos][HSVpos+1], plan[pos][HSVpos+2], plan[pos][HSVpos+3],
                 plan[pos+1][HSVpos+1], plan[pos+1][HSVpos+2], plan[pos+1][HSVpos+3],
                 offset )

      result[HSVpos]      = rgb_result.h
      result[HSVpos + 1]  = rgb_result.s
      result[HSVpos + 2]  = rgb_result.v
      
      j = j + 2
      n_hsv = n_hsv + 1
    else
      
      result[j] = (plan[pos][j+1]*(1-offset))+(plan[pos+1][j+1]*(offset))
    end

  end
  

  return result;
end;

function mix_and_interpolate__plan(plan1, plan2, mix, HSV__pos, angle, curve)

  local r1

  if mix < 1 then
    r1 = interpolate__plan(plan1, HSV__pos, angle, curve)
    if mix == 0 then return r1 end
  end

  local r2 = interpolate__plan(plan2, HSV__pos, angle, curve)
  if mix >= 1 then return r2 end

  if r1 == nil and r2 ~= nil then return r2 end
  if r1 ~= nil and r2 == nil then return r1 end

  local mix_plan = {}

  mix_plan[1] = {}
  mix_plan[2] = {}

  mix_plan[1][1] = 0
  mix_plan[2][1] = 1

  for i = 1, #r1 do

    mix_plan[1][i+1] = r1[i]
    mix_plan[2][i+1] = r2[i]
  end

  return interpolate__plan(mix_plan, HSV__pos, mix, 1)

end


function interpolate__2_plans(plan1, plan2, HSV__pos, start_angle, end_angle, offset, curve, resolution)
  --interpolates 2 plans from start to end with the given offset
 
  local angle = start_angle
  local i = 1

  local mix = {}
  mix[1] = {}
  mix[2] = {}

  local r1
  local r2

  local r = {}

  while angle<=end_angle do

    r1 = interpolate__plan(plan1, HSV__pos, angle, curve)
    r2 = interpolate__plan(plan2, HSV__pos, angle, curve)

    mix[1][1] = 0
    for ii = 1, #r1 do mix[1][ii+1] = r1[ii] end

    mix[2][1] = 1
    for ii = 1, #r2 do mix[2][ii+1] = r2[ii] end


    r_mix = interpolate__plan(mix, HSV__pos, offset, curve)


    r[i] = {}
    r[i][1] = angle
    for ii = 1, #r_mix do r[i][ii+1] = r_mix[ii] end


    angle = angle + (end_angle - start_angle)/math.max(0.01, resolution)
    i = i + 1
  end

  return r
end


function interpolate__2_plans_eco(plan1, plan2, HSV__pos, offset, curve)
  --interpolates 2 plans from start to end with the given offset
  --index sequence in plan1 and plan 2 have to be the same !!!!
 
  if #plan1 ~= #plan2 then return plan1 end


  local min = math.min
  local max = math.max

  offset = min(1.0, max(0, offset))

  local i = 1

  local mix = {}
  mix[1] = {}
  mix[2] = {}

  local r = {}

  for i=1, #plan1 do

    mix[1][1] = 0
    mix[2][1] = 1
    for ii = 2, #plan1[1] do
      mix[1][ii] = plan1[i][ii]
      mix[2][ii] = plan2[i][ii]
    end

    r_mix = interpolate__plan(mix, HSV__pos, offset, curve)

    r[i] = {}
    r[i][1] = plan1[i][1]
    for ii = 1, #r_mix do r[i][ii+1] = r_mix[ii] end

  end

  return r
end


function __sun_scale_angle(a,  bottom_limit, upper_limit)

  if sun__date_ratio == 0 then return a; end

  if bottom_limit == nil then bottom_limit = 90 end
  if upper_limit  == nil then upper_limit  = 90 end

  local upper_scale  =  math.lerp(1, __sun_angle_noon / 90, sun__date_ratio)
  local bottom_scale =  math.lerp(1, (__sun_angle_midday * -1) / 90, sun__date_ratio)

--log("__sun_scale_angle - upper_scale, bottom_scale: "..upper_scale..","..bottom_scale)

  local angle = a

  if math.abs(angle) >= bottom_limit then

    if angle < 0 then

      angle = (bottom_limit*-1) - ( ( (bottom_limit*-1) - angle ) * bottom_scale )
    else

      angle = bottom_limit + ( (angle - bottom_limit) * bottom_scale )
    end

  elseif math.abs(angle) <= upper_limit then

    if angle < 0 then

      angle = (upper_limit*-1) - ( ( (upper_limit*-1) - angle ) * upper_scale )
    else

      angle = upper_limit + ( (angle - upper_limit) * upper_scale )
    end

  else angle = a
  end

  return angle;
end


function scale__plan(plan, HSV__pos, bottom_limit, upper_limit)



  -- The plan is scaled within:
  --     -180°->(bottom_limit*-1)
  --     (upper_limit*-1)->0°->upper_limit,
  --     bottom_limit->180°,

  if sun__date_ratio == 0 then return plan; end

  
  if #plan <= 0 then
    return nil;
  elseif #plan == 1 then
    return plan;
  end

  local new_plan = {}
  local tmp
  local pos = 1

  for i=1, #plan do

    pos = __sun_scale_angle(plan[i][1], bottom_limit, upper_limit)

    tmp = nil

    if pos > 180 then pos = 180
    elseif pos < -180 then pos = -180
    end

--    log("scale_plan - old pos, new pos: "..plan[i][1]..","..pos)

    tmp = interpolate__plan(plan, HSV__pos, pos)

    if tmp ~= nil then
      new_plan[i] = {}
      new_plan[i][1] = plan[i][1]

      --local s = ""..plan[i][1]

      for ii=1, #tmp do

        new_plan[i][ii+1] = tmp[ii]
        --s = s..","..tmp[ii]
      end

      --log("scale_plan result: "..s)
    else
--log("scale_plan - no scaled result")
    end
  end

  return new_plan;
end


function mirror__plan(plan)

  local n = #plan
  local n_further = n

  for i=1, n-1 do

    n_further = n_further + 1
    plan[n_further] = {}
    for ii=1, #plan[n-i] do plan[n_further][ii] = plan[n-i][ii] end

    plan[n_further][1] =  math.abs(plan[n_further][1])
  end

  return plan;
end

local a__day = 0
function __curveDay(c, normalized)

  if c == nil then c = 1 end
  return math.pow(math.abs(a__day), c)
end;

function __IntD(valueDusk, valueNoon, c, normalized)
  -- interpolate 2 values with the day
  return math.lerp(valueDusk, valueNoon, __curveDay(c, normalized))
end;


local a__night = 0
function __curveNight(c, normalized)

  if c == nil then c = 1 end
  return math.pow(math.abs(a__night), c)
end;

function __IntN(valueMidnight, valueDawn, c)
  -- interpolate 2 values with the night
  return math.lerp(valueMidnight, valueDawn, __curveNight(c))
end;


local n = 1
local _l_sun_compensate_plan = {} 
_l_sun_compensate_plan[n] = {  -180, 1.00 }  n = n + 1
_l_sun_compensate_plan[n] = {   -90, 1.00 }  n = n + 1
_l_sun_compensate_plan[n] = {   -75, 0.00 }  n = n + 1
_l_sun_compensate_plan[n] = {     0, 0.00 }  n = n + 1
local comp__sun_var = { 0 }
function sun_compensate(v)

  return math.lerp(1, v, comp__sun_var[1]);
end

local n = 1
local _l_day_compensate_plan = {} 
_l_day_compensate_plan[n] = {  -180, 1.00 }  n = n + 1
_l_day_compensate_plan[n] = {  -102, 1.00 }  n = n + 1
_l_day_compensate_plan[n] = {   -93, 0.00 }  n = n + 1
_l_day_compensate_plan[n] = {     0, 0.00 }  n = n + 1
local comp__day_var = { 0 }
function day_compensate(v)

  return math.lerp(1, v, comp__day_var[1]);
end

n = 1
local _l_night_compensate_plan = {} 
_l_night_compensate_plan[n] = {  -180, 0.00 }  n = n + 1
_l_night_compensate_plan[n] = {  -102, 0.00 }  n = n + 1
_l_night_compensate_plan[n] = {   -93, 1.00 }  n = n + 1
_l_night_compensate_plan[n] = {     0, 1.00 }  n = n + 1
local comp__night_var = { 0 }
function night_compensate(v)

  return math.lerp(1, v, comp__night_var[1]);
end

n = 1
local _l_twilight_compensate_plan = {} 
_l_twilight_compensate_plan[n] = {  -180, 1.00 }  n = n + 1
_l_twilight_compensate_plan[n] = {   -99, 1.00 }  n = n + 1
_l_twilight_compensate_plan[n] = {   -80, 0.00 }  n = n + 1
_l_twilight_compensate_plan[n] = {     0, 0.00 }  n = n + 1
local comp__twilight_var = { 0 }
function from_twilight_compensate(v)

  return math.lerp(1, v, comp__twilight_var[1]);
end

n = 1
local _l_duskdawn_compensate_plan = {} 
_l_duskdawn_compensate_plan[n] = {  -180, 1.00 } n = n + 1
_l_duskdawn_compensate_plan[n] = {  -105, 1.00 } n = n + 1
_l_duskdawn_compensate_plan[n] = {  -100, 0.65 } n = n + 1
_l_duskdawn_compensate_plan[n] = {   -90, 0.00 } n = n + 1
_l_duskdawn_compensate_plan[n] = {   -80, 0.65 } n = n + 1
_l_duskdawn_compensate_plan[n] = {   -75, 1.00 } n = n + 1
_l_duskdawn_compensate_plan[n] = {     0, 1.00 } n = n + 1
local comp__duskdawn_var = { 0 }
function duskdawn_compensate(v)

  return math.lerp(1, v, comp__duskdawn_var[1]);
end

local comp__dawn_exclusive_var = 0
function dawn_exclusive(v)

  return math.lerp(1, v, comp__dawn_exclusive_var);
end

local comp__dusk_exclusive_var = 0
function dusk_exclusive(v)

  return math.lerp(1, v, comp__dusk_exclusive_var);
end

local day_time_multi = 1
function calc__day_time_multi()

  day_time_multi = math.pow(__AC_TIME / 43200, 1.0)
end

function interpolate_day_time(morning, noon, evening)

  if day_time_multi <= 1 and day_time_multi > 0.25 then

    return math.lerp(morning, noon, (day_time_multi-0.25)*1.34)
  elseif day_time_multi > 1 and day_time_multi <= 1.75 then

    return math.lerp(evening, noon, (1.75-day_time_multi)*1.34)
  else
    local m = 0.5
    if day_time_multi > 1.75 then m = 1-(day_time_multi-1.75)*2
    elseif day_time_multi <= 0.25 then m = 0.5-(day_time_multi*2)
    end

    return math.lerp(morning, evening, m)
  end

end


function update__basic__vars()
  -- made just once per frame

  comp__sun_var             = interpolate__plan(_l_sun_compensate_plan)
  comp__day_var             = interpolate__plan(_l_day_compensate_plan)
  comp__night_var           = interpolate__plan(_l_night_compensate_plan)
  comp__twilight_var        = interpolate__plan(_l_twilight_compensate_plan)
  comp__duskdawn_var        = interpolate__plan(_l_duskdawn_compensate_plan)

  if __AC_TIME < 43200 then 
    comp__dawn_exclusive_var = 1-comp__duskdawn_var[1]
    comp__dusk_exclusive_var = 0
  else
    comp__dawn_exclusive_var = 0
    comp__dusk_exclusive_var = 1-comp__duskdawn_var[1]
  end

  a__day = math.min(90, math.max(0, math.abs(__sun_angle-90)))
  a__day = math.cos(math.rad(a__day))

  a__night = math.min(-90, math.max(-180, __sun_angle-90))
  a__night = math.sin(math.rad(a__night))

  calc__day_time_multi()
end

-- Table functions
function table__deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[table__deepcopy(orig_key)] = table__deepcopy(orig_value)
        end
        setmetatable(copy, table__deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end



local perlin_permutation = { 151,160,137,91,90,15,
  131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,
  190, 6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,
  88,237,149,56,87,174,20,125,136,171,168, 68,175,74,165,71,134,139,48,27,166,
  77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,55,46,245,40,244,
  102,143,54, 65,25,63,161, 1,216,80,73,209,76,132,187,208, 89,18,169,200,196,
  135,130,116,188,159,86,164,100,109,198,173,186, 3,64,52,217,226,250,124,123,
  5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,
  223,183,170,213,119,248,152, 2,44,154,163, 70,221,153,101,155,167, 43,172,9,
  129,22,39,253, 19,98,108,110,79,113,224,232,178,185, 112,104,218,246,97,228,
  251,34,242,193,238,210,144,12,191,179,162,241, 81,51,145,235,249,14,239,107,
  49,192,214, 31,181,199,106,157,184, 84,204,176,115,121,50,45,127, 4,150,254,
  138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180
}
function noise(n)
  n = math.floor(n - (math.floor(n/256)*256))
  if n>=1 and n<=256 then
    return perlin_permutation[n]/256.0
  else
    return 0
  end
end

function file_exists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

-- fix of the CM 0.8.2561 bug
local ___file___ = nil
if io.output == nil then
  io.write = function(buffer)
    if ___file___ then
      ___file___:write(buffer)
    end
  end
  io.output = function(file)
    ___file___ = file
  end
end


function validate__vec3(vec, x,y,z)

  local ret = vec3(0,0,0)

  if vec then
    ret.x = vec.x or x
    ret.y = vec.y or y
    ret.z = vec.z or z
  end

  return ret
end

function validate__value(v, a)

  if v == nil then v = a end
  return v
end


function split_string(s, sep)
  if sep == nil then
      sep = "%s"
  end
  local t={}
  for str in string.gmatch(s, "([^"..sep.."]+)") do
      table.insert(t, str)
  end
  return t
end

function decodeValue(strg)
  if strg == "true" then
      return true
  elseif strg == "false" then
      return false
  else
      return tonumber(strg)
  end
end