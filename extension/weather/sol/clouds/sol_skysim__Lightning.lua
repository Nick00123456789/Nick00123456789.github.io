__SOL_LIGHTNING_RUNNING = false
__SOL_LIGHTNING_DIR = vec3(0,0,0)
__SOL_LIGHTNING_COLOR = rgb(0,0,0)

local running = false
local flash = 0
local c
local lightning_lifetime = OSC:new(2, 4)
local seq_pos = 1000
local seq_time = 0
local seq_last = 0.05

local next_discharge = -1
local discharge_time = 0.5
local discharge_position = vec3(0,0,0)
local discharge_direction = vec3(0,0,0)
local discharge_distance = 0
local feature_request = false
local feature_request_time = 0


local _l_lightning_gradient = ac.SkyExtraGradient()
_l_lightning_gradient.color = rgb.new(0,0,0)
_l_lightning_gradient.exponent  = 1.0
_l_lightning_gradient.direction = vec3(0,0,0)
_l_lightning_gradient.sizeFull  = 3.0
_l_lightning_gradient.sizeStart = 1.0
_l_lightning_gradient.isAdditive = true
_l_lightning_gradient.isIncludedInCalculate = false
ac.addSkyExtraGradient(_l_lightning_gradient)



function calc_next_discharge(layer)

	local probability_A = 1 + (2* math.random() / math.max(0.05, layer.dense))
	local probability_B = 10 / math.max(0.05, layer.dense) * math.random()

	--ac.debug("### next discharge", probability_A + probability_B)

	return os.clock() + probability_A + probability_B
end


function Preload_Lightning_Textures()
	local accloud = ac.SkyCloudV2():setTexture('\\clouds\\3d\\Lightning.png')
end


function Build_Lightning_Pattern(layer, dense, water, rnd_water)

  	local stack = Stack:new()

  	for i=1,6 do

  		stack:add({
              { "pos", vec3(10000, 500, 10000) },
              { "size", 5000 },
              { "water", 0 },
              { "style", (i-1)/6 },
            })
  	end

  	return stack
end

function Create_Lightning_Layer(layer)

	layer.static = true
end

function Update_Lightning_Layer(layer)

	if layer.clouds[1] and layer.clouds[1].transition < 0.8 then
		next_discharge = -1
	else
		if next_discharge < 0 then next_discharge = calc_next_discharge(layer) end

		if ac.featureRequested and not feature_request and os.clock() > feature_request_time + 1 then
			if ac.featureRequested("lightning") then
				feature_request = true
				feature_request_time = os.clock()
				next_discharge = os.clock()
			end
		elseif feature_request then
			feature_request = false
		end

		if os.clock() >= next_discharge and not running then

			--#### start a lightning

			--use directional ambient light to simulate light
			--if __sun_angle <= -9 then
			if ( math.horizontalLength(discharge_position) < (5000-2500*from_twilight_compensate(0)) and __overcast >= 0.5) then

				-- add light to dir. ambi light for time of lightning
				__SOL_LIGHTNING_RUNNING = true
			end

			if not feature_request then

					--find a big cloud
				local rnd_x = math.pow(math.random(), 1.2) * rnd(1) * 5000
				local rnd_z = math.pow(math.random(), 1.2) * rnd(1) * 5000
				discharge_position = vec3(rnd_x, 500, rnd_z)
				local sky = layer.parent 
				if sky then

					local storm_layer = sky:getLayerIndexByType(getCloudtypeByName("Cumulonimbus"))
					if storm_layer < 1 then
						storm_layer = sky:getLayerIndexByType(getCloudtypeByName("Cumulus"))
					end

					if storm_layer > 0 then

						storm_layer = sky.layer[storm_layer]

						for i=1, storm_layer.clouds_count do

							if storm_layer.clouds[i].charge > 1 then

								discharge_position.x = storm_layer.clouds[i].pos.x
								discharge_position.y = storm_layer.clouds[i].pos.y
								discharge_position.z = storm_layer.clouds[i].pos.z 

								storm_layer.clouds[i].charge = 0

								break
							end
						end
					end
				end
			else

				local dist = -math.pow(0.25+0.75*math.random(), 1.2) * (0.25 + 0.75*math.random()) * 5000
				discharge_position = vec3((__camDir.x+rnd(0.3))*dist, 500, (__camDir.z+rnd(0.3))*dist)
			end



			if math.horizontalLength(discharge_position) < 1000 then
				flash = math.floor(math.random() * layer.clouds_count * 0.5) + 1
			else
				flash = math.floor(math.random() * layer.clouds_count) + 1
			end

			if flash > 0 and flash <= layer.clouds_count then

				layer.clouds[flash].position = discharge_position

				discharge_direction.x = discharge_position.x
				discharge_direction.y = discharge_position.y
				discharge_direction.z = discharge_position.z
				discharge_direction:normalize()

				local grad_dir = vec3(discharge_direction.x, discharge_direction.y*0.5, discharge_direction.z)
				_l_lightning_gradient.direction = grad_dir * -1

				discharge_distance = math.horizontalLength(discharge_position)

				local s
				if layer.clouds[flash].style < 0.5 then
					s = 3000+rnd(700)
					s = vec2(s, s*0.5)
				else
					s = 2000+rnd(300)
					s = vec2(s, s)
				end
				s = s / math.pow(math.max(2000, discharge_distance), 0.1)

				for i=1, layer.clouds[flash].ac_clouds_count do

					c = layer.clouds[flash].ac_clouds[i]
					c.position = layer.clouds[flash].position

					
					c.size = s
					c.opacity = 0
				end
			

				seq_pos = 1
				seq_time = os.clock()

				running = true

				local delay = discharge_distance/330
				local sound_position = layer.clouds[flash].position*0.1
				local thunder
				if discharge_distance < 1000 then 
					thunder = __SoundEngine:addSound('/sol/thunder/near', 1, delay, sound_position)
					--ac.debug("###3","near")
				elseif discharge_distance < 3000 then 
					thunder = __SoundEngine:addSound('/sol/thunder/mid', 1, delay, sound_position)
					--ac.debug("###3","mid")
				else
					thunder = __SoundEngine:addSound('/sol/thunder/distant', 1, delay, sound_position)
					--ac.debug("###3","distant")
				end

				thunder.sound.cameraInteriorMultiplier = SOL__config("sound", "thunder_volume_interior")
				thunder.sound.cameraExteriorMultiplier = SOL__config("sound", "thunder_volume_exterior")
				thunder.sound.cameraTrackMultiplier    = thunder.sound.cameraExteriorMultiplier


				if __SOL_LIGHTNING_RUNNING then
					__SOL_LIGHTNING_DIR = discharge_direction
				end
			end

		elseif os.clock() > (next_discharge + discharge_time) and running then

			--#### stop it
			_l_lightning_gradient.color = rgb.new(0,0,0)

			if flash > 0 and flash <= layer.clouds_count then

				layer.clouds[flash].position = vec3(0, 1000, 0)

				for i=1, layer.clouds[flash].ac_clouds_count do

					c = layer.clouds[flash].ac_clouds[i]
					c.size = vec2(0, 0)
				end
			end

			running = false

			__SOL_LIGHTNING_RUNNING = false

			next_discharge = calc_next_discharge(layer)

		elseif running then

			--#### its running

			if os.clock() > seq_time + seq_last and seq_pos < 6 then

				seq_pos = seq_pos + 1
				seq_time = os.clock()
			end

			if __SOL_LIGHTNING_RUNNING then

				local level = math.pow( math.max(0, (seq_time + discharge_time) - os.clock()), 3)
				local color = math.lerp(rgb(0.92,0.85,1), rgb(0.9, 0.9, 0.8), math.min(1, math.max(0, discharge_distance*0.00025))) * 2000 * (1/math.max(4, math.pow(discharge_distance,0.4) + discharge_distance*0.05)) * level 
				
				__SOL_LIGHTNING_COLOR = color	
			end

			--gradient 
			local gradient_level = from_twilight_compensate(5)*75*math.pow(math.max(0, 1-(os.clock()-next_discharge)), 8)
			_l_lightning_gradient.color = rgb.new(1,1,1) * gradient_level

		end
	end

end




function Create_Lightning_Cloud(cloud)

	cloud.permanent_update = true
	cloud.always_in_front = true

	for i=1, 6 do

	    cloud.ac_clouds_count = cloud.ac_clouds_count + 1

	    accloud = cloudsstorage__get_free_cloud(2) --ac.SkyCloudV2()

	    
	    -- offsets of the different parts
	    cloud.ac_cloud_pos_offset[cloud.ac_clouds_count] = vec3(0,0,0)
	    
	    accloud.texStart:set( vec2((i-1)*1/6, cloud.style) )
	    accloud.texSize:set(vec2(1/6,1/6))
	    accloud:setTexture('\\clouds\\3d\\Lightning.png')

	    cloud.ac_cloud_sizes[cloud.ac_clouds_count] = vec2(0,0) 
    	accloud.size = cloud.ac_cloud_sizes[cloud.ac_clouds_count]

	    accloud.position = cloud.pos
	    accloud.material = cloud.material

	    accloud.horizontal = false
	    accloud.customOrientation = false
	    accloud.noTilt = false
	    accloud.procScale = vec2(1.0, 1.0) *1.0


	    cloud.ac_cloud_color[cloud.ac_clouds_count] = hsv(240,0.5,10):toRgb()

	    accloud.color = cloud.ac_cloud_color[cloud.ac_clouds_count]
	    accloud.occludeGodrays = false
	    accloud.useCustomLightColor = false
	    accloud.useCustomLightDirection = false


	    accloud.procMap = vec2(0,0)
		accloud.procScale = vec2(1,1)
	    accloud.procSharpnessMult = 0
		accloud.procNormalScale = vec2(1,1)
	    accloud.procShapeShifting = math.random()
	    accloud.opacity = 0
	    accloud.shadowOpacity = 0
	    accloud.cutoff = 1
	    accloud.useNoise = false

	    accloud.up = vec3(0, -1, 0)
	    accloud.side = math.cross(-accloud.position, accloud.up):normalize()
	    accloud.up = math.cross(accloud.side, -accloud.position):normalize()
	    accloud.noiseOffset:set(math.random(), math.random()) 

	    cloud.ac_clouds[cloud.ac_clouds_count] = accloud
	end
end

function Update_Lightning_Cloud(cloud)


	local opacity

	cloud.material.baseColor = rgb(1,1,1)
	cloud.material.ambientConcentration = 0
	cloud.material.ambientColor = hsv(60, 0.2, 5):toRgb()
	cloud.material.frontlitMultiplier = 0
	cloud.material.frontlitDiffuseConcentration = 0
	cloud.material.backlitMultiplier = 0
	cloud.material.backlitExponent = 10
	cloud.material.backlitOpacityMultiplier = 0
	cloud.material.backlitOpacityExponent = 10
	cloud.material.specularPower = 0
	cloud.material.specularExponent = 10

	cloud.material.lightSaturation = 1

	cloud.material.fogMultiplier = 0
	cloud.material.extraDownlit = rgb(0,0,0)

	for i=1, cloud.ac_clouds_count do

		c = cloud.ac_clouds[i]

		opacity = math.pow(math.max(0, 1-0.5*(os.clock()-seq_time)), 15)

		if seq_pos == i then

			if seq_pos < cloud.ac_clouds_count then
				c.opacity = 1
				c.cutoff  = 0
			else
				c.opacity = opacity
				c.cutoff  = 1-opacity
			end
		else

			c.opacity = 0
			c.cutoff  = 0
		end

		c = cloud.ac_clouds[i]
	end

end