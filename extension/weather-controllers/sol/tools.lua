
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
        if offset == low_limit then a = 0 end
  
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

function vec32sphere(vec)

  local alpha = _toDegrees(math.atan2(vec.z,vec.x))

  if alpha < 0 then alpha = alpha + 360 end
  if alpha >= 360 then alpha = alpha - 360 end

  local beta  = _toDegrees(math.asin(vec.y))

  return { alpha, beta }
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