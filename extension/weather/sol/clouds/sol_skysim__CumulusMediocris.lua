-- include pattern file
dofile (__sol__path.."clouds\\3d\\pattern\\CumulusMediocris_pattern.lua")

local radius_fog = 0
local radius_opac = 0
local _l_humid = 0
local day_curve = 1
local _l_config__clouds__opacity_multiplier
local _l_config__shadow_opacity_multiplier
local small_clouds_opacity_mod = 0

local _l_mat_LUT = {
       -- sky,      ambient,  sun,      in front of sun,  water,    water_absorb,   base
  { -180, 1.00,     0.40,     0.00,     0.00,             1.00,     1.00,           1.00  },
  { -108, 1.00,     0.40,     0.00,     0.00,             1.00,     1.00,           1.00  },
  { -102, 1.00,     0.45,     0.00,     0.05,             1.00,     1.00,           1.00  },
  {  -99, 1.00,     0.50,     0.00,     0.07,             1.00,     1.00,           1.00  },
  {  -96, 1.00,     0.50,     0.00,     0.10,             1.00,     1.00,           1.00  },
  {  -93, 1.00,     0.50,     0.20,     0.12,             1.00,     1.00,           1.00  },
  {  -90, 0.50,     0.50,     0.90,     0.14,             1.00,     1.00,           1.00  },
  {-87.5, 0.75,     0.52,     1.10,     0.15,             1.00,     1.00,           1.00  },
  {  -85, 1.00,     0.54,     1.00,     0.16,             1.00,     1.00,           1.00  },
  {  -80, 1.00,     0.57,     0.85,     0.17,             1.00,     1.00,           1.20  },
  {  -75, 1.00,     0.60,     0.80,     0.18,             1.00,     1.00,           3.50  },
  {  -70, 1.00,     0.65,     0.75,     0.19,             1.00,     1.00,           5.00  },
  {  -60, 1.00,     0.70,     0.70,     0.20,             1.00,     1.00,           6.00  },
  {  -40, 1.00,     0.75,     0.70,     0.20,             1.00,     1.00,           5.00  },
  {  -20, 1.00,     0.80,     0.70,     0.20,             1.00,     1.00,           4.50  },
  {    0, 1.00,     0.80,     0.70,     0.20,             1.00,     1.00,           4.00  },
}
local _l_MATlut = {}
local _l_MATlutCPP = LUT:new(_l_mat_LUT, nil, true)
                 
local _l_style_LUT = {
       -- 1     2       3     4      5        6       7      8      9       10      11       12       13      14       15
       -- size,  rnd , cutoff,  rnd, scale,  scatter, soft,  sharp, contour clouds, back,   bottom,  ratio  scale_comp map_comp
  { 0.0,  4000, 3000,   1.20, 0.10,  2.50,   -0.50,   1.30,  0.00,  1.25,     1,      0,      1,       0.70,  0.30,     0.50        },
  { 0.1,  4500, 3000,   1.00, 0.10,  2.50,   -0.50,   1.30,  0.00,  1.10,     3,      0,      1,       0.75,  0.30,     0.50        },
  { 0.2,  5000, 3000,   0.80, 0.10,  2.50,   -0.50,   1.30,  0.05,  1.10,     4,      0,      1,       0.80,  0.30,     0.50        },
  { 0.3,  5500, 3000,   0.60, 0.05,  2.50,   -0.50,   1.30,  0.10,  1.15,     2,      0,      1,       0.82,  0.60,     0.30        },
  { 0.4,  6000, 3000,   0.40, 0.05,  2.50,   -0.50,   1.30,  0.25,  1.20,     3,      0,      1,       0.86,  0.60,     0.40        },
  { 0.5,  7000, 3000,   0.35, 0.10,  2.50,   -0.50,   1.30,  0.50,  1.20,     4,      0,      1,       0.90,  0.10,     0.10        },
  { 0.6,  8000, 3000,   0.30, 0.05,  2.50,   -0.45,   1.30,  0.75,  1.35,     5,      0,      1,       0.93,  0.20,     0.15        },
  { 0.7,  9000, 3000,   0.20, 0.05,  2.50,   -0.40,   1.20,  0.85,  1.25,     3,      0,      1,       0.97,  0.30,     0.30        },
  { 0.8, 10000, 2000,   0.10, 0.00,  2.50,   -0.40,   1.15,  0.85,  1.25,     4,      0,      1,       1.00,  0.15,     0.05        },
  { 0.9, 12000, 2000,   0.00, 0.00,  2.50,   -0.35,   1.10,  0.70,  1.15,     5,      0,      1,       1.05,  0.05,     0.025       },
  { 1.0, 14000, 2000,   0.00, 0.00,  2.50,   -0.30,   1.00,  0.65,  1.10,     4,      0,      1,       1.10,  0.03,     0.025       },
}
local _l_STYLElut
local _l_STYLElutCPP = LUT:new(_l_style_LUT)

local _l_dense_LUT = {
  { 0.0, 0, },
  { 0.1, 2, },
  { 0.2, 2, },
  { 0.3, 3, },
  { 0.4, 3, },
  { 0.5, 3, },
  { 0.6, 3, },
  { 0.7, 4, },
  { 0.8, 4, },
  { 0.9, 4, },
  { 1.0, 5, },
}
local _l_DENSElut
local _l_DENSElutCPP = LUT:new(_l_dense_LUT)

n = 1                  --1  
local _l_AC_Clouds_Positions = {}
_l_AC_Clouds_Positions[n] = vec3( 1, 0.5, 0) n=n+1
_l_AC_Clouds_Positions[n] = vec3(-1, 0.5, 0) n=n+1
_l_AC_Clouds_Positions[n] = vec3( 0, 0.5, 1) n=n+1
_l_AC_Clouds_Positions[n] = vec3( 0, 0.5,-1) n=n+1
_l_AC_Clouds_Positions[n] = vec3( 1, 0.5, 1) n=n+1
_l_AC_Clouds_Positions[n] = vec3(-1, 0.5, 1) n=n+1
_l_AC_Clouds_Positions[n] = vec3( 1, 0.5,-1) n=n+1

_l_AC_Clouds_Positions[n] = vec3( 0.5, 0.75, 0.0) n=n+1
_l_AC_Clouds_Positions[n] = vec3(-0.5, 0.75, 0.0) n=n+1
_l_AC_Clouds_Positions[n] = vec3( 0.0, 0.75, 0.5) n=n+1
_l_AC_Clouds_Positions[n] = vec3( 0.0, 0.75,-0.5) n=n+1
_l_AC_Clouds_Positions[n] = vec3( 0.5, 0.75, 0.5) n=n+1
_l_AC_Clouds_Positions[n] = vec3(-0.5, 0.75, 0.5) n=n+1
_l_AC_Clouds_Positions[n] = vec3( 0.5, 0.75,-0.5) n=n+1

function CumulusMediocris__create_clouds_from_pattern(layer, stack, pattern, pos, scale, water_mult)
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
        --water = math.lerp(math.min(1, math.pow(math.pow(water*1.5, 3) + math.pow((math.random()*(1-water)), 1.5), 2)), water, 0.75+0.25*math.pow(water_mult, 2))
        water = math.pow(water_mult, 2.4+math.random()*0.2) + math.random()*(1-water)*0.4*math.pow(water_mult, 0.5)
        water = math.min(1, math.max(0, water))
        style  = math.floor(style+1) * 0.1

        _l_STYLElut = _l_STYLElutCPP:get(style) --interpolate__plan(_l_style_LUT, nil, style)
        
        rand = rnd(1, 0.65)
        size = _l_STYLElut[1]

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

function Preload_CumulusMediocris_Textures()
  local accloud = ac.SkyCloudV2():setTexture('\\clouds\\3d\\Cumulus.png')
end

function Build_CumulusMediocris_Pattern(layer, dense, water, rnd_water)

  local stack = Stack:new()

  local i, ii

  local dh = (layer.ceiling - layer.bottom) *0.3
  local size
  local rand
  local pos = vec3(0,0,0)

  local style


  _l_DENSElut = _l_DENSElutCPP:get(dense) --interpolate__plan(_l_dense_LUT, nil, dense)
 
  local rnd_water_up   = water * 0.125
  local rnd_water_down = water * -0.45

  --local tiles = math.floor(_l_DENSElut[1] * __sky__layer_max_distance_base/35000) / math.max(1, math.pow(__sky__clouds_quality, 0.5))
  
  local sqare_size = 35000
  local tiles = layer.radius / sqare_size
 
  if tiles > 0 then
    local space = sqare_size

    for i=-tiles, tiles do 
      for ii=-tiles, tiles do
            
        pos.x = i*space
        pos.y = dh
        pos.z = ii*space

        CumulusMediocris__create_clouds_from_pattern(layer, stack, CumulusMediocris__get_pattern(dense), pos, space*0.1, water)

      end
    end
  end


--[[
rand = rnd(1, 0.65)
_l_STYLElut = interpolate__plan(_l_style_LUT, nil, 0.8)
size = _l_STYLElut[1] + (rand*_l_STYLElut[2])

  stack:add({
              { "pos", vec3(-15000, layer.bottom , 0) },
              { "size", size },
              { "water", water },
              { "style", 0.8 },
            })
]]
  


  return stack
end


function Create_CumulusMediocris_Layer(layer)

  layer.static = false
    --_l_DENSElut = interpolate__plan(_l_dense_LUT, nil, dense)
end

local cdf_cl = 1

function Update_CumulusMediocris_Layer(layer)

    _l_humid = math.pow(gfx__get_humidity(), 2)
    
    local cdf = gfx__get_custom_distant_fog()
    cdf_cl = cdf.color:getLuminance()

    radius_fog  = (math.max(0, 5.0 - 3.5*math.pow(_l_humid, 1-math.min(1, 0.1*cdf_cl))) * __sky__base_dome_size)
    radius_opac = ((5 - 1.0*_l_humid) * __sky__base_dome_size)

   
    _l_MATlut = _l_MATlutCPP:get() --interpolate__plan(_l_mat_LUT)

    _l_config__clouds__opacity_multiplier = SOL__config("clouds", "opacity_multiplier")
    _l_config__shadow_opacity_multiplier = SOL__config("clouds", "shadow_opacity_multiplier")
    
    opacity_mod = 0.6 * (1.2+0.3*layer.dense) * blue_sky_cloud_opacity * _l_config__clouds__opacity_multiplier / math.max(0.8, math.pow(__sky__clouds_quality, 0.25))
   
    day_curve = __IntD(0, 1, 0.8)
    small_clouds_opacity_mod = 1.5-from_twilight_compensate(0.5)
end


local clouds_db = {}

function Create_CumulusMediocris_Cloud(cloud)

  _l_STYLElut = interpolate__plan(_l_style_LUT, nil, cloud.style)

  local quality_comp = math.pow(1/__sky__clouds_quality, 0.125)
  local scale_comp = math.pow(1/__sky__clouds_quality, 0.125) * 1.0
  local t = cloud.size * 0.75
  local tt = cloud.size * 0.00001
  local size_mod = (1-math.max(0, math.min(1, cloud.size*0.0003)))
  local accloud

  local n = math.floor((_l_STYLElut[10]) * __sky__clouds_quality)
  
  if n < 2 then
    cloud.cloud_bottom = 0
    cloud.cloud_back   = 0
  else
    cloud.cloud_bottom = math.floor(_l_STYLElut[12])
    cloud.cloud_back   = math.floor(_l_STYLElut[11])
  end

  local test = 0

  cloud.ramp_speed = 0.001 + rnd(0.0002)

  cloud.cutoff = _l_STYLElut[3] + rnd(_l_STYLElut[4])
  --local scale = vec2(1 , (accloud.size.y/accloud.size.x))
  --scale =  local scale * math.max(1+tt*5, (1.0 + tt*17))

  cloud.ac_cloud_extra["procScale"] = {}
  cloud.ac_cloud_extra["normScale"] = {}
  cloud.ac_cloud_extra["procMap"] = {}
  cloud.ac_cloud_extra["sharpnessMult"] = {}

  cloud.ac_cloud_extra["compensations"] = { _l_STYLElut[14] , _l_STYLElut[15] }

  --##########################################################################################################
  --##########################################################################################################
  --##########################################################################################################
  --##########################################################################################################
  --##########################################################################################################

  local tex = math.floor(math.random()*6)

  for i=1, n-cloud.cloud_bottom-cloud.cloud_back do

    --TOP part

    cloud.ac_clouds_count = cloud.ac_clouds_count + 1

    accloud = cloudsstorage__get_free_cloud(2) --ac.SkyCloudV2()

    --increase differency
    tex = tex + 1
    if tex >= 7 then tex = 0 end

    -- offsets of the different parts
    cloud.ac_cloud_pos_offset[cloud.ac_clouds_count] = _l_AC_Clouds_Positions[i]
    --cloud.ac_cloud_pos_offset[cloud.ac_clouds_count] = vec3(rnd(1), 0.5 + rnd(0.2), rnd(1))
    local y_diff= (cloud.ac_cloud_pos_offset[cloud.ac_clouds_count].y-0.3)

    --accloud.texStart:set( vec2( tex*0.1, math.max(0, math.floor(cloud.style*10-1) * 0.1)) )
    accloud.texStart:set( vec2( tex*0.1, 0.7 + math.max(0, math.floor(cloud.style*3-1) * 0.1)) )
   
    accloud.texSize:set(vec2(0.1,0.1))
    accloud:setTexture('\\clouds\\3d\\Cumulus.png')
    --accloud:setTexture('\\clouds\\3d\\debug.png')
    --accloud:setTexture('\\clouds\\3d\\c8.png')


    local dd = math.pow( (math.pow(cloud.ac_cloud_pos_offset[cloud.ac_clouds_count].x, 2) 
                       +  math.pow(cloud.ac_cloud_pos_offset[cloud.ac_clouds_count].z, 2)
                         ) 
                       , 0.5)
    
    cloud.ac_cloud_sizes[cloud.ac_clouds_count] = vec2(cloud.size * (0.95+(tt*0.1)), 
                                                       1.7 * _l_STYLElut[13] * cloud.size *  (0.95-(tt*0.1)) * (0.35 + tt + rnd(0.15-(tt*0.1)))) 
                                                  * quality_comp * 1.1

    cloud.ac_cloud_sizes[cloud.ac_clouds_count] = cloud.ac_cloud_sizes[cloud.ac_clouds_count] * (1.025 - 0.05*dd)

    accloud.size = cloud.ac_cloud_sizes[cloud.ac_clouds_count] * (1-0.1*math.max(cloud.ac_cloud_pos_offset[cloud.ac_clouds_count].x, cloud.ac_cloud_pos_offset[cloud.ac_clouds_count].z))

    accloud.position = cloud.pos
    accloud.material = cloud.material

    accloud.horizontal = false
    accloud.customOrientation = false
    accloud.noTilt = false
    accloud.procScale = vec2(1.0, 1.0) 


    cloud.ac_cloud_color[cloud.ac_clouds_count] = hsv(215,
                      0.07,
                      0.95 + rnd(dd*0.05) + y_diff):toRgb()
    --texture choose debug
    --cloud.ac_cloud_color[cloud.ac_clouds_count] = hsv(tex*60, 1, 1):toRgb()
    
    accloud.color = cloud.ac_cloud_color[cloud.ac_clouds_count]
    accloud.occludeGodrays = true
    accloud.useCustomLightColor = true
    accloud.useCustomLightDirection = true

    local scale = (_l_STYLElut[5])+(y_diff*0.4)-size_mod*10

    cloud.ac_cloud_extra["procMap"][cloud.ac_clouds_count] = vec2(_l_STYLElut[6]+0.6*y_diff,_l_STYLElut[7]+0.5*y_diff+size_mod) 
    accloud.procMap = cloud.ac_cloud_extra["procMap"][cloud.ac_clouds_count]

    cloud.ac_cloud_extra["procScale"][cloud.ac_clouds_count] = vec2( scale , scale * (accloud.size.y / accloud.size.x)  ) * math.pow((cloud.size / 10000), 0.2) * scale_comp
    accloud.procScale = cloud.ac_cloud_extra["procScale"][cloud.ac_clouds_count]
    
    cloud.ac_cloud_extra["sharpnessMult"][cloud.ac_clouds_count] = (_l_STYLElut[8]-y_diff*0.30) --* math.max(0, 1-size_mod*1000)
    accloud.procSharpnessMult = cloud.ac_cloud_extra["sharpnessMult"][cloud.ac_clouds_count]

    cloud.ac_cloud_extra["normScale"][cloud.ac_clouds_count] = vec2(0.15+tt*1.50+rnd(0.05),_l_STYLElut[9]) 
    accloud.procNormalScale = cloud.ac_cloud_extra["normScale"][cloud.ac_clouds_count] 

    accloud.procShapeShifting = math.random()
    accloud.opacity = 0
    accloud.shadowOpacity = 0
    accloud.receiveShadowsOpacityMult = 1
    accloud.cutoff = cloud.cutoff
    accloud.useNoise = true

    accloud.up = vec3(0, -1, 0)
    accloud.side = math.cross(-accloud.position, accloud.up):normalize()
    accloud.up = math.cross(accloud.side, -accloud.position):normalize()
    accloud.noiseOffset:set(math.random(), math.random()) 

    cloud.ac_cloud_pos_offset[cloud.ac_clouds_count] = cloud.ac_cloud_pos_offset[cloud.ac_clouds_count] * t
    cloud.ac_clouds[cloud.ac_clouds_count] = accloud
  end

  --##########################################################################################################
  --##########################################################################################################
  --##########################################################################################################
  --##########################################################################################################
  --##########################################################################################################


  for i=n-cloud.cloud_bottom+1, n do

    -- Bottom part

    cloud.ac_clouds_count = cloud.ac_clouds_count + 1

    accloud = cloudsstorage__get_free_cloud(2) --ac.SkyCloudV2()

    accloud.texStart:set( vec2( 0.7+math.floor(math.random()*3)*0.1, math.max(0, math.floor(cloud.style*10-1) * 0.1)) )
    accloud.texSize:set(vec2(0.1,0.1))
    accloud:setTexture('\\clouds\\3d\\Cumulus.png')
    --accloud:setTexture('\\clouds\\3d\\debug.png')
    --accloud:setTexture('\\clouds\\3d\\bottom3.png')

    cloud.ac_cloud_sizes[cloud.ac_clouds_count] = vec2(cloud.size * 1, cloud.size * 1) * 1.1
    accloud.size = cloud.ac_cloud_sizes[cloud.ac_clouds_count]

    accloud.position = cloud.pos
    cloud.ac_cloud_pos_offset[cloud.ac_clouds_count] = vec3(0, 0.25, 0)

    accloud.material = cloud.material

    accloud.horizontal = true
    accloud.customOrientation = false
    accloud.noTilt = false

    cloud.ac_cloud_color[cloud.ac_clouds_count] = hsv(218,
                      0.08,
                      1.25):toRgb()

    
    accloud.color = cloud.ac_cloud_color[cloud.ac_clouds_count]
    accloud.occludeGodrays = false
    accloud.useCustomLightColor = true
    accloud.useCustomLightDirection = false

    local scale = 1.5*scale_comp

    cloud.ac_cloud_extra["procMap"][cloud.ac_clouds_count] = vec2(_l_STYLElut[6],_l_STYLElut[7]*2) 
    accloud.procMap = cloud.ac_cloud_extra["procMap"][cloud.ac_clouds_count]

    cloud.ac_cloud_extra["procScale"][cloud.ac_clouds_count] = vec2( scale , scale * (accloud.size.y/accloud.size.x)) 
    accloud.procScale = cloud.ac_cloud_extra["procScale"][cloud.ac_clouds_count]
    
    cloud.ac_cloud_extra["sharpnessMult"][cloud.ac_clouds_count] = 0.6--(_l_STYLElut[8]) * math.max(0, 1-size_mod*4)
    accloud.procSharpnessMult = cloud.ac_cloud_extra["sharpnessMult"][cloud.ac_clouds_count]

    cloud.ac_cloud_extra["normScale"][cloud.ac_clouds_count] = vec2(0.25+tt*3.00+rnd(0.05),_l_STYLElut[9]*0.3) 
    accloud.procNormalScale = cloud.ac_cloud_extra["normScale"][cloud.ac_clouds_count] 


    accloud.procShapeShifting = math.random()
    accloud.opacity = 0
    accloud.shadowOpacity = 0
    accloud.cutoff = cloud.cutoff
    accloud.useNoise = true

    accloud.up = vec3(0, -1, 0)
    accloud.side = math.cross(-accloud.position, accloud.up):normalize()
    accloud.up = math.cross(accloud.side, -accloud.position):normalize()
    accloud.noiseOffset:set(math.random(), math.random()) 

    cloud.ac_cloud_pos_offset[cloud.ac_clouds_count] = cloud.ac_cloud_pos_offset[cloud.ac_clouds_count] * t
    cloud.ac_clouds[cloud.ac_clouds_count] = accloud
  end
end





--###################################################################################################

local min_sky_color = 100


function Update_CumulusMediocris_Cloud(cloud, everything)

  local t = osc_test.value

  local size_mod = (1-math.max(0, math.min(1, cloud.size*0.0003)))

  local tt = cloud.size * 0.00001
  local c
  local n = cloud.ac_clouds_count
  local d = cloud.lastDistance
  local bottom_switch_radius = 23000 - size_mod*2000
  local top_switch_radius = 19000 - size_mod*2000
  local sharpness_radius = 22000

  local calc_radius = cloud.layer.radius * 0.95
  local visible     =   math.pow(math.max(0, math.min(1, 4*((calc_radius - d) / calc_radius))), 0.5)

  if visible <= 0 then
    for i=1,n do
      cloud.ac_clouds[i].opacity = 0
    end
    return
  end

  local visible_top    --= 1-math.max(0, math.min(1, 2 * ((top_switch_radius - d)    / top_switch_radius)))
  local visible_back 
  local sharpness--      = 1-math.max(0, math.min(1, 1 * ((sharpness_radius - d) / sharpness_radius)))

  local s_c3
  local s_c4
  local s_c5
  local water
  local water_color
  local shadow_opacity = 1
  local vec_add 
  local c_tlp
  local color_distance
  local d_mod_opac = d/radius_opac
  local d_mod_fog  = math.min(1, math.pow(d/radius_fog, 2))
  local d_mod_near = math.lerp(1, math.pow(d/radius_opac, math.max(0, 0.25+0.5*__sky__clouds_quality-0.5*cloud.water_filled)), from_twilight_compensate(0))
  local procMap_mod
  local normScale_mod
  local custom_dir
  local custom_light
  
  local midrange_opacity = (1-0.35*cloud.style*(1-d_mod_opac)) * math.lerp(1, 1.20-(0.20*d_mod_opac), from_twilight_compensate(0))   --math.max(0, math.min(1, (0.75+0.25*math.max(d_mod_near, 1.2-n*0.2 ))))
  
  local custom_lighting = { color=rgb(0,0,0), dir=vec3(0,1,0) }

--[[
  local fog = gfx__get_fog_dense(d*0.175)

  if fog >= 1 then
    --if fog is full evolved for the cloud, don't calculate the color
    cloud.material.baseColor = rgb(1,1,1)
    cloud.material.fogMultiplier = 1

    cloud.materialBottom.baseColor = rgb(1,1,1)
    cloud.materialBottom.fogMultiplier = 1

    everything = false
  end
]]

  if everything then

      cloud.light_bounce = (1-cloud.water_filled) * 8.5 * tt
      cloud.layer:addLightBounce(cloud)

      s_c3 = cloud:getLightSourceRelevance(0.25, 2, 2.5) -- light source azimut modulator 0 = opposite direction, 1 = sun direction
      s_c5 = vec_diff(__lightDir, cloud.vec_simple, 1.5) -- light source vector modulator 0 = most difference of vector, 1 = cloud vector matches light source vector
      s_c4 = s_c5 * from_twilight_compensate(0)


      water = math.pow(cloud.water_filled*0.5, 3)
  
      custom_lighting = update_clouds_lighting(cloud, d_mod_opac, d_mod_fog, d_mod_near)

      -- less dense with distance, more dense with backlit
      procMap_mod   = vec2( sun_compensate(2)-0.5*s_c3
                            ,
                            1.25
                          -- 0.50 * cloud.water_filled
                          + (d_mod_opac+(0.3 - 0.6*cloud.water_filled)*s_c3)
                          -- math.min(0.5+0.5*cloud.water_filled, (1-sun_compensate(0))*1.5*s_c5)
                          )
     
      -- more bumpmap with backlit and distance, less with night night
      normScale_mod = (0.6+0.15*d_mod_fog)*vec2( 1.25 * sun_compensate(0.8),   (0.90*sun_compensate(0.5)+0.25*s_c3) * day_compensate(0.5)   )
      
      -- sharper with distance
      sharpness     = (1.2+0.8*d_mod_fog)-0.4*cloud.water_filled --math.max(0, (1.0-4.0*(1-sun_compensate(0))*sun_glow_mod))*(1.2-1.2*math.max(0, math.min(1, 1 * ((sharpness_radius - d) / sharpness_radius))))
      -- sharper with water
      sharpness     = math.min(1.2, math.lerp(sharpness*0.9, sharpness * 2, water*4))


      normScale_mod.x = normScale_mod.x * day_compensate(0.25) * 0.75

      -- reduce lighting sharpness in nighttimes
      --procMap_mod.y   = procMap_mod.y * (1 + 1.5*sun_glow_mod)

      -- more dense with water
      procMap_mod   = math.lerp(procMap_mod, procMap_mod * 0.70, math.min(0.6, cloud.water_filled))

      -- dense mod for big clouds
      --procMap_mod = procMap_mod * math.lerp(vec2((6-3*cloud.water_filled)+6*s_c3,  2.5-cloud.water_filled), vec2(1.00,1.25), day_curve * (1-0.5*cloud.water_filled))

      
      
      -- softer with backlit, but sharper with sunset
      --sharpness     = math.lerp(sharpness, sharpness * (0.8+4*water), s_c3 * sun_compensate(0.5))

  end

  local top_opacity
  local back_opacity
  local top_cutoff
  local back_cutoff

  -- make clouds biger and higher when they are near 
  -- make them smaller and more stretched with distance
  local pos_rel = 1-0.6*cloud.radius_position_relation
  local dist_illusion_vec = vec2( (1.00 + math.pow(pos_rel, 2.0) * 0.60),
                                  (0.65 + math.pow(pos_rel, 1.5) * 0.70))

  local fidelity_mod = math.pow( math.max(0, d_mod_fog), 1.25)
  local opacity_fog_mod = (1 - d_mod_near * math.pow(math.max(0, cloud.material.fogMultiplier-0.25), 2))
  local twiligth_small_clouds = math.min(0.5, cloud.style)*2
  twiligth_small_clouds = (1 - (twiligth_small_clouds * twiligth_small_clouds))*small_clouds_opacity_mod

  for i=1, n-cloud.cloud_bottom-cloud.cloud_back do

    -- general fluffy clouds

    d = math.horizontalLength(cloud.ac_clouds[i].position)
    visible_top    = 1-math.max(0, math.min(1, 2 * ((top_switch_radius - d)    / top_switch_radius)))
    top_opacity    = midrange_opacity * opacity_mod * (1.05+0.2*cloud.water_filled) * visible * visible_top * cloud.transition * math.max(0, 1 - (d_mod_opac*(2.5*_l_humid)))
    top_opacity    = math.min(1.05, 1.25 * top_opacity * opacity_fog_mod) 
    top_opacity    = top_opacity - twiligth_small_clouds
    top_cutoff     = math.max(0, math.min(1, (0.5 - 1.5*visible) + 0.8 - 0.8*visible_top + cloud.cutoff - 0.25*cloud.water_filled))

    c = cloud.ac_clouds[i]

    c.size = cloud.ac_cloud_sizes[i] * dist_illusion_vec

    if __CSP_version >= 1074 then c.extraFidelity = fidelity_mod end

    if everything then

        c.useCustomLightDirection = true
        c.customLightColor = custom_lighting.color
        c.customLightDirection = custom_lighting.dir

        c.procSharpnessMult = math.max((1-sun_compensate(0))*0.5, math.min(1.0, cloud.ac_cloud_extra["sharpnessMult"][i] * sharpness))
        c.procMap = cloud.ac_cloud_extra["procMap"][i] * procMap_mod

        c.procNormalScale = cloud.ac_cloud_extra["normScale"][i] * normScale_mod

        c.color = cloud.ac_cloud_color[i]

        c.opacity = top_opacity * math.pow(cloud.ac_cloud_extra["procMap"][i].y, duskdawn_compensate(0.25) * cloud.ac_cloud_extra["compensations"][2] * (0.80+0.20*s_c3))
    else
        c.opacity = top_opacity
    end

    c.shadowOpacity = _l_config__shadow_opacity_multiplier * (0.7+0.3*cloud.water_filled) * visible * visible_top * cloud.transition
    c.cutoff  = top_cutoff
  end
    
  for i=n-cloud.cloud_bottom+1, n do

    -- bottom part

    d = math.horizontalLength(cloud.ac_clouds[i].position)
    visible_bottom  = math.max(0, math.min(1, 2 * ((bottom_switch_radius - d)    / bottom_switch_radius)))
    bottom_opacity  = math.min(1.00, 1.15 * opacity_mod * visible  * visible_bottom - size_mod*0.35) * cloud.transition
    bottom_cutoff   = 0--math.max(0, 1 - visible_bottom + cloud.cutoff)

    c = cloud.ac_clouds[i]
    c.size = cloud.ac_cloud_sizes[i] * (1.0 + 1.5 * d_mod_opac) --expand the bottom part a little bit to improve cloud shadow

    if everything then

      c.useCustomLightDirection = false
      c.customLightColor = custom_lighting.color

      c.color = cloud.ac_cloud_color[i]
    end

    c.shadowOpacity = _l_config__shadow_opacity_multiplier * (0.7+0.3*cloud.water_filled) * visible * cloud.transition

    c.opacity = bottom_opacity
    c.cutoff  = bottom_cutoff
  end
end
