ac.log("Simple PP off")
ac.debug("Simple PP off", 0.5)

--set new fog algorithm
--comment to use the standard Kunos fog
ac.setFogAlgorithm(ac.FogAlgorithm.New) 

-- moon texture
ac.setSkyMoonTexture("extension\\weather\\sol\\space\\moon.dds")
-- stars texture
ac.setSkyStarsMap("extension\\weather\\sol\\space\\starmap_4k.dds")

function _toRadians(degrees)
  return math.pi * degrees / 180.0
end

function _toDegrees(radians)
  return  radians * 180.0 / math.pi
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
  if alpha > 360 then alpha = alpha - 360 end

  local beta  = _toDegrees(math.asin(vec.y))

  return { alpha, beta }
end

-- do initial dyn. ambi. settings
ac.setWeatherDynamicAmbientMultiplier(0.4)
ac.setWeatherDynamicAmbientSaturation(0.75)
ac.setWeatherDynamicAmbientGamma(1.0)
ac.setWeatherDynamicAmbientBrightness(2.0)



local sun_bloom = ac.SkyExtraGradient()
sun_bloom.color = rgb.new(1,0,0)
sun_bloom.exponent  = 1
sun_bloom.direction = vec3(0,1,0)
sun_bloom.sizeFull  = 5.0
sun_bloom.sizeStart = 1.0
sun_bloom.isAdditive = true
ac.addSkyExtraGradient(sun_bloom)


-- adaptions when PP is set off
local pp_checked = false
local pp_rechecked = false

local use_without_postprocessing = false

function update(dt)

	--############# check PP off ##############
	if pp_rechecked == false then

	    if pp_checked == false then

	      	if ac.isPpActive() == false then

		        use_without_postprocessing = true
		    else
		        use_without_postprocessing = false
		        pp_checked = true
		    end 

	      	pp_checked = true
	    else
	      
	      	if ac.isPpActive() == true then

	      		use_without_postprocessing = false
	        	pp_rechecked = true
	      	end 
	    end
	end

	ac.debug("###", use_without_postprocessing)
 
    local sunDir  = ac.getSunDirection()
  	local moonDir = ac.getMoonDirection()

  	local sun_angle  = vec32sphere(sunDir)[2]
  	local moon_angle = vec32sphere(moonDir)[2]

  	local day 		= math.pow( math.min(1, math.max(0, (sun_angle)/90*3)), 0.5)--math.pow( math.max(0, math.sin( _toRadians( math.min(90, sun_angle          ) ) ) ), 0.40)
  	local twilight 	= math.pow( math.min(1, math.max(0, (sun_angle+18)/90*3)), 1.5)--math.pow( math.max(0, math.sin( _toRadians( math.min(90, sun_angle + 18     ) ) ) ), 0.67)
  	local night 	= math.pow( math.min(1, math.max(0, (-sun_angle+5)/90*12)), 1)--math.pow( math.max(0, math.sin( _toRadians( math.min(90, (sun_angle *-1) + 5) ) ) ), 0.5)

	local ppoff  = 1
	local ppoff2 = 1
	local ppoff3 = 1
	local ppoff4 = 1
	local lights = 1.5

	local condition   = ac.getConditionsSet()

	if use_without_postprocessing == true then
		ppoff  = 0.60 -- ambient
		ppoff2 = 0.30 -- sky
		ppoff3 = 0.27 -- sun
		ppoff4 = 0.35 -- fog
		lights = 0.9
	end 

	ac.setLightDirection(sunDir)

	local lightColor = hsv.new( 10+35*day,
							    1.0-(0.60+(0.1*(condition.temperatures.ambient-20)*0.05))*day,
							    15.0*ppoff3*twilight* math.min(1, math.max(0, sun_angle*0.5-1)))
	ac.setLightColor(lightColor:toRgb())


	local specColor = lightColor
	specColor.s = specColor.s * 0.3

	ac.setSpecularColor(specColor:toRgb() * 1.0)


	__sky_color = hsv.new( 210+18*day, 0.65+0.18*day, 0.1)
	ac.setSkyColor(__sky_color:toRgb())
	ac.setSkyBrightnessMult( (0.025+(0.50-0.0*day)*math.pow(twilight, 0.7)) * ppoff2 * 1.5)


	ac.setSkyAnisotropicIntensity( 3-1*day )
	ac.setSkyDensity(1.2-0.2*day) 
	ac.setSkyZenithOffset(-0.03)
	ac.setSkyZenithDensityExp(-0.9+1.2*night)
	ac.setSkyInputYOffset(0.00)


	ac.debug("Stellar", string.format('day %.2f, twilight %.2f, night %.2f', day, twilight, night ) )

	local ambient = hsv( 220 , 0.25, 1)
	local night_bright = 0.3 * night
	local ambient_bright = (15-6*day)*twilight + night_bright

	ambient_bright = ambient_bright * 1.0

	__ambient_color = ambient

	ambient = ambient:toRgb()
	ac.setAmbientColor( rgbm.new( ambient.r, ambient.g, ambient.b, ambient_bright) * ppoff )

	--ac.setWeatherStaticAmbient(ambient,ambient)

	ac.setWeatherDynamicAmbientMultiplier(0.70*(1.25-0.25*twilight))
	ac.setWeatherDynamicAmbientSaturation(0.75*(0.2+0.8*twilight))
	ac.setWeatherDynamicAmbientBrightness(2.00*(1+1.5*night))



	ac.setFogColor( hsv.new(215, 0.0+0.5*day, ambient_bright*(0.20*math.pow(day,2))):toRgb() * ppoff4)
	ac.setFogDistance( 8000 )
	ac.setFogBlend(0.97) 
	ac.setFogDensity(1.2) 
	ac.setFogExponent( 1.2 ) 
	ac.setFogHeight(800)
	ac.setFogBacklitMultiplier(0.05-0.05*day) 
	ac.setFogBacklitExponent(1)
	ac.setSkyFogMultiplier(0) 
	ac.setSkyFogMultiplier(0) 
	ac.setHorizonFogMultiplier(0.6*twilight, 3, 1)
	

	-- sun appearence
	local sun_ap = hsv.new(15+15*day, 1.8-1.20*day, 0.01):toRgb()
	local sun_ap_bright = (1000-day*500) * ppoff
	ac.setSkySunBaseColor(sun_ap)
	ac.setSkySunBrightness(sun_ap_bright)
  	ac.setSkySunMieExp(5000)
  	ac.setSkySunMoonSizeMultiplier(2.0*1)
	ac.setSkyMultiScatterPhase(0)

	sun_bloom.direction = vec3(sunDir.x*-1, math.lerp(1.3, sunDir.y*-1, day), sunDir.z*-1)
	sun_bloom.sizeFull  = 4.0+1.0*day
	sun_bloom.exponent  = 2
	sun_bloom.color = sun_ap * sun_ap_bright * twilight * (10/ppoff2) * (1+0.5*night)


	ac.setSkyMoonBaseColor( rgbm(1, 1, 1, 1.5 ) * ppoff )
	ac.setSkyMoonOpacity(0.3+0.7*night)
	ac.setSkyMoonMieExp(1000)
	ac.setSkyMoonMieMultiplier(0)

	ac.setSkyStarsBrightness(0.25*(math.pow(night,2)) * ppoff * math.min(1, math.max(0, sun_angle*-0.28-1))  )
	ac.setSkyStarsSaturation(0.2)
	ac.setSkyStarsExponent(2.5)

	ac.setSkyPlanetsBrightness(0)
	ac.setSkyPlanetsOpacity(0.0)


	ac.setGlowBrightness(0.4)

	--ac.setWeatherLightsMultiplier( 1.0*(1-day) * lights )

	-- HEADLIGHTS
	if sun_angle < 5 then ac.setAiHeadlights(true)
	else ac.setAiHeadlights(false)
	end

	local before = collectgarbage('count')
	collectgarbage()
	ac.debug("collectgarbage", math.floor((before - collectgarbage('count')) * 100) / 100 .. " KB")
end