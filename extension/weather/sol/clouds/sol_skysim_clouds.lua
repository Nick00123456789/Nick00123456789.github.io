
function createGenericCloudMaterial()
  local ret = ac.SkyCloudMaterial()
  ret.baseColor = rgb(1, 1, 1):scale(0.5)
  ret.useSceneAmbient = false
  ret.ambientConcentration = 0.6
  ret.frontlitMultiplier = 0.75
  ret.frontlitDiffuseConcentration = 0.4
  ret.backlitMultiplier = 0
  ret.backlitExponent = 10
  ret.backlitOpacityMultiplier = 1.0
  ret.backlitOpacityExponent = 1.7
  ret.specularPower = 1
  ret.specularExponent = 1
  ret.fogMultiplier = 0.4
  ret.contourExponent = 1
  ret.contourIntensity = 0
  return ret
end

osc_test = OSC:new(0.03, 2)
osc_test:run()


dofile (__sol__path.."clouds\\sol_skysim__CumulusHumilis.lua")
dofile (__sol__path.."clouds\\sol_skysim__CumulusMediocris.lua")
dofile (__sol__path.."clouds\\sol_skysim__Stratus.lua")
dofile (__sol__path.."clouds\\sol_skysim__Cirrostratus.lua")

dofile (__sol__path.."clouds\\sol_skysim__DistantHaze.lua")
dofile (__sol__path.."clouds\\sol_skysim__DistantCloudy.lua")

dofile (__sol__path.."clouds\\sol_skysim__Lightning.lua")

local Create = {}
local Update = {}
for i=1, #__cloudtypes do
  Create[i] = _G['Create_'..__cloudtypes[i][2]..'_Cloud']
  Update[i] = _G['Update_'..__cloudtypes[i][2]..'_Cloud']
end

--######################################################################

Cloud = {}
function Cloud:new(layer, id, pos, size, water, style)
  o = {}
  setmetatable(o, self)
  self.__index = self
  o.initialized = false
  o.force_update = true
  o.updated = false
  o.permanent_update = false
  o.always_in_front = false
  o.update_invisible_counter = 0
  o.visible_in_camera = false

  o.update_position_counter = 0
  o.update_position_counter_dt = vec3(0,0,0)
  o.update_position_threshold = 0

  o.id = id

  o.fn_create = Create[layer.type]
  o.fn_update = Update[layer.type]

  o.ac_clouds = {}
  o.ac_cloud_color = {}
  o.ac_cloud_sizes = {}
  o.ac_cloud_pos_offset = {}
  o.ac_cloud_extra = {}
 
  o.ac_clouds_count = 0
  o.cloud_back = -1
  o.cloud_bottom = -1

  o.layer = layer
  o.style = style
  o.transition = 0
  o.pos = vec3.new(pos.x,pos.y,pos.z)
  o.vec_simple = vec3.new(0,0,0)
  o.real_altitude = 0
  o.lastDistance = 0
  o.radius_position_relation = 0
  o.radius_position_relation_scaled = 0

  if layer and layer.static then
    o.vec_simple.x = pos.x
    o.vec_simple.y = pos.y
    o.vec_simple.z = pos.z
    o.vec_simple:normalize()

    o.lastDistance = math.horizontalLength(pos)
  end

  o.size = size or 2000
  o.cutoff = 0

  o.draw_method = 0

  o.water_filled = water or 0
  o.water_filled = math.min(1, o.water_filled)

  o.charge = 0

  o.light_bounce = 0

  o.ramp = 0
  o.ramp_speed = 0.002
  o.rndosc = OSC:new(0.01,2)

  o.material = createGenericCloudMaterial()

  o:initialize()

  return o
end

function Cloud:initialize()
  self.initialized = true
  self.force_update = true

  self.ac_clouds = {}
  self.ac_cloud_sizes = {}
  self.ac_cloud_color = {}
  self.ac_cloud_pos_offset = {}
  self.ac_cloud_extra = {}

  self.fn_create(self)
  --[[
  for i=1, self.ac_clouds_count do
    ac.weatherClouds[#ac.weatherClouds + 1] = self.ac_clouds[i]
  end]]
  o.rndosc:run()
  o.ramp = 0
end

function Cloud:destroy()

	if self.initialized then
		for i=1, self.ac_clouds_count do
      --ac.weatherClouds:erase(self.ac_clouds[i])
      cloudsstorage__set_free(self.ac_clouds[i])
		end
	end

	self.ac_clouds = nil
  self.ac_cloud_sizes = nil
  self.ac_cloud_color = nil
  self.ac_cloud_pos_offset = nil

  if self.ac_cloud_extra then
    for k, v in next, self.ac_cloud_extra, nil do
        self.ac_cloud_extra[k] = nil
    end 
  end
  self.ac_cloud_extra = nil

  self.ac_clouds_count = 0

  self.initialized = false

  self = nil
end

function Cloud:setWaterFilled(water)
  self.water_filled = math.min(1, water)
end


local _l_n_all = 0
local _l_n_static = 0
local _l_n_dynamic = 0
local _max = 0
local _time = os.clock()

local ___debug___update = false
function DEBUG__clouds__updating(dt)

  ___debug___update = true

  if os.clock() - _time > 1 then
    _time = os.clock()
    
    ac.debug("### Upd. Cl.Pos.", "all: ".._l_n_all..", static: ".._l_n_static..", dynamic: ".._l_n_dynamic)

    _l_n_all = 0
    _l_n_static = 0
    _l_n_dynamic = 0
  end
end

function Cloud:update_position(dt, forceUpdate, absoluteUpdate)

  if self.initialized then

    if ___debug___update then _l_n_all = _l_n_all + 1 end

    self.update_position_counter = self.update_position_counter + 1
    self.update_position_counter_dt.x = self.update_position_counter_dt.x + self.layer.wind.x - self.layer.cam_movement_vector_corrected__scaled.x
    self.update_position_counter_dt.z = self.update_position_counter_dt.z + self.layer.wind.z - self.layer.cam_movement_vector_corrected__scaled.z

    if self.update_position_counter > self.update_position_threshold then
      self.update_position_counter = 0
    end

    -- check if cloud is visible in Camera
    if __sky__update_limiter > 0 then
      local visible_before = self.visible_in_camera

      -- increase Aera if update is forced
      if absoluteUpdate then
        self.visible_in_camera = true
      elseif forceUpdate then

        --[[
        local _l_pos = vec3(self.pos.x, self.real_altitude, self.pos.z)
        local _l_rotate = vec32sphere(_l_pos)
			  _l_pos:set(sphere2vec3(_l_rotate[1]-self.layer.parent.TrackHeadingAngle, _l_rotate[2]) * #_l_pos)
        self.visible_in_camera = ac.testFrustumIntersection(_l_pos, self.size * 1.75)
        ]]
        self.visible_in_camera = ac.testFrustumIntersection(vec3(self.pos.x, self.real_altitude, self.pos.z), self.size * 1.75)
      else

        --[[
        local _l_pos = vec3(self.pos.x, self.real_altitude, self.pos.z)
        local _l_rotate = vec32sphere(_l_pos)
        _l_pos:set(sphere2vec3(_l_rotate[1]-self.layer.parent.TrackHeadingAngle, _l_rotate[2]) * #_l_pos)
        self.visible_in_camera = ac.testFrustumIntersection(_l_pos, self.size * 1.25)
        ]]
        self.visible_in_camera = ac.testFrustumIntersection(vec3(self.pos.x, self.real_altitude, self.pos.z), self.size * 1.25)
      end

      if not visible_before and self.visible_in_camera then
        self.update_position_counter = 0
      end
    else
      self.visible_in_camera = true
      self.update_position_counter = 0
    end

    if self.update_position_counter < 1 then
    
      local _l_i

      if self.layer.static then

        if ___debug___update then _l_n_static = _l_n_static + 1 end

        if not self.always_in_front then
          for _l_i=1, self.ac_clouds_count do
            
            self.ac_clouds[_l_i].position = self.pos + self.ac_cloud_pos_offset[_l_i]
            self.ac_clouds[_l_i].position.y = self.ac_clouds[_l_i].position.y - __camPos.y 

            self.ac_clouds[_l_i].orderBy = math.horizontalLength(self.ac_clouds[_l_i].position) + 100000000
          end
        else
          for _l_i=1, self.ac_clouds_count do
            --self.ac_clouds[i].position.y = curvation_offset + (self.ac_cloud_pos_offset[i].y) - __sky__clouds_global_scale*__camPos.y 

            self.ac_clouds[_l_i].orderBy = 0
          end
        end

        self.update_position_threshold = 4 * __sky__update_multiplier
        if not self.visible_in_camera then
          self.update_position_threshold =  self.update_position_threshold * 4 * __sky__update_multiplier
        end
      else

        if ___debug___update then _l_n_dynamic = _l_n_dynamic + 1 end

        -- compensate the position of the cloud system to its neutral offset
        -- then all calculations have the same base
        self.pos = self.pos - __sky__camShift

        local _l_movement = self.update_position_counter_dt*(1.75-self.radius_position_relation) --*(1+0.5*self.radius_position_relation)

        local dOld = self.lastDistance
        local dNew = math.horizontalLength(self.pos + _l_movement)
        self.radius_position_relation_scaled  = (dNew / self.layer.radius_scaled)
        local dmod = 1-self.radius_position_relation_scaled
        self.radius_position_relation = (dNew / self.layer.radius)

        self.update_position_threshold = self.radius_position_relation * __sky__update_multiplier
        if not self.visible_in_camera then
          self.update_position_threshold =  self.radius_position_relation * 16 * __sky__update_multiplier
        end

        self.ramp = self.ramp + self.ramp_speed * self.layer.wind_distance * dt
        if self.ramp > 1 then self.ramp = 0 end

        --self.rndosc.freq = dt
        self.rndosc:update()

        local _l_swapped = false
        
        if dNew > 0 then
          if math.abs(dNew-dOld) > 1 then
            
            if dOld <= self.layer.radius and dNew > self.layer.radius then

              --rotate to reuse
              local height = self.pos.y
              self.pos:rotate(self.layer.reuse_rotation_vec)
              self.pos.y = height

              _l_swapped = true
            end

            self.lastDistance = dNew
          end
        end

        self.pos = self.pos + _l_movement -- add the movement
        self.pos = self.pos + __sky__camShift  --shift it back
        
        --curvature of the earth
        --local real_cloud_alti = (6378140 + self.pos.y)
        --local curvation_offset = real_cloud_alti * ( 1 - math.cos( _toRadians( ( 360/( 2*math.pi*real_cloud_alti ) ) * dNew ) ) )

        local curvation_offset = math.lerp( self.layer.bottom_scaled,
                                            __sky__curvature_distant_mouth_height,
                                            math.min(1, math.pow(self.lastDistance / self.layer.radius, __sky__curvature_exponent))
                                          ) 
        self.real_altitude = curvation_offset + self.pos.y*dmod

        self.vec_simple.x = self.pos.x
        self.vec_simple.y = self.real_altitude
        self.vec_simple.z = self.pos.z
        self.vec_simple:normalize()
        --self.vec_simple = self.vec_simple / math.max(1, #self.vec_simple)

        --local order = self.lastDistance*10 + self.layer.bottom*10000

        for _l_i=1, self.ac_clouds_count do

          self.ac_clouds[_l_i].position.x = self.pos.x + self.ac_cloud_pos_offset[_l_i].x
          self.ac_clouds[_l_i].position.y = self.real_altitude + self.ac_cloud_pos_offset[_l_i].y * dmod
          self.ac_clouds[_l_i].position.z = self.pos.z + self.ac_cloud_pos_offset[_l_i].z
          
          self.ac_clouds[_l_i].position.y   = self.ac_clouds[_l_i].position.y - self.layer.parent.camPos_scaled.y --restore the right reference point
          
          if self.visible_in_camera then
            if not self.always_in_front then
              self.ac_clouds[_l_i].orderBy = self.ac_clouds[_l_i].position:length()*10 + self.layer.bottom*10000
            else
              self.ac_clouds[_l_i].orderBy = 0
            end
          end

          --update processing
          self.ac_clouds[_l_i].procShapeShifting = self.ramp

          if _l_swapped then
            -- make invisible if position is swapped
            self.ac_clouds[_l_i].opacity = 0
          end
        end

        self.update_position_counter_dt:set(0,0,0)
      end
    else
      --self.visible_in_camera = false
    end
  end
end

function Cloud:shiftPosition(shift)
  if self.initialized then
    self.pos = self.pos + shift
    self.lastDistance = math.horizontalLength(self.pos)
  end
end

function Cloud:getLightSourceRelevance(azi_exp, alti_exp, mult)

  local angle1 = vec32sphere(__lightDir)
  local angle2 = vec32sphere(self.vec_simple)
  local r = (1-(angle_diff(angle1[1], angle2[1], azi_exp) + angle_diff(angle1[2], angle2[2], alti_exp))) * mult
  return math.min(1, math.max(0,  r ))

end

function Cloud:initial__update(dt)
  
  if self.initialized then
      self.fn_update(self)
  end
end

function Cloud:update(dt)
  osc_test:update()

  __sky__debug__pov_update_limiter = false

  if self.initialized then

    if self.force_update or self.permanent_update then
      self.force_update = false
      self.fn_update(self, true)
      self.updated = true
    else
      
      --local vec_cloud = vec3(self.pos.x, self.pos.y, self.pos.z) - __camPos
      --vec_cloud:normalize()

      if __sky__update_limiter == 1 then

        --if vec_diff(__camDir, vec_cloud) < ((0.12 + (self.size * 0.0000175)) * __camFOV * 0.010) or vec_cloud.y > 0.1 then
        if self.visible_in_camera then

          self.fn_update(self, true)
          self.updated = true

          if __sky__debug__pov_update_limiter then
            self.materialTop.baseColor = rgb(10,0,0)
            self.materialBottom.baseColor = rgb(10,0,0)
          end
        else

          self.fn_update(self, false)

          if __sky__debug__pov_update_limiter then
            self.materialTop.baseColor = rgb(0,10,0)
            self.materialBottom.baseColor = rgb(0,10,0)
          end
        end
      elseif __sky__update_limiter == 2 then

        self.fn_update(self, false)
      else

        self.fn_update(self, true)
      end
    end
  end
end