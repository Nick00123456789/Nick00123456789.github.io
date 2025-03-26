local __l__ac_clouds_storage = {}

function cloudsstorage__get_free_cloud(cloud_version)

  local _l_cloud = 0
  local c = nil

  for i=1,#__l__ac_clouds_storage do

    if __l__ac_clouds_storage[i] and __l__ac_clouds_storage[i].free then
      if cloud_version == __l__ac_clouds_storage[i].version then
        _l_cloud = i
        break
      end
    end
  end

  if _l_cloud > 0 then
    __l__ac_clouds_storage[_l_cloud].free = false
  else
    if cloud_version == 1 then
      c = ac.SkyCloud()
    elseif cloud_version == 2 then
      c = ac.SkyCloudV2()
    end
    if c then
      _l_cloud = #__l__ac_clouds_storage+1
      __l__ac_clouds_storage[_l_cloud] = {
        free = false,
        version = cloud_version,
        cloud = c,
      }
      ac.weatherClouds[#ac.weatherClouds + 1] = c
    end
  end

  return __l__ac_clouds_storage[_l_cloud].cloud
end

function cloudsstorage__set_free(cloud)

  if cloud then
    for i=1,#__l__ac_clouds_storage do

      if cloud == __l__ac_clouds_storage[i].cloud then

        __l__ac_clouds_storage[i].free = true
        __l__ac_clouds_storage[i].cloud.size=vec2(0,0)
        __l__ac_clouds_storage[i].cloud.opacity = 0
        __l__ac_clouds_storage[i].cloud.orderBy = 0
        __l__ac_clouds_storage[i].cloud:setTexture('')
        break
      end
    end
  end
end

function DEBUG__clouds__storage(dt) 
  local used = 0
  for i=1,#__l__ac_clouds_storage do
    if not __l__ac_clouds_storage[i].free then
      used = used + 1
    end
  end
  ac.debug("### Cloud Storage", #__l__ac_clouds_storage..", used: "..used)
end