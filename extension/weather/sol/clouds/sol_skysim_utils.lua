function math.randomVec2()
  return (vec2(math.random(), math.random()) - 0.5):normalize()
end

function math.randomVec3()
  return (vec3(math.random(), math.random(), math.random()) - 0.5):normalize()
end

function math.horizontalLength(v0)
  return math.sqrt(v0.x * v0.x + v0.z * v0.z)
end

function math.horizontalDistance(v0, v1)
  local x = v0.x - v1.x
  local y = v0.z - v1.z
  return math.sqrt(x * x + y * y)
end

function table.deepCopy(x)
  if type(x) ~= 'table' then return x end
  local t = {}
  for k, v in pairs(x) do
    t[k] = deepCopy(v)
  end
  return t
end

function table.fillProps(self, p)
  if p ~= nil then
    for k, v in pairs(p) do
      self[k] = v
    end
  end
end

RareUpdate = {}
function RareUpdate:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  o.dt = 0
  o.phase = o.phase or 0
  o.delay = o.phase
  o.skip = o.skip or 2
  return o
end
function RareUpdate:update(dt, forceUpdate)
  if forceUpdate then 
    self.callback(dt)
    self.dt = 0
  end
  if self.delay > 0 then
    self.delay = self.delay - 1
    self.dt = self.dt + dt
  else
    self.delay = self.skip
    if not forceUpdate then self.callback(self.dt + dt) end
    self.dt = 0
  end
end

local gcSmooth = 0
local gcRuns = 0
function runGC()
  local before = collectgarbage('count')
  collectgarbage()
  gcSmooth = math.applyLag(gcSmooth, before - collectgarbage('count'), gcRuns < 50 and 0.9 or 0.995, 0.01)
  gcRuns = gcRuns + 1
  ac.debug('GC', math.floor(gcSmooth * 100) / 100 .. " KB")
end


--###########################################################################################
--### Stack
--###########################################################################################

Stack = {}
function Stack:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self

	o.list = {}
	o.n = 0

	return o
end

function Stack:destroy()

	for i=1, self.n do
		self.list[i] = nil
	end
	self = nil
end

function Stack:add(pack, index)

	self.n = self.n+1

	if index == nil or index > self.n then index = self.n end
	if index <= 0 then index = 1 end	
	index = math.floor(index)
	
	for i=self.n-1, index, -1 do
		self:copyEntries(i, i+1)
	end

	self.list[index] = {}
	for i=1,#pack do
		self.list[index][pack[i][1]] = pack[i][2]
	end
end

function Stack:copyEntry(index)

	if index > 0 and index <= self.n then

		local c = {}
		for k, v in next, self.list[index], nil do
            c[k] = v
        end

        return c
	end
end

function Stack:copyEntries(indexFrom, indexTo)

	if indexFrom > 0 and indexFrom <= self.n and
	   indexTo > 0 and indexTo <= self.n and
	   indexTo ~= indexFrom then

        self.list[indexTo] = {}
        
		for k, v in next, self.list[indexFrom], nil do
            self.list[indexTo][k] = v
        end
	end
end

function Stack:modifyEntry(index, pack)

	if index > 0 and index <= self.n then
		for i=1,#pack do
			if pack[i][1] then self.list[index][pack[i][1]] = pack[i][2] end
		end
	end
end

function Stack:remove(index)

	if index > 0 and index <= self.n then
		for i=index, self.n-1 do
			self:copyEntries(i+1, i)
		end
		self.list[self.n] = nil
		self.n = self.n-1
	end
end

function Stack:copy()
	local c = Stack:new()

	for i=1, self.n do c.list[i] = self:copyEntry(i) end
	c.n = self.n

	return c
end

function Stack:get(index)

	if index > 0 and index <= self.n then
		return self.list[index]
	end
end

