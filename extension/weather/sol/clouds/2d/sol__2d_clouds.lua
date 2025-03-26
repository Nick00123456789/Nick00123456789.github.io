dofile (__sol__path.."clouds\\2d\\sol__cloud_db.lua")

-- deactivate this Sol <2.0 feature:
sol__economic_weather_transition = false


__cloud_stack  = {}
__clouds_future_stack = nil
__clouds_past_stack = nil
__cloud_change_momentum = 0


__clouds_scale = 1.00

local _l_cloud_density = 0
local _l_old_cloud_density = 0

local test = 0

local earth_radius = 6378140.0  -- meters

local n_act_cloud_render__A = 0
local n_act_cloud_render__B = 0
local n_cloud_render_range = 1

local hasCustomLightColor = true
if __CSP_version < 616 then hasCustomLightColor = false end

preload_textures = {}
local n_preload_textures = 0
function clouds_preload_textures()

	if __cloud_db == nil or #__cloud_db == 0 then return end

	local n = 0

	for i=1, #__cloud_db do

		--preload_textures[i] = {}

		for ii=1, #__cloud_db[i]["clouds"] do

			--n_preload_textures = n_preload_textures + 1

			ac.SkyCloud():setTexture(__sol__path.."clouds\\2d\\"..__cloud_db[i]["clouds"][ii][1].file)

			--preload_textures[n_preload_textures].opacity = 0
			--preload_textures[n_preload_textures].size = vec2(1, 1)
			--preload_textures[n_preload_textures].position = vec3(0, 10000, 0)

			--ac.weatherClouds[n_preload_textures]=preload_textures[n_preload_textures]
		end
	end

end


--local init_cloud = ac.SkyCloud()

--ac.weatherClouds[0]=init_cloud
--init_cloud.opacity = 0
--init_cloud.size = vec2(1, 1)
--init_cloud.position = vec3(0, 10000, 0)

if SOL__config("clouds", "preload_2d_textures") == true then

	clouds_preload_textures()
end

function rebuild_AC_clouds()

	local n = #__cloud_stack

	for i=#ac.weatherClouds, n_preload_textures+1, -1 do
		ac.weatherClouds[i]=nil
	end

	if n_preload_textures > 0 then
		for i=1, n_preload_textures do
			ac.weatherClouds[i] = preload_textures[i]
		end
	end

	for i=1, n do
		ac.weatherClouds[n_preload_textures + i]=__cloud_stack[n - i + 1]["ac_cloud"]
	end
	--ac.weatherClouds[n_preload_textures + #__cloud_stack + 1] = nil

	--ac.debug("###1 n_ac", #ac.weatherClouds)
	--ac.debug("###2 n_sol", #__cloud_stack)
	--ac.debug("###3 diff", #ac.weatherClouds - #__cloud_stack - n_preload_textures)
end


function clouds_set_density(a, complete_change)

	if complete_change == nil then complete_change = true end

	--local build_change = false

	--if a ~= _l_cloud_density then build_change = true end
	_l_old_cloud_density = _l_cloud_density
	_l_cloud_density  = a

	--if __weather_id_past ~= __weather_id_future then 

	if complete_change then
		remove_expired_cloud(true)
		add_introduced_cloud(true)
	end
	
	--end
		
	build_change_stack()
	

	-- reset render split
	n_act_cloud_render__A = 0
	n_act_cloud_render__B = 0
	n_cloud_render_range = 1
end

function add_cloud(cloud, pos)

	if cloud==nil then return end 
	local n = #__cloud_stack
	
	if pos==nil or pos > n+1 then

		pos = n+1 

		for i=1, #__cloud_stack do

			if cloud["grp_id"] >= __cloud_stack[i]["grp_id"] then

				pos = i
				break;
			end
		end
	end 

	if pos <= n then

		if #__cloud_stack > 0 then
			--insert
			for i=n, pos, -1 do

				__cloud_stack[i+1] 	  = table__deepcopy(__cloud_stack[i])
			end
		end
	end
		
	__cloud_stack[pos]    = table__deepcopy(cloud)

	--for i=1, #__cloud_stack do
		--ac.weatherClouds[n_preload_textures + i]=__cloud_stack[i]["ac_cloud"]
	--end
	rebuild_AC_clouds()

	return __cloud_stack[pos]["id"]
end

function remove_cloud(pos)

	local n = #__cloud_stack

	if pos > n or pos < 1 then return end;

	cloudsstorage__set_free(__cloud_stack[pos]["ac_cloud"])
	__cloud_stack[pos] = nil
	
	if pos < n then
		--cut and rearrange

		for i=pos, n-1 do

			__cloud_stack[i]    = table__deepcopy(__cloud_stack[i+1])
			--ac.weatherClouds[n_preload_textures + i] = __cloud_stack[i]["ac_cloud"]
		end
	end

	__cloud_stack[n] = nil
	--ac.weatherClouds[n_preload_textures + n] = nil
	--rebuild_AC_clouds()
end

function check_group_in_stack(c)

	if __cloud_stack == nil or __cloud_db == nil or #__cloud_stack == 0 or #__cloud_db == 0 then return false end

	for i=1, #__cloud_stack do

		if __cloud_stack[i]["grp_id"] == c then
			-- group is already present
			return true
		end
	end

	return false
end


function build_change_stack()

	if __cloud_db == nil or #__cloud_db == 0 then return end

	-- FUTURE
	local groups = {}
	local new = true

	for i=1, #__cloud_db do

		if _l_cloud_density  >= __cloud_db[i]["info"][4] and _l_cloud_density  <= __cloud_db[i]["info"][5] then
--[[
			new = true
			--only add a group, if it doesn't exist yet | only with preloaded clouds
			if sol__economic_weather_transition == false then

				for ii=1, #__cloud_stack do
					if __cloud_stack[ii]["grp_id"] == i then
						new = false
						break;
					end
				end
			end
			if new == true then ]]groups[#groups+1] = i --end
		end
	end

	__clouds_future_stack = {} --clear the stack

	local n_new = 1

	local t = 1
	local t_last = 0

	for g=1, #groups do

		--if check_group_in_stack(groups[i]) == false then

			local i = groups[g]

			local clouds_per_group = math.floor((__cloud_db[i]["info"][1] + rnd(__cloud_db[i]["info"]["rnd"][1])) /math.pow(__clouds_scale, 1.4))
		
			if clouds_per_group > 0 then --count

				local noise_start = math.floor(rnd(128)+128)

				for ii=1, clouds_per_group do

					--prevent duplicated neighbors
					local a = 0
					repeat
						t = math.floor(math.abs(rnd( #__cloud_db[i]["clouds"] ))) + 1
						t = math.min(#__cloud_db[i]["clouds"], math.max(1, t))

						a = a + 1
					until(t ~= t_last or a > 5)

					t_last = t

					__clouds_future_stack[n_new] = {}
					-- cloud group
					__clouds_future_stack[n_new][1] = i 
					-- cloud id
					__clouds_future_stack[n_new][2] = t
					-- azimuth
					__clouds_future_stack[n_new][3] = ((i-1)*277/#groups) + (ii-1)*(360/(clouds_per_group-1)) + rnd(79/(clouds_per_group))
					-- altitude
					__clouds_future_stack[n_new][4] = __cloud_db[i]["info"][2] + rnd(__cloud_db[i]["info"]["rnd"][2])
					-- radius
					__clouds_future_stack[n_new][5] = __cloud_db[i]["info"][3] + math.lerp(__cloud_db[i]["info"]["rnd"][3], -__cloud_db[i]["info"]["rnd"][3], rnd(0.5)+0.5 )  --(ii-1)/(clouds_per_group-1)
					-- change momentum
					__clouds_future_stack[n_new][6] = (ii*0.6)/(clouds_per_group+1)
					-- loaded
					__clouds_future_stack[n_new][7] = false


					-- transition mode memory
					__clouds_future_stack[n_new][8] = {}
					-- mode
					__clouds_future_stack[n_new][8][1] = 1 -- 0 = timed pop | 1 = fade
					-- transition
					__clouds_future_stack[n_new][8][2] = 0
					-- cloud_stack id 
					__clouds_future_stack[n_new][8][3] = 0


					n_new = n_new + 1
				end
			end
		--end
	end

	--PAST
	local n_new = 1

	__clouds_past_stack = {}

	for i=#__cloud_stack, 1, -1 do

--		if (_l_cloud_density  < __cloud_stack[i]["info"][4] or _l_cloud_density  > __cloud_stack[i]["info"][5]) or sol__economic_weather_transition == false then
			--only remove a cloud if it doesn't match density | if no preloaded clouds 
			__clouds_past_stack[n_new] = {}
			__clouds_past_stack[n_new][1] = __cloud_stack[i]["id"]
			__clouds_past_stack[n_new][2] = __cloud_stack[i]["pos"][1]
			--
			-- transition mode memory
			__clouds_past_stack[n_new][5] = {}
			-- mode
			__clouds_past_stack[n_new][5][1] = __cloud_stack[i]["transition"]["mode"] -- 0 = timed pop | 1 = fade
			-- transition
			__clouds_past_stack[n_new][5][2] = 1

			n_new = n_new + 1
--		end
	end

	for i=#__clouds_past_stack, 1, -1 do
		-- change momentum
		__clouds_past_stack[i][3] = (i*0.5)/(#__clouds_past_stack+1)
		__clouds_past_stack[i][4] = false
	end
end


function create_cloud(param)

	if param[1] > #__cloud_db or param[2] > #__cloud_db[param[1]]["clouds"] then return nil end


	cloud = {}
	cloud["grp_id"]= param[1]

	local id
	local found = false
	repeat 
		id = rnd(10000)+10000
		for i=1, #__cloud_stack do
			if __cloud_stack[i]["id"] == id then found = true end
		end
	until( found==false )

	cloud["id"]	   = id
	cloud["info"]  = table__deepcopy(__cloud_db[cloud["grp_id"]]["info"])
	cloud["cloud"] = table__deepcopy(__cloud_db[cloud["grp_id"]]["clouds"][param[2]])


	cloud["ac_cloud"] 		= cloudsstorage__get_free_cloud(1)--ac.SkyCloud()
	-- safest way to create the material here
	cloud["ac_cloud_mat"] 	= ac.SkyCloudMaterial()
		
	cloud["ac_cloud"]:setTexture(__sol__path.."clouds\\2d\\"..cloud["cloud"][1].file)

	cloud["ac_cloud"].useNoise = false
	--cloud["ac_cloud"]:setNoiseTexture(__sol__path.."clouds\\".."noise.dds")

	-- make random
	for iii=2, #cloud["info"] do

		cloud["info"][iii] = cloud["info"][iii] + rnd(__cloud_db[cloud["grp_id"]]["info"]["rnd"][iii])
	end
	for iii=2, #cloud["cloud"] do

		cloud["cloud"][iii] = cloud["cloud"][iii] + rnd(__cloud_db[cloud["grp_id"]]["clouds"]["rnd"][iii])
	end

	--altitude = altitude *math.pow(__clouds_scale, 0.76)

	cloud["pos"] = {}
	cloud["pos"][1] = param[3] -- azimuth
	cloud["pos"][2] = param[4] -- altitude
	cloud["pos"][3] = param[5] -- radius

	local ratio_alt = 0 --math.sin(_toRadians(__cloud_db[grp_id]["info"][2] - altitude))

	cloud["ac_cloud"].size = vec2(cloud["cloud"][3]--[[* (1+0.2*__weather_defs[__weather_id_future]["overcast"])]] , 1) * cloud["cloud"][2]
	--cloud["ac_cloud"].size = cloud["ac_cloud"].size * (1.0-4.0*ratio_alt) --modify size dependent to change of altitude


	
	cloud["ac_cloud"].position = vec3(1, 1, 1)

	cloud["ac_cloud"].opacity 						= cloud["cloud"][4] --* (1-0.9*ratio_alt)
	
	if hasCustomLightColor == true then
	-- check ones post csp 1.25.49 function	
		cloud["ac_cloud"].useCustomLightColor = true
	end

	-- link the material to the cloud
	cloud["ac_cloud"].material = cloud["ac_cloud_mat"]

	cloud["ac_cloud_mat"].frontlitMultiplier 			= cloud["cloud"][5]
	cloud["ac_cloud_mat"].frontlitDiffuseConcentration 	= cloud["cloud"][6]

	cloud["ac_cloud_mat"].backlitMultiplier 			= cloud["cloud"][7] 
    cloud["ac_cloud_mat"].backlitExponent 				= cloud["cloud"][8]
		
	cloud["ac_cloud_mat"].backlitOpacityMultiplier 		= cloud["cloud"][9] 
    cloud["ac_cloud_mat"].backlitOpacityExponent 		= cloud["cloud"][10]
    	
	cloud["ac_cloud_mat"].specularPower 				= cloud["cloud"][11]
    cloud["ac_cloud_mat"].specularExponent 				= cloud["cloud"][12] 

    cloud["ac_cloud"].color = rgb(1.0, 1.0, 1.0)
	cloud["ac_cloud"].horizontal = false
	
	-- this is also set in clouds update dynamically (with sun == true, with moon == false | change with sunangle -7.5)
	cloud["ac_cloud"].occludeGodrays = true

	cloud["ac_cloud"].cutoff = 0
	
	if __CSP_version >= 632 then --csp 1.25.74
    	cloud["ac_cloud"].flipHorizontal = false
    	cloud["ac_cloud"].flipVertical = false
    end

    cloud["transition"] = {}
    cloud["transition"]["mode"] = 1 --not used anymore

    if sol__economic_weather_transition == true then
    	cloud["transition"]["value"] = 1
    else
    	cloud["transition"]["value"] = 0
    end

	return cloud
end


function remove_expired_cloud(forced, inter_forced)

	if forced == nil then forced = false end -- force adding of all clouds
	if inter_forced == nil then inter_forced = false end -- force adding of clouds, dependent of monentum

	if __clouds_past_stack == nil or __cloud_db == nil or #__clouds_past_stack == 0 or #__cloud_db == 0 then return end

	--reverse CAM
	local angles = vec32sphere(__camDir*-1)
	
	local n = 0

	for i = 1, #__clouds_past_stack do
		
		if __clouds_past_stack[i][4] == false then

			n = n + 1

			if sol__economic_weather_transition == true then
				--Transition mode timed pop

				if forced == true or ((angle_diff(__clouds_past_stack[i][2], angles[1]) > 0.75 or inter_forced == true) and __clouds_past_stack[i][3] <= __weather_change_momentum ) then
					-- if not forced, only remove clouds if they're not in sight

					local pos = 0
					for iii = 1, #__cloud_stack do
					
						if __clouds_past_stack[i][1] == __cloud_stack[iii]["id"] then

							pos = iii
							break
						end
					end

					if pos > 0 then

						remove_cloud(pos)
						__clouds_past_stack[i][4] = true

						if forced == false and inter_forced == false then break; end--just do 1 cloud per frame
					end
				end
			else
				--Transition mode fade

				if forced == true or __clouds_past_stack[i][3] <= __weather_change_momentum or 
					(inter_forced == true and __weather_change_momentum==0) then

					local pos = 0
					for iii = 1, #__cloud_stack do
					
						if __clouds_past_stack[i][1] == __cloud_stack[iii]["id"] then

							pos = iii
							break
						end
					end

					if pos > 0 then

						if __weather_change_momentum < 0.9 then

							-- weather transition position = cloud transition
							__clouds_past_stack[i][5][2] = math.min(1, math.max(0, ((__weather_change_momentum-__clouds_past_stack[i][3]) * (1.5 / (1.12-__clouds_past_stack[i][3])))))
							__clouds_past_stack[i][5][2] = math.pow(__clouds_past_stack[i][5][2], 0.67)
							__cloud_stack[pos]["transition"]["value"] = 1-__clouds_past_stack[i][5][2]

						else

							remove_cloud(pos)
							__clouds_past_stack[i][4] = true
						end
					end
				end
			end
		end
	end

	if n==0 then __clouds_past_stack = {} end

	if SOL__config("debug", "weather_change") == true then ac.debug("Change: Clouds expired",string.format('%.0f/%.0f', n, #__clouds_past_stack)) end
end

function add_introduced_cloud(forced, inter_forced)

	if forced == nil then forced = false end -- force adding of all clouds
	if inter_forced == nil then inter_forced = false end -- force adding of clouds, dependent of monentum

	if __clouds_future_stack == nil or __cloud_db == nil or #__clouds_future_stack == 0 or #__cloud_db == 0 then return end

	--reverse CAM
	local angles = vec32sphere(__camDir*-1)

	--ac.debug("### cam angle", angles[1])
	local n = 0

	for i = 1, #__clouds_future_stack do
		
		if __clouds_future_stack[i][7] == false then --loaded

			n = n + 1

			if sol__economic_weather_transition == true then
				--Transition mode timed pop

				if forced == true or ((angle_diff(__clouds_future_stack[i][3], angles[1]) > 0.75 or inter_forced == true) and __clouds_future_stack[i][6] < __weather_change_momentum) then
					-- if not forced, only add clouds if they're not in sight

					add_cloud( create_cloud(__clouds_future_stack[i]))

					-- mark as added
					__clouds_future_stack[i][7] = true

					if forced == false and inter_forced == false then break;
					end--just do 1 cloud per frame	
				end
			else
				--Transition mode fade

				if forced == true or __clouds_future_stack[i][6] < __weather_change_momentum or 
					(inter_forced == true and __weather_change_momentum < 0.01) then

					if forced == false then
						__clouds_future_stack[i][8][2] = 0 -- transition start
					else
						__clouds_future_stack[i][8][2] = 1 -- force transition end 
					end--just do 1 cloud per frame

					-- add the cloud and save the position in the stack
					local cloud = create_cloud(__clouds_future_stack[i])
					__clouds_future_stack[i][8][3] = add_cloud( cloud )

					-- force transperancy till the first calculation
					cloud["ac_cloud"].opacity = 0

					-- mark as added
					__clouds_future_stack[i][7] = true

					if forced == false and inter_forced == false then break;
					end--just do 1 cloud per frame	
				end
			end

		elseif __clouds_future_stack[i][7] == true then
			-- cloud is already loaded

			if sol__economic_weather_transition == false and __clouds_future_stack[i][8][2] < 1.0 then
				--Transition mode fade

				local pos = 0

				for ii=1, #__cloud_stack do
					if __cloud_stack[ii]["id"] == __clouds_future_stack[i][8][3] then
						-- matching id
						pos = ii
						break;
					end
				end

				if pos > 0 then

					if __weather_change_momentum < 0.95 then

						n = n + 1 -- cloud introduction is still running

						-- weather transition position = cloud transition
						__clouds_future_stack[i][8][2] = math.min(1, math.max(0, ((__weather_change_momentum-__clouds_future_stack[i][6]) * (1.5 / (1.12-__clouds_future_stack[i][6])))))
						__clouds_future_stack[i][8][2] = math.pow(__clouds_future_stack[i][8][2], 1.5)
						__cloud_stack[pos]["transition"]["value"] = __clouds_future_stack[i][8][2]
					else

						__clouds_future_stack[i][8][2] = 1.0
						__cloud_stack[pos]["transition"]["value"] = __clouds_future_stack[i][8][2]
					end
				end
			end
		end
	end

	if n == 0 then __clouds_future_stack = {} end

	if SOL__config("debug", "weather_change") == true then ac.debug("Change: Clouds adding",string.format('%.0f/%.0f', n, #__clouds_future_stack)) end
end

function check__clouds_density()

	if inter_forced == nil then inter_forced = false end -- force adding of clouds, dependent of monentum

	if __clouds_past_stack ~= nil then
		if #__clouds_past_stack > 0 then remove_expired_cloud() end
	end
	
	if __clouds_future_stack ~= nil then
		if #__clouds_future_stack > 0 then add_introduced_cloud() end
	end
end

function check_momentum()

	remove_expired_cloud(false, true)
	add_introduced_cloud(false, true)

	__cloud_density = math.lerp(_l_old_cloud_density, _l_cloud_density, __weather_change_momentum)
end

function init__clouds()

	if __cloud_db == nil or __clouds_future_stack == nil or #__cloud_db == 0 then return end

	while #__cloud_stack > 0 do remove_cloud(1) end
	add_introduced_cloud(true)
end



local cloud_lit = {
				--	     FLM		    FLDC   V 		   fog 		  BLM    Sat 		Lit 		Distance  SPP  SPE 		opacity
	{  -180, 0.0,    1.0,    1.0,   0.4, 0.4,   0.35,0.30, 1.5,   0.2, 0.2,  1.0, 1.0, 	0.8,      1.0, 1.0, 	1.0	     },
	{-110.0, 0.0,    1.0,    1.0,   0.4, 0.4,   0.35,0.30, 1.5,   0.2, 0.2,  1.0, 1.0, 	0.8,      1.0, 1.0, 	1.0	     },
	{-102.0, 0.0,    1.0,    1.0,   0.6, 0.5,   0.35,0.25, 0.3,   0.2, 0.2,  1.0, 1.0, 	0.8,      1.0, 1.0, 	1.0	     },
	{-99.00,  1.0, 	1.0,    1.0,   0.5, 0.7,   0.30,0.15, 0.3,   0.2, 0.7,  1.0, 1.0, 	0.8,      1.0, 1.0, 	1.0	     },
-- change of moon and sun light source			
	{-97.50,  1.0, 	1.0,  	1.0,   0.45, 0.6,   0.25,0.10, 0.3,   0.2, 1.0,  0.0, 0.0, 	0.8,      1.0, 1.0, 	1.0	     },
	   		
	{-96.00,  0.5, 	1.0,  	1.0,  0.40, 0.5,   0.33,0.10, 0.3,   0.1, 1.0,  1.0, 1.0, 	0.8,      1.3, 0.4, 	1.0	     },
	{-93.00,  0.1, 	1.5,  	1.0,  0.25, 0.4,   0.30,0.15, 0.3,   0.2, 1.0,  1.0, 1.1, 	0.8,     1.00, 0.35, 	1.0	     },
	{-90.83,  0.1,	2.3,  	1.0,  0.30, 0.43,  0.34,0.30, 0.3,   0.25,1.5,  1.7, 1.6, 	0.72,    0.83, 0.31, 	1.0	     },
	{   -90,  0.1, 	2.0,  	1.0,  0.32, 0.2,   0.35,0.35, 0.3,   0.2, 1.6,  1.3, 1.7, 	0.7,      0.8, 0.30, 	1.10     },
	{   -85,  0.2,	2.0,  	1.8,   0.49,-0.1,  0.40,0.4,  0.5,   0.4, 1.2,  1.0, 1.6, 	0.45,     0.9, 0.45, 	1.05	 },
	{   -80,  0.1, 	2.2,  	2.2,   0.67,0.20,  0.30,0.3,  0.75,  0.7, 0.9,  0.8, 1.3, 	1,        1.0, 0.7, 	1.0	     },
	{   -70,  0.0, 	2.0,   1.35,   0.71,0.55,  0.15,0.0,  1.0,   0.9, 1.0,  0.7, 1.0, 	2,       0.97, 0.65, 	1.0      },
	{   -60,  0.1,   1.5,  	1.3,   0.82,0.6,   0.07,0.0,  0.95,  1.3, 1.4,  0.75,0.91, 	2.05,    0.96, 0.55, 	1.0      },
	{   -50,  0.3,   1.3,  	1.5,   0.90,0.8,   0.00,0.0,  0.9,   1.5, 1.5,  0.8, 0.9, 	2.1,     0.95, 0.50, 	1.0      },
	{     0,  0.5, 	0.7,  	1.5,   0.9, 0.9,   0.00,0.0,  0.8,   2.0, 2.0,  1.0, 1.0, 	2.2,     0.95, 0.30, 	1.0      },
}
local cloud_litCPP = LUT:new(cloud_lit, nil, true)



local cloud_mod1 = OSC:new(0.0002, 2)
cloud_mod1:init()
cloud_mod1:run()



function calc_cloud_position(azi, alti, radius)

	local real_cloud_alti = (earth_radius + alti)
	local curvation_offset = real_cloud_alti * ( 1 - math.cos( _toRadians( ( 360/( 2*math.pi*real_cloud_alti ) ) * radius ) ) ) * 5

	local alpha = 90-_toDegrees( math.atan(radius/(alti - curvation_offset)))
	local distance = math.sqrt( alti*alti + radius*radius )
	 
	local vec_simple = sphere2vec3(azi, alpha)
	local vec = vec_simple * distance
	
	if clouds__steady_world_position == true then

		vec.x = vec.x - __camPos.x
		vec.y = vec.y - __camPos.y
		vec.z = vec.z - __camPos.z
	else

		if ta_dome_size > 1 then
			local s = math.min(10, radius/ta_dome_size)
			vec.x = vec.x - __camPos.x*3*s
			vec.y = vec.y - (__camPos.y - __CamOffsetPos.y + (50 * ta_horizon_offset))*4*s 
			vec.z = vec.z - __camPos.z*3*s
		end
	end
	

	--vec.y = vec.y - __CM__altitude

	return vec, vec_simple, alpha, distance 
end



function update__clouds(dt)

	--DEBUG__clouds__storage()

	local _l_clouds_Lit = SOL__config("nerd__clouds_adjust", "Lit")
	if nopp__use_sol_without_postprocessing then
		_l_clouds_Lit = _l_clouds_Lit * 0.9 * SOL__config("ppoff", "brightness")
	end
	local _l_clouds_Contour = SOL__config("nerd__clouds_adjust", "Contour")
	local _l_clouds_Saturation = SOL__config("nerd__clouds_adjust", "Saturation")
	local _l_clouds_Saturation_limit = SOL__config("nerd__clouds_adjust", "Saturation_limit")

	clouds__render_split = 16--math.max(1, math.min(32, math.floor((10 / SOL__config("clouds", "render_per_frame")) * 5)))

	if __cloud_stack == nil or #__cloud_stack == 0 then return end

	if SOL__config("debug", "weather_change") == true then ac.debug("Change: Clouds number", #__cloud_stack) end

	local test = 0

	local lc = __lightColor:toHsv()

	local sky_color = gfx__get_sky_color(vec3(__sunDir.x,0.9,__sunDir.z), true, true, false) * math.lerp(1, __IntD(2.5,1,0.5), from_twilight_compensate(0))

	lc = mixHSV2(__lightColor:toHsv(), mixHSV2(__ambient_color, sky_color:toHsv(), 0.90 - 0.75*__badness), __overcast)
	

	local base_color = hsv(lc.h, temp_interpol(20, 0.3, 1.0) * __IntD(0.1, lc.s, 0.5), temp_interpol(20, 1.15, 0.85))
		  --base_color = mixHSV2(base_color,hsv(__inair_material.color.h,__inair_material.color.s,0),__inair_material.dense)	
	      base_color.v = base_color.v *__ambient_color.v * (1-0.5*__overcast)
	      							  * math.lerp( 1.0+3.0*__night__effects_multiplier, 1, 1-night_compensate(0))
	      							  * __IntD(0.29,0.34, 0.7)
	      							  * (1-__inair_material.dense*0.5)
	      base_color.s = base_color.s * (1 + 5*__overcast)
	      


	--local sky_color = hsv(__sky_color.h, __sky_color.s*0.5, base_color.v):toRgb()
	base_color = base_color:toRgb()

	local sin_sun = math.max(math.sin(_toRadians(__moon_angle)), 0)
	--ac.debug("###",sin_sun)
	
	local day_comp  	= day_compensate(0)
	local twilight_comp = from_twilight_compensate(0.5)
	local day_angle 	= __IntD(1,0, 1)
	local day_angle_sharp 	= __IntD(1, 0, 0.35)
	local night_angle 	= __IntN(1,0, 10)
	local skypos_saturation = __IntD(0.75, 0.3, 0.7)

	local haze_mod = gfx__get_fog_dense(8000) + (1-__solar_eclipse)*0.25
	if SOL__config("sky", "smog") > 1 then --smog overdrive
		haze_mod = haze_mod * (1 + (SOL__config("sky", "smog")-1)*0.75)
	end 

	local inair_brightness = math.lerp(1.0,0.5*__inair_material.color.v,__inair_material.dense) * math.pow(_l_clouds_Contour, 0.05)
	local inair_mat_opacity_mod = math.lerp(1.0,__IntN(0.0,0.5,10),__inair_material.dense)
	local inair_mfog_mod = (math.lerp(0.5,60.0,math.pow(__inair_material.dense*0.8, 10)))

	local overcast_mod = __overcast*__IntD(1.6, 0.53, 0.35)*day_compensate(0.75)
	local overcast_bright_mod = __overcast*__IntD(1.0, 0.5, 0.35)*day_compensate(0.75)

	local speed_pos = __wind_speed * dt *0.00000001* 60 --calibrated with 60 FPS


	local min = math.min
	local max = math.max
	local pow = math.pow
	local sin = math.sin
	local cos = math.cos

	local pollusion_rgb = hsv.new(__extern_illumination.h, __extern_illumination.s*0.9, __extern_illumination.v*0.35*math.pow(math.min(2, __extern_illumination_mix*0.15),0.35)):toRgb() * (night_compensate(0))
	pollusion_rgb = math.lerp( pollusion_rgb / (math.max(1, math.pow(__extern_illumination_mix, 0.2))) , pollusion_rgb, day_compensate(0))
	local pollusion_vec = validate__vec3(__extern_illumination_position,0,0,0)
	local pollusion_bright_mod = __IntD(1,0,0.4)
	local pollution_opac_mod = 1--__IntN(math.lerp(1,0.1,math.min(1, __extern_illumination_mix)), 1, 10)

	local direction = 1
	if __wind_direction > 180 then direction = direction *-1 end


	-- calculate lit by sun or moon --------------------------------------------------------------------------
	local cl_lit_color  = rgb.new(0,0,0)
	local cl_moon_color = __moonlight_color:toRgb()*1.0*_l_clouds_Lit
	local cl_sun_color  = __sun_color:toRgb() * math.lerp(1,0.5,math.pow(__overcast,3)) * _l_clouds_Lit * (1+0.3*sun_compensate(0))

	local sun_moon_balance = __moon_sun_balance --0--math.min(1, math.max(0, (cl_sun_color.getLuminance()/cl_moon_color.getLuminance()) - 0.5))

	cl_lit_color.r = math.lerp(cl_sun_color.r, cl_moon_color.r, sun_moon_balance)
	cl_lit_color.g = math.lerp(cl_sun_color.g, cl_moon_color.g, sun_moon_balance)
	cl_lit_color.b = math.lerp(cl_sun_color.b, cl_moon_color.b, sun_moon_balance)

	cl_lit_color = cl_lit_color * dawn_exclusive(1.15)

	local _l_moon_light__boost = math.max(1, day_compensate(10 * __moonlight_color.v * math.min(1, math.max(0, __moon_angle*15-15))))

	--local angle_light_source = nil--math.lerp(__sun_angle, __moon_angle, sun_moon_balance) - 90
	local temp_cloud_lit = cloud_litCPP:get() --interpolate__plan(cloud_lit, nil, angle_light_source)

	local l_ta_exp_fix = night_compensate(1/math.max(0.1, math.pow(ta_exp_fix, 0.45)))
	local l_bright_adapt = (1/math.pow(__bright_adapt, 0.5))
	if l_bright_adapt < 0 then l_bright_adapt = l_bright_adapt *-1 end
	temp_cloud_lit[4] = temp_cloud_lit[4] * l_ta_exp_fix * (1+0.6*(1-__solar_eclipse)) * l_bright_adapt
	temp_cloud_lit[5] = temp_cloud_lit[5] * l_ta_exp_fix * (1+0.2*(1-__solar_eclipse)) * l_bright_adapt
	---------------------------------------------------------------------------------------------------------


	if clouds__render_split > 1 then

		-- use render split to save cpu time
		n_act_cloud_render__A = n_act_cloud_render__B
		n_act_cloud_render__B = math.floor(n_act_cloud_render__A + n_cloud_render_range)

		if n_act_cloud_render__A == 0 or n_act_cloud_render__A > #__cloud_stack then

			n_act_cloud_render__A = 1
			n_cloud_render_range = math.max(1, math.floor(#__cloud_stack / math.max(1, clouds__render_split)))
			n_act_cloud_render__B = n_act_cloud_render__A + n_cloud_render_range
		end
	end



	local c, m, d, speed_step, vec, vec_simple, alpha, distance, s_c, m_sin_alt, skypos_color, vec_add, c_tlp, t_fog_cloud_pos
	local w_speed = (__wind_speed * dt * 3.6)

	--ac.debug("####", #__cloud_stack)
	for i=1, #__cloud_stack  do

	    c = __cloud_stack[i]["ac_cloud"]
	    m = __cloud_stack[i]["ac_cloud_mat"]

	    d = math.pow( math.pow(__cloud_stack[i]["pos"][3], 2) + math.pow(__cloud_stack[i]["pos"][2], 2), 0.4)
	    --local speed_step = (0.15/( cos( _toRadians( __cloud_stack[i]["pos"][3]*0.001  ) )  * sin(  _toRadians( __cloud_stack[i]["pos"][2]*0.001 ) ) )) * speed_pos * 10000000
	    speed_step = cos(  _toRadians( __cloud_stack[i]["pos"][2]*0.01)) / d * w_speed


	    --* sin(  _toRadians( __cloud_stack[i]["pos"][2]*0.00000001 ) )
	    
	     __cloud_stack[i]["pos"][1] = __cloud_stack[i]["pos"][1] + (speed_step * direction)

	    vec, vec_simple, alpha, distance = calc_cloud_position( __cloud_stack[i]["pos"][1], __cloud_stack[i]["pos"][2], __cloud_stack[i]["pos"][3] ) 
 		
		c.position = vec
 		
 		-- use render split to save cpu time
		if (i >= n_act_cloud_render__A and i < n_act_cloud_render__B) or clouds__render_split < 2 then

	 		s_c = vec_diff(__lightDir, vec_simple, 1.0) --* day_angle
	 		s_c = min(1, max(0,  s_c ))


	 		m_sin_alt  = math.lerp(math.min(1, math.max(1, __cloud_stack[i]["pos"][2])/650) ,
	 							   math.min(1, 1000/__cloud_stack[i]["pos"][2]), 
	 							   day_compensate(0)) --math.max( math.lerp( 0.2, 0.3, from_twilight_compensate(0) ) + 0.15 * __horizon_fog, pow(1-sin(_toRadians(alpha)), ta_fog_distance) )
	 		
	 		--m_sin_alt = 1-sin(_toRadians(alpha))
	 		dist_multi = math.min( temp_cloud_lit[13] , pow( ((__cloud_stack[i]["pos"][3])/7000) * 2250/__cloud_stack[i]["pos"][2], 4) * twilight_comp )

	 		skypos_color 	= gfx__get_sky_color(vec3(vec_simple.x,
	 														math.max(0.25,vec_simple.y), -- limit horizon to avoid color shifts
	 														vec_simple.z), false)
	 		skypos_color = skypos_color:toHsv()
	 		--skypos_color.v = math.lerp(2.2,1,skypos_color.s)
	 		-- leave a little bit for night
			skypos_color.v = math.max(0.05, skypos_color.v)
			skypos_color.v = math.pow(skypos_color.v, night_compensate(0.25))
			skypos_color.v = skypos_color.v * math.lerp(math.pow(sky__get__color_mod().v * 0.95, 1.67), 1, from_twilight_compensate(0)) --recalibration from Sol 2.0.18


	 		skypos_color.s = from_twilight_compensate(3.5) * skypos_color.s * skypos_saturation / (1+math.max(0.2, c.opacity))
	 		skypos_color.s = math.min(_l_clouds_Saturation_limit * blue_sky_cloud_sat_limit, skypos_color.s)
	 		skypos_color.s = day_compensate(0) * skypos_color.s
	 		skypos_color.s = skypos_color.s * blue_sky_cloud_adaption

	 		skypos_color = skypos_color:toRgb()
		

			m.baseColor.r = math.lerp(math.lerp(skypos_color.r, base_color.r, s_c), skypos_color.r, day_angle)
			m.baseColor.g = math.lerp(math.lerp(skypos_color.g, base_color.g, s_c), skypos_color.g, day_angle)
			m.baseColor.b = math.lerp(math.lerp(skypos_color.b, base_color.b, s_c), skypos_color.b, day_angle)

		    m.baseColor = m.baseColor * __cloud_stack[i]["cloud"][13] * math.lerp(temp_cloud_lit[4],temp_cloud_lit[5], math.pow(s_c, 1.5))
		    m.baseColor = m.baseColor * inair_brightness * (1-0.7*__badness) * (1+overcast_bright_mod) 
		    m.baseColor = m.baseColor + math.max(0.00, math.min(0.10, 0.0001 / dist_multi)) * day_compensate(0.6) 
			m.baseColor = m.baseColor * _l_moon_light__boost
			m.baseColor = m.baseColor * 2.5 --compensate new sky shader
			m.baseColor = m.baseColor * blue_sky_cloud_lev
			m.baseColor = m.baseColor * math.pow(_l_clouds_Lit, 0.5)


		    --if night__use_light_pollusion_from_track_ini == true then
		 		-- extern light pollution
		 		-- calculate an offset for the cloud's position, relative to the pollusion's position
		 		vec_add = validate__vec3(vec - pollusion_vec,0,0,0) --don't know why it has to be validated, but there is a bug which causes a nil value
		 		
		 		--if clouds__steady_world_position == false then vec_add = vec_add - __camPos end

		 		-- calculate cloud / night pollusion relation
		 		c_tlp = #(vec_add) / math.max(1, 1.5*__extern_illumination_radius)
		 		c_tlp = math.pow( math.max(0, 1-c_tlp), 1.5 )

		 		c.extraDownlit = pollusion_rgb
		 					   * pollusion_bright_mod
		 					   * c_tlp
		 					   * math.min(1, __extern_illumination_mix)
		 					   * (1.0 + 1.0 * __night__effects_multiplier)
		 					   * (1.5 + __night__brightness_adjust*1.5)

			--end

		    --c.noiseOffset = vec2(math.sin(cloud_mod1.value), math.cos(cloud_mod1.value))

		    --prevent godrays by moon
		    if __sun_angle <= -7.5 then
		    	c.occludeGodrays = false
		    else
		    	c.occludeGodrays = true
		    end

		    if hasCustomLightColor == true then
		
		    	c.customLightColor = cl_lit_color * math.lerp(temp_cloud_lit[11] --[[* dawn_exclusive(0.7)]],temp_cloud_lit[12],s_c)
			else
				--m.baseColor = cl_lit_color * math.lerp(temp_cloud_lit[11] * dawn_exclusive(0.7),temp_cloud_lit[12],s_c)
			end

			t_fog_cloud_pos = ac.calculateSkyFog(vec3(vec_simple.x, vec_simple.y-0.1, vec_simple.z))

			c.opacity 						= __cloud_stack[i]["cloud"][4]
											* (1-dist_multi*0.1)
											* inair_mat_opacity_mod
											* pollution_opac_mod
											* night_compensate( math.lerp(1-0.5*overcast_mod, 1-0.2*overcast_mod, s_c) )
											* SOL__config("clouds", "shadow_opacity_multiplier")
											* (1.10 + 0.45 * night_angle)
											* math.min(1, math.max(0, __cloud_stack[i]["transition"]["value"])) -- fade transition
											* (1+0.75*__badness)
											* (1-0.50*t_fog_cloud_pos)
											* temp_cloud_lit[16]
											* math.lerp(1.3, 0.7, s_c)
											* blue_sky_cloud_opacity

			--c.opacity = 1

			c.cutoff = math.min(1, math.max(0, math.pow(1-__cloud_stack[i]["transition"]["value"]*1.2, 2.75)))

			--c.cutoff = 0
				
			if hasCustomLightColor == true then																												  -- boost high clouds with really low sun
				m.lightSaturation = math.lerp(temp_cloud_lit[9],temp_cloud_lit[10],s_c)
								    * _l_clouds_Saturation * blue_sky_cloud_sat
				m.lightSaturation = math.min(_l_clouds_Saturation_limit * blue_sky_cloud_sat_limit, m.lightSaturation)				    
			end

			m.frontlitMultiplier 			= __cloud_stack[i]["cloud"][5] * math.lerp(temp_cloud_lit[1],temp_cloud_lit[2],s_c) * math.lerp(0.35, 1,2*math.abs(0.5-s_c))* __IntD(1 + (__cloud_stack[i]["pos"][2]/1000), 1, 0.5)
			m.frontlitDiffuseConcentration 	= __cloud_stack[i]["cloud"][6] * 1.15*math.lerp(temp_cloud_lit[3]*0.45, temp_cloud_lit[3],2*math.abs(0.5-s_c)) * (1+1.5*overcast_mod) * _l_clouds_Contour

			m.backlitMultiplier 			= __cloud_stack[i]["cloud"][7] * temp_cloud_lit[8]
		    m.backlitExponent 				= __cloud_stack[i]["cloud"][8] * 0.30
			
			m.backlitOpacityMultiplier 		= __cloud_stack[i]["cloud"][9]
		    m.backlitOpacityExponent 		= __cloud_stack[i]["cloud"][10]
		    
			m.specularPower 				= __cloud_stack[i]["cloud"][11] 
											  * (1 + __night__effects_multiplier * 2.5 * __moon_sun_balance)
											  * (3-3*__overcast)
											  * temp_cloud_lit[14]
											  * 0.05 + (0.95*day_comp)


		    m.specularExponent 				= __cloud_stack[i]["cloud"][12]
		    								  * (3.5+2.5*__overcast)
		    								  * temp_cloud_lit[15]
		    								  --* 0.25 + (0.75*day_comp)								  

		    m.fogMultiplier					= math.lerp(temp_cloud_lit[6] * dawn_exclusive(1.5), temp_cloud_lit[7],s_c)
		    m.fogMultiplier					= math.max(0, m.fogMultiplier - 0.2*c_tlp)
		    m.fogMultiplier					= m.fogMultiplier + haze_mod*0.25*m_sin_alt --fog plan controlled increase with lower projection-angle
		    m.fogMultiplier					= m.fogMultiplier * (1 + (dist_multi * inair_mfog_mod)) --radius/fog_distance
		    m.fogMultiplier					= math.lerp( m.fogMultiplier,
		    											 1.5,
		    											 __fog_dense )

		    m.fogMultiplier					= m.fogMultiplier * math.lerp(1+overcast_mod, 1+0.15*overcast_mod, s_c)

		    m.fogMultiplier = math.max(m.fogMultiplier, t_fog_cloud_pos)
	    end
	end
end