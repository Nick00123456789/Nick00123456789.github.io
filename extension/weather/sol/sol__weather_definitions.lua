local id --do not touch this
__weather_defs = {} --do not touch this



id = 1 -- LightThunderstorm
__weather_defs[id] = {}
__weather_defs[id]["name"] = "Light Thunderstorm"
__weather_defs[id]["clouds"]  = { 0.8, 0 } --only for 2d clouds
__weather_defs[id]["sky"]    = {} i=1
__weather_defs[id]["sky"][i] = { layer="CumulusMediocris", dense=0.9, waterfilled=0.70 } i=i+1
__weather_defs[id]["sky"][i] = { layer="DistantCloudy", dense=0.7, waterfilled=0.4 } i=i+1
__weather_defs[id]["sky"][i] = { layer="Lightning", dense=0.3 } i=i+1
__weather_defs[id]["inair_material"]  = { color=hsv(225, 0.3, 0.80), dense=0.0, granulation = 0.0 }
__weather_defs[id]["fog_dense"] = 0.00
__weather_defs[id]["humidity"]  = 0.95
__weather_defs[id]["overcast"]  = 0.40
__weather_defs[id]["water_on_road"] = 0.10
__weather_defs[id]["rain"] = 0.50
__weather_defs[id]["badness"] = 0.60

id = 2 -- Thunderstorm
__weather_defs[id] = {}
__weather_defs[id]["name"] = "Thunderstorm"
__weather_defs[id]["clouds"]  = { 0.92, 0 } --only for 2d clouds
__weather_defs[id]["sky"]    = {} i=1
__weather_defs[id]["sky"][i] = { layer="CumulusMediocris", dense=0.9, waterfilled=0.75 } i=i+1
__weather_defs[id]["sky"][i] = { layer="Lightning", dense=0.6 } i=i+1
__weather_defs[id]["inair_material"]  = { color=hsv(30, 0.4, 1.50), dense=0.0, granulation = 0.0 }
__weather_defs[id]["fog_dense"] = 0.00
__weather_defs[id]["humidity"]  = 0.90
__weather_defs[id]["overcast"]  = 0.60
__weather_defs[id]["water_on_road"] = 0.30
__weather_defs[id]["rain"] = 0.65
__weather_defs[id]["badness"] = 0.8

id = 3 -- HeavyThunderstorm
__weather_defs[id] = {}
__weather_defs[id]["name"] = "Heavy Thunderstorm"
__weather_defs[id]["clouds"]  = { 0.95, 0 } --only for 2d clouds
__weather_defs[id]["sky"]    = {} i=1
__weather_defs[id]["sky"][i] = { layer="CumulusMediocris", dense=1.0, waterfilled=0.90 } i=i+1
__weather_defs[id]["sky"][i] = { layer="Lightning", dense=0.9 } i=i+1
__weather_defs[id]["inair_material"]  = { color=hsv(30, 0.3, 0.50), dense=0.4, granulation = 0.00 }
__weather_defs[id]["fog_dense"] = 0.0
__weather_defs[id]["humidity"]  = 0.90
__weather_defs[id]["overcast"]  = 0.8
__weather_defs[id]["water_on_road"] = 0.50
__weather_defs[id]["rain"] = 0.80
__weather_defs[id]["badness"] = 0.90


id = 4 -- LightDrizzle
__weather_defs[id] = {}
__weather_defs[id]["name"] = "Light Drizzle"
__weather_defs[id]["clouds"]  = { 0.7, 0 } --only for 2d clouds
__weather_defs[id]["sky"]    = {} i=1
__weather_defs[id]["sky"][i] = { layer="CumulusMediocris", dense=0.80, waterfilled=0.25 } i=i+1
__weather_defs[id]["sky"][i] = { layer="Stratus", dense=0.60, waterfilled=0.05 } i=i+1
__weather_defs[id]["sky"][i] = { layer="DistantCloudy", dense=0.62, waterfilled=0.25 } i=i+1
__weather_defs[id]["inair_material"]  = { color=hsv(210, 0.4, 3.00), dense=0.10, granulation = 0.0 }
__weather_defs[id]["fog_dense"] = 0.00
__weather_defs[id]["humidity"]  = 0.80
__weather_defs[id]["overcast"]  = 0.15
__weather_defs[id]["water_on_road"] = 0.30
__weather_defs[id]["rain"] = 0.20
__weather_defs[id]["badness"] = 0.10

id = 5 -- Drizzle
__weather_defs[id] = {}
__weather_defs[id]["name"] = "Drizzle"
__weather_defs[id]["clouds"]  = { 0.8, 0 } --only for 2d clouds
__weather_defs[id]["sky"]    = {} i=1
__weather_defs[id]["sky"][i] = { layer="CumulusMediocris", dense=0.80, waterfilled=0.30 } i=i+1
--__weather_defs[id]["sky"][i] = { layer="DistantHaze", dense=0.7, waterfilled=0.55 } i=i+1
__weather_defs[id]["inair_material"]  = { color=hsv(210, 0.2, 1.00), dense=0.3, granulation = 0.0 }
__weather_defs[id]["fog_dense"] = 0.0
__weather_defs[id]["humidity"]  = 0.85
__weather_defs[id]["overcast"]  = 0.8
__weather_defs[id]["water_on_road"] = 0.50
__weather_defs[id]["rain"] = 0.30
__weather_defs[id]["badness"] = 0.30

id = 6 -- HeavyDrizzle
__weather_defs[id] = {}
__weather_defs[id]["name"] = "Heavy Drizzle"
__weather_defs[id]["clouds"]  = { 0.8, 0 } --only for 2d clouds
__weather_defs[id]["sky"]    = {} i=1
__weather_defs[id]["sky"][i] = { layer="CumulusMediocris", dense=0.90, waterfilled=0.70 } i=i+1
--__weather_defs[id]["sky"][i] = { layer="DistantHaze", dense=0.8, waterfilled=0.57 } i=i+1
__weather_defs[id]["inair_material"]  = { color=hsv(213, 0.2, 0.90), dense=0.6, granulation = 0.0 }
__weather_defs[id]["fog_dense"] = 0.0
__weather_defs[id]["humidity"]  = 0.89
__weather_defs[id]["overcast"]  = 0.95
__weather_defs[id]["water_on_road"] = 0.80
__weather_defs[id]["rain"] = 0.40
__weather_defs[id]["badness"] = 0.70


id = 7 -- LightRain
__weather_defs[id] = {}
__weather_defs[id]["name"] = "Light Rain"
__weather_defs[id]["clouds"]  = { 0.55, 0 } --only for 2d clouds
__weather_defs[id]["sky"]    = {} i=1
__weather_defs[id]["sky"][i] = { layer="Stratus", dense=0.7, waterfilled=0.6 } i=i+1
__weather_defs[id]["sky"][i] = { layer="DistantCloudy", dense=0.7, waterfilled=0.7 } i=i+1
__weather_defs[id]["inair_material"]  = { color=hsv(212, 0.5, 1.00), dense=0.10, granulation = 0.2 }
__weather_defs[id]["fog_dense"] = 0.00
__weather_defs[id]["humidity"]  = 0.70
__weather_defs[id]["overcast"]  = 0.20
__weather_defs[id]["water_on_road"] = 0.50
__weather_defs[id]["rain"] = 0.50
__weather_defs[id]["badness"] = 0.20


id = 8 -- Rain
__weather_defs[id] = {}
__weather_defs[id]["name"] = "Rain"
__weather_defs[id]["clouds"]  = { 0.7, 0 } --only for 2d clouds
__weather_defs[id]["sky"]    = {} i=1
__weather_defs[id]["sky"][i] = { layer="Stratus", dense=0.8, waterfilled=0.5 } i=i+1
__weather_defs[id]["sky"][i] = { layer="DistantCloudy", dense=0.5, waterfilled=0.8 } i=i+1
__weather_defs[id]["inair_material"]  = { color=hsv(212, 0.4, 1.25), dense=0.2, granulation = 0.0 }
__weather_defs[id]["fog_dense"] = 0.00
__weather_defs[id]["humidity"]  = 0.75
__weather_defs[id]["overcast"]  = 0.80
__weather_defs[id]["water_on_road"] = 0.80
__weather_defs[id]["rain"] = 0.70
__weather_defs[id]["badness"] = 0.30


id = 9 -- HeavyRain
__weather_defs[id] = {}
__weather_defs[id]["name"] = "Heavy Rain"
__weather_defs[id]["clouds"]  = { 0.7, 0 } --only for 2d clouds
__weather_defs[id]["sky"]    = {} i=1
__weather_defs[id]["sky"][i] = { layer="Stratus", dense=0.9, waterfilled=0.8 } i=i+1
__weather_defs[id]["inair_material"]  = { color=hsv(215, 0.45, 1.00), dense=0.40, granulation = 0.0 }
__weather_defs[id]["fog_dense"] = 0.00
__weather_defs[id]["humidity"]  = 0.80
__weather_defs[id]["overcast"]  = 1.00
__weather_defs[id]["water_on_road"] = 1.00
__weather_defs[id]["rain"] = 1.00
__weather_defs[id]["badness"] = 0.7


id = 10 -- LightSnow
__weather_defs[id] = {}
__weather_defs[id]["name"] = "Light Snow"
__weather_defs[id]["clouds"]  = { 0.4, 0 } --only for 2d clouds
__weather_defs[id]["sky"]    = {} i=1
__weather_defs[id]["sky"][i] = { layer="Stratus", dense=0.4, waterfilled=0.25 } i=i+1
__weather_defs[id]["inair_material"]  = { color=hsv(210, 0.0, 5.00), dense=0.2, granulation = 0.2 }
__weather_defs[id]["fog_dense"] = 0.40
__weather_defs[id]["humidity"]  = 0.80
__weather_defs[id]["overcast"]  = 0.4
__weather_defs[id]["water_on_road"] = 0.70
__weather_defs[id]["rain"] = 0.10
__weather_defs[id]["badness"] = 0.30


id = 11 -- Snow
__weather_defs[id] = {}
__weather_defs[id]["name"] = "Snow"
__weather_defs[id]["clouds"]  = { 0.5, 0 } --only for 2d clouds
__weather_defs[id]["sky"]    = {} i=1
__weather_defs[id]["sky"][i] = { layer="Stratus", dense=0.5, waterfilled=0.4 } i=i+1
__weather_defs[id]["inair_material"]  = { color=hsv(210, 0.0, 4.00), dense=0.2, granulation = 0.0 }
__weather_defs[id]["fog_dense"] = 0.50
__weather_defs[id]["humidity"]  = 0.85
__weather_defs[id]["overcast"]  = 0.70
__weather_defs[id]["water_on_road"] = 0.30
__weather_defs[id]["rain"] = 0.20
__weather_defs[id]["badness"] = 0.40


id = 12 -- HeavySnow
__weather_defs[id] = {}
__weather_defs[id]["name"] = "Heavy Snow"
__weather_defs[id]["clouds"]  = { 0.5, 0 } --only for 2d clouds
__weather_defs[id]["sky"]    = {} i=1
__weather_defs[id]["sky"][i] = { layer="Stratus", dense=0.4, waterfilled=0.8 } i=i+1
__weather_defs[id]["inair_material"]  = { color=hsv(210, 0.20, 6.00), dense=0.2, granulation = 0.0 }
__weather_defs[id]["fog_dense"] = 0.80
__weather_defs[id]["humidity"]  = 0.90
__weather_defs[id]["overcast"]  = 0.80
__weather_defs[id]["water_on_road"] = 0.05
__weather_defs[id]["rain"] = 0.30
__weather_defs[id]["badness"] = 0.95



id = 13 -- LightSleet
__weather_defs[id] = {}
__weather_defs[id]["name"] = "Light Sleet"
__weather_defs[id]["clouds"]  = { 0.5, 0 } --only for 2d clouds
__weather_defs[id]["sky"]    = {} i=1
__weather_defs[id]["sky"][i] = { layer="Stratus", dense=0.3, waterfilled=0.5 } i=i+1
__weather_defs[id]["inair_material"]  = { color=hsv(210, 0.03, 4.00), dense=0.20, granulation = 0.2 }
__weather_defs[id]["fog_dense"] = 0.30
__weather_defs[id]["humidity"]  = 0.90
__weather_defs[id]["overcast"]  = 0.10
__weather_defs[id]["water_on_road"] = 0.80
__weather_defs[id]["rain"] = 0.20
__weather_defs[id]["badness"] = 0.50


id = 14 -- Sleet
__weather_defs[id] = {}
__weather_defs[id]["name"] = "Sleet"
__weather_defs[id]["clouds"]  = { 0.5, 0 } --only for 2d clouds
__weather_defs[id]["sky"]    = {} i=1
__weather_defs[id]["sky"][i] = { layer="Stratus", dense=0.4, waterfilled=0.9 } i=i+1
__weather_defs[id]["inair_material"]  = { color=hsv(210, 0.08, 5.00), dense=0.20, granulation = 0.0 }
__weather_defs[id]["fog_dense"] = 0.40
__weather_defs[id]["humidity"]  = 0.95
__weather_defs[id]["overcast"]  = 0.50
__weather_defs[id]["water_on_road"] = 0.90
__weather_defs[id]["rain"] = 0.25
__weather_defs[id]["badness"] = 0.60


id = 15 -- HeavySleet
__weather_defs[id] = {}
__weather_defs[id]["name"] = "Heavy Sleet"
__weather_defs[id]["clouds"]  = { 0.5, 0 } --only for 2d clouds
__weather_defs[id]["sky"]    = {} i=1
__weather_defs[id]["sky"][i] = { layer="Stratus", dense=0.5, waterfilled=0.7 } i=i+1
__weather_defs[id]["inair_material"]  = { color=hsv(210, 0.03, 4.00), dense=0.20, granulation = 0.0 }
__weather_defs[id]["fog_dense"] = 0.70
__weather_defs[id]["humidity"]  = 0.98
__weather_defs[id]["overcast"]  = 0.90
__weather_defs[id]["water_on_road"] = 1.00
__weather_defs[id]["rain"] = 0.40
__weather_defs[id]["badness"] = 0.80


id = 16 -- Clear
__weather_defs[id] = {}
__weather_defs[id]["name"] = "Clear"
__weather_defs[id]["clouds"]  = { 0.1, 0 } --only for 2d clouds
__weather_defs[id]["sky"]    = {} i=1
--__weather_defs[id]["sky"][i] = { layer="Cumulus", dense=0.1, waterfilled=0.0 } i=i+1
--__weather_defs[id]["sky"][i] = { layer="Cirrostratus", dense=0.2, waterfilled=0.4 } i=i+1
__weather_defs[id]["sky"][i] = { layer="DistantCloudy", dense=0.35, waterfilled=0.1 } i=i+1
__weather_defs[id]["inair_material"]  = { color=hsv(210, 1.0, 1.00), dense=0.02, granulation = 0.8 }
__weather_defs[id]["fog_dense"] = 0.02
__weather_defs[id]["humidity"]  = 0.00
__weather_defs[id]["overcast"]  = 0.01 + rnd(0.01)
__weather_defs[id]["water_on_road"] = 0.00
__weather_defs[id]["rain"] = 0.0
__weather_defs[id]["badness"] = 0.00


id = 17 -- FewClouds
__weather_defs[id] = {}
__weather_defs[id]["name"] = "Few Clouds"
__weather_defs[id]["clouds"]  = { 0.25, 0.08 } --only for 2d clouds
__weather_defs[id]["sky"]    = {} i=1
__weather_defs[id]["sky"][i] = { layer="CumulusMediocris", dense=0.45, waterfilled=0.2 } i=i+1
__weather_defs[id]["sky"][i] = { layer="Cirrostratus", dense=0.25, waterfilled=0.2 } i=i+1
__weather_defs[id]["sky"][i] = { layer="DistantCloudy", dense=0.4, waterfilled=0.4 } i=i+1
__weather_defs[id]["inair_material"]  = { color=hsv(210, 0.2, 1.00), dense=0.00, granulation = 0.77 }
__weather_defs[id]["fog_dense"] = 0.0
__weather_defs[id]["humidity"]  = 0.00
__weather_defs[id]["overcast"]  = 0
__weather_defs[id]["water_on_road"] = 0.00
__weather_defs[id]["rain"] = 0.0
__weather_defs[id]["badness"] = 0.00


id = 18 -- ScatteredClouds
__weather_defs[id] = {}
__weather_defs[id]["name"] = "Scattered Clouds"
__weather_defs[id]["clouds"]  = { 0.38, 0.02 } --only for 2d clouds
__weather_defs[id]["sky"]    = {} i=1
__weather_defs[id]["sky"][i] = { layer="CumulusMediocris", dense=0.65, waterfilled=0.35 } i=i+1
__weather_defs[id]["sky"][i] = { layer="Stratus", dense=0.55, waterfilled=0.25 } i=i+1
__weather_defs[id]["sky"][i] = { layer="Cirrostratus", dense=0.65, waterfilled=0.0 } i=i+1
__weather_defs[id]["sky"][i] = { layer="DistantCloudy", dense=0.3, waterfilled=0.4 } i=i+1
__weather_defs[id]["inair_material"]  = { color=hsv(210, 0.8, 1.00), dense=0.02, granulation = 0.7 }
__weather_defs[id]["fog_dense"] = 0.00
__weather_defs[id]["humidity"]  = 0.60
__weather_defs[id]["overcast"]  = 0.10
__weather_defs[id]["water_on_road"] = 0.00
__weather_defs[id]["rain"] = 0.0
__weather_defs[id]["badness"] = 0.00


id = 19 -- BrokenClouds
__weather_defs[id] = {}
__weather_defs[id]["name"] = "Broken Clouds"
__weather_defs[id]["clouds"]  = { 0.75, 0 } --only for 2d clouds
__weather_defs[id]["sky"]    = {} i=1
__weather_defs[id]["sky"][i] = { layer="CumulusMediocris", dense=0.80, waterfilled=0.4 } i=i+1
__weather_defs[id]["sky"][i] = { layer="Stratus", dense=0.70, waterfilled=0.1 } i=i+1
__weather_defs[id]["sky"][i] = { layer="DistantCloudy", dense=0.62, waterfilled=0.40 } i=i+1
__weather_defs[id]["inair_material"]  = { color=hsv(220, 0.50, 1.0), dense=0.02, granulation = 0.0 }
__weather_defs[id]["fog_dense"] = 0.02
__weather_defs[id]["humidity"]  = 0.60
__weather_defs[id]["overcast"]  = 0.10
__weather_defs[id]["water_on_road"] = 0.00
__weather_defs[id]["rain"] = 0.0
__weather_defs[id]["badness"] = 0.00


id = 20 -- OvercastClouds
__weather_defs[id] = {}
__weather_defs[id]["name"] = "Overcast Clouds"
__weather_defs[id]["clouds"]  = { 0.75, 0 } --only for 2d clouds
__weather_defs[id]["sky"]    = {} i=1
__weather_defs[id]["sky"][i] = { layer="CumulusMediocris", dense=1.00, waterfilled=0.0 } i=i+1
__weather_defs[id]["sky"][i] = { layer="DistantCloudy", dense=0.5, waterfilled=0.35 } i=i+1
__weather_defs[id]["inair_material"]  = { color=hsv(220, 0.0, 1.0), dense=0.00, granulation = 0.0 }
__weather_defs[id]["fog_dense"] = 0.00
__weather_defs[id]["humidity"]  = 0.50
__weather_defs[id]["overcast"]  = 0.75
__weather_defs[id]["water_on_road"] = 0.00
__weather_defs[id]["rain"] = 0.0
__weather_defs[id]["badness"] = 0.00


id = 21 -- Fog
__weather_defs[id] = {}
__weather_defs[id]["name"] = "Fog"
__weather_defs[id]["clouds"]  = { 0.0, 0 } --only for 2d clouds
__weather_defs[id]["sky"]    = {} i=1
__weather_defs[id]["inair_material"]  = { color=hsv(210, 0.8, 2.0), dense=0.25, granulation = 0.0 }
__weather_defs[id]["fog_dense"] = 0.85
__weather_defs[id]["humidity"]  = 0.99
__weather_defs[id]["overcast"]  = 0.65
__weather_defs[id]["water_on_road"] = 0.00
__weather_defs[id]["rain"] = 0.0
__weather_defs[id]["badness"] = 0.3


id = 22 -- Mist
__weather_defs[id] = {}
__weather_defs[id]["name"] = "Mist"
__weather_defs[id]["clouds"]  = { 0.15, 0 } --only for 2d clouds
__weather_defs[id]["sky"]    = {} i=1
--__weather_defs[id]["sky"][i] = { layer="Stratus", dense=0.5, waterfilled=0.15 } i=i+1
--__weather_defs[id]["sky"][i] = { layer="Cirrostratus", dense=0.4, waterfilled=0.3 } i=i+1
__weather_defs[id]["inair_material"]  = { color=hsv(30, 0.50, 4.0), dense=0.1, granulation = 0.05 }
__weather_defs[id]["fog_dense"] = 0.70
__weather_defs[id]["humidity"]  = 0.92
__weather_defs[id]["overcast"]  = 0.0
__weather_defs[id]["water_on_road"] = 0.00
__weather_defs[id]["rain"] = 0.0
__weather_defs[id]["badness"] = 0.0


id = 23 -- Smoke
__weather_defs[id] = {}
__weather_defs[id]["name"] = "Smoke"
__weather_defs[id]["clouds"]  = { 0.8, 0 } --only for 2d clouds
__weather_defs[id]["sky"]    = {} i=1
__weather_defs[id]["inair_material"]  = { color=hsv(213, 0.0, 1.50), dense=0.65, granulation = 0.0 }
__weather_defs[id]["fog_dense"] = 0.00
__weather_defs[id]["humidity"]  = 0.00
__weather_defs[id]["overcast"]  = 0.95
__weather_defs[id]["water_on_road"] = 0.00
__weather_defs[id]["rain"] = 0.00
__weather_defs[id]["badness"] = 0.60


id = 24 -- Haze
__weather_defs[id] = {}
__weather_defs[id]["name"] = "Haze"
__weather_defs[id]["clouds"]  = { 0.3, 0.1 } --only for 2d clouds
__weather_defs[id]["sky"]    = {} i=1
__weather_defs[id]["sky"][i] = { layer="CumulusMediocris", dense=0.30, waterfilled=0.5 } i=i+1
--__weather_defs[id]["sky"][i] = { layer="Stratus", dense=0.4, waterfilled=0.2 } i=i+1
__weather_defs[id]["sky"][i] = { layer="Cirrostratus", dense=0.7, waterfilled=0.85 } i=i+1
__weather_defs[id]["sky"][i] = { layer="DistantCloudy", dense=0.7, waterfilled=0.4 } i=i+1
__weather_defs[id]["inair_material"]  = { color=hsv(220, 0.99, 1.00), dense=0.175, granulation = 0.10 }
__weather_defs[id]["fog_dense"] = 0.25
__weather_defs[id]["humidity"]  = 0.89
__weather_defs[id]["overcast"]  = 0.0
__weather_defs[id]["water_on_road"] = 0.00
__weather_defs[id]["rain"] = 0.0
__weather_defs[id]["badness"] = 0.00


id = 25 -- Sand
__weather_defs[id] = {}
__weather_defs[id]["name"] = "Sand"
__weather_defs[id]["clouds"]  = { 0.1, 0 } --only for 2d clouds
__weather_defs[id]["sky"]    = {} 
__weather_defs[id]["inair_material"]  = { color=hsv(29, 0.70, 3.00), dense=0.56, granulation = 0.0 }
__weather_defs[id]["fog_dense"] = 0.00
__weather_defs[id]["humidity"]  = 0.0
__weather_defs[id]["overcast"]  = 0.0
__weather_defs[id]["water_on_road"] = 0.00
__weather_defs[id]["rain"] = 0.0
__weather_defs[id]["badness"] = 0.25


id = 26 -- Dust
__weather_defs[id] = {}
__weather_defs[id]["name"] = "Dust"
__weather_defs[id]["clouds"]  = { 0.1, 0 } --only for 2d clouds
__weather_defs[id]["sky"]    = {} i=1
--__weather_defs[id]["sky"][i] = { layer="CumulusHumilis", dense=0.75, waterfilled=0.35 } i=i+1
--__weather_defs[id]["sky"][i] = { layer="Stratus", dense=0.5, waterfilled=0.25 } i=i+1
--__weather_defs[id]["sky"][i] = { layer="DistantHaze", dense=0.5, waterfilled=0.15 } i=i+1
__weather_defs[id]["inair_material"]  = { color=hsv(25, 0.25, 4.00), dense=0.3, granulation = 0.0 }
__weather_defs[id]["fog_dense"] = 0.02
__weather_defs[id]["humidity"]  = 0.70
__weather_defs[id]["overcast"]  = 0.0
__weather_defs[id]["water_on_road"] = 0.00
__weather_defs[id]["rain"] = 0.0
__weather_defs[id]["badness"] = 0.00


id = 27 -- Squalls
__weather_defs[id] = {}
__weather_defs[id]["name"] = "Squalls"
__weather_defs[id]["clouds"]  = { 0.7, 0 } --only for 2d clouds
__weather_defs[id]["sky"]    = {} i=1
__weather_defs[id]["sky"][i] = { layer="CumulusMediocris", dense=0.9, waterfilled=0.50 } i=i+1
__weather_defs[id]["sky"][i] = { layer="Stratus", dense=0.7, waterfilled=0.3 } i=i+1
__weather_defs[id]["sky"][i] = { layer="Cirrostratus", dense=0.7, waterfilled=0.0 } i=i+1
__weather_defs[id]["sky"][i] = { layer="DistantCloudy", dense=0.8, waterfilled=0.5 } i=i+1
__weather_defs[id]["inair_material"]  = { color=hsv(210, 0.60, 3.00), dense=0.10, granulation = 0.0 }
__weather_defs[id]["fog_dense"] = 0.00
__weather_defs[id]["humidity"]  = 0.60
__weather_defs[id]["overcast"]  = 0.20
__weather_defs[id]["water_on_road"] = 0.20
__weather_defs[id]["rain"] = 0.0
__weather_defs[id]["badness"] = 0.10


id = 28 -- Tornado
__weather_defs[id] = {}
__weather_defs[id]["name"] = "Tornado"
__weather_defs[id]["clouds"]  = { 0.95, 0 } --only for 2d clouds
__weather_defs[id]["sky"]    = {} i=1
__weather_defs[id]["sky"][i] = { layer="CumulusMediocris", dense=0.9, waterfilled=0.95 } i=i+1
__weather_defs[id]["sky"][i] = { layer="Lightning", dense=0.2 } i=i+1
__weather_defs[id]["inair_material"]  = { color=hsv(220, 0.50, 1.00), dense=0.20, granulation = 0.0 }
__weather_defs[id]["fog_dense"] = 0.00
__weather_defs[id]["humidity"]  = 0.90
__weather_defs[id]["overcast"]  = 0.80
__weather_defs[id]["water_on_road"] = 0.50
__weather_defs[id]["rain"] = 0.55
__weather_defs[id]["badness"] = 1.00

id = 29 -- Hurricane
__weather_defs[id] = {}
__weather_defs[id]["name"] = "Hurricane"
__weather_defs[id]["clouds"]  = { 0.8, 0 } --only for 2d clouds
__weather_defs[id]["sky"]    = {} i=1
__weather_defs[id]["sky"][i] = { layer="CumulusMediocris", dense=1.0, waterfilled=1.00 } i=i+1
__weather_defs[id]["sky"][i] = { layer="Lightning", dense=0.4 } i=i+1
__weather_defs[id]["inair_material"]  = { color=hsv(210, 0.56, 1.00), dense=0.45, granulation = 0.0 }
__weather_defs[id]["fog_dense"] = 0.00
__weather_defs[id]["humidity"]  = 0.85
__weather_defs[id]["overcast"]  = 0.80
__weather_defs[id]["water_on_road"] = 1.00
__weather_defs[id]["rain"] = 1.0
__weather_defs[id]["badness"] = 1.00


id = 32 -- Windy
__weather_defs[id] = {}
__weather_defs[id]["name"] = "Windy"
__weather_defs[id]["clouds"]  = { 0.7, 0.08 } --only for 2d clouds
__weather_defs[id]["sky"]    = {} i=1
__weather_defs[id]["sky"][i] = { layer="CumulusMediocris", dense=0.7, waterfilled=0.2 } i=i+1
--__weather_defs[id]["sky"][i] = { layer="Stratus", dense=0.45+rnd(0.1), waterfilled=0.45 } i=i+1
__weather_defs[id]["sky"][i] = { layer="Cirrostratus", dense=0.65, waterfilled=0.1 } i=i+1
__weather_defs[id]["sky"][i] = { layer="DistantCloudy", dense=0.5, waterfilled=0.25 } i=i+1
__weather_defs[id]["inair_material"]  = { color=hsv(240, 0.5, 1.0), dense=0.05, granulation = 0.0 }
__weather_defs[id]["fog_dense"] = 0.00
__weather_defs[id]["humidity"]  = 0.50
__weather_defs[id]["overcast"]  = 0.0
__weather_defs[id]["water_on_road"] = 0.00
__weather_defs[id]["rain"] = 0.0
__weather_defs[id]["badness"] = 0.00


id = 33 -- Hail
__weather_defs[id] = {}
__weather_defs[id]["name"] = "Hail" 
__weather_defs[id]["clouds"]  = { 0.8, 0 } --only for 2d clouds
__weather_defs[id]["sky"]    = {} i=1
__weather_defs[id]["sky"][i] = { layer="Stratus", dense=0.6, waterfilled=0.25 } i=i+1
__weather_defs[id]["inair_material"]  = { color=hsv(210, 0.00, 6.00), dense=0.20, granulation = 0.35 }
__weather_defs[id]["fog_dense"] = 0.20
__weather_defs[id]["humidity"]  = 0.80
__weather_defs[id]["overcast"]  = 0.70
__weather_defs[id]["water_on_road"] = 0.30
__weather_defs[id]["rain"] = 0.7
__weather_defs[id]["badness"] = 0.50


id = 101 -- no clouds/performance
__weather_defs[id] = {}
__weather_defs[id]["name"] = "NoClouds"
__weather_defs[id]["clouds"]  = { 0.0, 0 } --only for 2d clouds
__weather_defs[id]["sky"] = {}
__weather_defs[id]["inair_material"]  = { color=hsv(240, 0.5, 1.0), dense=0.01, granulation = 0.0 }
__weather_defs[id]["fog_dense"] = 0.0
__weather_defs[id]["humidity"]  = 0.0
__weather_defs[id]["overcast"]  = 0.0
__weather_defs[id]["water_on_road"] = 0.00
__weather_defs[id]["rain"] = 0.0
__weather_defs[id]["badness"] = 0.00

id = 102 -- no clouds technical reset weather
__weather_defs[id] = {}
__weather_defs[id]["name"] = "NoClouds"
__weather_defs[id]["clouds"]  = { 0.0, 0 } --only for 2d clouds
__weather_defs[id]["sky"] = {} 
__weather_defs[id]["inair_material"]  = { color=hsv(210, 0, 1.00), dense=0.00, granulation = 0.0 }
__weather_defs[id]["fog_dense"] = 0.00
__weather_defs[id]["humidity"]  = 0.00
__weather_defs[id]["overcast"]  = 0.0
__weather_defs[id]["water_on_road"] = 0.00
__weather_defs[id]["rain"] = 0.0
__weather_defs[id]["badness"] = 0.00


id = 999 -- reserved for custom weather
__weather_defs[id] = __CW

function WeatherDefs__updateCustomWeather()

	__weather_defs[999]["inair_material"] = { 

		color = hsv(__CW__.CustomWeather__inair_material.Hue, __CW__.CustomWeather__inair_material.Saturation, __CW__.CustomWeather__inair_material.Level),
		dense = __CW__.CustomWeather__inair_material.Dense,
		granulation = __CW__.CustomWeather__inair_material.Granulation
	}

	__weather_defs[999]["fog_dense"] = __CW__.CustomWeather__Pollutions.Mist
	__weather_defs[999]["humidity"]  = __CW__.CustomWeather__Pollutions.Humidity

	__weather_defs[999]["overcast"]  = __CW__.CustomWeather__Skylook.Overcast
	__weather_defs[999]["water_on_road"] = 0.00
	__weather_defs[999]["badness"] = __CW__.CustomWeather__Skylook.Badness

	__weather_defs[999]["clouds"]  = { __CW__.CustomWeather__2dClouds.dense, 0 } --only for 2d clouds
end
WeatherDefs__updateCustomWeather()

__weather_defs[id]["sky"] = {} i=1

if __CW__.CustomWeather__CumulusHumilis.use then 
	__weather_defs[id]["sky"][i] = { layer="CumulusHumilis", dense=__CW__.CustomWeather__CumulusHumilis.dense, waterfilled=__CW__.CustomWeather__CumulusHumilis.waterfilled } i=i+1
end
if __CW__.CustomWeather__CumulusMediocris.use then 
	__weather_defs[id]["sky"][i] = { layer="CumulusMediocris", dense=__CW__.CustomWeather__CumulusMediocris.dense, waterfilled=__CW__.CustomWeather__CumulusMediocris.waterfilled } i=i+1
end
if __CW__.CustomWeather__Stratus.use then 
	__weather_defs[id]["sky"][i] = { layer="Stratus", dense=__CW__.CustomWeather__Stratus.dense, waterfilled=__CW__.CustomWeather__Stratus.waterfilled } i=i+1
end
if __CW__.CustomWeather__Cirrostratus.use then 
	__weather_defs[id]["sky"][i] = { layer="Cirrostratus", dense=__CW__.CustomWeather__Cirrostratus.dense, waterfilled=__CW__.CustomWeather__Cirrostratus.waterfilled } i=i+1
end
if __CW__.CustomWeather__DistantHaze.use then 
	__weather_defs[id]["sky"][i] = { layer="DistantHaze", dense=__CW__.CustomWeather__DistantHaze.dense, waterfilled=__CW__.CustomWeather__DistantHaze.waterfilled } i=i+1
end
if __CW__.CustomWeather__DistantCloudy.use then 
	__weather_defs[id]["sky"][i] = { layer="DistantCloudy", dense=__CW__.CustomWeather__DistantCloudy.dense, waterfilled=__CW__.CustomWeather__DistantCloudy.waterfilled } i=i+1
end
if __CW__.CustomWeather__Lightning.use then 
	__weather_defs[id]["sky"][i] = { layer="Lightning", dense=__CW__.CustomWeather__Lightning.dense } i=i+1
end