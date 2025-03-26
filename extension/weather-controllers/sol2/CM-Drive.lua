local weather_options = {
    -- name                   
    {"No Clouds"           , 100},

    {"Clear"               , 15 },
    {"Few Clouds"          , 16 },
    {"Scattered Clouds"    , 17 },
    {"Windy"               , 31 },
    {"Broken Clouds"       , 18 },
    {"Overcast Clouds"     , 19 },

    {"Haze"                , 23 },
    {"Mist"                , 21 },
    {"Fog"                 , 20 },
    {"Dust"                , 25 },
    {"Sand"                , 24 },
    {"Smoke"               , 22 },

    {"Light Drizzle"       , 3 },
    {"Drizzle"             , 4 },
    {"Heavy Drizzle"       , 5 },
    {"Light Rain"          , 6 },
    {"Rain"                , 7 },
    {"Heavy Rain"          , 8 },

    {"Light Thunderstorm"  , 0 },
    {"Thunderstorm"        , 1 },
    {"Heavy Thunderstorm"  , 2 },
    {"Squalls"             , 26 },
    {"Tornado"             , 27 },
    {"Hurricane"           , 28 },
    
    {"Light Snow"          , 9 },
    {"Snow"                , 10 },
    {"Heavy Snow"          , 11 },
    {"Light Sleet"         , 12 },
    {"Sleet"               , 13 },
    {"Heavy Sleet"         , 14 },
    
    {"Random Dry"          , 40 },
    {"Random Rainy"        , 41 },
    {"Random Bad"          , 42 },
    {"Random"              , 43 },

    {"predefined"          , 44 },

    --"Cold"                ,
    --"Hot"                 ,
    --"Hail"                ,
}

function SOL2_CM_DRIVE__getWeatherString(id)
    return weather_options[id][1]
end
function SOL2_CM_DRIVE__getWeatherRealId(id)
    return weather_options[id][2]
end

local wetness_options = {
    "auto",
    "none",
    "low",
    "wet",
    "slippery",
    "under water"
}

local puddles_options = {
    "auto",
    "none",
    "some",
    "more",
    "full",
}


local function write_dropdown(variable, name, default, list)
    local tmp = variable.." = "..default.." ; "..name.." ; "
    for i=1, #list do
        tmp_name = ""
        if type(list[i]) == "table" then
            tmp_name = list[i][1]
        else
            tmp_name = list[i]
        end
        tmp = tmp.."\""..tmp_name.."\" is "..i..", "
    end
    io.write(tmp.."\n")
end

function SOL2_CM_DRIVE__readSettings()

    local cfg = ac.INIConfig.scriptSettings():mapSection('SETTINGS', {
        START_WEATHER = 1,
        START_WETNESS = 1,
        START_PUDDLES = 1,
    })
    return cfg
end

function SOL2_CM_DRIVE__buildMenu()

    local cfg = SOL2_CM_DRIVE__readSettings()

    local file = ac.getFolder(ac.FolderID.Root)..'\\extension\\weather-controllers\\sol2\\settings.ini'
    local f=io.open(file,"w+")
    if f~=nil then

        io.output(f)
        io.write("[SETTINGS]\n")

        write_dropdown("START_WEATHER", "Start Weather", cfg.START_WEATHER, weather_options)
        write_dropdown("START_WETNESS", "Start Wetness", cfg.START_WETNESS, wetness_options)
        write_dropdown("START_PUDDLES", "Start Puddles", cfg.START_PUDDLES, puddles_options)

        io.close(f)
    end
end
