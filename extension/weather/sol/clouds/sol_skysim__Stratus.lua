-- include pattern file
dofile (__sol__path.."clouds\\3d\\pattern\\Stratus_pattern.lua")

local dense_mod = 0
local dense_mod2 = 0
local _l_config__clouds__opacity_multiplier
local _l_config__shadow_opacity_multiplier
local _l_config__nerd__clouds_adjust_Contour

n = 1
local _l_mat_LUT = {
       --sun, water,  front, dist_fog, sun_dist, amb
 { -180, 0.0,  0.10,   0.0 ,  0.0 ,     0.05,    1.00 },
 { -108, 0.0,  0.10,   0.0 ,  0.0 ,     0.05,    1.00 },
 { -102, 0.0,  0.30,   0.0 ,  0.0 ,     0.05,    1.00 },
 {  -99, 0.0,  1.00,   0.0 ,  0.0 ,     0.05,    1.00 },
 {  -96, 0.0,  1.00,   0.0 ,  0.0 ,     0.05,    1.00 },
 {  -93, 0.0,  1.00,   0.0 ,  0.0 ,     0.05,    1.00 },
 {-91.5,0.05,  1.00,   0.1 ,  0.0 ,     0.05,    1.00 },
 {  -90,0.12,  1.00,   0.3 ,  0.0 ,     0.50,    1.00 },
 {-87.5,0.18,  1.00,   0.4 ,  0.0 ,     0.75,    1.00 },
 {  -85,0.30,  1.20,   0.45,  0.0 ,     0.40,    1.00 },
 {  -80,0.40,  1.40,   0.2 ,  0.0 ,     0.10,    1.00 },
 {  -75,0.30,  1.50,   0.2 ,  0.0 ,     0.15,    1.00 },
 {  -70,0.20,  1.40,   0.2 ,  0.0 ,     0.20,    1.00 },
 {  -60,0.15,  1.15,   0.2 ,  0.0 ,     0.25,    1.00 },
 {  -40,0.10,  1.00,   0.2 ,  0.0 ,     0.25,    1.00 },
 {  -20,0.10,  1.00,   0.2 ,  0.0 ,     0.25,    1.00 },
 {    0,0.10,  1.00,   0.2 ,  0.0 ,     0.25,    1.00 },
}
local _l_MATlut = {}  
local _l_MATlutCPP = LUT:new(_l_mat_LUT, nil, true) 

function Stratus__create_clouds_from_pattern(layer, stack, pattern, pos, scale, water_mult)
  local style = 0
  local size = 0
  local water = 0
  local cloud_pos

  local i, ii

  for i=1, #pattern do
    for ii=1, #pattern[i] do
      
      style  = math.floor(pattern[i][ii] * 0.1)
      if style >= 1 then

        water = (pattern[i][ii] - style * 10) * 0.1 * water_mult
        style  = math.floor(style+1) * 0.1
        
        rand = rnd(1, 0.65)
        size = style * 45000

        cloud_pos = vec3(pos.x+i*scale, (rand*pos.y) , pos.z+ii*scale)

        if math.horizontalLength(cloud_pos - __sky__camShift) <= layer.radius then
        
          stack:add({
            { "pos", cloud_pos },
            { "size", size },
            { "water", water },
            { "style", style },
          })
        end
      end
    end
  end
end

function Preload_Stratus_Textures()
  local accloud = ac.SkyCloudV2():setTexture('\\clouds\\3d\\Stratus.png')
end

function Build_Stratus_Pattern(layer, dense, water, rnd_water)
--[[
  local stack = Stack:new()
  local cloud_pos

  if dense > 0.1 then

    local n = math.max(3, math.floor(__sky__layer_max_distance_base * math.min(1, math.pow(dense, 1.00)) / 8000))-1

    local tile = layer.radius/n

    local size = math.min(115000/ (__sky__layer_max_distance_base/25000) , 3*tile*math.pow(dense, 1.25))

    local dh = (layer.ceiling - layer.bottom)

    local w = 0

    for i=-n, n do 
        for ii=-n, n do
          
          rnd_water = rnd(0.05)-- math.random()*0.75-0.375 ---math.lerp(rnd_water_down, rnd_water_up, math.pow(math.random(), 1-0.5*water) )

          cloud_pos = vec3(i*tile, dh * (1-w), ii*tile)
          if math.horizontalLength(cloud_pos - __sky__camShift) <= layer.radius then

            stack:add({
              { "pos", cloud_pos },
              { "size", size },
              { "water", math.min(1, math.max(0, water + rnd_water)) },
              { "style", dense },
            })
          end
        end
    end
  end
]]
  local stack = Stack:new()

  local i, ii

  local dh = (layer.ceiling - layer.bottom) *0.3
  local size
  local rand
  local pos = vec3(0,0,0)

  local style

 
  local rnd_water_up   = water * 0.05
  local rnd_water_down = water * -0.10

  local sqare_size = 35000
  local tiles = layer.radius / sqare_size
 
  if tiles > 0 then
    local space = sqare_size

    for i=-tiles, tiles do 
      for ii=-tiles, tiles do
            
        pos.x = i*space
        pos.y = dh
        pos.z = ii*space

        Stratus__create_clouds_from_pattern(layer, stack, Stratus__get_pattern(dense), pos, space*0.1, water)

      end
    end
  end





  return stack
end


function Create_Stratus_Layer(layer)

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

function Update_Stratus_Layer(layer)
  
  _l_config__nerd__clouds_adjust_Contour = SOL__config("nerd__clouds_adjust", "Contour")

  dense_mod = 1-math.max(0, math.min(1, math.pow(layer.dense + 0.3, 1.5)))
  dense_mod2 = 1-math.max(0, math.min(1, math.pow(math.max(0, layer.dense - 0.5), 0.76) * 2))
  
  _l_MATlut = _l_MATlutCPP:get() --interpolate__plan(_l_mat_LUT)

  _l_config__clouds__opacity_multiplier = SOL__config("clouds", "opacity_multiplier")
  _l_config__shadow_opacity_multiplier = SOL__config("clouds", "shadow_opacity_multiplier")
  
end

--local ttttmin = 10
--local ttttmax = 0
function Create_Stratus_Cloud(cloud)

  cloud.draw_method = 1

  local accloud
  local t = cloud.size * 0.33
  local tt = cloud.size * 0.00001
  local size_mod = (1-math.max(0, math.min(1, cloud.size*0.0003)))

  local n = math.max(1, math.floor(cloud.size * 0.00012 * __sky__clouds_quality))
  --cloud.cloud_type_change = math.floor(n * 0.75)

  --[[
  if tt < ttttmin then
    ttttmin = tt
    ac.debug("###min",ttttmin)
  end
  if tt > ttttmax then
    ttttmax = tt
    ac.debug("###max",ttttmax)
  end
  ]]

  dense_mod = 1-math.max(0, math.min(1, math.pow(cloud.layer.dense + 0.3, 1.5)))
  dense_mod2 = 1-math.max(0, math.min(1, math.pow(math.max(0, cloud.layer.dense - 0.5), 0.76) * 2))

  local scattered = math.max(0.6+rnd(0.2), 2.0*tt+rnd(0.25)) * (0.7+0.3*dense_mod2) * 1.25

  cloud.ac_cloud_extra["procScale"] = {}


  cloud.ramp_speed = 0.00050 + rnd(0.00005)

  local tex = math.floor(math.random()*5)

  for i=1, n do

    cloud.ac_clouds_count = cloud.ac_clouds_count + 1

    accloud = cloudsstorage__get_free_cloud(2) --ac.SkyCloudV2()

    cloud.ac_cloud_pos_offset[cloud.ac_clouds_count] = vec3(rnd(1), 0, rnd(1))

    tex = tex + 1
    if tex >= 5 then tex = 0 end

    

    accloud.texStart:set( vec2( tex*0.2, math.max(0, math.floor(cloud.style*5-1) * 0.2)) )
    accloud.texSize:set(vec2(0.2,0.2))
    accloud:setTexture('\\clouds\\3d\\Stratus.png')

    cloud.ac_cloud_sizes[cloud.ac_clouds_count] = vec2(math.max(9000, math.pow(cloud.size, 0.92+(tt*0.1))), 
                                                       math.max(9000, math.pow(cloud.size, 0.92+(tt*0.1))))
                                                * 0.90

    accloud.size = cloud.ac_cloud_sizes[cloud.ac_clouds_count]

    accloud.position = cloud.pos
    accloud.material = cloud.material

    accloud.horizontal = true
    accloud.customOrientation = true
    accloud.noTilt = true
    accloud.procScale = vec2(1.0, 1.0) * 1.0

    cloud.ac_cloud_color[cloud.ac_clouds_count] = hsv(220,
                      0.085,
                      1.0):toRgb()

    
    accloud.color = cloud.ac_cloud_color[cloud.ac_clouds_count]
    accloud.occludeGodrays = true
    accloud.useCustomLightColor = true
    accloud.useCustomLightDirection = true


    local scale = scattered

    accloud.procMap = vec2(0.01+0.15*dense_mod,0.9+0.3*dense_mod)--vec2(0.05+rnd(0.05), 3.0+rnd(0.5))

    cloud.cutoff = 0.10 + (dense_mod*0.3+rnd(0.05)) + 10*math.max(0, 0.45-tt)
    cloud.ac_cloud_extra["procScale"][cloud.ac_clouds_count] = vec2( scale , scale) 
    accloud.procScale = cloud.ac_cloud_extra["procScale"][cloud.ac_clouds_count]
    
    accloud.procSharpnessMult = 0.5
    accloud.procNormalScale = vec2(1.0, 1.0)
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

function Update_Stratus_Cloud(cloud, everything)


  local tt = cloud.size * 0.00005
  local c
  local d = cloud.lastDistance
  local radius = cloud.layer.radius * 0.95
  
  local visible = math.max(0, math.min(1, 4 * ((radius - d) / radius)))

  if visible <= 0 then
    for i=1, cloud.ac_clouds_count do
      cloud.ac_clouds[i].opacity = 0
    end
    return
  end
  
  local curved = math.max(0, math.min(1, d/radius))
  
  local d_mod = d/radius

  local custom_lighting = { color=rgb(0,0,0), dir=vec3(0,1,0) }

  if everything then

    custom_lighting = update_clouds_lighting(cloud, d_mod, d_mod, d_mod)
  end


  cloud.light_bounce = (1-cloud.water_filled) * 0.75 * tt
  cloud.layer:addLightBounce(cloud)

  water = math.max(0, math.min(1, math.pow(cloud.water_filled, 1.35)))*0.6*day_compensate(0)

  local w = _toRadians(-7.5 * (math.pow(curved, 2)))

  local vec_pos = cloud.pos - __camPos
  vec_pos:normalize()

  local temp = vec32sphere(vec_pos)
  local rotation_vec = sphere2vec3(temp[1]+90, 0)

  temp = vec32sphere(cloud.layer.wind_normalized)
  local up = sphere2vec3(temp[1],0)
  local side = sphere2vec3(temp[1]+90,0)

  up:rotate(quat.fromAngleAxis(w, rotation_vec))
  side:rotate(quat.fromAngleAxis(w, rotation_vec))


  local opacity = math.min(1.0, 1.0*(1.0+water) * blue_sky_cloud_opacity * _l_config__clouds__opacity_multiplier * visible * cloud.transition)
  local cutoff = math.lerp(1, cloud.cutoff, cloud.transition) 


  local fidelity_mod = 0.25 + 0.25 * d_mod

  local _l_light_color = custom_lighting.color * 0.175

  local size__near_mod, d_mod_new
  for i=1, cloud.ac_clouds_count do

    c = cloud.ac_clouds[i]

    if __CSP_version >= 1074 then c.extraFidelity = fidelity_mod end

    if everything then
      c.customLightColor = _l_light_color
      c.customLightDirection = custom_lighting.dir 
    end

    --c.color = (cloud.ac_cloud_color[i]) --- rgb(0.7,0.68,0.65)*water) 

    --c.procScale = cloud.ac_cloud_proc_scale[i]
    --c.procShapeShifting = cloud.ramp
    c.procNormalScale = vec2(1.0, _l_config__nerd__clouds_adjust_Contour)

    c.shadowOpacity = (0.7 + 0.3 * water) * _l_config__shadow_opacity_multiplier * visible * cloud.transition

    c.opacity = opacity
    c.cutoff = math.max(d_mod*0.87, math.lerp(1, cutoff, cloud.transition))

    c.up = up
    c.side = side
  end
  
end