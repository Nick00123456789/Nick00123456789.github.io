local presets = {}
presets['Performance'] = {}
presets['Performance'][1] = { parameter = 'performance.use_cpu_split' , values = {true,false,false,false}}
presets['Performance'][2] = { parameter = 'clouds.distance_multiplier', values = { 1.0,1.45, 1.60, 1.75 }}
presets['Performance'][3] = { parameter = 'clouds.quality'            , values = { 0.4, 0.6, 0.80, 1.00 }}
presets['Performance'][4] = { parameter = 'clouds.render_per_frame'   , values = {  15,   20,  25,   35 }}

presets['Night'] = {}
presets['Night'][1] = { parameter = 'night.brightness_adjust'   , values = {0.0, 0.35, 0.7, 1.0}}
presets['Night'][2] = { parameter = 'night.moonlight_multiplier', values = {1.0,  1.0, 2.0, 4.0}}
presets['Night'][3] = { parameter = 'night.starlight_multiplier', values = {0.5,  1.0, 2.0, 4.0}}


function sol_config__set_preset(section, id) 
    
    if presets[section] then
        for i=1,#presets[section] do
            if presets[section][i]['parameter'] and presets[section][i]['values'][id] ~= nil then
                t = split_string(presets[section][i]['parameter'], ".")
                if #t == 2 then
                    SOL__set_config(t[1], t[2], presets[section][i]['values'][id], true, false, true)
                end
            end
        end
    end
end