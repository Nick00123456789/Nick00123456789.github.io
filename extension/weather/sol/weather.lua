--ac.debug("#####1", os.getenv('USERNAME'))
--ac.debug("#####2", ac.getFolder(5))

ac.debug(">>> Sol weather-script","v".."2.2.9 beta 1")
__Sol__version = 2.29

function get__dirname()
  if ac.dirname then
    return ac.dirname()
  else
    return "assettocorsa\\extension\\weather\\sol"
  end
end

__sol__path = get__dirname()
local a,b = string.find(__sol__path, "extension")
if a==nil and b==nil then
  ac.debug("1XXX","         incompatible install of Assetto Corsa ")
else
  __sol__path = string.sub(__sol__path, a)
  __sol__path = __sol__path.."\\"
  ac.debug(">>> Implementation path", __sol__path)

  a,b = string.find(get__dirname(), "common\\assettocorsa")
  if a==nil and b==nil then
    ac.debug("1XXX","                 ! non-Steam installation !")
  end


  function _d(v)
    ac.debug("---",v)
    return v
  end

  function file_exists(name)
     local f=io.open(name,"r")
     if f~=nil then io.close(f) return true else return false end
  end

 

  dofile (__sol__path.."sol__basics.lua")
  dofile (__sol__path.."sol__LUT.lua")
  dofile (__sol__path.."sol__ini_parser.lua")
  dofile (__sol__path.."sol__interface.lua")









  -- the main intercommunication with the Sol_config App
  __configAppInterface = Interface:new("configAPP", 0.25)
  __configAppInterface:setOrderExecutorList({
      SET_VALUE = {call="configAPP__execute_order_SETVALUE",},
      CMD       = {call="configAPP__execute_order_CMD",},
  })

   -- load config at first to access all settings
  if __CONFIG__ALLOW__DIRECT__ACCESS then dofile (__sol__path.."sol__config.lua") end -- #$# remove with new config
  dofile (__sol__path.."sol__shared_memory__backup.lua")  
  dofile (__sol__path.."config\\sol_config_manager.lua")
  dofile (__sol__path.."config\\sol_config__presets.lua")
  -- generate all old sol_config variables, to prevent crashes with old unconverted custom config
  dofile (__sol__path.."sol__config__backward_compatibility.lua")


  --must be defined after config manager is loaded
  function configAPP__execute_order_SETVALUE(order)
      if order.content then
          if order.content.section and order.content.key and order.content.value~=nil then
            if order.content.section == "TA" then
              
            else
              SOL__set_config(order.content.section, order.content.key, order.content.value, false, true, true, false) --command from interface, also with possible reset
            end
          end
      end
  end
  function configAPP__execute_order_CMD(order)
      if order.content['CMD1'] then

        if order.content['CMD1'] == "Performance" or order.content['CMD1'] == "Night" then
          sol_config__set_preset(order.content['CMD1'], tonumber(order.content['CMD2']))

        elseif order.content['CMD1'] == "ResetToDefaults" then
          config_manager__reset_to_defaults()
        elseif order.content['CMD1'] == "SaveStandard" then
          config_manager__store_standard_config_file(false)
        elseif order.content['CMD1'] == "LoadStandard" then
          config_manager__load_standard_config_file()
        end
      end
  end

  dofile (__sol__path.."sol__custom_config.lua")












  -- get CSP version
  __CSP_version = 0
  if ac['getPatchVersionCode'] ~= nil then __CSP_version = ac.getPatchVersionCode() end

  __CSP__wrong_version__ = false
  __CSP__minimum_version = { 1819, "0.1.76" }
  --__CSP__minimum_version = { 1430, "0.1.73" }

  if __CSP_version < __CSP__minimum_version[1] then

    local needed_version = __CSP__minimum_version[2]

    dofile (__sol__path.."sol__LL_info.lua")
    show_low_level_info(needed_version)

    __CSP__wrong_version__ = true

    ac.debug("1XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX", " ")
    ac.debug("2XXX       Please update CSP to version ", needed_version)
    ac.debug("3XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX", " ")


    ac.setSystemMessage("Please update CSP to version "..needed_version.. " !", "Content Manager -> SETTINGS -> Custom Shaders Patch -> about & info")
  end
end

if __CSP__wrong_version__ == false then

  --__configAppInterface:add_order("CMD", {"system","run","true"})
  config_manager__read_config()
  -- clear the dirty state, its the point where we start now
  __configAppInterface:add_order("CMD", {"system","clearDirty","true"})

  __CM__altitude = ac.getAltitude()
  if __CM__altitude == nil then __CM__altitude = 300 end 

  __weather__force__reset = false
  __calc_bug__ = false

  __sun_angle = 90
  __sun_angle_normalized = 0

  __track_ID     = ac.getTrackId()
  __track_Layout = ac.getTrackLayout()

  __AC_TIME = ac.getDaySeconds()
  __custom_sky_preset_LUT = nil
  __sunDir = nil
  __moonDir = nil
  __lightDir = vec3(0,0,0)
  __lightColor = rgb(0,0,0)
  __camDir = vec3.new(1,-1,1)
  __camPos = vec3.new(0,0,0)
  __camFOV = 60
  __CamOffsetPos = vec3(0,0,0)
  local _l_CamPosInit = false
  __track__Cam_offset = 0
  __frame_time = 0
  __WET__MOD = false
  __predictedInteriorAE = 1

  __PPFILTER_PARSE = nil
  
  __VIDEO_INI_PARSE = nil
  __VIDEO_MODE = nil
  __VIDEO_SELECTED_FILTER = nil

  __GRAPHICS_INI_PARSE = nil
  __SYSTEM_MIP_LOD_BIAS = -1

  if #__track_Layout >= 3 and
     (string.sub(__track_Layout, #__track_Layout-2, #__track_Layout) == 'Wet' or 
      string.sub(__track_Layout, #__track_Layout-2, #__track_Layout) == 'wet') then
    __WET__MOD = true
  end

  __session_running_since = os.clock()


  __AE_generated = 1
  function weather__get_hdr_multiplier()

    return SOL__config("weather", "HDR_multiplier")
  end
  function weather__get_AE() return __AE_generated end

  function weather__get_Video_Settings(key, parameter)

    local tmp = get_parsed_value(__VIDEO_INI_PARSE, key, parameter)
    if tmp ~= nil then
      return tmp
    else 
      ac.debug("Get Video Settings Error", "["..key.."],"..parameter.." not found!")
    end
  end

  function weather__get_Graphic_Settings(key, parameter)

    local tmp = get_parsed_value(__GRAPHICS_INI_PARSE, key, parameter)
    if tmp ~= nil then
      return tmp
    else 
      ac.debug("Get Graphic Settings Error", "["..key.."],"..parameter.." not found!")
    end
  end

  function weather__get_PPFilter_INI_Settings(key, parameter)

    local tmp = ppfilter__get_value(key, parameter)
    if tmp ~= nil then return tmp end

    ac.debug("Get PPFilter INI Settings Error", "["..key.."],"..parameter.." not found!")
    return nil
  end

  function SOL_filter__predict_interiorAE()
    return __predictedInteriorAE
  end

  --dofile (__sol__path.."sol__basic_plans.lua")


  --###############################################
  --# Track adaptions
  --###############################################
  dofile (__sol__path.."track adaptions\\sol__track_adaptions.lua") 

  




  --########################################
  --# PP FILTER STUFF
  --########################################

  --interface to custom config
  cc__init_weather_variables()

  function ppfilter__get_value(group, parameter)

    if __PPFILTER_PARSE then
      
      local pp_exp = get_parsed_value(__PPFILTER_PARSE, group, parameter)

      if pp_exp ~= nil then 
        return pp_exp
      end
    end

    return nil
  end

  function ppfilter__reset_ppfilter()
    
    if __CSP_version >= 1937 then -- CSP 1.77
      -- don't do anything, CSP is resetting it right
    else

      local entries = {}
      local n = 1

      entries[n] = { "COLOR", "COLOR_TEMP" ,    ac.setPpColorTemperatureK,  ac.getPpColorTemperatureK   } n=n+1
      entries[n] = { "COLOR", "WHITE_BALANCE" , ac.setPpWhiteBalanceK,      ac.getPpWhiteBalanceK       } n=n+1
      entries[n] = { "COLOR", "HUE" ,           ac.setPpHue,                ac.getPpHue                 } n=n+1
      entries[n] = { "COLOR", "SEPIA" ,         ac.setPpSepia,              ac.getPpSepia               } n=n+1
      entries[n] = { "COLOR", "SATURATION" ,    ac.setPpSaturation,         ac.getPpSaturation          } n=n+1
      entries[n] = { "COLOR", "BRIGHTNESS" ,    ac.setPpBrightness,         ac.getPpBrightness          } n=n+1
      entries[n] = { "COLOR", "CONTRAST"   ,    ac.setPpContrast,           ac.getPpContrast            } n=n+1
      
      
      entries[n] = { "TONEMAPPING", "FUNCTION" ,        ac.setPpTonemapFunction,      ac.getPpTonemapFunction       } n=n+1
      entries[n] = { "TONEMAPPING", "EXPOSURE" ,        ac.setPpTonemapExposure,      ac.getPpTonemapExposure       } n=n+1
      entries[n] = { "TONEMAPPING", "GAMMA"    ,        ac.setPpTonemapGamma   ,      ac.getPpTonemapGamma          } n=n+1
      entries[n] = { "TONEMAPPING", "MAPPING_FACTOR" ,  ac.setPpTonemapMappingFactor, ac.getPpTonemapMappingFactor  } n=n+1
      entries[n] = { "TONEMAPPING", "HDR" ,             ac.setPpTonemapUseHdrSpace,   ac.getPpTonemapUseHdrSpace    } n=n+1
    

      entries[n] = { "GODRAYS", "LENGTH" ,                ac.setGodraysLength           , ac.getGodraysLength             } n=n+1
      entries[n] = { "GODRAYS", "GLARE_RATIO" ,           ac.setGodraysGlareRatio       , ac.getGodraysGlareRatio         } n=n+1
      entries[n] = { "GODRAYS", "ANGLE_ATTENUATION" ,     ac.setGodraysAngleAttenuation , ac.getGodraysAngleAttenuation   } n=n+1
      entries[n] = { "GODRAYS", "NOISE_FREQUENCY" ,       ac.setGodraysNoiseFrequency   , ac.getGodraysNoiseFrequency     } n=n+1
      entries[n] = { "GODRAYS", "NOISE_MASK" ,            ac.setGodraysNoiseMask        , ac.getGodraysNoiseMask          } n=n+1
      entries[n] = { "GODRAYS", "DEPTH_MASK_THRESHOLD" ,  ac.setGodraysDepthMapThreshold, ac.getGodraysDepthMapThreshold  } n=n+1


      entries[n] = { "GLARE", "THRESHOLD" ,               ac.setGlareThreshold           , ac.getGlareThreshold              } n=n+1
      entries[n] = { "GLARE", "BLOOM_LUMINANCE_GAMMA" ,   ac.setGlareBloomLuminanceGamma , ac.getGlareBloomLuminanceGamma    } n=n+1
      entries[n] = { "GLARE", "BLOOM_FILTER_THRESHOLD" ,  ac.setGlareBloomFilterThreshold, ac.getGlareBloomFilterThreshold   } n=n+1
      entries[n] = { "GLARE", "STAR_FILTER_THRESHOLD" ,   ac.setGlareStarFilterThreshold , ac.getGlareStarFilterThreshold    } n=n+1

      for i = 1, #entries do
        local v = ppfilter__get_value(entries[i][1], entries[i][2])
        local w = 0
        if v then
          if entries[i][4] then
            w = entries[i][4]()
            if w ~= v then
              entries[i][3](v)
            end
          else
            entries[i][3](v)
          end
        end
      end
    end
  end


  local ppfilter_name = ""

  function ___reset__Sol___(msg)

    local caller = debug.getinfo(2).name
    if caller ~= "update_sol_custom_config__every_frame" and
       caller ~= "update_sol_custom_config" and
       caller ~= "init_sol_custom_config" then

      -- set the time of the reset in the backup memeory
      msg = msg or "___reset__Sol___"

      local f=io.open(__sol__path.."reset_dummy.lua","w+")
      if f~=nil then
        io.output(f)
        io.write(msg)
        io.close(f)
      end
    else
      ac.debug("WARNING", "Reset is called from script. Was blocked!")
    end
  end



  local _l_pp_state = ac.isPpActive()
  local _l_PPactive_firstRead = false

  function SOL__checkPP_enabled()
    if ac.getSim ~= nil then
      if ac.getSim() ~= nil then
          if _l_PPactive_firstRead ~= ac.getSim().isPostProcessingActive then
              _l_PPactive_firstRead = ac.getSim().isPostProcessingActive
              if _l_PPactive_firstRead ~= ac.isPpActive() then
                  -- if PP enabled state is not steady, reset Sol, to load the right things
                  ___reset__Sol___("PP on/off state change")
              end
          end
      end
      if _l_pp_state ~= ac.isPpActive() then
        ___reset__Sol___("PP on/off state change")
      end
    end
    _l_pp_state = ac.isPpActive()
  end
  SOL__checkPP_enabled()

  function SOL__getPP_enabled()
      return _l_pp_state
  end





  local tmp
  function check_ppfilter_change()

      if ac.getPpFilter ~= nil then
      -- post csp 1.25.49 function
          tmp = ac.getPpFilter()
          if tmp=="" then 
              tmp = "default"
          end
          if tmp ~= ppfilter_name then 
              --this will force CSP to reload the weatherFX implementation
              ___reset__Sol___("ppfilter change -> sol weather.lua")
          end
      end
  end


  local _l_PPactive_firstRead = false
  if __CSP_version >= 1777 then
    _l_PPactive_firstRead = ac.getSim().isPostProcessingActive
  else
    _l_PPactive_firstRead = ac.isPpActive()
  end

  if ac.getPpFilter ~= nil then
    -- post csp 1.25.49 function
  
      --get display mode 
      local vidini = ac.getFolder(5) .. '\\video.ini'
  
      if vidini ~= nil and vidini ~= "" then 
  
        if file_exists(vidini) == true then 
          if SOL__config("debug", "graphics") == true then ac.debug("Gfx: video.ini", vidini) end
          __VIDEO_INI_PARSE = parse_INI(vidini, "PP")
  
          if __VIDEO_INI_PARSE ~= nil then
  
            __VIDEO_MODE = get_parsed_value(__VIDEO_INI_PARSE, "CAMERA", "MODE")
            if __VIDEO_MODE ~= nil then
              if SOL__config("debug", "graphics") == true then ac.debug("Gfx: Videomode", __VIDEO_MODE) end
            else 
              __VIDEO_MODE = "DEFAULT"
              ac.log("Parse Error".."...could not parse video mode")
            end
  
            __VIDEO_SELECTED_FILTER = get_parsed_value(__VIDEO_INI_PARSE, "POST_PROCESS", "FILTER")
          end
        end
      end
  
  
      ppfilter_name = ""
  
      if __VIDEO_MODE == "OCULUS" or __VIDEO_MODE == "OPENVR" then
  
        if __VIDEO_SELECTED_FILTER ~= nil then 
          ppfilter_name = __VIDEO_SELECTED_FILTER
        else
          ppfilter_name = ""
        end
      else
        ppfilter_name = ac.getPpFilter()
      end
  
      if ppfilter_name=="" then 
          ppfilter_name = "default"
      end
      --if ppfilter_name ~= "" then 
  
        local ppfilter_file = "system\\cfg\\ppfilters\\"..ppfilter_name..".ini"
  
        if file_exists(ppfilter_file) == true then 
          --parse PPFilter file and store it in a table
          __PPFILTER_PARSE = parse_INI(ppfilter_file, "PP")
          if __PPFILTER_PARSE ~= nil then 
  
            --try to reset all available entries
            --ppfilter__reset_ppfilter()

            if SOL__config("debug", "graphics") == true then ac.debug("GFX: loaded and parsed PPFilter", ppfilter_name) end
            --list all entries in the log
            --[[
            local count = 0
            for k1,v1 in pairs(__PPFILTER_PARSE) do
              count = count + 1
              for k2,v2 in pairs(__PPFILTER_PARSE[k1]) do
                count = count + 1
                local tmp = ""
                local a = __PPFILTER_PARSE[k1][k2]
                if a ~= nil then
                  for i=1, #a do
                    tmp = tmp..a[i]
                    if i < #a then tmp = tmp.."," end
                  end
                  ac.log("PP".."...["..k1.."]..."..k2.."="..tmp)
                else
                  ac.log("PP Error".."...["..k1.."]..."..k2)
                end
              end
            end
            ac.log("PP".."...entry count: "..count)
            ]]
          else
            ac.log("PP Error".."...could not parse the PPFilter file: "..ppfilter_file)
          end
        else
          ac.log("PP Error".."...could not open file "..ppfilter_file)
        end
      --else
      --  ac.log("PP Error".."...could not retrieve the PPFilter-name from CSP")
      --end
  
    elseif __CSP_version <= 333 then --csp 1.25.49
  
      if ppfilter__load_basic_custom_config == true then
        ppfilter_name = ""
      else
        ppfilter_name = "__Sol"
      end
    end
  
    local custom_config = "extension\\weather\\sol\\"..ppfilter_name..".lua"
    if file_exists(custom_config) ==  false then
  
        custom_config = "system\\cfg\\ppfilters\\sol_custom_configs\\"..ppfilter_name..".lua"
        if file_exists(custom_config) ==  false then
  
          if ppfilter__load_basic_custom_config == true then
  
            -- if no custom config is available, load the default one
            custom_config = "system\\cfg\\ppfilters\\sol_custom_configs\\__Sol_basic_CC.lua"
            if file_exists(custom_config) ==  false then custom_config = nil end
          else
            custom_config = nil
          end
        else
          if __PPFILTER_PARSE ~= nil then 
            --try to reset all available entries, only if a custom config is used
            ppfilter__reset_ppfilter()
          end
        end
    else
      if __PPFILTER_PARSE ~= nil then 
        --try to reset all available entries, only if a custom config is used
        ppfilter__reset_ppfilter()
      end
    end

    -- reset cars AE multis to the standard value
    ac.setCarExposureActive(true)
  

    function init_config()
      if __PPFILTER_PARSE ~= nil then 
        ppfilter__reset_ppfilter()
      end
      if custom_config ~= nil and ac.isPpActive() then
        local backup_sky__blue_booster = sky__blue_booster
        sky__blue_booster = -1
        dofile (custom_config)
        if SOL__config("debug", "custom_config") == true then ac.debug("CC file", custom_config) end
        if init_sol_custom_config ~= nil then
          init_sol_custom_config()
          __configAppInterface:add_order("CMD", {"system","BottomConsole","Custom Config was initialized"})
        end
      else
        if SOL__config("debug", "custom_config") == true then ac.debug("CC file", "no custom_config loaded") end
      end
    end
    init_config()

  -----------------------------------------------------------------------------------
  -- N O  P P    ---    Do not change this - it is set automatically !!!
  nopp__use_sol_without_postprocessing = false
  -- AMBIENT_BASED_BRIGHTNESS_MULT=0.7 !!!!
  ------------------------------------------------------------------------------------------
  -- adaptions when PP is set off
  local pp_checked = false
  local pp_rechecked = false
  





  function update__config()

    if pp_rechecked == false then

      if pp_checked == false then

        if ac.isPpActive() == false then

          nopp__use_sol_without_postprocessing = true
        else
          nopp__use_sol_without_postprocessing = false
          pp_checked = true
        end 
        
        pp_checked = true
      else
        
        if ac.isPpActive() == true then
          
          pp_rechecked = true
        end 
      end
    end
  end

  --get display mode 
  local graphicsini = ac.getFolder(4) .. '\\system\\cfg\\graphics.ini'
  if graphicsini ~= nil and graphicsini ~= "" then 
    
    if file_exists(graphicsini) == true then 
      __GRAPHICS_INI_PARSE = parse_INI(graphicsini, "PP")
      
      if __GRAPHICS_INI_PARSE ~= nil then

        __SYSTEM_MIP_LOD_BIAS = get_parsed_value(__GRAPHICS_INI_PARSE, "DX11", "MIP_LOD_BIAS")
        if __SYSTEM_MIP_LOD_BIAS ~= nil then
        else 
        end
      end
    end
  end



  if __CONFIG__ALLOW__DIRECT__ACCESS then dofile (__sol__path.."sol__check_config.lua") end -- #$# remove with new config

  
  dofile (__sol__path.."sol__sequenzer.lua")
  dofile (__sol__path.."sol__audio.lua")
  dofile (__sol__path.."sol__weather_effects.lua")

  dofile (__sol__path.."sol__weather.lua")
  dofile (__sol__path.."sol__solar_system.lua")


  local _l_config__clouds__render_method = SOL__config("clouds", "render_method")

  dofile (__sol__path.."clouds\\sol_skysim_utils.lua")
  dofile (__sol__path.."clouds\\sol_skysim_dome.lua")
  if _l_config__clouds__render_method == 1 then
    dofile (__sol__path.."clouds\\3d_basemod\\consts.lua")
  end
  
  

  dofile (__sol__path.."sol__filter.lua")
  if SOL__config("debug", "track") == true then
    ac.debug("Track: ID", __track_ID..", Layout: "..__track_Layout)
    ac.debug("Track: Heading angle", string.format('%.1f°',ac.getRealTrackHeadingAngle()))
  end

  local dt_sol = 0
  local dt_sol_a = 0
  local dt_sol_b = 0
  local dt_sol_n = 0
  local dt_sol_avg = os.clock()
  local dt_sol_max = 0
  --[[
  local dt_long_avg = os.clock()
  local dt_long_avg_calc = 0
  local dt_avg_check = 0
  ]]
  function sol_dt()

    --[[
    dt_avg_check = dt_avg_check + 1
    if dt_avg_check > 30 then

      local _l_avg_long = os.clock()-dt_long_avg

      if dt_long_avg_calc > 0 then
        if _l_avg_long > dt_long_avg_calc * 1.5 then
          --__weather__force__reset = true
          if __weather_change_momentum < 0.05 then
            __calc_bug__ = true
            ac.debug("!!! calc bug","clouds update stoped !!!")
          end
        else
            dt_long_avg_calc = 0.9*dt_long_avg_calc + 0.1*_l_avg_long
        end
      else
        dt_long_avg_calc = _l_avg_long
      end

      dt_long_avg = os.clock()
      dt_avg_check = 0
    end
    ]]

    if os.clock() - dt_sol_avg > 1 and dt_sol_n > 0 then

      local avg = (dt_sol/dt_sol_n)

      if SOL__config("debug", "runtime") == true then
        ac.debug("Runtime: avg.", string.format('x: %.2f ms, max.: %.2f ms', avg*1000, dt_sol_max*1000  ))
      end

      dt_sol = 0
      dt_sol_n = 0
      dt_sol_avg = os.clock()
      dt_sol_max = 0
    else

      local t = (dt_sol_b - dt_sol_a)

      dt_sol_max = math.max(t, dt_sol_max)

      dt_sol = dt_sol + t
      dt_sol_n = dt_sol_n + 1
    end 
  end


  local waiting__headlights_off = 0
  local waiting__for_filter = true

  local _l_cam_offset = -1


  local ruBase = nil
  local ruCloudMaterials = nil
  local ruClouds = nil
  local lastSunDir = vec3()
  local lastCamPos = vec3()
  local lastGameTime = 0
  local cloudsDtSmooth = 0

  local cpu_split = 0
  local cpu_split_count = 4


  
  if SOL__config("clouds", "randomize_with_reset") then
		math.randomseed(os.time())
	else
		math.randomseed(SOL__config("clouds", "manual_random_seed") or 0)
	end

  
  if _l_config__clouds__render_method == 0 then

    --ruClouds = RareUpdate:new{ callback = update__clouds, phase = 2 }

  elseif _l_config__clouds__render_method == 1 then

    local cloudMap = ac.SkyCloudMapParams.new()
    cloudMap.perlinFrequency = 4.0
    cloudMap.perlinOctaves = 7
    cloudMap.worleyFrequency = 4.0
    cloudMap.shapeMult = 20.0
    cloudMap.shapeExp = 0.5
    cloudMap.shape0Mip = 1.2
    cloudMap.shape0Contribution = 0
    cloudMap.shape1Mip = 2.8
    cloudMap.shape1Contribution = 0.5
    cloudMap.shape2Mip = 4.5
    cloudMap.shape2Contribution = 1.0
    ac.generateCloudMap(cloudMap)

    ac.setCloudShadowMaps(true)
    ac.setManualCloudsInvalidation(true)

	  ac.setLightShadowOpacity(1)

    if ta_horizon_offset < 0 then

      DynCloudsDistantHeight = DynCloudsDistantHeight - 400 * ta_horizon_offset
    else

      DynCloudsDistantHeight = DynCloudsDistantHeight - 300 * ta_horizon_offset
    end

    DynCloudsMinHeight = DynCloudsMinHeight - (__CM__altitude * 0.75)
    DynCloudsMaxHeight = DynCloudsMaxHeight - (__CM__altitude * 0.75)

    ruCloudMaterials = RareUpdate:new{ callback = updateCloudMaterials, phase = 1 }
    ruClouds = RareUpdate:new{ callback = updateClouds, phase = 2 }

  elseif _l_config__clouds__render_method == 2 then

    initialize_skysim()
    ruClouds = RareUpdate:new{ callback = update_skysim, phase = 2 }
  end
  
  function getCloudsDeltaT(dt, gameDT)

    if SOL__config("clouds", "movement_linked_to_time_progression") == false then
        return __frame_time
    else
      local gameTime = ac.getCurrentTime()
      local cloudsDeltaTime = gameTime - lastGameTime
      local cloudsDeltaTimeAdj = math.sign(cloudsDeltaTime) * math.abs(cloudsDeltaTime) / (1 + math.abs(cloudsDeltaTime))
      lastGameTime = gameTime
      cloudsDtSmooth = math.applyLag(cloudsDtSmooth, 
        math.lerp(math.clamp(cloudsDeltaTimeAdj, -1, 1), gameDT, 0.8),
        0.9, dt)
      return cloudsDtSmooth
    end
  end

  

  local _l_custom_config_DT = 0

  function rareUpdateBase(dt)

    _l_custom_config_DT = _l_custom_config_DT + dt

    cpu_split = cpu_split + 1
    
    if cpu_split > cpu_split_count then

      cpu_split = 1
    end

    if _l_config__cpu_split==false or cpu_split == 1 then

      update__config()

      if update_sol_custom_config ~= nil then
        update_sol_custom_config(_l_custom_config_DT)
        _l_custom_config_DT = 0

        if __CONFIG__ALLOW__DIRECT__ACCESS then sol_check_config() end -- #$# remove with new config
      end
    end

    if _l_config__cpu_split==false or cpu_split == 2 then update__basic__vars() end
    if _l_config__cpu_split==false or cpu_split == 3 then update__weather(dt) end

    if _l_config__cpu_split==false or cpu_split == 4 then
      --update__SOL_WFX__preSolar()
      --update__SOL_WFX__postSolar()
      --gfx__update_sunlight() --update sunlight again, to prevent flashing clouds
      --update__solar_system(dt)
      if _l_config__clouds__render_method == 0 then
        --update__clouds(dt) 
      end
    end 
  end


  local ruBase = RareUpdate:new{ callback = rareUpdateBase }

  local gameDT = 0
  local cloudsDT = 0
  local currentSunDirection = ac.getSunDirection()
  local forceUpdate = false

  -- check the dummy file, if the filter was reset less than 2 seconds ago, do not check it again
  local __AFTER__VR__RESET__ = false
  local __BEFORE__VR__RESET__ = false
  if __VIDEO_MODE == "OCULUS" or __VIDEO_MODE == "OPENVR" then
      local l = lines_from(__sol__path.."\\reset_dummy.lua")
      __BEFORE__VR__RESET__ = true
      if l~=nil then
          for i=1, #l do
              if string.find(l[i], "check ppfilter vr") == 1 then
                  if l[i+1]~=nil then
                      local time = tonumber(l[i+1])
                      if math.abs(os.time()-time) < 10 then
                          __AFTER__VR__RESET__ = true
                          __BEFORE__VR__RESET__ = false
                      end
                  else
                      __BEFORE__VR__RESET__ = false
                  end
                  break
              end
          end
      end
  end

  ac.skipSaneChecks()

  if SOL__config("debug", "runtime") == true then
  
    function asyncMaintenance()
      runGC()
    end

    local gcSmooth = 0
    local gcRuns = 0
    local gcLast = 0
    function runGC()
      local before = collectgarbage('count')
      collectgarbage()
      gcSmooth = math.applyLag(gcSmooth, before - collectgarbage('count'), gcRuns < 50 and 0.9 or 0.995, 0.01)
      gcRuns = gcRuns + 1
      gcLast = math.floor(gcSmooth * 100) / 100
    end

    function printGC()
      ac.debug("Runtime: collectgarbage", gcLast .. " KB")
    end
  end


  local _l_reset_blocker = os.clock()

  local skysim__dt = 0

  if use_custom_weather then
    ac.debug("Custom Weather", "is used!")
  end



  local _l_speed = 0
  local _l_vr_reset_overdue_time = os.clock()

  function update(dt)

    local _l_HL_amb = SOL__config("headlights", "if_ambient_light_is_under")
    if nopp__use_sol_without_postprocessing then
      _l_HL_amb = _l_HL_amb * 0.9 * SOL__config("ppoff", "brightness")
    end
    local _l_HL_sun = SOL__config("headlights", "if_sun_angle_is_under")
    local _l_HL_fog = SOL__config("headlights", "if_fog_dense_is_over")
    local _l_HL_bad = SOL__config("headlights", "if_bad_weather")


    --if _l_config__clouds__render_method > 0 then
      gameDT = ac.getGameDeltaT()

      -- clouds operate on actual passed time
      cloudsDT = getCloudsDeltaT(dt, gameDT)  
      currentSunDirection = ac.getSunDirection()
      
      forceUpdate = math.dot(lastSunDir, currentSunDirection) < 0.999998
      if forceUpdate then
        lastSunDir:set(currentSunDirection)
      end
    --end





    -- constantly checking if PP enabled state is steady.
    -- In VR it is not set right while the start of AC
    SOL__checkPP_enabled()
    
    -- Check if ppfilter was changed
    if __VIDEO_MODE ~= "OCULUS" and __VIDEO_MODE ~= "OPENVR" then
        check_ppfilter_change()
    elseif not __AFTER__VR__RESET__ then
        -- if VR is used and there was no reset yet, do the reset and write the time for comparison 
        local msg = "check ppfilter vr\n"..os.time()
        ___reset__Sol___(msg)
        __AFTER__VR__RESET__ = true
    elseif __AFTER__VR__RESET__ and __BEFORE__VR__RESET__ then
        -- in case something happens and the reset after VR reset is not recognized
        -- call the necessary things
        if (os.clock() - _l_vr_reset_overdue_time) > 1 then
            init_config()
            __BEFORE__VR__RESET__ = false
        end
    end 


    if __BEFORE__VR__RESET__ then return end






--[[
    -- if recognition of PP activated is running late (first start of AC), then do a wfx reset.
    -- Nobody will notice it, but everything is loaded correctly then
    if __CSP_version >= 1777 then
      if _l_PPactive_firstRead ~= ac.getSim().isPostProcessingActive then
        ___reset__Sol___()
      end
    else
      if _l_PPactive_firstRead ~= ac.isPpActive() then
        ___reset__Sol___()
      end
    end


    if _l_PPactive_firstRead then
      if __VIDEO_MODE ~= "OCULUS" and __VIDEO_MODE ~= "OPENVR" then
        check_ppfilter_change()
      elseif not checked_filter_once then
        -- if VR is used and there was no reset yet, do the reset and write the time for comparison
        local f=io.open(__sol__path.."reset_dummy.lua","w+")
        if f~=nil then
          io.output(f)
          io.write("check ppfilter vr\n")
          io.write(""..os.time())
          io.close(f)
        end 
        checked_filter_once = true
      end 
    end
]]













    if dt == nil then dt = 16.67 end
    __frame_time = dt

    __sunDir  = ac.getSunDirection()
    __moonDir = ac.getMoonDirection()



    -- rotate CAM
    local thA = ac.getRealTrackHeadingAngle()
    if thA ~= 0 then

      local angles = vec32sphere(ac.getCameraDirection())
      angles[1] = angles[1] + thA
      __camDir = sphere2vec3(angles[1], angles[2])

      __camPos  = ac.getCameraPosition()
      angles = vec32sphere(__camPos/math.max(1, #__camPos))
      angles[1] = angles[1] + thA
      __camPos = sphere2vec3(angles[1], angles[2]) * #__camPos
    else
    
      __camDir  = ac.getCameraDirection()
      __camPos  = ac.getCameraPosition()
    end 

    -- fake some higher view point for high tracks
    --__camPos.y = __camPos.y + __CM__altitude*0.2

    if _l_CamPosInit == false then 
      __CamOffsetPos = __camPos
      _l_CamPosInit = true
    end

    if math.horizontalDistance(lastCamPos, __camPos) > 5 then

      forceUpdate = true
      gameDT = dt
    end

    
    local angles = vec32sphere(__sunDir)
    __sun_heading = angles[1]
    __sun_angle   = angles[2]

    angles = vec32sphere(__moonDir)
    __moon_heading = angles[1]
    __moon_angle   = angles[2]

    angles = vec32sphere(__camDir)
    __cam_heading = angles[1]
    __cam_angle   = angles[2]

    __camFOV = ac.getCameraFOV()
    

    if SOL__config("debug", "camera") == true then
      ac.debug("Camera: direction", string.format('x: %.2f, y: %.2f, z: %.2f', __camDir.x,__camDir.y,__camDir.z))
      ac.debug("Camera: position", string.format('x: %.2f, y: %.2f, z: %.2f', __camPos.x,__camPos.y,__camPos.z))

      local _l_dist = math.horizontalDistance(lastCamPos, __camPos)
      _l_speed = _l_speed*0.9 + ((_l_dist/dt)*3.6)*0.1

      ac.debug("Camera: speed", string.format('%.2f km/h', _l_speed))
    end

    lastCamPos:set(__camPos)

    dt_sol_a = os.clock()


    __AC_TIME = ac.getDaySeconds()


    ruBase:update(gameDT, forceUpdate)
    gfx__update_sunlight()
    -- update sun color with every frame, to prevent flashing
    -- update__solar_system will change the values
    update__solar_system(dt)


    if update_sol_custom_config__every_frame ~= nil then
      update_sol_custom_config__every_frame(dt)
      if __CONFIG__ALLOW__DIRECT__ACCESS then sol_check_config() end -- #$# remove with new config
    end
    update__weather__every_frame()
    if update_sol_custom_config ~= nil then  
      if update_sol_custom_config__post then update_sol_custom_config__post(dt) end
    end

    if _l_config__clouds__render_method > 0 then
      -- increasing refresh rate for faster moving clouds
      if math.abs(cloudsDT) > 0.05 then 
        ruClouds.skip = 1
      elseif math.abs(cloudsDT) < 0.03 then 
        ruClouds.skip = 2
      end
    end
    

    if _l_config__clouds__render_method == 0 then
      update__clouds(dt) --ruClouds:update(cloudsDT, forceUpdate)
    elseif _l_config__clouds__render_method == 1 then
      ruCloudMaterials:update(gameDT, forceUpdate)
      ruClouds:update(cloudsDT, forceUpdate)
    else
      update_skysim(cloudsDT, forceUpdate)
    end


    update__filter(dt)

    update_audio(dt)

    waiting__for_filter = false

    if __ambient_color ~= nil and __ambient_color_raw ~= nil then

      if sol__debug__weather == true then
        ac.debug("Weather: Ambient brightness", string.format('%.2f', __ambient_color_raw.v))
      end

      if __ambient_color_raw.v < (_l_HL_amb * ta_exp_fix) or
        __sun_angle < _l_HL_sun or
        __fog_dense > _l_HL_fog or
        __badness >= _l_HL_bad then

        --  ac.debug("###", _l_HL_amb)

        if os.clock() - __session_running_since > 1 then 
          waiting__headlights_off = dt_sol_a
        end

        ac.setAiHeadlights(true)
        if SOL__config("debug", "AI") == true then ac.debug("AI: Headlights", "on") end
        
      elseif (__ambient_color_raw.v > (_l_HL_amb * ta_exp_fix) + 0.5 and (dt_sol_a - waiting__headlights_off) > 10 ) and
              __sun_angle > _l_HL_sun + 0.1 and
              __fog_dense < _l_HL_fog then

        ac.setAiHeadlights(false)
        if SOL__config("debug", "AI") == true then ac.debug("AI: Headlights", "off") end
      end
    end

    -- update the communication to CSP/Python
    __configAppInterface:update()
    __customWeatherAPPInterface:update()

    dt_sol_b = os.clock()
    sol_dt()

    if SOL__config("debug", "runtime") == true then
      runGC()
      printGC()
    end

    if __weather__force__reset then
      if os.clock() - _l_reset_blocker > 5 then
        ___reset__Sol___()
        __weather__force__reset = false
      end
    end
  end


else --__CSP__wrong_version__ == true

  if ac.setSkyUseV2 then
    ac.setSkyUseV2(false)
  end

  function update(dt)
    ac.setLightColor(rgb(0,0,10))	
    ac.setLightDirection(vec3(0,1,0))
    ac.setSkyColor(rgb(1,0,0))
    ac.setSkyBrightnessMult(1)
    ac.setAmbientColor( rgbm(1,0,0,1) )
    ac.setFogBlend(1)
    ac.setFogDensity(2) 
    ac.setFogExponent(1) 
    ac.setFogDistance(5000)
    ac.setFogColor( rgb(0,1,0) ) 
  end

end -- end of __CSP__wrong_version__ == false