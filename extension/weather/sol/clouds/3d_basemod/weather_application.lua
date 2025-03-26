



function createGenericCloudMaterial()
  local ret = ac.SkyCloudMaterial()
  ret.baseColor = rgb(1, 1, 1):scale(0.6)
  ret.useSceneAmbient = false
  ret.ambientConcentration = 0.40
  ret.frontlitMultiplier = 1
  ret.frontlitDiffuseConcentration = 0.45
  ret.backlitMultiplier = 0
  ret.backlitExponent = 30
  ret.backlitOpacityMultiplier = 1.0
  ret.backlitOpacityExponent = 1.7
  ret.specularPower = 1
  ret.specularExponent = 5
  if __CSP_version >= 1599 then --CSP version 1.75p41
    ret.alphaSmoothTransition = 0
  end
  ret.contourExponent = 1
  ret.contourIntensity = 0
  --ret.normalFacingExponent = 1
  return ret
end

CloudMaterials = {
  Main = createGenericCloudMaterial(),
  Bottom = createGenericCloudMaterial(),
  Hovering = createGenericCloudMaterial(),
}

CloudMaterials.Bottom.specularPower = 1
CloudMaterials.Bottom.specularExponent = 1
CloudMaterials.Bottom.ambientConcentration = 0.40
CloudMaterials.Hovering.frontlitMultiplier = 0.2
CloudMaterials.Hovering.frontlitDiffuseConcentration = 0.15
CloudMaterials.Hovering.ambientConcentration = 0.1
CloudMaterials.Hovering.backlitMultiplier = 0.2
CloudMaterials.Hovering.backlitOpacityMultiplier = 0
CloudMaterials.Hovering.backlitOpacityExponent = 1
CloudMaterials.Hovering.backlitExponent = 5
CloudMaterials.Hovering.specularPower = 1.0
CloudMaterials.Hovering.specularExponent = 1



n = 1
local _l_mat_LUT = {}
_l_mat_LUT[n] = { -180, 0.0, 1.0, 1.0, 0.0, 1.00, 1.0, 0.5, 0.0  } n=n+1
_l_mat_LUT[n] = { -108, 0.0, 1.0, 1.0, 0.0, 1.00, 1.0, 0.5, 0.0  } n=n+1
_l_mat_LUT[n] = { -102, 0.0, 1.0, 1.0, 0.0, 1.00, 1.0, 0.5, 0.0  } n=n+1
_l_mat_LUT[n] = {  -99, 0.0, 1.0, 1.0, 0.0, 1.00, 1.0, 0.5, 0.0  } n=n+1
_l_mat_LUT[n] = {  -96, 0.0, 1.0, 1.0, 0.0, 1.00, 1.0, 1.0, 0.0  } n=n+1
_l_mat_LUT[n] = {  -93, 0.1, 1.0, 1.0, 0.0, 1.00, 1.0, 3.0, 0.0  } n=n+1
_l_mat_LUT[n] = {  -90, 0.2, 1.0, 1.0, 0.0, 1.00, 1.1, 2.0, 0.0  } n=n+1
_l_mat_LUT[n] = {-87.5, 0.9, 1.0, 1.0, 0.1, 1.15, 1.2, 1.7, 0.0  } n=n+1
_l_mat_LUT[n] = {  -85, 0.8, 3.0, 0.8, 0.3, 0.95, 1.3, 1.5, 0.4  } n=n+1
_l_mat_LUT[n] = {  -80,0.75, 4.0, 0.5, 0.5, 0.80, 2.2, 1.0, 0.7  } n=n+1
_l_mat_LUT[n] = {  -75, 0.8, 3.0, 0.2, 0.7, 0.70, 2.0, 1.0, 1.1  } n=n+1
_l_mat_LUT[n] = {  -70,0.90, 2.0, 0.1, 0.8, 0.85, 2.0, 1.0, 1.5  } n=n+1
_l_mat_LUT[n] = {  -60, 0.8, 1.5, 0.1, 0.9, 0.90, 2.0, 1.0, 1.7  } n=n+1
_l_mat_LUT[n] = {  -40, 0.7, 1.0, 0.1, 1.0, 1.00, 2.0, 1.0, 1.9  } n=n+1
_l_mat_LUT[n] = {  -20, 0.5, 1.0, 0.1, 1.0, 1.00, 2.0, 1.0, 2.3  } n=n+1
_l_mat_LUT[n] = {    0, 0.5, 1.0, 0.1, 1.0, 1.00, 2.0, 1.0, 2.4  } n=n+1
local _l_MATlutCPP = LUT:new(_l_mat_LUT, nil, true)


function updateCloudMaterials()
  --ac.setLightShadowOpacity(0.4 + 0.4 * __cloud_transition_density)

  local lut = _l_MATlutCPP:get() --interpolate__plan(_l_mat_LUT)

  if lut ~= nil then

    local light = __lightColor:toHsv()
    local haze_mod = gfx__get_fog_dense(1000) + (1-__solar_eclipse)*0.25

    local inair_brightness = math.lerp(1.0,0.5*__inair_material.color.v,__inair_material.dense) * math.pow(SOL__config("nerd__clouds_adjust", "Contour"), 0.05)
    local inair_mat_opacity_mod = math.lerp(1.0,__IntN(0.0,0.5,10),__inair_material.dense)
    local inair_mfog_mod = (math.lerp(0.0,60.0,math.pow(__inair_material.dense*0.8, 10)))

    local overcast_steady_mod = math.pow(__overcast, 2)
    local overcast_mod = __overcast*__IntD(0.3, 0.1, 0.35)*day_compensate(0.75)
    local overcast_bright_mod = __overcast*__IntD(1.0, 0.5, 0.35)*day_compensate(0.75)

    --local pollusion_rgb = hsv.new(__extern_illumination.h, __extern_illumination.s*0.9, __extern_illumination.v*0.35*math.pow(math.min(2, __extern_illumination_mix*0.15),0.35)):toRgb() * (night_compensate(0))
    --pollusion_rgb = math.lerp( pollusion_rgb / (math.max(1, math.pow(__extern_illumination_mix, 0.2))) , pollusion_rgb, day_compensate(0))
    --local pollusion_bright_mod = __IntD(1,0,0.4)

    local cloud_color = ac.calculateSkyColor(vec3(0, 1, 0), false, false):toHsv()
    cloud_color.s = cloud_color.s * (0.7 - (0.25 * (1 - __cloud_transition_density)) + (0.5 - 0.5 * math.max(0, 1-__inair_material.color.s)) * overcast_steady_mod)
    cloud_color.s = math.min(blue_sky_cloud_sat_limit, cloud_color.s * blue_sky_cloud_sat)
    cloud_color.v = cloud_color.v * 3.5 * lut[6] * (0.30 + 0.15 * (1 - overcast_steady_mod * sun_compensate(-1)))
    cloud_color.v = cloud_color.v * blue_sky_cloud_lev

    local cloud_color = cloud_color:toRgb()  
    --add sunlight
    cloud_color:add(__sun_color:toRgb() * 0.85 * lut[8] * (0.05 + 0.4 * (1 - __overcast)))
    --add ambientlight
    cloud_color:add(__ambient_color:toRgb()*0.5)
    --add moonlight
    cloud_color:add(__moonlight_color__withoutCloudCover * math.pow( math.sin(_toRadians(math.min(90, math.max(0, __moon_angle))) * 1.5), 1.5 ) * (0.03 * (1.0 + 1.0 * __night__effects_multiplier)) * night_compensate(0))
    --??? worth it ???

    cloud_color = cloud_color * 0.5
    
    local pollusion_rgb = hsv.new(__extern_illumination.h, __extern_illumination.s*0.9, __extern_illumination.v*0.35*math.pow(math.min(2, __extern_illumination_mix*0.15),0.35)):toRgb() * (night_compensate(0))
    local pollusion_rgb = math.lerp( pollusion_rgb / (math.max(1, math.pow(__extern_illumination_mix, 0.2))) , pollusion_rgb, day_compensate(0))
    local pollusion_bright_mod = __IntD(1,0,0.4)

    local downlit = pollusion_rgb
            * pollusion_bright_mod
            * math.min(1, __extern_illumination_mix)
            * (1.0 + 1.0 * __night__effects_multiplier)
            * (1.5 + __night__brightness_adjust*1.5)
            * 0.05

    cloud_color:add(downlit)




    local main = CloudMaterials.Main
    main.baseColor = rgb(1, 1, 1):scale(0.3 * lut[7] * inair_brightness * (1-0.7*__badness) * (1+overcast_bright_mod) )
    main.ambientConcentration = (lut[5] * 0.55
                                        - (0.20 * overcast_steady_mod)
                                        + (0.05 * __inair_material.color.s)
                                        - (0.22 * (1 - __cloud_transition_density))
                                        - (0.20 * (1-ta_fog_level) )
                                ) * (from_twilight_compensate(0.25))
    if nopp__use_sol_without_postprocessing then
      main.ambientConcentration = main.ambientConcentration * 0.75 
      main.ambientColor:set(cloud_color*__IntD(1,0.25))
    else
      main.ambientColor:set(cloud_color)
    end
    --main.ambientColor = main.ambientColor / (__fog_denseTint)
    --  :add(ambientTopColor)
    --[[ main.extraDownlit:set(pollusion_rgb
                 * pollusion_bright_mod
                 * math.min(1, __extern_illumination_mix)
                 * (1.0 + 1.0 * __night__effects_multiplier)
                 * (1.5 + __night__brightness_adjust*1.5)
                 * 1.0
                ) ]]

    main.frontlitMultiplier = lut[1] * (0.5 - (0.00 * overcast_steady_mod))
    main.frontlitDiffuseConcentration = lut[2] *  (1.00 - (0.8 * math.pow((1 - overcast_steady_mod), 0.75)))
    main.backlitMultiplier = 0.2
    main.backlitExponent = 5
    main.backlitOpacityMultiplier = 1.0 - (0.7 * (1 - overcast_steady_mod))
    main.backlitOpacityExponent = 10
    if nopp__use_sol_without_postprocessing then 
      main.specularPower = 2
    else
      main.specularPower = 8
    end
    
    main.specularExponent = 4
    
    main.fogMultiplier = 0.70 + haze_mod*0.033 + __IntD(0.1, 0, 0.5) - __IntN(0.1, 0, 10)
    main.fogMultiplier = main.fogMultiplier * (1 + inair_mfog_mod)
    main.fogMultiplier = math.lerp( main.fogMultiplier, 1.1, __fog_dense )
    main.fogMultiplier = main.fogMultiplier * (1+overcast_mod*sun_compensate(0))
    main.fogMultiplier = main.fogMultiplier / math.max(0.12, math.pow(ta_fog_blend,0.85))

    local bottom = CloudMaterials.Bottom
    bottom.ambientConcentration = main.ambientConcentration * 0.70
    bottom.ambientColor:set(main.ambientColor)
    bottom.extraDownlit:set(main.extraDownlit)
    bottom.frontlitMultiplier = main.frontlitMultiplier
    bottom.frontlitDiffuseConcentration = main.frontlitDiffuseConcentration 
    bottom.backlitOpacityMultiplier = main.backlitOpacityMultiplier
    bottom.backlitOpacityExponent = main.backlitOpacityExponent
    bottom.backlitMultiplier = main.backlitMultiplier * 0.2
    bottom.backlitExponent = main.backlitExponent
    bottom.specularPower = 0.0 
    bottom.specularExponent = 4
    bottom.fogMultiplier = main.fogMultiplier
    
    local hovering = CloudMaterials.Hovering
    hovering.baseColor = rgb(1, 1, 1):scale(0.5 * lut[7])
    hovering.ambientColor:set(cloud_color * 0.5)

    hovering.frontlitMultiplier = 0.0
    hovering.frontlitDiffuseConcentration = 0

    hovering.fogMultiplier = main.fogMultiplier * math.lerp(0.5, 1, __fog_dense) + (0.5 * (1-from_twilight_compensate(0) - 0.5 * night_compensate(0)))
    
    hovering.backlitMultiplier = 0.1 - (0.1 * __overcast)
    hovering.backlitExponent = 1.5
    hovering.specularPower = lut[3]
  end
end

