
local _l_ambient_v
local _l_ambient_add
local _l_sun_v
local _l_light_color = rgb(0,0,0)
local _l_water_color
local _l_ambient_light
local _l_improved_light_with_low_sun
local _l_overcast_nonlin = 0
local _l_day_curve
local _l_day_curve2
local _l_day_curve3
local _l_day_curve4
local _l_day_curve5
local _l_night_curve
local _l_night_curve2
local _l_spectral_filter
local _l_dist_mod
local _l_global_sky_color
local _l_pollution = nil
local _l_clouds_Lit = 1
local _l_clouds_Contour = 1
local _l_clouds_Saturation = 1
local _l_clouds_Saturation_limit = 1
local _l_nopp_top = 1
local _l_nopp_level = 1
local _l_nopp_concentration = 1
local _l_gain_mod = 1
local _l_gain_filter_mod = 1
local _l_saturation = 1
local _l_Lit_Boost = 1
local _l_Lit_Boost_Sat = 1
local _l_moon_light_strength = 25

function update_clouds_lighting__call_every_frame(sky)

    if ta_exp_fix < 1 then
        _l_gain_mod         = math.pow(1/ta_exp_fix, 0.05)
        _l_gain_filter_mod  = math.pow(1/ta_exp_fix, 0.5)
    elseif ta_exp_fix > 1 then
        _l_gain_mod =  math.pow(1/ta_exp_fix, 0.5)
        _l_gain_filter_mod = 1
    else
        _l_gain_mod = 1
    end

    -- adapt main environment variables to be 1 at day
    _l_ambient_v = math.pow(__ambient_color_raw.v * 0.075, 0.5)
    _l_sun_v = math.min(1, 16.5*(1-__overcast)/math.max(10, __lightColor:getLuminance()))
    _l_light_color:set(__lightColor * (__IntD(0.4, math.pow(_l_sun_v+0.1,1), 0.8)) )

    _l_ambient_add = (__ambient_color:toRgb()*0.01)--:adjustSaturation(sun_compensate(2*__overcast))

    _l_overcast_nonlin = math.pow(__overcast, 2)

    _l_pollution = sky:getLightPollution()
    --_l_pollution.downlit = _l_pollution.downlit

    _l_ambient_light = __ambient_color_raw:toRgb() * 0.1 * night_compensate(0.25)
    _l_improved_light_with_low_sun = 1

    if nopp__use_sol_without_postprocessing then
        _l_nopp_top = 2.5
        _l_nopp_level = 1.5 - 0.25*__overcast
        _l_nopp_concentration = 0.5
    else
        
    end

    _l_day_curve  = __IntD(0, 1, 0.7)
    _l_day_curve2 = __IntD(0, 1, 1.5)
    _l_day_curve3 = (0.5+0.5*math.min(1, math.max((1-from_twilight_compensate(0)), (__sun_angle-20)*0.033))) -- lower things from 50° to 20° about 75%
    _l_day_curve4 = math.min(1, math.max(0, (2-_l_day_curve2*3))) -- >50°=0 40°=0.5 <30°=1
    _l_day_curve5 = math.lerp(0.5, _l_day_curve, math.pow(from_twilight_compensate(0), 2)) * math.pow(day_compensate(0), 1.5)


    _l_night_curve  = 1-math.min(1, math.max(0,  (__sun_angle+18)*0.15 ))
    _l_night_curve2 = 1-math.min(1, math.max(0,  (__sun_angle+14)*0.15 ))
    --_d(_l_night_curve.." , ".._l_night_curve2)

    _l_moon_light_strength = math.min(25, math.pow(__IntN(25,0,15), 1.2))

    _l_spectral_filter = gfx__get_distance_spectral_filter() / _l_gain_filter_mod

    -- make a real distant dependency / scale it right
    _l_dist_mod = math.max(20000, gfx__get_custom_distant_fog().distance) * 5--__sky__height_offset*0.001

    local gsc_vec = sphere2vec3(__sun_heading - 90, 30)
    _l_global_sky_color = gfx__get_sky_color(gsc_vec, true, true, false)
    _l_global_sky_color = _l_global_sky_color:toHsv()

    _l_clouds_Lit = SOL__config("nerd__clouds_adjust", "Lit")
	if nopp__use_sol_without_postprocessing then
        _l_clouds_Lit = _l_clouds_Lit * 0.5
        _l_spectral_filter = _l_spectral_filter * 0.25
    end
    _l_clouds_Contour = SOL__config("nerd__clouds_adjust", "Contour")


    local color = gfx__get_sky_color(vec3(__sunDir.x,0.9,__sunDir.z), true, true, false) * math.lerp(1, __IntD(2.5,1,0.5), from_twilight_compensate(0))
    _l_water_color = (color:adjustSaturation(0.8-0.0*__badness+2*_l_overcast_nonlin)) * math.lerp(1.0, 0.5, __overcast)
    
    _l_saturation = math.min(1, __IntD(1.3,0.75,0.7)) 
    _l_Lit_Boost = ((dawn_exclusive(4) * dusk_exclusive(3.5)) - 1) 
    _l_Lit_Boost_Sat = math.min(6, math.pow(_l_Lit_Boost, 7))
    --ac.debug("##C",gfx__get_sky_color(__camDir*-1, true, true, false))

    _l_clouds_Saturation = SOL__config("nerd__clouds_adjust", "Saturation")
    _l_clouds_Saturation_limit = SOL__config("nerd__clouds_adjust", "Saturation_limit")
end




function update_clouds_lighting(cloud, d1_mod, d2_mod, d3_mod)

   

    local water = cloud.water_filled
    local water_nonlin = math.pow(water, 2)
    local water_nonlin2 = math.pow(water, 0.5)
    local top_botton_contrast = 1
    local real_distance_mod = cloud.lastDistance / _l_dist_mod
    local distance_filter = _l_spectral_filter * real_distance_mod

    local size_mod = math.max(0, math.min(1, cloud.size*0.00015)) * (0.5 + 0.5*water_nonlin2)

    local thickness = 1

    local s_c3 = cloud:getLightSourceRelevance(0.25, 2, 2.5)
    local s_c5 = vec_diff(__lightDir, cloud.vec_simple, 1.5) * _l_day_curve4 * (1 - __overcast)

    local _l_curve3 = math.lerp(_l_day_curve3, 1, water)

    local _l_overcast_sky_ratio = 0.3+0.7*__overcast
    local vec = vec3(cloud.vec_simple.x, _l_overcast_sky_ratio-_l_overcast_sky_ratio*d1_mod, cloud.vec_simple.z)
    
    --gfx__get_sky_color(cloud.vec_simple, true)
    local sky_color = gfx__get_sky_color(vec, true, true, false, true)
    --sky_color:adjustSaturation((2.0-from_twilight_compensate(2)*s_c3)*(1-water))
    local sky_color_hsv = sky_color:toHsv()
    
    --_l_water_color = sky_color * 0.5
    local ambient_add = (_l_ambient_add:clone()):adjustSaturation(10-(9*(1-__overcast))*water)


    -- calculate night light pollusion relative position ratio
    vec_add = cloud.pos - _l_pollution.fake_pos
    vec_add.y = 0
    c_tlp = #(vec_add) / _l_pollution.radius
    c_tlp = math.pow( math.max(0, 1-c_tlp), 0.5)


    local cloud_color = rgb(1,1,1)
    cloud_color:add(hsv(sky_color_hsv.h+5-10*_l_day_curve,
                        sky_color_hsv.s
                      * (1 + (-1+4.5*(1-d1_mod))*_l_overcast_nonlin*(1-0.8*__badness))
                      * math.lerp((0.25 + 0.75*water), 1.5-water,  d1_mod)
                      * _l_saturation
                      * (1+s_c5), -- increase saturation with suncover
                      _l_day_curve5*math.lerp((3-0.5*water), 1.25-0.5*__badness, __overcast)):toRgb())
    -- add sunlight to the whole cloud              
    cloud_color:add(  _l_light_color
                    * 0.063 -- calibrate
                    * (1-0.95*water) -- reduce with waterfill
                    * (1 - s_c5) --reduce with suncover
                )
    
    
    -- adjust cloud brightness befor water look
    cloud_color = cloud_color
                * sky_color_hsv.v
                * _l_gain_mod
                

    -- adapt cloud to sky with missing sunlight
    cloud_color = math.lerp(
                    math.lerp((sky_color:adjustSaturation( 1 + __humidity * (1.5+2.0*s_c3) ))* ( 1 - __humidity * (0.5+0.5*s_c3) ) * (2-s_c3) , cloud_color, night_compensate(0)), -- don't do this in night times
                    cloud_color,
                    from_twilight_compensate(0)
                ) 

    cloud_color:adjustSaturation(night_compensate(1 + 0.25 * __overcast))
    cloud_color = cloud_color * night_compensate(from_twilight_compensate(1-0.5*__overcast))

    -- adapt cloud to water look
    local _l_water_temp = _l_water_color:clone()
    if cloud.draw_method == 0 then
        _l_water_temp:adjustSaturation(3.75-3.00*water_nonlin)
        cloud_color = math.lerp(cloud_color, _l_water_temp*(1-math.max(0.30*__overcast,0.45*__badness)), water) 
    else
        cloud_color = math.lerp(cloud_color, _l_water_color*(1-math.max(0.5*__overcast,0.5*__badness)), water) 
    end

    cloud_color = cloud_color
                * _l_clouds_Lit
                * blue_sky_cloud_lev
                

    if cloud.draw_method == 0 then
        
    else
        -- add night light pollution to the cloud's body
        -- those textures can't create enough downlit
        cloud_color:add(_l_pollution.downlit * math.min(0.25, c_tlp) * (1-water))
    end

    if __sun_angle < -7.5 then  
        cloud_color:add(__lightColor * 0.25 * s_c5)
    end


    local top = cloud_color:toHsv()

    -- compensate topcolor to be white, no matter which color the cloud has
    -- this garanties separate color control of top and bottom part
    if cloud.draw_method == 0 then
        top.h = __rev_hue(top.h, -1)
        top.s = top.s * 0.5 * blue_sky_cloud_sat * _l_Lit_Boost_Sat
    end
    
    top.v = top.v * _l_nopp_top * (2-s_c5) --sun cover or not 
    top = top:toRgb() * _l_gain_mod

    if cloud.draw_method == 0 then
        top:sub(distance_filter*top:getLuminance()*0.03)
        --cloud_color = rgb(50,0,0)
    else
        cloud_color:scale(1+water_nonlin*_l_day_curve-0.5*water*(1-sun_compensate(0)))
        top:scale((0.75+0.75*water)*sun_compensate(0))
        cloud_color:adjustSaturation( (1-0.25*water_nonlin*sun_compensate(0)) *0.5 )
        cloud_color:sub(distance_filter*top:getLuminance()*0.045)
        --cloud_color = rgb(0,50,0)
    end

    -- limit saturation
    cloud_color:adjustSaturation(
      math.min(cloud_color:getSaturation(), _l_clouds_Saturation * blue_sky_cloud_sat_limit)
    )
    
    cloud.material.fogMultiplier = gfx__get_fog_dense(cloud.lastDistance*(0.25))     

    cloud.material.baseColor:set(top) -- just the top part
    cloud.material.ambientConcentration = _l_clouds_Contour
                                           * sun_compensate(0.5)
                                           * _l_nopp_concentration
                                           * (0.2+(0.20*d3_mod+0.23*d1_mod*_l_day_curve)*size_mod) 
                                           * (1-0.5*__overcast*(1-water)+0.35*__badness)
                                           * (1-d3_mod*cloud.material.fogMultiplier*water)
                                           
    
    if cloud.draw_method == 0 then
        cloud_color = cloud_color * night_compensate(1 - 0.95*(1-sun_compensate(0)) * water_nonlin2 * (1-d3_mod*cloud.material.fogMultiplier))  
        cloud_color = cloud_color * math.lerp(1, 0.75+0.25*water_nonlin, sun_compensate(0) * (1 - __overcast) * water_nonlin2)
    else
       
    end
    cloud.material.ambientColor:set(cloud_color * _l_nopp_level)


    cloud.material.frontlitMultiplier = math.lerp(0, 0.15-0.15*water, s_c5)--(0.25-0.1*s_c3) * (1 - _l_day_curve) * (1-water)
    
    local diffuse = (0.25+0.0*water)+0.75*(1-d1_mod) --simulating view angle / more dark bottom with steeper view angle
    diffuse = math.min(0.4, 0.2+0.5*water)--diffuse * ( 0.1 + 0.9*water*_l_day_curve)
    cloud.material.frontlitDiffuseConcentration = diffuse 
    
    --cloud.material.receiveShadowsOpacity = true
    
    cloud.material.backlitMultiplier = 0--math.lerp(0.02-0.04*thickness, 0, water)*s_c5--(0.05-0.09*water)*s_c5
    cloud.material.backlitExponent = 10
    cloud.material.backlitOpacityMultiplier = 0+2*water
    cloud.material.backlitOpacityExponent = 10

    

    local lit = 0
    local splendid = 0.5
    if cloud.draw_method == 0 then
        splendid = 5
    else
        cloud.material.backlitMultiplier = 40*s_c5*math.max(0,1-water_nonlin2)*from_twilight_compensate(0)--math.lerp(0.02-0.04*thickness, 0, water)*s_c5--(0.05-0.09*water)*s_c5
        cloud.material.backlitExponent = 35
    end
    
    lit = math.lerp(math.lerp((0.75+(1+splendid*_l_day_curve)*d1_mod) * (1-0.75*water) * (2-_l_day_curve3) * _l_sun_v, math.max(0, 10-10*d1_mod), _l_night_curve2), 
                          0.05, s_c5)
    cloud.material.specularPower = lit * (1 + (_l_Lit_Boost * (1-water_nonlin)))
    cloud.material.specularExponent = 2 + 2*day_compensate(0)
 
    cloud.material.lightSaturation = 0.5 * math.min(_l_clouds_Saturation * blue_sky_cloud_sat_limit, _l_clouds_Saturation_limit)



    -- ### DOWNLIT ###  
    cloud.material.extraDownlit:set(rgb(0,0,0))
    cloud.material.extraDownlit:add(_l_ambient_add)
    cloud.material.extraDownlit:add(_l_pollution.downlit * math.min(0.25, c_tlp) * (2-water))




    --cloud.material.fogMultiplier = gfx__get_fog_dense(cloud.lastDistance*(0.25))
    --cloud.material.fogMultiplier = math.max(_l_cloud_fog_modifier*(1-0.5*sun_compensate(0))*0.75+d2_mod*_l_cloud_fog_modifier*0.25, cloud.material.fogMultiplier)
    --cloud.material.fogMultiplier = math.max(0.8*d2_mod, cloud.material.fogMultiplier)
    
    -- adapt clouds fog fix with CSP 1.69
    --cloud.material.fogMultiplier = cloud.material.fogMultiplier * 1.5


    if cloud.draw_method == 0 then
        -- use new alpha smooth to make the cloud more precise in the distance and more fluffy above 
        if __CSP_version >= 1599 then --CSP version 1.75p41
            cloud.material.alphaSmoothTransition = 1.5-2.5*d2_mod
        end
    else
        cloud.material.ambientConcentration = cloud.material.ambientConcentration * 0.5 * sun_compensate(0)
    end
    

    local custom_dir
    local angle = vec32sphere(cloud.pos)

    --calc strength of sun contra side for illumination from above
    local s_c2 = angle_diff(__sun_heading, angle[1], 1) * 2
    s_c2 = math.min(1, math.max(0.0, s_c2 )) --* from_twilight_compensate(1-s_c3)

    if cloud.draw_method == 0 then
        
    else
        --s_c2 = s_c2 * (1-_l_day_curve4)
    end

    custom_dir = __lightDir or vec3(0,1,0)

    local angle2 = vec32sphere(custom_dir)
    angle2[1] = interpolate__angle(angle2[1], angle[1], s_c2 * _l_improved_light_with_low_sun)
    angle2[2] = interpolate__angle(angle2[2], (60-40*d1_mod), s_c2 * _l_improved_light_with_low_sun)   --math.lerp(angle2[2], 60+30*from_twilight_compensate(0), s_c2 * 2 * __IntD(1,0.7, 0.6))
    custom_dir = sphere2vec3(angle2[1], angle2[2])
    
    local custom_lighting
    if __sun_angle > -7.5 then 
        custom_lighting = {
            color = ((__sun_color:toRgb() *_l_sun_v* (0.15+0.2*water)):sub(distance_filter)),
            dir = custom_dir,
        }

    else
        custom_lighting = {
            color = __lightColor*_l_moon_light_strength*_l_night_curve2*(1-__overcast),
            dir = custom_dir,
        }
    end

    custom_lighting.color:scale((1-__overcast))

    return custom_lighting
end