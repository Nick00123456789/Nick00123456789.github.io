--------
-- Clouds: spawning dynamically in chunks, moving with the wind and what not.
--------

-- Local state
local windDir = vec2(1, 0)
local windSpeed = 100
-- local windSpeed = 0

local pollusion_rgb
local pollusion_bright_mod
local downlit

local fog__multi

local fps_clouds_quality_multi = 1

-- How many textures of different types are available, with sizes and offsets in the atlas
local CloudTextures = {
  Blurry = { group = 'b', count = 8, start = vec2(0, 0/8), size = vec2(1/4, 1/8) },
  Hovering = { group = 'h', count = 1, start = vec2(0, 2/8), size = vec2(1/4, 1/8) },
  Spread = { group = 's', count = 1, start = vec2(0, 4/8), size = vec2(1/4, 1/8) },
  Flat = { group = 'f', count = 3, start = vec2(0, 6/8), size = vec2(1/4, 1/8) },
  Bottoms = { group = 'd', count = 5, start = vec2(0, 7/8), size = vec2(1/8, 1/8) },
}



local _l_sun_light_low_LUT = {
  {-180,  0, 0.00, 0.00 },
  { -98, 10, 0.70, 0.00 },
  { -94, 20, 0.90, 2.00 },
  { -90, 21, 1.00, 2.70 },
  { -85, 24, 0.80, 3.00 },
  { -80, 32, 0.62, 3.50 },
  { -75, 38, 0.54, 3.80 },
  { -70, 43, 0.46, 4.00 },
  { -60, 44, 0.26, 4.00 },
  { -45, 48, 0.24, 4.00 },
  { -30, 50, 0.21, 4.00 },
  {   0, 50, 0.20, 4.00 },
}
local _l_sun_low__LUT
local _l_sun_lowCPP = LUT:new(_l_sun_light_low_LUT, {1}, true)
_g_clouds__sun_light__low = rgb(1,1,1)


local _l_sun_light_high_LUT = {
  {-180,  0, 0.00, 0.00 },
  {-105, 15, 0.00, 0.00 },
  {-102, 15, 0.60, 0.10 },
  { -99, 20, 0.70, 2.00 },
  { -96, 24, 0.80, 6.00 },
  { -90, 26, 0.90, 4.00 },
  { -85, 28, 0.50, 4.00 },
  { -80, 32, 0.40, 4.00 },
  { -75, 38, 0.35, 4.00 },
  { -70, 43, 0.33, 4.00 },
  { -60, 44, 0.31, 4.00 },
  { -45, 48, 0.30, 4.00 },
  { -30, 50, 0.30, 4.00 },
  {   0, 50, 0.30, 4.00 },
}
local _l_sun_high__LUT
local _l_sun_highCPP = LUT:new(_l_sun_light_high_LUT, {1}, true)
_g_clouds__sun_light__high = rgb(1,1,1)

n = 1
local _l_clouds__improved_light_with_low_sun_LUT = {
  {-180, 0.00, 1.00 },
  { -96, 0.00, 1.00 },
  { -93, 0.20, 1.00 },
  { -90, 1.00, 1.00 },
  { -75, 1.00, 1.50 },
  { -70, 0.80, 1.35 },
  { -60, 0.70, 1.25 },
  { -50, 0.60, 1.00 },
  {   0, 0.50, 1.00 },
}
local _l_clouds__improved_light_with_low_sun = 0
local _l_clouds__improved_light_with_low_sunCPP = LUT:new(_l_clouds__improved_light_with_low_sun_LUT, nil, true)


-- Creates a new cloud and sets it using `fn`, which would be one of `CloudTypes` functions
local function createCloud(fn, arg1, arg2)
  local cloud = ac.SkyCloudV2()
  local c_r = rnd(0.10)
  local color = hsv(230,
                    0.08 * c_r,
                    0.97 + c_r):toRgb()
  cloud.color = color
  cloud.procMap = vec2(0.6, 0.65 + math.random() * 0.05) + math.random() * 0.1
  cloud.procNormalScale = vec2(0.9, 0.3)
  cloud.procShapeShifting = math.random()
  cloud.opacity = 1--SOL__config("clouds", "shadow_opacity_multiplier") * 0.95
  cloud.shadowOpacity = SOL__config("clouds", "shadow_opacity_multiplier")
  cloud.cutoff = 0
  cloud.occludeGodrays = false
  cloud.useNoise = true
  cloud.material = CloudMaterials.Main
  cloud.up = vec3(0, -1, 0)
  cloud.side = math.cross(-cloud.position, cloud.up):normalize()
  cloud.up = math.cross(cloud.side, -cloud.position):normalize()
  cloud.noiseOffset:set(math.random(), math.random()) 
  fn(cloud, arg1, arg2)
  return cloud
end

-- Various helper functions for clouds
local cloudutils = {}
function cloudutils.setPos(cloud, params)
  params = params or {}
  local height = params.height or 100 + math.random() * 200
  local sizeMult = params.size or 1
  local aspectRatio = params.aspectRatio or 0.32
  local distanceMult = params.distance or 10
  local pos = params.pos and params.pos:clone():normalize() or math.randomVec2():normalize()
  cloud.size = vec2(130, 130 * aspectRatio) * sizeMult * (1 + 0.5 * math.random()) * distanceMult
  cloud.position = vec3(400 * pos.x, height, 400 * pos.y) * distanceMult
  --cloud.position = cloud.position - _g_camPos
  cloud.horizontal = params.horizontal or false
  cloud.customOrientation = params.customOrientation or false
  cloud.noTilt = params.noTilt or false
  cloud.procScale = vec2(1.0, (params.horizontal and 1 or 1.2) * aspectRatio) * (params.procScale or 1) * sizeMult
end
function cloudutils.setTexture(cloud, type)
  local index = math.floor(math.random() * type.count)
  --cloud:setTexture('/clouds/3d_basemod/clouds/' .. type.group .. index .. '.png')
  cloud:setTexture(__sol__path.."clouds\\3d_basemod\\clouds\\" .. type.group .. index .. ".png")
  cloud.flipHorizontal = math.random() > 0.5
  return index
end
function cloudutils.setProcNormalShare(cloud, globalShare, totalIntensity)
  globalShare = globalShare or 0.5
  totalIntensity = totalIntensity or 1
  cloud.procNormalScale = vec2((1 - globalShare) * totalIntensity, globalShare * totalIntensity)
end

-- Different types of clouds
local CloudTypes = {}
function CloudTypes.Basic (cloud, pos)
  cloudutils.setTexture(cloud, CloudTextures.Blurry)
  -- cloud.procMap = vec2(0.6, 0.95 - math.random() * 0.2) + math.random() * 0.1
  cloud.procMap = vec2(0.6, 0.85) + math.random() * 0.15
  -- cloud.procMap = vec2(0.4, 0.5) + math.random() * 0.15
  cloud.procSharpnessMult = math.random()
  cloudutils.setProcNormalShare(cloud, 0.6)
  cloudutils.setPos(cloud, { 
    pos = pos, 
    size = (1 + math.random()) * 2, 
    procScale = 0.45 
  })
end
function CloudTypes.Dynamic(cloud, pos)
  cloudutils.setTexture(cloud, CloudTextures.Blurry)
  cloud.occludeGodrays = true
  cloud.useCustomLightColor = true
  cloud.useCustomLightDirection = true
  if math.random() > 0.8 then 
    cloud.procMap = vec2(0.5, 0.75) + math.random() * 0.15
    cloud.procSharpnessMult = 0.8
    cloudutils.setProcNormalShare(cloud, 0.6, 1.4)
    cloudutils.setPos(cloud, { 
      pos = pos, 
      size = (1 + math.random()) * 1.5 * CloudSpawnScale, 
      procScale = 1.2 * (0.8 + 0.2 * math.random()) / CloudSpawnScale
    })
  else
    cloud.procMap = vec2(0.6, 0.82) + math.random() * 0.08
    cloud.procSharpnessMult = math.random() ^ 2
    cloudutils.setProcNormalShare(cloud, 0.6, 1.4)
    cloudutils.setPos(cloud, { 
      pos = pos, 
      size = (1 + math.random()) * 2.5 * CloudSpawnScale, 
      procScale = 0.85 * (0.5 + 0.5 * math.random()) / CloudSpawnScale
    })
  end
end
function CloudTypes.Bottom(cloud, mainCloud)
  cloudutils.setTexture(cloud, CloudTextures.Bottoms)
  cloud.occludeGodrays = true
  cloud.useCustomLightColor = true
  cloud.shadowOpacity = cloud.shadowOpacity * 1.5
  cloud.horizontal = true
  cloud.horizontalHeading = math.random() * 360
  cloud.procScale:set(1, 1)
  cloud.procMap = mainCloud.procMap * vec2(0.8, 1)
  cloud.procSharpnessMult = mainCloud.procSharpnessMult
  local size = (mainCloud.size.x + mainCloud.size.y) / 2
  cloud.size:set(size, size)
  cloudutils.setProcNormalShare(cloud, 0.7, 1.4)
  cloud.material = CloudMaterials.Bottom
end
function CloudTypes.Hovering(cloud, pos)
  cloudutils.setTexture(cloud, CloudTextures.Hovering)
  cloud.opacity = cloud.opacity * 0.35
  cloud.useCustomLightColor = true
  cloud.shadowOpacity = 0.2 * SOL__config("clouds", "shadow_opacity_multiplier")
  cloud.procMap = vec2(0.5, 0.85) + math.random() * 0.15
  cloud.procSharpnessMult = math.random() ^ 2
  cloudutils.setProcNormalShare(cloud, 0.75)

  cloudutils.setPos(cloud, { 
    pos = pos, 
    horizontal = true,
    size = (1 + math.random()) * 12 * CloudSpawnScale, 
    procScale = 0.125 / CloudSpawnScale
  })
  cloud.horizontalHeading = math.atan2(windDir.y, -windDir.x) * 180 / math.pi + math.random() * 30 - 15
  cloud.material = CloudMaterials.Hovering
end
function CloudTypes.Spread(cloud, pos)
  cloudutils.setTexture(cloud, CloudTextures.Spread)
  cloud.procMap = vec2(0.5, 0.85) + math.random() * 0.05
  cloud.procSharpnessMult = math.random() ^ 2
  cloudutils.setProcNormalShare(cloud, 0.75)

  local isSpread = math.random() > 0.5
  cloudutils.setPos(cloud, { 
    pos = pos, 
    horizontal = true,
    size = (1 + math.random() * 2.5) * 5 * CloudSpawnScale, 
    procScale = 0.05 / CloudSpawnScale,
    aspectRatio = 1.0
  })
  cloud.horizontalHeading = math.atan2(windDir.y, -windDir.x) * 180 / math.pi + math.random() * 20 - 10
  cloud.material = CloudMaterials.Hovering
  cloud.procScale:mul(vec2(0.2, 2))
  cloud.procMap = vec2(0.6, 0.99)
  cloud.opacity = SOL__config("clouds", "shadow_opacity_multiplier") * 0.25
end
function CloudTypes.Low(cloud, pos, distance)
  local index = cloudutils.setTexture(cloud, CloudTextures.Flat)
  local heightFixes = { 0, 4, -13 }
  cloud.occludeGodrays = true
  cloud.procMap = vec2(0.35, 0.75)
  cloud.procSharpnessMult = 0.8
  cloud.color = rgb(1, 1, 1) * (1 - distance * 0.3)
  cloud.opacity = SOL__config("clouds", "shadow_opacity_multiplier") * 0.8 * (1 - distance * 0.8)
  cloud.orderBy = 1e12 + distance * 1e10
  cloudutils.setProcNormalShare(cloud, 0.7, 1.4)
  cloudutils.setPos(cloud, { 
    pos = pos, 
    height = 50 - 30 * distance + (heightFixes[index + 1] or 0), 
    distance = 50 + distance, 
    size = 1.6, 
    aspectRatio = 0.3 
  })
end

local CloudsCell = {}
function CloudsCell:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  o.initialized = false
  o.clouds = {}
  o.cloudsCount = 0
  o.hoveringClouds = {}
  o.hoveringCloudsCount = 0
  o.lastActive = 0
  --o.mMain = createGenericCloudMaterial()
  --o.mBottom = createGenericCloudMaterial()
  --o.mHover = createGenericCloudMaterial()
  o:reuse(o.index)
  return o
end
function CloudsCell:reuse(index)
  self.index = index
  self.pointA = CloudsCell.getCellCenter(self.index)
  self.pointB = self.pointA + vec3(CloudCellSize, 0, CloudCellSize)
  self.center = (self.pointA + self.pointB) / 2
  if self.initialized then
    for i = 1, self.cloudsCount do
      self.clouds[i].pos = self:getPos()
    end
  end
end
function CloudsCell:addCloud(cloudInfo)
  if cloudInfo.hovering then
    self.hoveringCloudsCount = self.hoveringCloudsCount + 1
    self.hoveringClouds[self.hoveringCloudsCount] = cloudInfo
  else
    self.cloudsCount = self.cloudsCount + 1
    self.clouds[self.cloudsCount] = cloudInfo
  end
end
function CloudsCell:getPos(hovering)
  return vec3(
    math.lerp(self.pointA.x, self.pointB.x, math.random()), 
    hovering 
      and math.lerp(HoveringMinHeight, HoveringMaxHeight, math.random())
      or math.lerp(DynCloudsMinHeight, DynCloudsMaxHeight, math.random()),
    math.lerp(self.pointA.z, self.pointB.z, math.random()))

  -- pos.x = math.lerp(self.pointA.x, self.pointB.x, i/6)
  -- pos.y = DynCloudsMinHeight
  -- pos.z = math.lerp(self.pointA.z, self.pointB.z, i/6)
end
function CloudsCell:initialize()
  self.initialized = true
  local DynamicClouds = CloudCellDynCloudNumber
  local HoveringClouds = CloudCellHooveringNumber
  -- local DynamicClouds = 4
  -- local HoveringClouds = 1
  for i = 1, DynamicClouds + HoveringClouds do
    local hovering = i > DynamicClouds
    local pos = self:getPos(hovering)
    local cloud = createCloud((hovering 
      and CloudTypes.Hovering) 
      or CloudTypes.Dynamic, pos)
    local weatherThreshold = math.random() * 0.95
    self:addCloud({
      cloud = cloud,
      pos = pos,
      size = cloud.size:clone(),
      procMap = cloud.procMap:clone(),
      procScale = cloud.procScale:clone(),
      opacity = cloud.opacity,
      flatCloud = nil,
      visibilityOffset = 1 + (hovering and 0.5 or math.random()),
      weatherThreshold0 = weatherThreshold,
      weatherThreshold1 = 0.05 + weatherThreshold,
      weatherScale = 1,
      hovering = hovering,
      cloudAdded = false,
      flatCloudAdded = false
    })
  end
end
function CloudsCell:updateHovering(cameraPos, cellDistance, dt)
  for i = 1, self.hoveringCloudsCount do
    local e = self.hoveringClouds[i]
    local c = e.cloud
    c.position:set(e.pos):sub(cameraPos)

    c.customLightColor = _g_clouds__sun_light__high

    local d = math.horizontalLength(c.position)
    c.opacity = e.opacity * (1 - math.saturateN(e.visibilityOffset * d * 5 / (cellDistance * CloudCellSize) - 4)) * (1 - 0.2 * __cloud_transition_density)

    if c.opacity > 0.001 then
      local weatherCutoff = 1 - math.lerpInvSat(__cloud_transition_density, e.weatherThreshold0, e.weatherThreshold1)
      c.orderBy = math.dot(c.position, c.position) + 1e9
      c.opacity = c.opacity * (0.5 + 0.5 * __cloud_transition_density) * (1 - weatherCutoff)

      local up = windDir.x * c.up.x + windDir.y * c.up.z
      local side = windDir.x * c.side.x + windDir.y * c.side.z
      local windDeltaC = (0.15 * windSpeed * dt * CloudShapeMovingSpeed) / c.size.x
      c.noiseOffset.x = c.noiseOffset.x - windDeltaC * side
      c.noiseOffset.y = c.noiseOffset.y - windDeltaC * up
      if not e.cloudAdded then 
        e.cloudAdded = true
        ac.weatherClouds[#ac.weatherClouds + 1] = c
      end
    elseif e.cloudAdded then
      e.cloudAdded = false
      ac.weatherClouds:erase(c)
    end
  end
end
function CloudsCell:updateDynamic(cameraPos, cellDistance, dt)
  local distance = math.horizontalDistance(self.center, cameraPos)
  local distanceK = 1 - math.pow(math.saturateN(1 - CloudDistanceShift / distance), 2)

  local windDelta = windSpeed * dt * CloudShapeMovingSpeed
  local shapeShiftingDelta = dt * CloudShapeShiftingSpeed
  local maxDistanceInv = 5 / (cellDistance * CloudCellSize)
  local fadeNearbyInv = 1 / CloudFadeNearby
  local ccClouds = __cloud_transition_density
  local opacityMult = 1.0 - 0.1 * ccClouds - 0.5 * (1 - distanceK)
  local sizeMult = math.lerp(1.5, 1, distanceK) * (1 + ccClouds * 0.5)
  local weatherScale = (0.5 + 0.5 * ccClouds) --* fps_clouds_quality_multi
  local mapMultX = 1 - ccClouds * 0.5
  local mapMultY = 1 - ccClouds * 0.2

  local pos = self.center

  local c_tlp = math.horizontalDistance(pos, __extern_illumination_position) / math.max(1, 2.5*__extern_illumination_radius)
  c_tlp = math.pow( math.max(0, 1-c_tlp), 2 )

  local angle = vec32sphere(pos)

  --calc strength of sun pro side for direct illumination
  local s_c = angle_diff(__sun_heading, angle[1], 3) + 0.7
  s_c = math.min(1, math.max(0,  1-s_c ))

  local fog_m = math.min(0.3 - 0.28 * __overcast, gfx__get_fog_dense(distance*0.01) ) --math.min(0.3 - 0.28 * __overcast, distance / fog__multi) * sun_compensate(0)
  local distance_bright = math.min(1.2, math.pow(distance / (80000), 2))
                        * math.lerp(1, 100 / (math.abs(ta_fog_blend - 1) + 1), math.min(1, s_c + math.min(1, math.max(0, (__sun_angle-6)*0.1) ) ) )
  
  --calc strength of sun contra side for illumination from above
  local s_c2 = angle_diff(__sun_heading, angle[1], 2) * 2
  s_c2 = math.min(1, math.max(0, s_c2 ))

  local custom_dir = __lightDir or vec3(0,1,0)
  angle2 = vec32sphere(custom_dir)
  angle2[1] = interpolate__angle(angle2[1], angle[1], s_c2 * _l_clouds__improved_light_with_low_sun)
  angle2[2] = interpolate__angle(angle2[2], 37 * from_twilight_compensate(2), s_c2 * _l_clouds__improved_light_with_low_sun)   --math.lerp(angle2[2], 60+30*from_twilight_compensate(0), s_c2 * 2 * __IntD(1,0.7, 0.6))
  custom_dir = sphere2vec3(angle2[1], angle2[2])

  local light_method = math.lerp( distance_bright, (3*from_twilight_compensate(0)+5*sun_compensate(0))*(1-__overcast) , s_c2 * duskdawn_compensate(0))

  local opac_mod = sun_compensate( math.lerp( 0.925, 1.2, s_c) ) - math.max(0, (0.8* (0.5 - __cloud_transition_density)))
  --opac_mod = opac_mod * blue_sky_cloud_opacity

  opac_mod = opac_mod + 0.1 - 0.5*(1-math.pow(c_tlp, 0.01))*__humidity
  fog_m = fog_m + 0.1*(1-math.pow(c_tlp, 0.02))*__humidity

  for i = 1, self.cloudsCount do
    local e = self.clouds[i]
    local c = e.cloud
    local horDist = math.horizontalLength(c.position)

    c.position:set(e.pos):sub(cameraPos)

    c.customLightColor = _g_clouds__sun_light__low * light_method * 0.75

    c.customLightDirection = custom_dir

    c.extraDownlit:set(downlit * c_tlp)

    c.fogMultiplier = 1+fog_m

    local weatherCutoff = 0
    local nearbyCutoff = 0
    local windDeltaC = 0

    c.opacity = (1 - math.saturateN(e.visibilityOffset * horDist * maxDistanceInv - 4)) * math.lerp(e.opacity * opacityMult * opac_mod, 1, __overcast*0.75)
    if c.opacity > 0.001 then
      c.orderBy = math.dot(c.position, c.position)
      --setLightPollution(c)
      c.size:set(e.size):scale(sizeMult)

      windDeltaC = windDelta / c.size.x
      nearbyCutoff = math.saturateN(2 - horDist * fadeNearbyInv)
      weatherCutoff = 1 - math.lerpInvSat(ccClouds, e.weatherThreshold0, e.weatherThreshold1)
      c.cutoff = math.max(nearbyCutoff, weatherCutoff)
      c.position.y = math.lerp(DynCloudsDistantHeight, c.position.y + c.size.y * 0.8, distanceK)
    end

    if c.cutoff < 0.999 and c.opacity > 0.001 then
      c.noiseOffset:scale(e.weatherScale / weatherScale)
      e.weatherScale = weatherScale
      c.procScale:set(e.procScale):scale(weatherScale)
      c.procMap.x = e.procMap.x * mapMultX
      c.procMap.y = e.procMap.y * mapMultY

      local fwd = windDir.x * c.position.x / horDist + windDir.y * c.position.z / horDist
      local side = windDir.x * c.position.z / horDist + windDir.y * -c.position.x / horDist
      c.noiseOffset.x = c.noiseOffset.x + windDeltaC * side
      c.procShapeShifting = c.procShapeShifting + shapeShiftingDelta + windDeltaC * fwd * 0.5
      if not e.cloudAdded then 
        e.cloudAdded = true
        ac.weatherClouds[#ac.weatherClouds + 1] = c
      end
    elseif e.cloudAdded then
      e.cloudAdded = false
      ac.weatherClouds:erase(c)
    end

    local flatCutoff = math.max(1 - nearbyCutoff, weatherCutoff)
    if flatCutoff < 0.999 and c.opacity > 0.001 then
      local f = e.flatCloud
      if f == nil then
        f = createCloud(CloudTypes.Bottom, c)
        e.flatCloud = f
      end
      f.cutoff = flatCutoff
      f.opacity = c.opacity
      if f.cutoff < 0.999 then
        f.position:set(c.position)
        f.extraDownlit = c.extraDownlit
        f.procMap:set(c.procMap)

        local up = windDir.x * f.up.x + windDir.y * f.up.z
        local side = windDir.x * f.side.x + windDir.y * f.side.z
        f.noiseOffset.x = f.noiseOffset.x - windDeltaC * side
        f.noiseOffset.y = f.noiseOffset.y - windDeltaC * up
        f.procShapeShifting = f.procShapeShifting + (shapeShiftingDelta + windDeltaC * 0.5) * 0.5
        local size = (c.size.x + c.size.y) / 2
        f.size:set(size, size)
        f.orderBy = c.orderBy + c.size.y

        if not e.flatCloudAdded then 
          e.flatCloudAdded = true
          ac.weatherClouds[#ac.weatherClouds + 1] = f
        end
      end
    elseif e.flatCloudAdded then
      e.flatCloudAdded = false
      ac.weatherClouds:erase(e.flatCloud)
    end
  end
end



function CloudsCell:update(cameraPos, cellDistance, dt)
  if not self.initialized then
    self:initialize()
  end
  
  self:updateHovering(cameraPos, cellDistance*fps_clouds_quality_multi, dt)
  self:updateDynamic(cameraPos, cellDistance*fps_clouds_quality_multi, dt)
end
function CloudsCell:deactivate() 
  for i = 1, self.cloudsCount do
    local e = self.clouds[i]
    if e.cloudAdded then 
      ac.weatherClouds:erase(e.cloud) 
      e.cloudAdded = false
    end
    if e.flatCloudAdded then 
      ac.weatherClouds:erase(e.flatCloud) 
      e.flatCloudAdded = false
    end
  end
  --self.cloudsCount = 0
  --self.hoveringCloudsCount = 0
  --self.initialized = false
end
function CloudsCell:destroy()
  for i = 1, self.cloudsCount do
    local e = self.clouds[i]
    ac.weatherClouds:erase(e.cloud)
    ac.weatherClouds:erase(e.flatCloud)
  end
  --self.cloudsCount = 0
  --self.hoveringCloudsCount = 0
  --self.initialized = false
end
function CloudsCell.getCellOrigin(pos)
  return vec3(math.floor(pos.x / CloudCellSize) * CloudCellSize, 0, math.floor(pos.z / CloudCellSize) * CloudCellSize)
end
function CloudsCell.getCellCenter(cellIndex)
  local x = math.floor(cellIndex / 1e5 - 100) * CloudCellSize
  local y = (math.fmod(cellIndex, 1e5) - 100) * CloudCellSize
  return vec3(x, 0, y)
end
function CloudsCell.getCellIndex(pos)
  return math.floor(100 + pos.x / CloudCellSize) * 1e5 + math.floor(100 + pos.z / CloudCellSize)
end
function CloudsCell.getCellNeighbour(cell, x, y)
  return cell + x + y * 1e5
end

local cloudCells = {}
local cloudCellsList = {}
local cellsTotal = 0
local activeIndex = 0
local windOffset = vec2()
local cellsPool = {}
local cellsPoolTotal = 0

local function createCloudCell(cellIndex)
  local c = nil
  if cellsPoolTotal > 0 then 
    c = cellsPool[cellsPoolTotal]
    table.remove(cellsPool, cellsPoolTotal)
    cellsPoolTotal = cellsPoolTotal - 1
    c:reuse(cellIndex)
  else
    c = CloudsCell:new{ index = cellIndex }
  end
  cloudCells[cellIndex] = c
  cloudCellsList[cellsTotal + 1] = c
  cellsTotal = cellsTotal + 1
  return c
end

local cameraPos = vec3()
local cleanUp = 0

local function updateCloudCells(dt)
  if __cloud_transition_density <= 0.0001 and (cellsPoolTotal > 1 or cellsTotal > 1) then 
    if activeIndex >= 0 then
      activeIndex = -1

      for i = cellsTotal, 1, -1 do
        local cell = cloudCellsList[i]
        cellsPoolTotal = cellsPoolTotal + 1
        cellsPool[cellsPoolTotal] = cell
        cell:deactivate()
      end
      cloudCellsList = {}
      cloudCells = {}
      cellsTotal = 0
    end
    return
  end

  activeIndex = activeIndex + 1
  if activeIndex > 1e6 then activeIndex = 0 end
  if activeIndex > 20 then pause = true end

  ac.getCameraPositionTo(cameraPos)
  ac.fixHeadingInvSelf(cameraPos)
  cameraPos.x = cameraPos.x + windOffset.x
  cameraPos.z = cameraPos.z + windOffset.y
  windOffset:add(windDir * (windSpeed * dt))

  local cellIndex = CloudsCell.getCellIndex(cameraPos)
  local cellDistance = math.ceil(CloudCellDistance * (1 - __fog_dense * 0.3))
  for x = -cellDistance, cellDistance do
    for y = -cellDistance, cellDistance do
      local n = CloudsCell.getCellNeighbour(cellIndex, x, y)
      local c = cloudCells[n]

      if c == nil then 
        c = createCloudCell(n)
      end
      if c then 
        c:update(cameraPos, cellDistance, dt) 
        c.lastActive = activeIndex
      end
    end
  end

  if cleanUp > 0 then
    cleanUp = cleanUp - 1
  else
    for i = cellsTotal, 1, -1 do
      local cell = cloudCellsList[i]
      if cell.lastActive ~= activeIndex then
        table.remove(cloudCellsList, i)
        cloudCells[cell.index] = nil
        cellsTotal = cellsTotal - 1
        cellsPoolTotal = cellsPoolTotal + 1
        cellsPool[cellsPoolTotal] = cell
        cell:deactivate()
      end
    end
    cleanUp = 0
  end

  --ac.debug("####", cellsTotal)
end

-- Static clouds
local staticClouds = {}
local staticCloudsCount = 0
local function addStaticCloud(cloud)
  staticCloudsCount = staticCloudsCount + 1
  staticClouds[staticCloudsCount] = cloud
  ac.weatherClouds[#ac.weatherClouds + 1] = cloud
end
local function updateStaticClouds(dt)
  local cutoff = math.saturate(1.1 - __cloud_transition_density * 1.5) ^ 2
  local lightPollution = 0--__extern_illumination.v * __extern_illumination_mix
  local dtLocal = math.min(dt, 0.05)
  for i = 1, staticCloudsCount do
    local c = staticClouds[i]
    local withWind = math.dot(vec2(c.side.x, c.side.z), windDir)
    c.noiseOffset.x = c.noiseOffset.x + (0.2 + math.saturate(windSpeed / 100)) * 0.02 * dtLocal * withWind
    c.procShapeShifting = c.procShapeShifting + (1 + math.saturate(windSpeed / 100) * (1 - withWind)) * 0.02 * dtLocal
    c.extraDownlit:set(lightPollution)
    c.cutoff = cutoff
  end
end
for j = 1, 0 do
  local lowRow = (math.randomVec2()):normalize()
  local count = math.floor(math.random() * 3 + 3)
  for i = 1, count do
    addStaticCloud(createCloud(CloudTypes.Low, lowRow, 1 - i / count))
    lowRow = (lowRow + math.randomVec2():normalize() * 0.2):normalize()
  end
end


function updateClouds(dt)

  _l_sun_low__LUT = _l_sun_lowCPP:get() --interpolate__plan(_l_sun_light_low_LUT, {1})
  _g_clouds__sun_light__low  = hsv(_l_sun_low__LUT[1],
                                   _l_sun_low__LUT[2],
                                   _l_sun_low__LUT[3]):toRgb()
  _g_clouds__sun_light__low  = _g_clouds__sun_light__low * (1 - __overcast)

  _l_sun_high__LUT = _l_sun_highCPP:get() --interpolate__plan(_l_sun_light_high_LUT, {1})
  _g_clouds__sun_light__high  = hsv(_l_sun_high__LUT[1],
                                    _l_sun_high__LUT[2],
                                    _l_sun_high__LUT[3]):toRgb()
  _g_clouds__sun_light__high  = _g_clouds__sun_light__high * (1 - __overcast)

  -- adapt wind direction to AC world direction
  windDir = angle2vec2(__wind_direction - 90 )
  windSpeed = __wind_speed

  pollusion_rgb = hsv.new(__extern_illumination.h, __extern_illumination.s*0.9, __extern_illumination.v*0.35*math.pow(math.min(2, __extern_illumination_mix*0.15),0.35)):toRgb() * (night_compensate(0))
  pollusion_rgb = math.lerp( pollusion_rgb / (math.max(1, math.pow(__extern_illumination_mix, 0.2))) , pollusion_rgb, day_compensate(0))
  pollusion_bright_mod = __IntD(1,0,0.4)

  downlit = pollusion_rgb
            * pollusion_bright_mod
            * math.min(1, __extern_illumination_mix)
            * (1.0 + 1.0 * __night__effects_multiplier)
            * (1.5 + __night__brightness_adjust*1.5)
            * 1.0

  local temp = _l_clouds__improved_light_with_low_sunCPP:get() --interpolate__plan(_l_clouds__improved_light_with_low_sun_LUT)
  _l_clouds__improved_light_with_low_sun = temp[1]

  fog__multi = (100000 * temp[2] * math.pow(ta_fog_distance, 0.5) / math.max(0.12, ta_fog_blend))

  fps_clouds_quality_multi = math.max(0.2, math.min(1, fps_clouds_quality_multi - 0.016 * (1 - (1/math.max(0.001,__frame_time)) / 30)))

  if SOL__config("debug", "graphics") == true then ac.debug("Gfx: FPS clouds quality", string.format('%.2f', fps_clouds_quality_multi)) end

  updateCloudCells(dt)
  --updateStaticClouds(dt)
  ac.sortClouds()
  ac.invalidateCloudMaps()

  ac.debug("Clouds", #ac.weatherClouds)
end
