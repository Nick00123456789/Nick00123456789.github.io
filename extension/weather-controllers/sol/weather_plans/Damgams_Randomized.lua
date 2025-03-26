--[[

			 Changelog:
				1.0
Features:
> Fast transitions between weathers (slow version is available. Also it's very easy to edit)
> 500 weather slots
> Uses ALL Sol Weathers
> Always starts with NoCloud
> Chance for Rainy and Cloudy weather increases over time
> Higher chance for Rain after Cloudy weather
> Higher chance for Cloudy weather after rain
> Chance for rain resets to very low after rain occurs
> Chance for clouds resets to very low after rain occurs
> Sunny weather most of the time, especially in first minutes
> Extended transition time when it's swtiching between weather types (which are: clear, cloud and rain)
				
				1.1
> Added changelog on top of the script
> Randomized maximum chance for rainy/cloudy weathers (so you can have a lot of good weather in one race and a lot of rain/clouds in another)
> Moved Windy and Mist weathers to Cloudy group
> All config options are now separated from everything else on top of the script (for now only one option)
> Removed starter weather (that was always NoClouds)
> Removed slow version of the plan (that's why there's *nice* config now)

				1.2
> Small chance for weather to be bad for whole race
]]


		
		
		
		--[[Config]]--
-- higher = weather stays longer + slower weather transitions (only natural numbers)
local timemultiplier = 1

	 --[[End of Config]]--



	 
	 
math.randomseed( os.clock() )
math.random()
math.random()
math.random()

local current = "NoClouds"
local last = "NoClouds"
local currenttype = "clear"
local lasttype = "clear"
local additionaltime = 0
local planswithoutrain = 0
local planswithoutcloud = 0
local wrandom = math.random(0,20)

for i=1, 500 do
	if wrandom > 1 then 
		r = math.random(1,wrandom*2) -- rain chance
		r2 = math.random(1,wrandom) -- cloud chance
		r3 = math.random(1,wrandom) -- rain after cloud or vice versa chance
	elseif wrandom == 1 then
		r = math.random(1,2) -- rain chance
		r2 = 1 -- cloud chance
		r3 = 1 -- rain after cloud or vice versa chance
	else 
		r = 1 -- rain chance
		r2 = 0 -- cloud chance
		r3 = 1 -- rain after cloud or vice versa chance
	end
		
	if r <= planswithoutrain or (lasttype == "cloud" and r3 == 1)  then -- rain
		current = random({"LightDrizzle", "Drizzle", "HeavyDrizzle", "LightRain", "Rain", "HeavyRain", "LightThunderstorm", "Thunderstorm", " HeavyThunderstorm", "Tornado", "Hurricane", "LightSleet", "Sleet", "HeavySleet", "Hail", "LightSnow", "Snow", "HeavySnow"})
		currenttype = "rain"
		planswithoutrain = 0
		planswithoutcloud = planswithoutcloud + 1
	elseif r2 <= planswithoutcloud or (lasttype == "rain" and r3 == 1) then -- cloud
		current = random({"BrokenClouds", "OvercastClouds", "Fog", "Squalls", "Sand", "Smoke", "Windy", "Mist"})
		currenttype = "cloud"
		planswithoutcloud = 0
		planswithoutrain = planswithoutrain + 1
	else -- clear
		current = random({"NoClouds", "Clear", "FewClouds", "ScatteredClouds", "Haze", "Dust"})
		currenttype = "clear"
		planswithoutrain = planswithoutrain + 1
		planswithoutcloud = planswithoutcloud + 1
	end
	
	if currenttype ~= lasttype then
		additionaltime = math.random(500,1000)
	else
		additionaltime = 0
	end
	last = current
	lasttype = currenttype
	
	__SOL_WEATHER_PLAN:add_weather_slot({
		weather = current,
		time_holding = (math.random(50,300) + additionaltime)*timemultiplier,
		time_changing = (math.random(150,500) + additionaltime)*timemultiplier,
		temperature_ambient = math.random(0,36),
		temperature_road = nil,
		wind_direction = random(0,360),
		wind_speed = random(2,20),
	})
end

--[[ avialable weather types :
NoClouds
Clear, FewClouds, ScatteredClouds
Windy, BrokenClouds, OvercastClouds
Fog, Mist, Smoke, Haze
Sand, Dust
LightDrizzle, Drizzle, HeavyDrizzle
LightRain, Rain, HeavyRain
LightThunderstorm, Thunderstorm, HeavyThunderstorm
Squalls, Tornado, Hurricane
LightSleet, Sleet, HeavySleet
LightSnow, Snow, HeavySnow
Hail
]]