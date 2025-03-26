function negative_pow(base, exponent)

  if base < 0 then
    return math.pow(base*-1,exponent)*-1
  else
    return math.pow(base, exponent)
  end
end

function _toRadians(degrees)
  return math.pi * degrees / 180.0
end

function _toDegrees(radians)
  return  radians * 180.0 / math.pi
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
        if offset == limit_low then a = 0 end
  
        a = (offset - limit_low) / math.max(0.01, mid_point - limit_low) * 0.5
      else
  
        if offset == limit_high then a = 0 end
        
        a = ((offset - mid_point) / math.max(0.01, limit_high - mid_point) * 0.5) + 0.5
      end
  
      return (v1*(1-a))+(v2*(a))
    end
end;

function getTemperatureOffset(base, mult, low_limit, high_limit, temp)
  
  local f = math.pow(math.abs(temp - base), mult)
  local result
  
  if temp < base then
    f = math.abs(temp - base)/base
    result = 1.0 - (f*mult)
  elseif temp > base then
    f = math.abs(temp - base)/(40-base)
    result = 1.0 + (f*mult)
  else
    result = 1.0
  end;
  
  return math.max(math.min(result, high_limit), low_limit);
end;

function temp_interpol_unipolar(temp, temp__base, mult_bottom, mult_upper)

  if mult_bottom == nil then mult_bottom = 1 end
  if mult_upper == nil then mult_upper = 1 end

  local tmp = getTemperatureOffset(temp__base, 1.0, 0, 2, temp)

  if tmp > 1 then

    tmp = 1-(tmp-1)*mult_upper
  else

    tmp = 1-(1-tmp)*mult_bottom
  end

  return tmp;
end 

function temp_interpol(temp, temp__base, value1, value2)

  local tmp = getTemperatureOffset(temp__base, 1.0, 0, 2, temp)

  tmp = tmp * 0.5

  --ac.debug("test",tmp)

  return math.lerp(value1,value2,tmp)
end



function sphere2vec3(azi, alti)

  local alpha = _toRadians(azi)
  local beta  = _toRadians(alti)

  x = math.cos(alpha)*math.cos(beta);
  z = math.sin(alpha)*math.cos(beta);
  y = math.sin(beta);

  return vec3(x,y,z)
end

function sphere2vec3To(v, azi, alti)

  local alpha = _toRadians(azi)
  local beta  = _toRadians(alti)

  v.x = math.cos(alpha)*math.cos(beta);
  v.z = math.sin(alpha)*math.cos(beta);
  v.y = math.sin(beta);
end

function vec32sphere(vec)

  local alpha = _toDegrees(math.atan2(vec.z,vec.x))

  if alpha < 0 then alpha = alpha + 360 end
  if alpha >= 360 then alpha = alpha - 360 end

  local beta  = _toDegrees(math.asin(vec.y))

  return { alpha, beta }
end

function vec32sphereTo(v, vec)

  v[1] = _toDegrees(math.atan2(vec.z,vec.x))

  if v[1] < 0 then v[1] = v[1] + 360 end
  if v[1] >= 360 then v[1] = v[1] - 360 end

  v[2] = _toDegrees(math.asin(vec.y))
end

function angle2vec2(azi)

  local alpha = _toRadians(azi)

  x = math.cos(alpha);
  z = math.sin(alpha);

  return vec2(x,z)
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


function update__basic__vars()
  -- made just once per frame

  local angles = vec32sphere(ac.getSunDirection())
  --__sun_heading = angles[1]
  --__sun_angle   = angles[2]

  a__day = math.min(90, math.max(0, math.abs(angles[2]-90)))
  a__day = math.cos(math.rad(a__day))

  a__night = math.min(-90, math.max(-180, angles[2]-90))
  a__night = math.sin(math.rad(a__night))
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
