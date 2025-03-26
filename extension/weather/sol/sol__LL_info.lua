local n_info_clouds = 0

local m = ac.SkyCloudMaterial()
m.baseColor 					= rgb(0,0,0)
m.frontlitMultiplier 			= 0
m.frontlitDiffuseConcentration 	= 0
m.backlitMultiplier 			= 0
m.backlitExponent 				= 1
m.backlitOpacityMultiplier 		= 0
m.backlitOpacityExponent 		= 1
m.specularPower 				= 0
m.specularExponent 				= 0.5
m.fogMultiplier					= 0

local pos = 0
local scale = 0.03

function _toRadians(degrees)
  return math.pi * degrees / 180.0
end

function _toDegrees(radians)
  return  radians * 180.0 / math.pi
end

function sphere2vec3(azi, alti)

  local alpha = _toRadians(azi)
  local beta  = _toRadians(alti)

  x = math.cos(alpha)*math.cos(beta);
  z = math.sin(alpha)*math.cos(beta);
  y = math.sin(beta);

  return vec3(x,y,z)
end

function create_info_cloud(position, text)

	local path = __sol__path.."clouds\\info\\"

	local file = path..text..".dds"

	if file_exists(file) == true then

		n_info_clouds = n_info_clouds + 1
		ac.weatherClouds[n_info_clouds] = ac.SkyCloud()

		ac.weatherClouds[n_info_clouds].color = rgb(1.0, 1.0, 1.0)
		ac.weatherClouds[n_info_clouds].opacity = 2
		ac.weatherClouds[n_info_clouds].cutoff = 0

		ac.weatherClouds[n_info_clouds].material = m

		ac.weatherClouds[n_info_clouds]:setTexture(file)
		ac.weatherClouds[n_info_clouds].useNoise = false

		ac.weatherClouds[n_info_clouds].position = sphere2vec3(position+((#text) * 52*scale)*0.5, 10)
		ac.weatherClouds[n_info_clouds].size 	= vec2(1*#text*scale, 2*scale)

		n_info_clouds = n_info_clouds + 1

		ac.weatherClouds[n_info_clouds] = ac.SkyCloud()

		ac.weatherClouds[n_info_clouds].color = rgb(1.0, 1.0, 1.0)
		ac.weatherClouds[n_info_clouds].opacity = 2
		ac.weatherClouds[n_info_clouds].cutoff = 0

		ac.weatherClouds[n_info_clouds].material = m

		ac.weatherClouds[n_info_clouds]:setTexture(file)
		ac.weatherClouds[n_info_clouds].useNoise = false

		ac.weatherClouds[n_info_clouds].position = sphere2vec3(position+((#text) * 52*scale)*0.5, 20)
		ac.weatherClouds[n_info_clouds].size 	= vec2(1*#text*scale, 1.4*scale)
	end
end

function show_text(text)

	if text == " " then

		pos = pos + (2 * 52*scale)
	else

		for i=0, 4 do create_info_cloud(pos+i*72, text) end
		pos = pos + ((#text) * 52*scale)
	end
end

function show_low_level_info(needed_version)

	show_text("CSP_update_to")
	show_text(" ")

	for i=1, #needed_version do
	
		show_text(string.sub(needed_version,i,i))
	end

	show_text(" ")
	show_text("is_needed")
end

function update__clouds(dt)


end

function update(dt)


end