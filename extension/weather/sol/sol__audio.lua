ac.loadSoundbank('/audio/sol.bank')
ac.loadSoundbank('/audio/rain.bank')

__SoundEngine = nil


Sound = {}
function Sound:new(sound, volume, preDelay, position)
  o = {}
  setmetatable(o, self)
  self.__index = self
  o.initialized = false

  o.sound = ac.AudioEvent(sound, false)
  o.sound:setPosition(position)

  o.sound:keepAlive()

  o.interior = true
  o.exterior = true

  o.sound.inAutoLoopMode = false
  o.sound.volume = 1
  o.sound.cameraInteriorMultiplier = 1.0
  o.sound.cameraExteriorMultiplier = 1
  o.sound.cameraTrackMultiplier = 1


  o.event = sound
  o.volume = volume or 1
  o.preDelay = preDelay
  o.time = os.clock()

  o.finished = false
  o.playing = false

  return o
end

function Sound:destroy()

	self.sound = nil
end

function Sound:setInteriorVolume(v)

	if o.sound then
		o.sound.cameraInteriorMultiplier = v
	end
end

function Sound:setExteriorVolume(v)

	if o.sound then
		o.sound.cameraExteriorMultiplier = v
	end
end

function Sound:setTrackVolume(v)

	if o.sound then
		o.sound.cameraTrackMultiplier = v
	end
end

function Sound:setParam(param, value)

	if self.sound then
		self.sound:setParam(param, value)
	end
end

function Sound:update()

	if not self.finished then
		if (self.time + self.preDelay) < os.clock() then

			if self.sound:isPlaying() then

			elseif self.playing then

				self.finished = true
				self.playing = false
				self.sound:stop()
			else
				self.sound:start()
				self.playing = true

				--ac.debug("###1", self.sound:isPlaying())
				--ac.debug("###2", self.sound:isWithinRange())
			end
		end
	end
end



--######################################################################


Soundengine = {}
function Soundengine:new(sound)
  o = {}
  setmetatable(o, self)
  self.__index = self
  o.initialized = false

  o.sounds = {}
  o.sounds_count = 0

  return o
end

function Soundengine:addSound(sound, volume, preDelay, position)

	self.sounds_count = self.sounds_count + 1
	self.sounds[self.sounds_count] = Sound:new(sound, volume, preDelay, position)

	return self.sounds[self.sounds_count]
end

function Soundengine:setParam(param, value)

	for i = 1, self.sounds_count do
		self.sounds[i]:setParam(param, value)
	end
end

function Soundengine:update()

	if self.sounds_count > 0 then

		local playing = 0
		local i=1

		repeat

			if self.sounds[i].finished then

				self.sounds[i]:destroy()
				self.sounds[i] = nil
				for ii = i, self.sounds_count-1 do
					self.sounds[ii] = self.sounds[ii+1]
				end
				self.sounds_count = self.sounds_count - 1
			else
				self.sounds[i]:update()
				if self.sounds[i].playing then playing = playing + 1 end
			end

			i=i+1

		until (i > self.sounds_count) 

		--ac.debug("####", playing..","..self.sounds_count)
	end
end




__SoundEngine = Soundengine:new()


__rain_sound = ac.AudioEvent('/rain/exterior', false)
__rain_sound.cameraInteriorMultiplier = 1.0
__rain_sound.cameraExteriorMultiplier = 1
__rain_sound.cameraTrackMultiplier = 1
__rain_sound.volume = 0
__rain_sound:setParam('strength', 0)
__rain_sound:start()
__rain_sound:setPosition(ac.getCameraPosition(), ac.getCameraDirection())
__rain_sound:keepAlive()

__drop_sound = ac.AudioEvent('/rain/interior', false)
__drop_sound.cameraInteriorMultiplier = 1.0
__drop_sound.cameraExteriorMultiplier = 1
__drop_sound.cameraTrackMultiplier = 1
__drop_sound.volume = 0
__drop_sound:setParam('strength', 0)
__drop_sound:start()
__drop_sound:setPosition(ac.getCameraPosition(), ac.getCameraDirection())
__drop_sound:keepAlive()


__wiper_sound = ac.AudioEvent('/wiper/std', false)
__wiper_sound.cameraInteriorMultiplier = 1.0
__wiper_sound.cameraExteriorMultiplier = 1
__wiper_sound.cameraTrackMultiplier = 1
__wiper_sound.volume = 0
__wiper_sound:setParam('state', 0.0)
__wiper_sound:start()
__wiper_sound:setPosition(ac.getCameraPosition(), ac.getCameraDirection())
__wiper_sound:keepAlive()


__wind_sound = ac.AudioEvent('/sol/wind', false)
__wind_sound.cameraInteriorMultiplier = 1
__wind_sound.cameraExteriorMultiplier = 1
__wind_sound.cameraTrackMultiplier = 1
__wind_sound.volume = 0
__wind_sound:setParam('strength', 0.0)
__wind_sound:start()
__wind_sound:setPosition(ac.getCameraPosition(), ac.getCameraDirection())
__wind_sound:keepAlive()


local _l_speed = 0
local _l_wind_speed = 0
local _l_lastCamPos = vec3()

local _l_SimState = nil
if ac.getSimState then _l_SimState = ac.getSimState() end
local _l_focused_car = -1
local _l_player = nil


local _l_up_vec = vec3(0, 1, 0)
local _l_up_vel = vec3(0, 0, 0)

local _l_sound_init = true
local _l_sound_init_start = os.clock()

function update_audio(dt)

	if _l_SimState==nil and ac.getSimState then
		_l_SimState = ac.getSimState()

		_l_sound_init = true
		_l_sound_init_start = os.clock()
	end

	if _l_sound_init then
		if os.clock() > _l_sound_init_start + 1 then
			_l_sound_init = false

			__rain_sound.volume = 1
			__drop_sound.volume = 1
			__wiper_sound.volume = 1
			__wind_sound.volume = 1

			_l_focused_car = -1
		end
	else

		if __CSP_version >= 1566 then
			if _l_SimState and _l_SimState.focusedCar~=nil then
				_l_focused_car = _l_SimState.focusedCar+1
				if _l_focused_car > 0 then
				else
					_l_focused_car = -1
				end
				if ac.getCarState then
					_l_player = ac.getCarState(_l_focused_car)
				else
					_l_player = nil
				end
				if _l_player == nil then
					_l_focused_car = -1
				end
			end
		end
	end

	__wind_sound.cameraInteriorMultiplier = SOL__config("sound", "wind_volume_interior")
	__wind_sound.cameraExteriorMultiplier = SOL__config("sound", "wind_volume_exterior")
	__wind_sound.cameraTrackMultiplier = __wind_sound.cameraExteriorMultiplier

	local rain_strenght = weather__get_rainIntensity_Scaled() --ac.getRainAmount()



	local update_position = true

	local rain_int_mult = SOL__config("sound", "rain_volume_interior")
	local rain_ext_mult = SOL__config("sound", "rain_volume_exterior")

	__rain_sound:setParam('strength', rain_strenght)
	__drop_sound:setParam('strength', rain_strenght)
	

	if ac.isInteriorView() then 
		__SoundEngine:setParam("closed", 1)
		__rain_sound:setParam("closed", 1)
		__drop_sound:setParam("closed", 1)
		__rain_sound.volume = rain_int_mult
		__drop_sound.volume = rain_int_mult
		if _l_player and _l_player.wiperMode>0 and _l_player.wiperProgress>0.01 then
			__wiper_sound:setParam("state", _l_player.wiperProgress)
			__wiper_sound:setParam("speed", _l_player.wiperMode)
			__wiper_sound:setParam("friction", 1-math.min(1,rain_strenght*1.25))
			__wiper_sound.volume = 1
		else
			__wiper_sound:setParam("state", 0)
			__wiper_sound.volume = 0
		end
		__wind_sound:setParam("closed", 1)
	else
		__SoundEngine:setParam("closed", 0)
		__rain_sound:setParam("closed", 0)
		__drop_sound:setParam("closed", 0)
		__rain_sound.volume = rain_ext_mult
		__drop_sound.volume = 0
		__wiper_sound.volume = 0
		__wind_sound:setParam("closed", 0)
		_l_player = nil
	end

	if update_position then
		__rain_sound:setPosition(ac.getCameraPosition(), ac.getCameraDirection(), _l_up_vec, _l_up_vel)
		__drop_sound:setPosition(ac.getCameraPosition(), ac.getCameraDirection(), _l_up_vec, _l_up_vel)
		__wiper_sound:setPosition(ac.getCameraPosition(), ac.getCameraDirection(), _l_up_vec, _l_up_vel)
		__wind_sound:setPosition(ac.getCameraPosition(), ac.getCameraDirection(), _l_up_vec, _l_up_vel)
	end

	_l_speed = 0
	if _l_player then
		_l_speed = _l_player.speedKmh
	else
		local _l_dist = math.horizontalDistance(_l_lastCamPos, __camPos)
		_l_speed = _l_speed*0.9 + ((_l_dist/dt)*3.6)*0.1
	end

	_l_lastCamPos:set(__camPos)

	__rain_sound:setParam('speed', _l_speed)
	__drop_sound:setParam('speed', _l_speed)


	--last_cam_pos = ac.getCameraPosition()
	--last_cam_pos_time = os.clock()

	--ac.debug("### speed", _l_speed)

	local _l_wind_speed = math.horizontalLength(( sphere2vec3(__wind_direction,0)*__wind_speed)) --+ speed*3.6
	_l_wind_speed = math.max(0.00, _l_wind_speed)
	if ac.isInteriorView() then
		_l_wind_speed = _l_wind_speed + _l_speed*2
	end

	--ac.debug("####windspeed", wind_speed)
	__wind_sound:setParam("strength", _l_wind_speed)

	--wiper_OSC:update()
	--__wiper_sound:setParam('state', wiper_OSC.value)
	--ac.debug("### wiper", wiper_OSC.value)


	--ac.debug("###1", __wind_sound:isPlaying())
	--ac.debug("###2", __wind_sound:isWithinRange())


	__SoundEngine:update()
end