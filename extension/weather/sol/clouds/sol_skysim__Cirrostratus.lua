local gain_mod = 1
local haze_mod = 0
local inair_brightness = 0
local inair_mat_opacity_mod = 0 
local inair_mfog_mod = 0
local cloud_fog_modifier = 0
local overcast_steady_mod = 0
local overcast_mod = 0
local overcast_bright_mod = 0
local pollusion_rgb = rgb(0,0,0)
local pollusion_rgb = rgb(0,0,0)
local pollusion_bright_mod = 0
local downlit = rgb(0,0,0)
local sun_vector = vec3(0,0,0)
local sun_intensity = 1
local sun_color = rgb(0,0,0)
local _l_config__clouds__opacity_multiplier
local _l_config__shadow_opacity_multiplier

local _l_sun_light_LUT = {
  {-180,  0, 0.00, 1.00 },
  {-105,  0, 0.00, 1.00 },
  { -98,  0, 0.00, 0.00 },
  {-97.5,22, 0.35, 0.00 },
  { -96, 24, 1.00, 1.00 },
  { -93, 29, 0.95, 4.00 },
  { -90, 32, 0.93, 3.00 },
  { -85, 35, 0.90, 3.50 },
  { -80, 38, 0.60, 4.00 },
  { -75, 41, 0.35, 4.00 },
  { -70, 43, 0.33, 4.00 },
  { -60, 44, 0.31, 4.00 },
  { -45, 48, 0.30, 4.00 },
  { -30, 50, 0.30, 4.00 },
  {   0, 50, 0.30, 4.00 },
}
local _l_sun__LUT = {}
local _l_sunCPP = LUT:new(_l_sun_light_LUT, {1}, true)
local _l_custom_sun_light = rgb(1,1,1)



local _l_improved_light_with_low_sun_LUT = {
  {-180, 0.00 },
  { -99, 0.00 },
  { -96, 0.40 },
  { -93, 0.80 },
  { -90, 1.00 },
  { -75, 1.00 },
  { -70, 0.80 },
  { -60, 0.40 },
  { -50, 0.00 },
  {   0, 0.00 },
}
_l_improved_light_with_low_sun = 0
local _l_improved_light_with_low_sunCPP = LUT:new(_l_improved_light_with_low_sun_LUT, nil, true)


n = 1
local _l_mat_LUT = {
  { -180, 1.5, 1.0, },
  { -108, 1.5, 1.0, },
  { -102, 1.2, 1.0, },
  {  -99, 1.0, 1.0, },
  {  -96, 3.0, 1.0, },
  {  -93, 4.0, 1.0, },
  {  -90, 2.0, 2.0, },
  {-87.5, 1.5, 1.7, },
  {  -85, 1.0, 1.4, },
  {  -80, 0.3, 1.0, },
  {  -75, 0.2, 1.0, },
  {  -70, 0.2, 1.0, },
  {  -60, 0.2, 1.0, },
  {  -40, 0.2, 1.0, },
  {  -20, 0.2, 1.0, },
  {    0, 0.2, 1.0, },
}
local _l_MATlut = {}
local _l_MATlutCPP = LUT:new(_l_mat_LUT, nil, true)


function Preload_Cirrostratus_Textures()
  local accloud = ac.SkyCloudV2():setTexture('\\clouds\\3d\\Cirrostratus.png')
end

function Build_Cirrostratus_Pattern(layer, dense, water)

  local stack = Stack:new()
  local cloud_pos

  if dense > 0.1 then

    local n = math.max(2, math.floor(30000 * math.min(1, math.pow(dense, 1.00)) / 7000))

    local tile = 100000/n

    local size = math.min(100000 , 3.0*tile*math.pow(dense, 0.67))

    for i=-n, n do 
      for ii=-n, n do

        cloud_pos = vec3(i*tile, 0, ii*tile)
        if math.horizontalLength(cloud_pos - __sky__camShift) <= layer.radius then

          stack:add({
            { "pos", cloud_pos },
            { "size", size },
            { "water", water },
            { "style", dense },
          })
        end
      end
    end
  end

  return stack
end


function Create_Cirrostratus_Layer(layer)

  layer.static = false
  layer.use_rotation_fix = true

--[[
  local h = layer.ceiling - layer.bottom
  local dh = h*0.25
  local size = 1000
  local water = 1
]]
  --[[
  for i=1, 10 do 
      size = 30000 + rnd(10000)
      water = 0.2+rnd(0.2)
      layer.clouds_count = layer.clouds_count + 1
      layer.clouds[layer.clouds_count] = Cloud:new(layer, vec3(rnd(layer.radius), layer.bottom + dh + rnd(dh), rnd(layer.radius)), size, water)
  end
  ]]
 
--[[
  local n = 3
  local tile = layer.radius/n
  for i=-n, n do 
      for ii=-n, n do
        size = 1.5*tile--30000 + rnd(10000)
        water = 0.2+rnd(0.2)
        layer.clouds_count = layer.clouds_count + 1
        layer.clouds[layer.clouds_count] = Cloud:new(layer, vec3(i*tile, layer.bottom, ii*tile), size, water)
      end
  end
]]

--[[
local n = 2
  local tile = layer.radius/n
  for i=-n, n do 
      for ii=-n, n do
        size = 1.5*tile--30000 + rnd(10000)
        water = 0.2+rnd(0.2)
        layer.clouds_count = layer.clouds_count + 1
        layer.clouds[layer.clouds_count] = Cloud:new(layer, vec3(i*tile, layer.bottom, ii*tile), size, water)
      end
  end
]]
  --layer.clouds_count = layer.clouds_count + 1
  --layer.clouds[layer.clouds_count] = Cloud:new(layer, vec3(25000, layer.bottom, -25000), 10000, 0.0)
end

function Update_Cirrostratus_Layer(layer)

  if ta_exp_fix < 1 then
    gain_mod =  math.pow(1/ta_exp_fix, 0.75)
  elseif ta_exp_fix > 1 then
    gain_mod =  math.pow(1/ta_exp_fix, 1/math.pow(ta_exp_fix, 0.5))
  end
  
  gain_mod = 1
           * math.pow(1/__bright_adapt, 0.3)
           * math.lerp(math.pow(sky__get__color_mod().v * 0.95, 1.67), 1, from_twilight_compensate(0)) --recalibration from Sol 2.0.18
             
  haze_mod = 0.8 + (1-__solar_eclipse)

  inair_brightness = math.lerp(1.0,0.5*__inair_material.color.v,__inair_material.dense) * math.pow(SOL__config("nerd__clouds_adjust", "Contour"), 0.05)
  inair_mat_opacity_mod = math.lerp(1.0,__IntN(0.0,0.5,10),__inair_material.dense)
  inair_mfog_mod = (math.lerp(0.0,60.0,math.pow(__inair_material.dense*0.8, 10)))

  cloud_fog_modifier = (inair_mfog_mod * 2 + __fog_dense)

  overcast_steady_mod = math.pow(__overcast, 0.25)
  overcast_mod = __overcast*__IntD(0.3, 0.1, 0.35)*day_compensate(0.75)
  overcast_bright_mod = __overcast*__IntD(1.0, 0.5, 0.35)*day_compensate(0.75)

  pollusion_rgb = hsv.new(__extern_illumination.h, __extern_illumination.s*0.9, __extern_illumination.v*0.35*math.pow(math.min(2, __extern_illumination_mix*0.15),0.35)):toRgb() * (night_compensate(0))
  pollusion_rgb = math.lerp( pollusion_rgb / (math.max(1, math.pow(__extern_illumination_mix, 0.2))) , pollusion_rgb, day_compensate(0))
  pollusion_bright_mod = __IntD(1,0,0.4) 

  -- LIGHT --

  _l_sun__LUT = _l_sunCPP:get() --interpolate__plan(_l_sun_light_LUT, {1})
  _l_custom_sun_light  = hsv( _l_sun__LUT[1],
                              _l_sun__LUT[2],
                              _l_sun__LUT[3]):toRgb()
  _l_custom_sun_light  = _l_custom_sun_light * (1 - __overcast)

  --local temp = _l_improved_light_with_low_sunCPP:get() --interpolate__plan(_l_improved_light_with_low_sun_LUT)
  --_l_improved_light_with_low_sun = temp[1]

  _l_MATlut = _l_MATlutCPP:get() --interpolate__plan(_l_mat_LUT)

  sun_vector = __camPos + (layer.radius * __sunDir)
  sun_intensity = math.pow(SOL__config("nerd__sky_adjust", "SunIntensityFactor"), 0.175 - 0.175*__overcast)

  sun_color:set(__sun_color:toRgb())

  _l_config__clouds__opacity_multiplier = SOL__config("clouds", "opacity_multiplier")
  _l_config__shadow_opacity_multiplier = SOL__config("clouds", "shadow_opacity_multiplier")
  
end

function Create_Cirrostratus_Cloud(cloud)

  cloud.draw_method = 1

  local accloud
  local t = cloud.size * 0.5
  local tt = cloud.size * 0.00001
  local size_mod = (1-math.max(0, math.min(1, cloud.size*0.0003)))

  local n = math.max(1, math.floor(cloud.size * 0.00005 * __sky__clouds_quality))
  --cloud.cloud_type_change = math.floor(n * 0.75)

  local scattered = math.max(1.0+rnd(0.25), 10*tt+rnd(1)) * (0.25 + 0.1 * cloud.style)


  cloud.ramp_speed = 0.00075 + rnd(0.00002)
  cloud.cutoff = math.max(0, 0.95-cloud.style) +rnd(0.05)

  cloud.ac_cloud_extra["procScale"] = {}

  local tex = math.floor(math.random()*5)

  for i=1, n do

    cloud.ac_clouds_count = cloud.ac_clouds_count + 1

    accloud = cloudsstorage__get_free_cloud(2) --ac.SkyCloudV2()

    cloud.ac_cloud_pos_offset[cloud.ac_clouds_count] = vec3(rnd(1), 0, rnd(1))

    --accloud:setTexture('\\clouds\\3d\\cirro'..math.floor(math.random() * 4)..'.png')

    tex = tex + 1
    if tex >= 5 then tex = 0 end

    accloud.texStart:set( vec2( tex*0.2, math.max(0, math.floor(cloud.style*5-1) * 0.2)) )
    --accloud.texStart:set( 0.2, 0.4 )
    accloud.texSize:set(vec2(0.2,0.2))
    accloud:setTexture('\\clouds\\3d\\Cirrostratus.png')

    accloud.size = vec2(0.7*cloud.size, 0.6*cloud.size*(1+rnd(0.1))) * 1.15

    accloud.position = cloud.pos
    accloud.material = cloud.material

    accloud.horizontal = true
    accloud.customOrientation = true
    accloud.noTilt = true
    accloud.procScale = vec2(1.0, 1.0) *1.0

    local c_r = rnd(0.10)
    cloud.ac_cloud_color[cloud.ac_clouds_count] = hsv(230,
                      0.08 * c_r,
                      2 + c_r):toRgb()

    
    accloud.color = cloud.ac_cloud_color[cloud.ac_clouds_count]
    accloud.occludeGodrays = true
    accloud.useCustomLightColor = true
    accloud.useCustomLightDirection = false


    local scale = scattered

    accloud.procMap = vec2(0.05+rnd(0.05), 10.0+rnd(0.5))

    
    cloud.ac_cloud_extra["procScale"][cloud.ac_clouds_count] = vec2( scale , scale) 
    accloud.procScale = cloud.ac_cloud_extra["procScale"][cloud.ac_clouds_count]
    
    accloud.procSharpnessMult = 1.1
    accloud.procNormalScale = vec2(0.5, 1.25)
    accloud.procShapeShifting = math.random()
    accloud.opacity = 0
    accloud.shadowOpacity = 0
    accloud.cutoff = cloud.cutoff
    accloud.useNoise = true

    
    accloud.up = vec3(0,0,1)
    accloud.side = vec3(1,0,0)

    --accloud.up = vec3(0, -1, 0)
    --accloud.side = math.cross(-accloud.position, accloud.up):normalize()
    --accloud.up = math.cross(accloud.side, -accloud.position):normalize()
    --accloud.side:normalize()
    
    accloud.noiseOffset:set(math.random(), math.random()) 

    cloud.ac_cloud_pos_offset[cloud.ac_clouds_count] = cloud.ac_cloud_pos_offset[cloud.ac_clouds_count] * t
    cloud.ac_clouds[cloud.ac_clouds_count] = accloud

  end





end

function Update_Cirrostratus_Cloud(cloud, everything)


  if everything then

    local tt = cloud.size * 0.00001
    local c
    local d = cloud.lastDistance
    local radius = cloud.layer.radius

    cloud.light_bounce = (1-cloud.water_filled) * 0.9 * tt
    cloud.layer:addLightBounce(cloud)

    local visible = math.max(0, math.min(1, 4 * ((radius - d) / radius)))
    if visible <= 0 then
      for i=1,cloud.ac_clouds_count do
        cloud.ac_clouds[i].opacity = 0
      end
      return
    end
    
    local curved = math.max(0, math.min(1, d/radius))

    local main_gain = 1.10 * SOL__config("nerd__clouds_adjust", "Lit") * blue_sky_cloud_lev * gain_mod * sun_intensity

    local _l_humid = gfx__get_humidity()


    local vec_simple = cloud.pos - __camPos
    vec_simple:normalize()
    
    s_c3 = cloud:getLightSourceRelevance(0.4, 1.5, 2)
    s_c3 = math.lerp( sun_compensate(s_c3), math.pow(s_c3, 2), night_compensate(0))


    local water = math.pow(cloud.water_filled, 2)

    local cloud_color = gfx__get_sky_color(cloud.pos, true):toHsv()
    local fog = math.pow(ac.calculateSkyFog(vec3(vec_simple.x,vec_simple.y-0.05,vec_simple.z)), from_twilight_compensate(0.4)*(8.0-5*__fog_dense) + (-1 + vec_simple.y*3))



    cloud_color.s = cloud_color.s * 0.5
                                  * blue_sky_cloud_adaption
                                  * blue_sky_cloud_sat


    cloud_color.v = cloud_color.v *2* (1 - (0.9 * water)) 
    cloud_color = cloud_color:toRgb() 

    
    cloud_color:add(sun_color * _l_MATlut[1] * 0.25 * math.pow(s_c3, 2) * (1 - (0.5 * water)))
    cloud_color:add(_l_custom_sun_light * s_c3 * (1 - (0.5 * water) * from_twilight_compensate(0)) )
    cloud_color = cloud_color * main_gain

    -- limit saturation
    cloud_color:adjustSaturation(
      math.min(cloud_color:getSaturation(), SOL__config("nerd__clouds_adjust", "Saturation_limit") * blue_sky_cloud_sat_limit)
    )

    cloud.material.baseColor = cloud_color:scale(0.25 * _l_MATlut[2])
   
    cloud.material.ambientColor:set(cloud_color)
    cloud.material.ambientConcentration = 0

    cloud.material.frontlitMultiplier = 1.0
    cloud.material.frontlitDiffuseConcentration = 1.0 * ( 1 - sun_compensate(0) )

    cloud.material.lightSaturation = 1 * SOL__config("nerd__clouds_adjust", "Saturation") * blue_sky_cloud_sat
    cloud.material.lightSaturation = math.min(SOL__config("nerd__clouds_adjust", "Saturation_limit") * blue_sky_cloud_sat_limit, cloud.material.lightSaturation)            
      

    --### s_c3 debug ### green=pro sun / red=contra sun
    --cloud.material.ambientColor:set(math.lerp(rgb(10,0,0),rgb(0,10,0),s_c3))

    d_mod = d/radius

    cloud.material.fogMultiplier = fog + (0.10 * water)
    cloud.material.fogMultiplier = cloud.material.fogMultiplier + d_mod*0.55
    cloud.material.fogMultiplier = math.max(cloud_fog_modifier*0.50+d_mod*cloud_fog_modifier*0.50, cloud.material.fogMultiplier)
    cloud.material.fogMultiplier = math.max(0.8*d_mod, cloud.material.fogMultiplier)
    
    cloud.material.backlitMultiplier = (day_compensate(7.5) + 0.9) * 1 * (1 - __overcast) * (1-water)
    cloud.material.backlitExponent = 16
    cloud.material.specularPower = _l_MATlut[1]


    local w = _toRadians(-5 * (math.pow(curved, 2)))

    local vec_pos = cloud.pos - __camPos
    vec_pos:normalize()

    local temp = vec32sphere(vec_pos)
    local rotation_vec = sphere2vec3(temp[1]+90, 0)

    temp = vec32sphere(cloud.layer.wind_normalized)
    local up = sphere2vec3(temp[1],0)
    local side = sphere2vec3(temp[1]+90,0)

    up:rotate(quat.fromAngleAxis(w, rotation_vec))
    side:rotate(quat.fromAngleAxis(w, rotation_vec))


    local opacity = math.min(1, 0.1 * blue_sky_cloud_opacity * _l_config__clouds__opacity_multiplier * visible * cloud.transition)
    opacity = opacity * (1 - overcast_steady_mod) -- higher than overcast sky
                      * (1-_l_humid*d_mod)
    local cutoff = math.lerp(1, cloud.cutoff, cloud.transition) 

    local fidelity_mod = 0.5*math.pow( math.max(0, 1-d_mod), 1)

    for i=1, cloud.ac_clouds_count do

      c = cloud.ac_clouds[i]

      if __CSP_version >= 1074 then c.extraFidelity = fidelity_mod end

      if __sun_angle > -7.5 then 
        c.customLightColor = _l_custom_sun_light * from_twilight_compensate(s_c3)
      else
        c.customLightColor = __lightColor*2*_l_custom_sun_light    
      end
      
      
      c.color = (cloud.ac_cloud_color[i] - rgb(0.7,0.68,0.65)*water) --* s_c3

      --c.procScale = cloud.ac_cloud_proc_scale[i]
      --c.procShapeShifting = cloud.ramp

      c.opacity = opacity
      c.cutoff = math.lerp(1, cutoff, cloud.transition)

      c.up = up
      c.side = side
    end
  end
end