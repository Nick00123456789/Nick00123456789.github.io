
math.randomseed(os.clock())

function random(data1, data2)

	if data1 == nil then return nil end

	if type(data1) == 'table'  then

		local r = 1 + math.floor(math.random() * #data1)
		return data1[r]

	elseif type(data1) == 'number' then

		if data2 ~= nil and type(data2) == 'number' then

			return math.lerp( data1, data2, math.random())
		end
	end

end


WEATHER_PLAN = {}
function WEATHER_PLAN:new ()

	local this = {

		version = 1,

		current_slot = 0,
		next_slot = 0,
		current_slot_time = os.clock(),
		current_slot_lifetime = 0,

		current_weather_id = 100,
		upcoming_weather_id = 100,
		transition = 0.0,
		
		weather_slots = {},

		--__new_weather_def = nil,
		--new_weather_def_send = false,
	}

	function this:load_next_slot()

		if this.current_slot == 0 or this.weather_slots[this.current_slot].time_changing >= 0 then

			if this.current_slot > 0 then
				this.weather_slots[this.current_slot].rain_mod_osc:stop()
			end

			this.current_slot = this.current_slot + 1

			if this.current_slot > #this.weather_slots then

				this.current_slot = 1
			end

			this.weather_slots[this.current_slot].rain_mod_osc:run()

			this.current_slot_time     = os.clock()
			this.current_slot_lifetime = this.weather_slots[this.current_slot].time_holding + this.weather_slots[this.current_slot].time_changing
		
			this.transition = 0.0

			this.current_weather_id = this.weather_slots[this.current_slot].weather

			if this.current_slot < #this.weather_slots then
				this.next_slot = this.current_slot+1
			else
				this.next_slot = 1
			end

			this.upcoming_weather_id = this.weather_slots[this.next_slot].weather
--[[	
			local f=io.open(__sol_ctrl__path.."last_weather.sol","w+")
			if f~=nil then
				--f:output()
				f:write("__SOL_WEATHER_PLAN:add_weather_slot({\n")
				f:write("weather = \""..this.weather_slots[this.next_slot].weather_name.."\",\n")
				f:write("time_holding = 0,\n")
				f:write("time_changing = 5,\n")
				f:write("temperature_ambient = "..this.weather_slots[this.next_slot].temperature_ambient..",\n")
				f:write("temperature_road = "..this.weather_slots[this.next_slot].temperature_road..",\n")
				f:write("wind_direction = "..this.weather_slots[this.next_slot].wind_direction..",\n")
				f:write("wind_speed = "..this.weather_slots[this.next_slot].wind_speed.."\n")
				f:write("})\n")
				
				f:close()
			end]]
		end
	end

	function this:interpolate_slot_value(key)

		if this.current_slot == 0 then
			return 0
		elseif #this.weather_slots == 1 then
			return this.weather_slots[1][key]
		else
			return math.lerp(this.weather_slots[this.current_slot][key], this.weather_slots[this.next_slot][key], this.transition)
		end
	end

	function this:reset()

		if #this.weather_slots > 0 then

			this.current_slot = 0
			this:load_next_slot()

			if #this.weather_slots == 1 then this.transition = 1 end
		else
			--load standard weather/no clouds
			this.current_weather_id = 100
			this.upcoming_weather_id = 100
		end
	end

	function this:check_for_rain()

		local rain = false

		for i=1,#this.weather_slots do
			if __weather_params[ this.weather_slots[i].weather ][2] > 0 then
				rain = true
				break
			end 
		end

		return rain
	end

	function this:update()

		ac.debug("Weather slot", this.current_slot.."\\"..#this.weather_slots)

		if #this.weather_slots > 0 and this.current_slot > 0 then
			--weather sequence is running
			local time = os.clock()

			if this.weather_slots[this.current_slot].time_changing >= 0 then

				if (time-this.current_slot_time) > (this.weather_slots[this.current_slot].time_holding) then

					this.transition = ((time-this.weather_slots[this.current_slot].time_holding)-this.current_slot_time) / ( this.weather_slots[this.current_slot].time_changing )

					if this.transition > 1.0 then

						if (time-this.current_slot_time) > this.current_slot_lifetime then
							
							this:load_next_slot()
						else

							this.transition = 1.0
						end
					end
				end
			end
		end

		local rain = this:interpolate_slot_value('rain_amount')
		this.weather_slots[this.current_slot].rain_mod_osc:update()
		rain = rain + math.min(1, math.max(-1, this.weather_slots[this.current_slot].rain_mod_osc.value))
		--ac.debug("###",this.weather_slots[this.current_slot].rain_mod_osc.value)

		--[[
		local new_weather_def_package = nil
		if this.new_weather_def_send == false then
			new_weather_def_package = this.__new_weather_def
		else
			this.__new_weather_def = nil --reset package
		end

		this.new_weather_def_send = true
		]]

		return { current = this.current_weather_id,
				 upcoming = this.upcoming_weather_id,
				 transition = this.transition,
				 temperature_ambient = this:interpolate_slot_value('temperature_ambient'),
				 temperature_road = this:interpolate_slot_value('temperature_road'),
				 wind_direction = this:interpolate_slot_value('wind_direction'),
				 wind_speed = this:interpolate_slot_value('wind_speed'),
				 rain_amount = rain,
				 --[[__new_weather_def = new_weather_def_package,]]--
				}
	end

	function this:ValueFromLastSlot(key, initValue)

		if #this.weather_slots == 0 then
			return initValue
		else
			return this.weather_slots[#this.weather_slots][key]
		end
	end

	function this:ValueFromLastSlot_CustomWeather__(key, custom_weather, initValue)

		if custom_weather == nil or custom_weather[key] == nil then

			if #this.weather_slots == 0 or __weather_defs[ this.weather_slots[#this.weather_slots].weather ] == nil then

				return initValue
			else
				return __weather_defs[ this.weather_slots[#this.weather_slots].weather ][key]
			end
		else
			return custom_weather[key]
		end
	end
	
	function this:add_weather_slot(slot)

		local weather_id = 100

		if slot.weather == nil then
			weather_id 	= this:ValueFromLastSlot('weather', 100)
		end

		slot.time_holding 			= slot.time_holding 		or this:ValueFromLastSlot('time_holding', 60)
		slot.time_changing 			= slot.time_changing 		or this:ValueFromLastSlot('time_changing', 120)
		slot.temperature_ambient 	= slot.temperature_ambient 	or this:ValueFromLastSlot('temperature_ambient', 20)
		slot.temperature_road 		= slot.temperature_road		or this:ValueFromLastSlot('temperature_road', 20)
		slot.wind_direction 		= slot.wind_direction 		or this:ValueFromLastSlot('wind_direction', 0)
		slot.wind_speed 			= slot.wind_speed 			or this:ValueFromLastSlot('wind_speed', 0)
		slot.rain_amount 			= slot.rain_amount 			or this:ValueFromLastSlot('rain_amount', -1)
		slot.rain_mod_min 			= slot.rain_mod_min 		or this:ValueFromLastSlot('rain_mod_min', 0)
		slot.rain_mod_max 			= slot.rain_mod_max 		or this:ValueFromLastSlot('rain_mod_max', 0)
		slot.rain_mod_speed 		= slot.rain_mod_speed 		or this:ValueFromLastSlot('rain_mod_speed', 10)
		
		if slot.weather ~= nil then

			if     string.find(slot.weather, "LightThunderstorm") == 1 then weather_id = 0
			elseif string.find(slot.weather, "Thunderstorm") == 1 then weather_id = 1
			elseif string.find(slot.weather, "HeavyThunderstorm") == 1 then weather_id = 2
			elseif string.find(slot.weather, "LightDrizzle") == 1 then weather_id = 3
			elseif string.find(slot.weather, "Drizzle") == 1 then weather_id = 4
			elseif string.find(slot.weather, "HeavyDrizzle") == 1 then weather_id = 5
			elseif string.find(slot.weather, "LightRain") == 1 then weather_id = 6
			elseif string.find(slot.weather, "Rain") == 1 then weather_id = 7
			elseif string.find(slot.weather, "HeavyRain") == 1 then weather_id = 8
			elseif string.find(slot.weather, "LightSnow") == 1 then weather_id = 9
			elseif string.find(slot.weather, "Snow") == 1 then weather_id = 10
			elseif string.find(slot.weather, "HeavySnow") == 1 then weather_id = 11
			elseif string.find(slot.weather, "LightSleet") == 1 then weather_id = 12
			elseif string.find(slot.weather, "Sleet") == 1 then weather_id = 13
			elseif string.find(slot.weather, "HeavySleet") == 1 then weather_id = 14
			elseif string.find(slot.weather, "Clear") == 1 then weather_id = 15
			elseif string.find(slot.weather, "FewClouds") == 1 then weather_id = 16
			elseif string.find(slot.weather, "ScatteredClouds") == 1 then weather_id = 17
			elseif string.find(slot.weather, "BrokenClouds") == 1 then weather_id = 18
			elseif string.find(slot.weather, "OvercastClouds") == 1 then weather_id = 19
			elseif string.find(slot.weather, "Fog") == 1 then weather_id = 20
			elseif string.find(slot.weather, "Mist") == 1 then weather_id = 21
			elseif string.find(slot.weather, "Smoke") == 1 then weather_id = 22
			elseif string.find(slot.weather, "Haze") == 1 then weather_id = 23
			elseif string.find(slot.weather, "Sand") == 1 then weather_id = 24
			elseif string.find(slot.weather, "Dust") == 1 then weather_id = 25
			elseif string.find(slot.weather, "Squalls") == 1 then weather_id = 26
			elseif string.find(slot.weather, "Tornado") == 1 then weather_id = 27
			elseif string.find(slot.weather, "Hurricane") == 1 then weather_id = 28
			elseif string.find(slot.weather, "Cold") == 1 then weather_id = 29
			elseif string.find(slot.weather, "Hot") == 1 then weather_id = 30
			elseif string.find(slot.weather, "Windy") == 1 then weather_id = 31
			elseif string.find(slot.weather, "Hail") == 1 then weather_id = 32
			elseif string.find(slot.weather, "NoClouds") == 1 then weather_id = 100
			end
		end

		this.weather_slots[#this.weather_slots+1] = {
		
			weather = weather_id,
			weather_name = slot.weather,
			time_changing = math.max(slot.time_changing, 2),
			time_holding = math.max(slot.time_holding, 0),
			temperature_ambient = math.min(40, math.max(slot.temperature_ambient, 0)),
			temperature_road = math.min(40, math.max(slot.temperature_road, 0)),
			wind_direction = math.min(40, math.max(slot.wind_direction, 0)),
			wind_speed = math.min(200, math.max(slot.wind_speed, 0)),
			rain_amount = math.min(1, math.max(slot.rain_amount, -1)),
			rain_mod_min = slot.rain_mod_min,
			rain_mod_max = slot.rain_mod_max,
			rain_mod_speed = slot.rain_mod_speed,
			rain_mod_osc = OSC:new(1/math.max(slot.rain_mod_speed, 2), -- set frequency
								   0, -- style: random
								   slot.rain_mod_min, -- bottom
								   slot.rain_mod_max), -- up
		}
		
		if slot.time_changing < 0 then
			this.weather_slots[#this.weather_slots].time_changing = -1
		end

	end

	return this
end
