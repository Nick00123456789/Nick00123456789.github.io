----------------------------------   Weather Effects ----------------------------------
---------------------------------------------------------------------------------------

--------------------------            lightning             ---------------------------

local SOL__WFX_lightning = 0
local SOL__WFX_lightning__value = 0

SOL__WFX__LIGHTNING__RUNNING = false
SOL__WFX__LIGHTNING__POSITION = vec3(0,0,0)

local SOL__WFX_lightning__flash_patterns = {}
SOL__WFX_lightning__flash_patterns[1]  = { 0,1,0.5,1,0.2,1,0.7,0.5,0.35,0.3,0.2,0.1,0 }
SOL__WFX_lightning__flash_patterns[2]  = { 0,1,0.5,0.3,0.9,1,0.7,0.5,0.3,0.6,0.4,0.3,0.15,0 }
SOL__WFX_lightning__flash_patterns[3]  = { 0,0.5,0.7,1,0.8,0.5,0.3,0.7,0.35,0.3,0.2,0.1,0 }
SOL__WFX_lightning__flash_patterns[4]  = { 0,1,0.5,1,0.6,0.2,0.9,0.8,0.4,0.3,0.2,0.1,0 }
SOL__WFX_lightning__flash_patterns[5]  = { 0,0.5,0.3,0.1,1,0.5,0.3,0.2,0.1,0.35,0.3,0.2,0.1,0 }
SOL__WFX_lightning__flash_patterns[6]  = { 0,0.2,0.8,0.3,0.7,0.1,1,0.9,0.4,0.35,0.3,0.2,0.1,0 }
SOL__WFX_lightning__flash_patterns[7]  = { 0,1,0.2,1,0.6,0.2,0.7,0.1,0.6,0.3,0.1,0 }
SOL__WFX_lightning__flash_patterns[8]  = { 0,0.7,0.3,0.9,0.2,0.6,0.1,1,0.8,0.2,0.5,0.35,0.3,0.2,0.1,0 }
SOL__WFX_lightning__flash_patterns[9]  = { 0,1,0.5,0.1,0.2,1,0.7,0.5,0.35,0.3,0.2,0.1,0 }
SOL__WFX_lightning__flash_patterns[10] = { 0,1,0.5,0.1,0.7,0.45,0.3,0.2,0.1,0 }

local SOL__WFX_lightning__flashs = {}

local n_lightnings = 3
local i=0

function rnd_lightning_location()

	local alpha = rnd(37)+37

	return sphere2vec3(rnd(180), alpha) * (500 + math.cos(_toRadians(alpha)) * 8500 ) --sphere2vec3(rnd(180), 10+rnd(10)) * (5000+rnd(1500))
end

function rnd_lightning_time()

	return 2--rnd(math.lerp(90, 15, SOL__WFX_lightning)) + math.lerp(100, 20, SOL__WFX_lightning)	--4 + rnd(2)--
end


function SOL__WFX_lightning_update()

	local time = os.clock()

	for i=1, n_lightnings do 

		if SOL__WFX_lightning__flashs[i]['osc'].running == false then

			if time > SOL__WFX_lightning__flashs[i]['time'] then

				SOL__WFX_lightning__flashs[i]['osc']:run()
				SOL__WFX__LIGHTNING__RUNNING = true
			else
				
				SOL__WFX__LIGHTNING__RUNNING = false
			end
		else 



			SOL__WFX_lightning__flashs[i]['osc']:update()

			local dist = #SOL__WFX_lightning__flashs[i]['sky_gradient'].direction
			local level = __IntN(5, 8, 25)
			local dist_mult = dist/9000
			SOL__WFX_lightning__flashs[i]['sky_gradient'].color = rgb.new(level,level,((level*(1.4-0.50*dist_mult)) ) ) * (SOL__WFX_lightning__flashs[i]['osc'].value * math.max(0,1-(0.5*dist_mult)))

			if SOL__WFX_lightning__flashs[i]['osc'].value > 0 then

				local fog_comp = (1-
								  ( math.pow(SOL__WFX_lightning__flashs[i]['osc'].value, 0.3)
								  	* (__IntN(0.6, 0.1, 25)
								  	+ (0.1*math.pow(1.0-__inair_material.granulation, 2)))
								  )
								 )

				ac.setSkyFogMultiplier( math.lerp(__sky_fog * fog_comp,
											      math.lerp(__sky_fog, math.min(0.97, __sky_fog), math.pow(SOL__WFX_lightning__flashs[i]['osc'].value, 0.5) ),
											      from_twilight_compensate(0) ) )

				--ac.setSkyFogMultiplier( __sky_fog * fog_comp )
				--ac.setSkyBrightnessMult( math.lerp(__sky_color.v, 1, math.pow(SOL__WFX_lightning__flashs[i]['osc'].value, 0.5) ) )

				--ac.setSkyFogMultiplier(  )

				-- light source flashes only when it isn't used anymore
				--if __sun_angle <= -9 then

					ac.setShadows(ac.ShadowsState.On)

					ac.setLightDirection( vec3( SOL__WFX_lightning__flashs[i]['sky_gradient'].direction.x,
												SOL__WFX_lightning__flashs[i]['sky_gradient'].direction.y,
												SOL__WFX_lightning__flashs[i]['sky_gradient'].direction.z )  )

					ac.setLightColor( SOL__WFX_lightning__flashs[i]['sky_gradient'].color * math.max(0, math.pow(SOL__WFX_lightning__flashs[i]['osc'].value, dist_mult*0.1)-(1.5*dist_mult)) * level)
	--[[
					ac.setAmbientColor( rgbm(SOL__WFX_lightning__flashs[i]['sky_gradient'].color.r,
											 SOL__WFX_lightning__flashs[i]['sky_gradient'].color.g,
											 SOL__WFX_lightning__flashs[i]['sky_gradient'].color.b,
											 math.max(0, SOL__WFX_lightning__flashs[i]['osc'].value-(2.0*dist_mult)) * 4 ) )
	]]				
				--end
			end

			if SOL__WFX_lightning__flashs[i]['osc'].running == false then

				--was running, pattern completelly played, stopped

				SOL__WFX_lightning__flashs[i]['osc']:init()
				SOL__WFX_lightning__flashs[i]['osc']:set_pattern(SOL__WFX_lightning__flash_patterns[math.min(10, math.max(1, math.floor(rnd(5)+5)))])

				SOL__WFX_lightning__flashs[i]['time'] = time + rnd_lightning_time()

				SOL__WFX_lightning__flashs[i]['sky_gradient'].direction = rnd_lightning_location()
			end
		end

	end
end
--[[
function SOL__WFX_get_lightning()

	--ac.debug("###", SOL__WFX_lighting__value)
	return SOL__WFX_lightning__value
end]]
function SOL__WFX_set_lightning(a)

end
---------------------------------------------------------------------------------------


function init__SOL_WFX()

	-- init sky gradient for lightning
	--[[
	for i=1, n_lightnings do 

		SOL__WFX_lightning__flashs[i] = {}

		SOL__WFX_lightning__flashs[i]['osc'] = OSC:new(7.5, 1)
		SOL__WFX_lightning__flashs[i]['osc']:init()
		SOL__WFX_lightning__flashs[i]['osc']:set_pattern(SOL__WFX_lightning__flash_patterns[1]) --math.min(10, math.max(1, math.floor(rnd(5)+5)))

		SOL__WFX_lightning__flashs[i]['time'] = os.clock() + i

		SOL__WFX_lightning__flashs[i]['sky_gradient'] = ac.SkyExtraGradient()
		SOL__WFX_lightning__flashs[i]['sky_gradient'].color = rgb.new(0,0,0)
		SOL__WFX_lightning__flashs[i]['sky_gradient'].exponent  = 1.0
		SOL__WFX_lightning__flashs[i]['sky_gradient'].direction = rnd_lightning_location()
		SOL__WFX_lightning__flashs[i]['sky_gradient'].sizeFull  = 5.0
		SOL__WFX_lightning__flashs[i]['sky_gradient'].sizeStart = 0.5
		SOL__WFX_lightning__flashs[i]['sky_gradient'].isAdditive = true
		SOL__WFX_lightning__flashs[i]['sky_gradient'].isIncludedInCalculate = false
		ac.addSkyExtraGradient(SOL__WFX_lightning__flashs[i]['sky_gradient'])
	end
	]]
end

function reset__SOL_WFX()

	-- set initial time of lightning
	for i=1, n_lightnings do

		--SOL__WFX_lightning__flashs[i]['time'] = os.clock() + rnd_lightning_time()
	end
end


function update__SOL_WFX__preSolar()

	
end


function update__SOL_WFX__postSolar()

	if SOL__WFX_lightning > 0 then
		--SOL__WFX_lightning_update()
	else

	end 

end