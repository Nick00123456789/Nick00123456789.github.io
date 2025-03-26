__cloud_map = {}

__sky__camShift = vec3(0,0,0)
__sky__camShift__prev_frame = vec3(0,0,0)
__sky__cam_moving_vec = vec3(0,0,0)
__sky__cam_moving_vec__scaled = vec3(0,0,0)
__sky__vec_Y_rotate = vec3(0,1,0)
__sky__wind = vec3(0,0,0)

__sky__clouds_quality = SOL__config("clouds", "quality")
--__sky__height_offset = 5000
__sky__base_dome_size = 35000
__sky__layer_max_distance_base = 50000 * SOL__config("clouds", "distance_multiplier")
__sky__curvature_distant_mouth_height = 750--__sky__height_offset -- (__sky__layer_max_distance_base * 0.03) 
__sky__curvature_distant_mouth_height = __sky__curvature_distant_mouth_height - (__sky__base_dome_size-ta_dome_size) * 0.075
__sky__curvature_exponent = 1
__sky__transition_blend = 0.05 + 0.15 * SOL__config("clouds", "quality")
__sky__clouds_global_scale = 7.5--__sky__height_offset*0.0015

__sky__clouds_light_bounce_calculation_grid_resolution = 8

__sky__update_limiter = 2 --0=all, 1=FOV based, 2=one per frame
__sky__debug__pov_update_limiter = false

__sky__update_multiplier = 1

--[[
n = 1                  --1  
local _l_MIPLODMAP_LUT = {}
_l_MIPLODMAP_LUT[n] = { -4, 1.60, 2.00 } n=n+1
_l_MIPLODMAP_LUT[n] = { -3, 1.35, 1.50 } n=n+1
_l_MIPLODMAP_LUT[n] = { -2, 1.15, 1.10 } n=n+1
_l_MIPLODMAP_LUT[n] = { -1, 0.97, 0.95 } n=n+1
_l_MIPLODMAP_LUT[n] = {  0, 0.85, 0.90 } n=n+1

local _l_MIPLODMAP_LUT_r = interpolate__plan(_l_MIPLODMAP_LUT, nil, __SYSTEM_MIP_LOD_BIAS)
]]

local _l_MIPLODMAP_LUT_r = { 0.97, 0.95 }

__cloud_map = ac.SkyCloudMapParams.new()
__cloud_map.perlinFrequency = 3
__cloud_map.perlinOctaves = 45
__cloud_map.worleyFrequency = 3
__cloud_map.shapeMult = 500.0/_l_MIPLODMAP_LUT_r[2]
__cloud_map.shapeExp = 0.85
__cloud_map.shape0Mip = 3.0*_l_MIPLODMAP_LUT_r[1]
__cloud_map.shape0Contribution = 0.90
__cloud_map.shape1Mip = 4.0*_l_MIPLODMAP_LUT_r[1]
__cloud_map.shape1Contribution = 0.95
__cloud_map.shape2Mip = 4.5*_l_MIPLODMAP_LUT_r[1]
__cloud_map.shape2Contribution = 1.00


local test_osc = OSC:new(0.025, 4)
test_osc:run()


__cloudtypes = {

	{ 1, "CumulusHumilis",		1000, 1300},
	{ 2, "CumulusMediocris",	1200, 1500},
	{ 3, "Nimbostratus", 		1500, 2500},
	{ 4, "Stratocumulus",		2000, 2500},
	{ 5, "Stratus", 			1500, 2000},
	{ 6, "Altocumulus", 		4000, 6000},
	{ 7, "Altostratus", 		3000, 4000},
	{ 8, "Cirrus", 				8000, 8000},
	{ 9, "Cirrostratus", 		6000, 6000},
	{10, "Cirrocumulus", 		7000, 7000},
	{11, "Cumulonimbus", 		1000, 9000},

	{12, "DistantHaze",        	   0, 1000},
	{13, "DistantCloudy",          0, 1000},
	{14, "FarStatic",          	   0, 1000},
		   
	{15, "Lightning",          	   0, 1000},
}

function getCloudtypeByName(name)

	local index = 0

	for i=1, #__cloudtypes do
		if name == __cloudtypes[i][2] then
			index = i
			break
		end
	end

	return index
end

dofile (__sol__path.."clouds\\sol_skysim_clouds_lighting.lua")
dofile (__sol__path.."clouds\\sol_skysim_clouds.lua")


--These functions are located in the corresponding cloud files
local Build = {}
local Create = {}
local Update = {}
local Preload = {}
for i=1, #__cloudtypes do
	Preload[i]  = _G['Preload_'..__cloudtypes[i][2]..'_Textures']
	Build[i]  	= _G['Build_'..__cloudtypes[i][2]..'_Pattern']
	Create[i] 	= _G['Create_'..__cloudtypes[i][2]..'_Layer']
	Update[i] 	= _G['Update_'..__cloudtypes[i][2]..'_Layer']
end


--#########################################################################################
--######     ###############      ######     ######      ##             ###            ####
--######     ##############       #######     ####     ####             ###              ##
--######    ##############         #######    ###     #####    ############    #####     ##
--#####     #############    ##    #######           #####     ###########     #####     ##
--#####     ############    ###    ########        #######            ####     ####     ###
--#####    ############    ####    #########      #######            ####             #####
--####     ###########              ########     ########     ###########     ##     ######
--####    ###########               ########    #########    ###########     ####     #####
--###             ##    #######     #######     ########             ###     #####     ####
--###             #     #######     #######    #########             ###     ######     ###
--#########################################################################################

local SkyLayer = {}
function SkyLayer:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  o.initialized = false
  o.first_update = true

  o.type = 0
  o.ceiling = 0
  o.bottom = 0
  o.bottom_scaled = o.bottom

  o.use_rotation_fix = false
  o.cam_movement_vector = vec3(0,0,0)
  o.cam_movement_vector__scaled = vec3(0,0,0)
  o.cam_movement_vector_corrected = vec3(0,0,0)
  o.cam_movement_vector_corrected__scaled = vec3(0,0,0)

  o.dense = 0
  o.dense_A = 0
  o.dense_B = 0

  o.static = false
  o.radius = 10000
  o.radius_scaled = o.radius

  o.clouds = {}
  o.clouds_count = 0
  o.clouds_id_counter = 0
  o.clouds_updated = 0
  o.clouds_update_positions_split = 1
  o.clouds_update_positions_split_tile = 0

  o.remove_stack = nil
  o.add_stack = nil

  o.clouds_light_bounce_calculation_grid = nil

  o.move = vec3(0,0,0)
  o.wind = vec3(0,0,0)
  o.wind_normalized = vec3(0,0,0)
  o.wind_distance = 0
  o.wind_multi = 1
  o.reuse_rotation_vec = vec3(0,0,0)

  o.fn_build = nil
  o.fn_create = nil
  o.fn_update = nil

  o.parent = nil

  return o
end

function SkyLayer:addCloud(index_of_stack, transition)

	if index_of_stack > 0 and index_of_stack <= self.add_stack.n then

		self.clouds_count = self.clouds_count + 1

		if self.clouds_id_counter > 100000 then self.clouds_id_counter = 0 end
        self.clouds_id_counter = self.clouds_id_counter + 1

        self.clouds[self.clouds_count] = Cloud:new(self,
        										   self.clouds_id_counter,
        										   self.add_stack:get(index_of_stack)["pos"],
        										   self.add_stack:get(index_of_stack)["size"], 
        										   self.add_stack:get(index_of_stack)["water"],
        										   self.add_stack:get(index_of_stack)["style"]
        										  )
        self.clouds[self.clouds_count].transition = transition

        self.add_stack:modifyEntry(index_of_stack, {
        												{"id", self.clouds[self.clouds_count].id },
        												{"cloud", self.clouds[self.clouds_count] },
    											   })

        return self.clouds[self.clouds_count]
    end
end

function SkyLayer:removeCloud(index)

	if index > 0 and index <= self.clouds_count then

		self.clouds[index]:destroy()

		for i=index, self.clouds_count-1 do
			self.clouds[i] = self.clouds[i + 1]
		end

		self.clouds[self.clouds_count] = nil
		self.clouds_count = self.clouds_count - 1
	end
end


function SkyLayer:removeCloudByID(id)

	for i=1, self.clouds_count do
		if self.clouds[i].id == id then
			self:removeCloud(i)
			break
		end
	end
end

function SkyLayer:setParent(p)

	self.parent = p
end

function SkyLayer:initialize()
 	self.initialized = true
	self.first_update = true
	 
	self.clouds = {}
	self.clouds_count = 0

 	self.dense_A = 0
	self.dense_B = nil --set nil to force right value initialization of dense_A in "buildStacks" 

 	if self.ceiling > 0 then
		self.radius = __sky__layer_max_distance_base + (self.ceiling * 4)
		self.radius_scaled = self.radius * __sky__clouds_global_scale 
	end
	 
	self.bottom_scaled = self.bottom * __sky__clouds_global_scale

	self.update_duration_counter = 0
	self.update_duration_time = 0
	self.update_duration_average = 0
  
  	self.fn_build  = Build[self.type]
 	self.fn_create = Create[self.type]
  	self.fn_update = Update[self.type]

  	self.wind_multi = 1 / math.pow(math.max(0.1, (self.bottom / 1000)), 0.25)

  	self:resetCloudsLightBounceCalculationGrid()

   	if self.fn_create then self.fn_create(self) end
end

function SkyLayer:destroy()

	if self.initialized then
		for i=1, self.clouds_count do
			if self.clouds[i] and self.clouds[i].initialized then
				self.clouds[i]:destroy()
				self.clouds[i]=nil
			end
		end
	end

	self.clouds = nil
	self.clouds_count = 0
	  
	-- reset debug output
	ac.debug(string.format("▌ %2i", self.type), "")
end

--######################################################################################################################
--######################################################################################################################
--######################################################################################################################

function SkyLayer:buildStacks(dense, water, rnd_water, force_remove)

	force_remove = force_remove or false

	local already_in_remove_stack
	
	self.dense_A = self.dense_B or dense

	if self.fn_build then

		if SOL__config("clouds", "randomize_with_reset") then
			math.randomseed(os.time())
		else
			math.randomseed(SOL__config("clouds", "manual_random_seed") or 0)
		end
		

		if self.add_stack ~= nil then
			self.add_stack:destroy()
	        self.add_stack = nil
		end

		if dense < 0.01 or force_remove then
			self.add_stack = Stack:new()
		else
			self.add_stack = self.fn_build(self, dense, water, rnd_water)
			--ac.debug("####", self.add_stack.n)
		end


		if (self.remove_stack == nil and self.add_stack ~= nil) then 
			-- stack is build for the first time (session start)
			self.clouds = {}
			self.clouds_count = 0
			self.clouds_id_counter = 0

			for i=1, self.add_stack.n do self:addCloud(i, 1) end

	        self.remove_stack = self.add_stack:copy()
	        self.add_stack:destroy()
	        self.add_stack = nil
	    else

	    	for i=1, self.clouds_count do
				-- check, if all clouds of the layer are in the remove stack

				already_in_remove_stack = false
				for ii=1, self.remove_stack.n do

					if self.remove_stack:get(ii)["id"] == self.clouds[i].id then
						already_in_remove_stack = true
						break
					end
				end

				if not already_in_remove_stack then
					self.remove_stack:add({
							              { "pos", self.clouds[i].pos },
							              { "size", self.clouds[i].size },
							              { "water", self.clouds[i].water_filled },
							              { "style", self.clouds[i].style },
							            })
					self.remove_stack:modifyEntry(self.remove_stack.n, {
							        										{"id", self.clouds[i].id },
							        										{"cloud", self.clouds[i] },
							    										})
				end
			end

			--ac.debug("####"..self.type, self.remove_stack.n)
		end
	end

	self.dense_B = dense

	collectgarbage()
end

function SkyLayer:createTransitionTimes()

	--if not self.static then

		local dN = math.min(0.75, math.max(0.05, __sky__transition_blend))

		if self.remove_stack and self.remove_stack.n > 0 then

			for i=1, self.remove_stack.n do

				self.remove_stack:modifyEntry(i, { 
													{ "A", ((i-1)/(self.remove_stack.n + 1)) * (1-dN) },
													{ "B", dN + (i/(self.remove_stack.n + 1)) * (1-dN) }
												 })
			end
		end

		if self.add_stack and self.add_stack.n > 0 then

			for i=1, self.add_stack.n do

				self.add_stack:modifyEntry(i, { 
												{ "A", ((i-1)/(self.add_stack.n + 1)) * (1-dN) },
												{ "B", dN + (i/(self.add_stack.n + 1)) * (1-dN) }
											})
			end
		end

		
	--[[
	else

		if self.remove_stack and self.remove_stack.n > 0 then

			for i=1, self.remove_stack.n do

				self.remove_stack:modifyEntry(i, { 
													{ "A", 0 },
													{ "B", 1 }
												 })
			end
		end

		if self.add_stack and self.add_stack.n > 0 then

			for i=1, self.add_stack.n do

				self.add_stack:modifyEntry(i, { 
												{ "A", 0 },
												{ "B", 1 }
											})
			end
		end
	end
	]]
end

function SkyLayer:checkPopulation(transition_position)

	if transition_position > 0 then

		local cloud = nil
		local cloud_transition = 1
		local w = 0
		local a = 0
		local b = 0
		local i=1
		local __n__ = 1

		if self.add_stack then

			if self.add_stack.n > 0 then

				while (i <= self.add_stack.n and __n__ <= self.add_stack.n) do

					a = self.add_stack:get(i)["A"]
					b = self.add_stack:get(i)["B"]

					if transition_position >= b then
						cloud = self.add_stack:get(i)["cloud"]
						if not cloud then
							cloud = self:addCloud(i, 0)
						end
						if cloud then cloud.transition = 1 end
						self.add_stack:remove(i)
					else

						if transition_position > a then

							cloud = self.add_stack:get(i)

							if cloud then
								if not cloud["cloud"] then
									self:addCloud(i, 0)
								else
									w = math.max(0.001, b - a)
									cloud_transition = math.min(1, math.max(0, (transition_position - a) * 1/w))
									cloud["cloud"].transition = cloud_transition
								end
							end
						end

						i=i+1
					end

					__n__ = __n__ + 1
				end
			end

			if self.remove_stack and self.remove_stack.n > 0 then
				cloud = nil
				cloud_transition = 1
				w = 0
				a = 0
				b = 0
				i=1
				__n__ = 1
				while (i <= self.remove_stack.n and __n__ <= self.remove_stack.n) do

					a = self.remove_stack:get(i)["A"]
					b = self.remove_stack:get(i)["B"]

					if transition_position >= b then
						self:removeCloudByID(self.remove_stack:get(i)["id"])
						self.remove_stack:remove(i)
					else

						if transition_position > a then

							cloud = self.remove_stack:get(i)["cloud"]
							if cloud then
								w = math.max(0.001, b - a)
								cloud_transition = 1 - math.min(1, math.max(0, (transition_position - a) * 1/w))
								cloud.transition = cloud_transition
							end
						end

						i=i+1
					end

					__n__ = __n__ + 1
				end
			end
		end
	end
end


--######################################################################################################################
--######################################################################################################################
--######################################################################################################################

function SkyLayer:resetCloudsLightBounceCalculationGrid()

	self.clouds_light_bounce_calculation_grid = {}
  	for i=0,__sky__clouds_light_bounce_calculation_grid_resolution do
  		self.clouds_light_bounce_calculation_grid[i] = {}
  		for ii=0,__sky__clouds_light_bounce_calculation_grid_resolution do
  			self.clouds_light_bounce_calculation_grid[i][ii] = 0
  		end
  	end
end

function SkyLayer:addLightBounce(cloud)

	local step = 2*self.radius / __sky__clouds_light_bounce_calculation_grid_resolution
	local x = math.floor( (cloud.pos.x + self.radius) / step ) + 1
	local y = math.floor( (cloud.pos.z + self.radius) / step ) + 1

	if x >= 1 and x <= __sky__clouds_light_bounce_calculation_grid_resolution and
	   y >= 1 and y <= __sky__clouds_light_bounce_calculation_grid_resolution then

	   	self.clouds_light_bounce_calculation_grid[x][y] = math.max(cloud.light_bounce, self.clouds_light_bounce_calculation_grid[x][y])
	end
end

--######################################################################################################################
--######################################################################################################################
--######################################################################################################################


function SkyLayer:shiftPosition(shift)
	if self.initialized then
		for i=1, self.clouds_count do
			self.clouds[i]:shiftPosition(shift)
		end
	end
end

function SkyLayer:calcReuseRotation()

	self.reuse_rotation_vec = self.wind + self.cam_movement_vector_corrected

	self.move.x = self.reuse_rotation_vec.x
	self.move.y = 0
	self.move.z = self.reuse_rotation_vec.z

	-- if no rotation vector can be set, because no camera movement and no wind,
	-- just set a default one, to prevent miscalculations
	if #self.reuse_rotation_vec == 0 then
		self.reuse_rotation_vec.x = 1
	end 
	
	self.reuse_rotation_vec:normalize()
	self.reuse_rotation_vec:rotate(quat.fromAngleAxis(math.pi*0.5, __sky__vec_Y_rotate))
	self.reuse_rotation_vec = quat.fromAngleAxis(math.pi, self.reuse_rotation_vec)
end

--######################################################################################################################
--######################################################################################################################
--######################################################################################################################
function SkyLayer:update(dt, forceUpdate)

	if self.dense_B ~= nil then
		self.dense = math.lerp(self.dense_A, self.dense_B, __weather_change_momentum)
	else
		self.dense = self.dense_A
	end

	self:checkPopulation(__weather_change_momentum)

	if self.fn_update then self.fn_update(self) end

	ac.debug(string.format("▌ %2i", self.type), string.format("%s, %i", __cloudtypes[self.type][2], self.clouds_count))

	if self.static then

	else

		self.cam_movement_vector:set(__sky__cam_moving_vec)
		self.cam_movement_vector__scaled:set(__sky__cam_moving_vec * __sky__clouds_global_scale)

		local _l_wind = __sky__wind

		if self.use_rotation_fix then
			local _l_rotate = vec32sphere(self.cam_movement_vector)
			self.cam_movement_vector_corrected:set(sphere2vec3(_l_rotate[1]-self.parent.TrackHeadingAngle, _l_rotate[2]) * #self.cam_movement_vector)
			self.cam_movement_vector_corrected__scaled:set(self.cam_movement_vector_corrected * __sky__clouds_global_scale)
		
			local _l_rotate = vec32sphere(_l_wind)
			_l_wind = sphere2vec3(_l_rotate[1]-self.parent.TrackHeadingAngle, _l_rotate[2]) * #__sky__wind
			
		else
			self.cam_movement_vector_corrected:set(self.cam_movement_vector)
			self.cam_movement_vector_corrected__scaled:set(self.cam_movement_vector__scaled)
		end



		self.wind:set(_l_wind * self.wind_multi)
		self.wind_distance = math.horizontalLength(self.wind)
		self:calcReuseRotation()
		self.wind_normalized:set(self.wind * math_sign2(dt)) -- do not flip the clouds, if dt is negative
		self.wind_normalized:normalize()
	end

	if self.initialized then

		--if not __calc_bug__ then
			for i=1, self.clouds_count do
				if self.clouds[i] then
					self.clouds[i]:update_position(dt, forceUpdate, self.first_update)
				end
			end
		--end


		if self.first_update then
			for i=1, self.clouds_count do
				if self.clouds[i] then
					self.clouds[i].force_update = true
					self.clouds[i]:update_position(dt, true)
					self.clouds[i]:update(dt)
					self.clouds[i].updated = false
				end
			end
			self.clouds_updated = 0
			self.first_update = false

		elseif forceUpdate then
			for i=1, self.clouds_count do
				if self.clouds[i] then
					if self.clouds[i].visible_in_camera then
						self.clouds[i].force_update = true
					end
					self.clouds[i]:update(dt)
					self.clouds[i].updated = false
				end
			end
			self.clouds_updated = 0
			
		else
			if __sky__update_limiter < 2  then
				self.clouds_updated = 0
				for i=1, self.clouds_count do
					if self.clouds[i] then
						self.clouds[i]:update(dt)
						if self.clouds[i].updated then self.clouds_updated = self.clouds_updated + 1 end
					end
				end
				if __sky__debug__pov_update_limiter then
					ac.debug("### FOV clouds", self.clouds_updated)
				end
			end
			if self.clouds_updated < self.clouds_count then
				local n_rendered = 0
				for i=1, self.clouds_count do
					if self.clouds[i] then
						if not self.clouds[i].updated then
						
							if self.clouds[i].visible_in_camera then 
								-- if visible in camera, update completely
								self.clouds[i].force_update = true
								self.clouds[i]:update(dt)
								self.clouds_updated = self.clouds_updated + 1
							else
								-- if not visible in camera, reduce update rate by 1/20
								if self.clouds[i].update_invisible_counter >= 20 then
									self.clouds[i].force_update = true
									self.clouds[i]:update(dt)
									self.clouds_updated = self.clouds_updated + 1
									self.clouds[i].update_invisible_counter = 0
								else
									self.clouds[i].update_invisible_counter = self.clouds[i].update_invisible_counter + 1
									self.clouds[i].updated = true
									self.clouds_updated = self.clouds_updated + 1
								end
							end

							n_rendered = n_rendered + 1
							if n_rendered >= SOL__config("clouds", "render_per_frame") then break end
						end
					end
				end
			end
			if self.clouds_updated >= self.clouds_count then
				for i=1, self.clouds_count do
					self.clouds[i].updated = false
				end
				self.clouds_updated = 0
			end	
		end
	end

	
end



--###########################################################################
--##################          #####   ######    ##   #######    #############
--################            ####    ####     ###    ####     ##############
--###############    ######## ####   ###    ######    ###    ################
--###############     ###########    ##   #########    #    #################
--################         ######        ###########      ###################
--#####################      ####        ###########     ####################
--#######################    ###    ###    ##########   #####################
--#############     ####     ###    ###     ########    #####################
--##############           ####    #####     #######   ######################
--###########################################################################

local SKY = {}
function SKY:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	o.initialized = false

	o.layer = {}
	o.layer_count = 0

	o.height_offset = 0
	o.camPos_scaled = vec3(0,0,0)

	o.pollution_fake_pos = vec3(0,0,0)
	o.pollution_radius = 1000
	o.pollution_downlit = rgb(1,1,1)

	o.TrackHeadingRotationVec = vec3(0,1,0)
	o.TrackHeadingAngle = ac.getRealTrackHeadingAngle()

	return o
end

function SKY:initialize()
	self.initialized = true
	self:calcTrackHeadingRotation()
end

function SKY:destroy()

	if self.initialized then
		for i=1, self.layer_count do
			if self.layer[i] and self.layer[i].initialized then
				self.layer[i]:destroy()
				self.layer[i]=nil
			end
		end
	end

	self.layer = nil
	self.layer = {}
  	self.layer_count = 0
end

function SKY:addLayer(Ltype, dense, water)

	self.layer_count = self.layer_count + 1
	self.layer[self.layer_count] = SkyLayer:new()

	local bottom = 0
	local ceiling = 0

	for i=1, #__cloudtypes do
		if Ltype == __cloudtypes[i][1] then
			bottom = __cloudtypes[i][3]
			ceiling = __cloudtypes[i][4]
		end
	end

	if ceiling == 0 then
		ac.debug("## SKY:addLayer", Ltype.." unknown type")
	end

	self.layer[self.layer_count].bottom = bottom --+ __CM__altitude*0.25
	self.layer[self.layer_count].ceiling = ceiling --+ __CM__altitude*0.25

	self.layer[self.layer_count].type  = Ltype or 0
	self.layer[self.layer_count]:initialize()

	if dense and water then
		self.layer[self.layer_count]:buildStacks(dense, water, 0)
	end

	self.layer[self.layer_count]:setParent(self)

	return self.layer[self.layer_count]
end

function SKY:shiftPosition(shift)
	for i=1, self.layer_count do
		self.layer[i]:shiftPosition(shift)
	end
end


function SKY:getHeightOffset()

	return self.height_offset
end

function SKY:setHeightOffset(offset)

	self.height_offset = offset or 0
end

function SKY:fixeSizeWithHeightOffset(size)

	if self.height_offset == 0 then
		return size
	else
		return size * (1-0.00025*self.height_offset)
	end
end

function SKY:getLayerIndexByType(Ltype)
	local pos = 0
	for i=1, self.layer_count do
		if self.layer[i].initialized and self.layer[i].type == Ltype then
			pos = i
			break
		end
	end
	return pos
end

function SKY:removeLayer(Ltype)
	local pos = self:getLayerIndexByType(Ltype)
	if pos > 0 then
		self.layer[pos]:destroy()
		for i=pos, self.layer_count-1 do
			self.layer[i] = self.layer[i+1]
		end
		self.layer[self.layer_count] = nil
		self.layer_count = self.layer_count - 1
	end
end

function SKY:buildWeather(init)

	local skys = {}
	local CloudType
	local LayerIndex
	local layer
	local i = 1

	init = init or false

	if init then self:destroy() end

	
	if __weather_id_past ~= __weather_id_future then
		skys[1] = table__deepcopy( __weather_defs[__weather_id_past]["sky"] )
		i=2
	end
	skys[i] = table__deepcopy( __weather_defs[__weather_id_future]["sky"] )

	if not init and self.layer_count > 0 then

		for i=1, self.layer_count do
			if self.layer[i].initialized then
				if self.layer[i].dense_B == 0 then
					self.layer[i]:destroy()
					self.layer[i]:initialize()
				else
					local found = false
					
					for ii=1, #skys[1] do
						CloudType = getCloudtypeByName(skys[1][ii]["layer"])
						if self.layer[i].type == CloudType then
							found = true
							break
						end
					end

					if not found then
						--force 
						self.layer[i]:buildStacks(0,0,0,true)
					end
				end
			end
		end
	end

	for i=1, #skys do
		for ii=1, #skys[i] do	
			CloudType = getCloudtypeByName(skys[i][ii]["layer"])
			if CloudType > 0 then
				LayerIndex = self:getLayerIndexByType(CloudType)
				if LayerIndex > 0 and LayerIndex <= self.layer_count then
					layer = self.layer[LayerIndex]
				else
					layer = self:addLayer(CloudType)
					if i == 2 then layer:buildStacks(0,0,0) end --start from dense 0
				end
				layer:buildStacks(skys[i][ii]["dense"] or 0, skys[i][ii]["waterfilled"] or 0, 0.00)
			end
		end
	end


	--trigger disappearing layer
	if self.layer_count > 0 then
		local e
		local ee
		for e=1, self.layer_count do
			if self.layer[e].initialized then
				ee = false
				i=#skys
				for ii=1, #skys[i] do
					CloudType = getCloudtypeByName(skys[i][ii]["layer"])
					if self.layer[e].type == CloudType then
						ee = true
						break
					end
				end
				
				if not ee then
					self.layer[e]:buildStacks(0,0,0)
				end
			end
		end
	end

	for i=1, self.layer_count do
		if self.layer[i].initialized then
			self.layer[i]:createTransitionTimes()
		end
	end

end

function SKY:calcTrackHeadingRotation()

	self.TrackHeadingRotationVec:set(vec3(0,1,0))
	self.TrackHeadingRotationVec = quat.fromAngleAxis((math.pi/180)*ac.getRealTrackHeadingAngle(), self.TrackHeadingRotationVec)
end

function SKY:update(dt, forceUpdate)
	self.camPos_scaled = __sky__clouds_global_scale*__camPos
	self:calcLightPollution()
	
	for i=1, self.layer_count do
		if self.layer[i].initialized then
			self.layer[i]:update(dt, forceUpdate)
		end
	end

	--DEBUG__clouds__updating(dt)
end

function SKY:calcLightBounce()

	local bounce = 0

	if self.layer_count > 0 and __sky__clouds_light_bounce_calculation_grid_resolution > 0 then

		local grid_bounce = 0
		local grids = __sky__clouds_light_bounce_calculation_grid_resolution * __sky__clouds_light_bounce_calculation_grid_resolution

		for i=1,__sky__clouds_light_bounce_calculation_grid_resolution do
			for ii=1,__sky__clouds_light_bounce_calculation_grid_resolution do
				grid_bounce = 0
				for iii=1, self.layer_count do
					grid_bounce = math.max(grid_bounce, self.layer[iii].clouds_light_bounce_calculation_grid[i][ii])
				end
				bounce = bounce + grid_bounce / grids
			end
		end
	end 

	return bounce
end


function SKY:getLightPollution()

	return { 
			fake_pos = self.pollution_fake_pos,
			radius = self.pollution_radius,
			downlit = self.pollution_downlit
		}
end

function SKY:calcLightPollution()

	self.pollution_fake_pos = (__extern_illumination_position - __camPos)*4.0
	self.pollution_radius = math.max(1000, (25000*math.pow(__extern_illumination_radius*0.001, 0.53)))
	
	

	self.pollution_downlit = __light_pollution__raw:toRgb()
						     * night_compensate(0)
						     --* math.min(1, __extern_illumination_mix)
						     * (1.0 + 1.0 * __night__effects_multiplier)
						     * (1.5 + __night__brightness_adjust*1.5)
						     * (1 + __sky_light_bounce)
							 --* (1 + __overcast)
							 * 0.125

							 

end

function SKY:preload_clouds()

	for i=1, #__cloudtypes do
		if Preload[i] then
			Preload[i]()
		end	
	end

end


--###################################################################


--[[
function sort_ac_clouds()

	local tmp = {}
	local n_acc = 0

	for i=1, __Sky.layer_count do
		
		if __Sky.layer[i].initialized then
			
			for ii=1, __Sky.layer[i].clouds_count do
				
				if __Sky.layer[i].clouds[ii] and __Sky.layer[i].clouds[ii].initialized then
				
					for iii=1, __Sky.layer[i].clouds[ii].ac_clouds_count do
    
						n_acc = n_acc + 1
						tmp[n_acc] = {

							cloud = __Sky.layer[i].clouds[ii].ac_clouds[iii],
							distance = math.horizontalLength(__Sky.layer[i].clouds[ii].pos + __Sky.layer[i].clouds[ii].ac_cloud_pos_offset[iii]),
						}
  					end
				end
			end
		end
	end

	table.sort(tmp, function(a,b) return a.distance > b.distance end)

	for i=1,n_acc do

		ac.weatherClouds[i] = tmp[i].cloud
	end
	ac.weatherClouds[n_acc+1]=nil

end
]]

function sky_get_clouds_light_bounce()
	return __Sky:calcLightBounce()
end

local wind_sound
function initialize_skysim()

	ac.generateCloudMap(__cloud_map)

	if __CSP_version >= 1281 then -- 1.69preview18
		ac.setCloudShadowMaps(true)
		ac.setCloudShadowIndependantOpacity(true)
		--ac.setCloudShadowDistance(float value)
		ac.setCloudShadowScalingFactor(__sky__clouds_global_scale);
	end

	ac.setManualCloudsInvalidation(false)
	ac.setCloudArcMultiplier(0)
	ac.setLightShadowOpacity(1)


	ac.fixSkyColorCalculateOrder(true)
	ac.fixSkyColorCalculateResult(true)
	ac.fixSkyV2Fog(true)
	ac.fixCloudsV2Fog(true)


	__sky__layer_max_distance_base = math.min(100000, math.max(15000, __sky__layer_max_distance_base))

	
	__Sky = SKY:new()
	__Sky:initialize()
	--__Sky:setHeightOffset(0)

	-- texture preloading
	__Sky:preload_clouds()
	--[[
	for i=1, #__cloudtypes do
		__Sky:addLayer(i, 0.5, 0)
		__Sky:removeLayer()
	end
	]]
	ac.setCloudsSorting(true)
end

function fix_cloud_map()

	--__cloud_map.shapeMult = 50.0--/math.pow(_l_MipLodBias2,0.67)
	__cloud_map.shapeMult = 45.0/_l_MIPLODMAP_LUT_r[2]
	ac.generateCloudMap(__cloud_map)
end

local _l_Start = os.clock()
local _l_bStart = true

function update_skysim(dt, forceUpdate)

	if _l_bStart then
		fix_cloud_map()
		if os.clock()-_l_Start > 60 then
			_l_bStart = false
		end
	end

	--ac.setLightShadowOpacity(0.4 + 0.4 * __cloud_transition_density)
	--ac.setLightShadowOpacity(1)

	-- Try to get the same amounts of clouds updated per seconds
	-- This will give even higher fps in the high fps areas
	-- The update intervalls were developed with 60Hz (0.0167ms), to have a smooth movement
	-- So we can even lower the intervalls for higher fps
	__sky__update_multiplier = 0.0167 / math.max(0.005, dt)

	test_osc:update()

	ac.debug("▌ ACclouds", #ac.weatherClouds)
	--ac.debug("### FOV", __camFOV)

	-- Movement --
	__sky__wind= sphere2vec3(__wind_direction + 90, 0) * (__wind_speed/3.6) * dt * __sky__clouds_global_scale * SOL__config("clouds", "movement_multiplier")

	__sky__camShift.x = __camPos.x
	__sky__camShift.y = 0--__Sky:getHeightOffset() * __sky__clouds_global_scale *-1
	__sky__camShift.z = __camPos.z

	__sky__camShift = __sky__camShift --* (__sky__clouds_global_scale) -- don't do scaling here

	__sky__cam_moving_vec = (__sky__camShift - __sky__camShift__prev_frame)

	local camMoveDistance = #__sky__cam_moving_vec
	if camMoveDistance > 100 then --camera jump
		__Sky:shiftPosition(__sky__cam_moving_vec)
		__sky__cam_moving_vec = __sky__cam_moving_vec*0
	elseif camMoveDistance > 1 then
		__sky__cam_moving_vec:normalize()
	elseif camMoveDistance < 0.01 then
		__sky__cam_moving_vec = __sky__cam_moving_vec*0
	end
	__sky__cam_moving_vec__scaled = __sky__cam_moving_vec * __sky__clouds_global_scale

	__sky__curvature_distant_mouth_height = 2000 - (__camPos.y*__sky__clouds_global_scale*0.5)
	__sky__curvature_distant_mouth_height = __sky__curvature_distant_mouth_height - (__sky__base_dome_size-ta_dome_size) * 0.075
	__sky__curvature_distant_mouth_height = __sky__curvature_distant_mouth_height - 1000 * ta_horizon_offset
	
	__sky__update_limiter = SOL__config("clouds", "render_limiter")

	-- update clouds lighting locals
	update_clouds_lighting__call_every_frame(__Sky)
	
	__Sky:update(dt, forceUpdate)
	--ac.sortClouds()
	
	--local t = os.clock()
	--sort_ac_clouds()
	--ac.debug("######", (os.clock()-t)*1000)

	__sky__camShift__prev_frame.x = __sky__camShift.x
	__sky__camShift__prev_frame.y = __sky__camShift.y
	__sky__camShift__prev_frame.z = __sky__camShift.z

	--DEBUG__clouds__storage()

	--ac.invalidateCloudMaps()
end