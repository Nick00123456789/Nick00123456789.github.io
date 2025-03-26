-------------------- 
-- TRACK ADAPTION --

-- Technical fog (distance fog) adjustments
ta_fog_level = 1.0 --min=0.0,max=2.0
ta_fog_blend = 1.0 --min=0.0,max=2.0
ta_fog_distance = 1.0 --min=0.5,max=2.0

-- The angle where sun is faded in/out
ta_sun_dawn = 1.0 --min=0.0,max=10.0  
ta_sun_dusk = 1.0 --min=0.0,max=10.0

-- The local humidity correction
ta_humidity_offset = 0.5 --min=0.0,max=1.0

-- Local smog
ta_smog_morning = 0.25 --min=0.0,max=1.0
ta_smog_noon = 0.35 --min=0.0,max=1.0
ta_smog_evening = 0.5 --min=0.0,max=1.0

-- Exposure fix
ta_exp_fix = 1.0 --min=0.25,max=1.75

-- Horizon offset
ta_horizon_offset = 0.0 --min=-5.0,max=5.0
ta_dome_size = 35000 --min=15000,max=50000

-- Smoke track adaptation
g_ta_spray = 0.98 --min=0.0,max=2.0


local _l_TA__INI__PARSE = nil
local ta_list = {
--    global variable       section key                min    max
    { "ta_horizon_offset",  "SOL2", "HORIZON_OFFSET"  ,-10   ,10   },
    { "ta_dome_size",       "SOL2", "DOME_SIZE"       ,15000 ,50000 },
    { "ta_exp_fix",         "SOL",  "EXPOSURE_FIX"    ,0.25  ,1.75  },
    { "ta_humidity_offset", "SOL2", "HUMIDITY_OFFSET" ,0     ,1     },
    { "ta_smog_morning",    "SOL",  "SMOG_MORNING"    ,0     ,1     },
    { "ta_smog_noon",       "SOL",  "SMOG_NOON"       ,0     ,1     },
    { "ta_smog_evening",    "SOL",  "SMOG_EVENING"    ,0     ,1     },
    { "ta_sun_dawn",        "SOL",  "SUN_DAWN"        ,-10   ,10    },
    { "ta_sun_dusk",        "SOL",  "SUN_DUSK"        ,-10   ,10    },
    { "ta_fog_level",       "SOL2", "FOG_LEVEL"       ,0     ,10    },
    { "ta_fog_blend",       "SOL2", "FOG_BLEND"       ,0     ,10    },
    { "ta_fog_distance",    "SOL2", "FOG_DISTANCE"    ,0     ,10    },
}

_l_TA__INI__PARSE = parse_INI(__sol__path.."track adaptions\\track_adaption.ini", "PP")
if _l_TA__INI__PARSE ~= nil then 

    -- check for values in the trackconfig
    for k, v in pairs(ta_list) do

        if _G[v[1]] then

            -- try to read settings from Sol's track adaption ini file
            local ini = get_parsed_value(_l_TA__INI__PARSE, __track_ID, v[1])
            if ini ~= nil then
                _G[v[1]] = ini
            end

            __configAppInterface:add_order("INIT_VALUE", { "TA", v[1], _G[v[1]] })

            -- try to read those parameters from the tack config
            tmp = ac.getTrackConfig().number(v[2], v[3], -99999)
            if tmp ~= -99999 then
                _G[v[1]] = tmp
                __configAppInterface:add_order("SET_VALUE", { "TA", v[1], _G[v[1]], false })
            end

            _G[v[1]] = math.max( v[4],  math.min( v[5], _G[v[1]] ))
        end
    end
end