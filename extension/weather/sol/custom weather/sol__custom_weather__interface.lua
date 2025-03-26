use_custom_weather = false -- for backwards compatibility

-- the main intercommunication with the Sol_config App
__customWeatherAPPInterface = Interface:new("customWeatherAPP")
__customWeatherAPPInterface:setOrderExecutorList({
    SET_VALUE = {call="customWeatherAPP__execute_order_SETVALUE",},
    CMD       = {call="customWeatherAPP__execute_order_CMD",},
})

local _l_CC_SharedBackup = "sol.TempCustomWeather"

local _l_reset_parameters = {
    "CustomWeather__CumulusHumilis",
    "CustomWeather__CumulusMediocris",
    "CustomWeather__Stratus",
    "CustomWeather__Cirrostratus",
    "CustomWeather__DistantHaze",
    "CustomWeather__DistantCloudy",
    "CustomWeather__Lightning"
}

function custom_weather__reset_Sol(s)

    local f=io.open(__sol__path.."reset_dummy.lua","w+")
    if f~=nil then
        io.output(f)
        io.write("Custom Weather Parameter Reset -> "..s)
        io.close(f)
    end
end

function custom_weather__initAppValues()

    for k, v in pairs(__CW__) do
        if k then
            for kk, vv in pairs(v) do
                __customWeatherAPPInterface:add_order("INIT_VALUE", {k,kk,vv})
            end
        end
    end
    __customWeatherAPPInterface:clear_order_list_after_send()
end

-- try to read backuped things after a reset
__CW__ = shared_memory_backup__Read(_l_CC_SharedBackup, __CW__)
custom_weather__initAppValues()

function customWeatherAPP__execute_order_SETVALUE(order)
    if order.content then
        if order.content.section and order.content.key and order.content.value~=nil then
            if _G["__CW__"][order.content.section] ~= nil then
                if _G["__CW__"][order.content.section][order.content.key] ~= nil then
                    _G["__CW__"][order.content.section][order.content.key] = order.content.value

                    -- update the weather definition of custom weather
                    WeatherDefs__updateCustomWeather()

                    -- backup values
                    shared_memory_backup__Write(_l_CC_SharedBackup, __CW__)

                    for i=1, #_l_reset_parameters do
                        if order.content.section == _l_reset_parameters[i] then
                            custom_weather__reset_Sol()
                            break
                        elseif order.content.section == "CustomWeather__2dClouds" and SOL__config("clouds", "render_method")==0 then
                            custom_weather__reset_Sol()
                            break
                        end
                    end
                end 
            end
        end
    end
end

function customWeatherAPP__execute_order_CMD(order)
    if order.content['CMD1'] then

        if order.content['CMD1'] == "ResetToDefaults" then

            -- restore the internal defaults
            __CW__ = table__deepcopy(CustomWeather__Defaults)
            shared_memory_backup__Clear(_l_CC_SharedBackup)
            custom_weather__initAppValues()
            __configAppInterface:add_order("CMD", {"system","console","resetted to default values"})

        elseif order.content['CMD1'] == "SaveStandard" then

            --[[
            __configAppInterface:add_order("CMD", {"system","console","Config stored"})
            __configAppInterface:add_order("CMD", {"system","clearDirty","true"})
            ]]
        elseif order.content['CMD1'] == "LoadStandard" then
            --[[
            msg = "Config loaded"
            __configAppInterface:add_order("CMD", {"system","console",msg})
            __configAppInterface:add_order("CMD", {"system","clearDirty","true"})
            ]]
        end
    end
end

