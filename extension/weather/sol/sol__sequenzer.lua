OSC = {}
function OSC:new (f, s, ll, hl)

	local t_ll = -1
	if ll ~= nil then t_ll = ll end

	local t_hl = 1
  	if hl ~= nil then t_hl = hl end

  	local this = {

        freq  = f,
        style = s, --0=random, 1=pattern, 2=sin, 3=trigger, 4=saw
        time  = os.clock(),

        low_limit = t_ll,
        high_limit = t_hl,

        value = 0,
        a = 0,
        b = 0,

        pattern = nil,
        pattern_pos = 1,

        running = false,
        loop = false,
        still = 0, -- do nothing for n seconds
        still_start = 0,

        callback_func = nil
    }

    function this:init(l)

        this.value = 0
        this.time  = os.clock()

    	if this.style == 0 then --rnd

    		this.b = rnd(1)
    		loop = l or true

        elseif this.style == 3 then --trigger

            this.a = 0
            this.b = 1
            loop = l or true

        elseif this.style == 4 then --saw

            this.a = 0
            this.b = 1
            loop = l or true
    	end
    end

    function this:pattern_reset()

    	this.pattern_pos = 1

    	if this.style == 0 then
    		--random
    		this.a = 0
    		this.b = rnd(1)
    		loop = true

    	elseif this.style == 1 then
    		--pattern
    		if this.pattern ~= nil and #this.pattern > 0 then

	    		this.a = this.pattern[1]
	    		if #this.pattern > 1 then
	    			this.b = this.pattern[2]
	    			this.pattern_pos = 2
	    		end
	    	end
	    elseif this.style == 2 then
	    	--sin
	    	this.value = 0
	    	this.a = 0
	    	this.b = 0

        elseif this.style == 3 or this.style == 4 then
            --trigger, saw
            this.value = 0
            this.a = 0
            this.b = 1
    	end
    end

    function this:set_pattern(p)

    	this.pattern = p
    	this:pattern_reset()
    end

    function this:set_callback(cb)

        this.callback_func = cb
    end

    function this:stand_still(sec)

        this.still = sec
        still_start = os.clock()
    end

    function this:run()

    	this.running = true

    	if this.style == 1 then

    		this:pattern_reset()
    	end
    end

    function this:stop()

    	this.running = false
        this.still = 0
    end

    function this:update()

        if this.running == false then return end

        local clock = os.clock()

        if this.still > 0 then

            if clock - still_start >= this.still then

                this.still = 0
                this.time = this.time + (clock - still_start)
            end
        else

        	local temp = clock - this.time
        	if temp < 0 then

        		temp = 0
        		this.time = clock
        	end

        	

	    	local pos = temp * this.freq

    		if pos >= 1 then

    			if this.style == 0 then
    				--random
	    			this.a = this.b
	    			this.b = rnd(1)
	    		elseif this.style == 1 then
	    			--pattern
	    			this.a = this.b
	    			
	    			if this.pattern_pos >= #this.pattern then 

	    				if this.loop == false then
	    					this:stop()
	    				end
	    				this.pattern_pos = 0 
	    			end
	    			this.pattern_pos = this.pattern_pos + 1

	    			this.b = this.pattern[this.pattern_pos]

	    		elseif this.style == 2 then
	    			--sin
	    		
                elseif this.style == 3 then
                    -- trigger
                    --if this.callback_func ~= nil then this:callback_func() end
                elseif this.style == 4 then
                    -- saw

                    if this.loop == false then
                        this:stop() 
                    else
                        this.a = 0
                        this.b = 1
                    end
                end

                if this.callback_func ~= nil then this:callback_func() end

	    		this.time = clock

	    		pos = 0
    		end

    		if this.style == 2 then
    			--sin
    			this.value = math.sin(pos * 2*math.pi)
    		else
    			--pattern + rnd
    			this.value = math.lerp(this.a, this.b, pos)
    			this.value = math.min(this.high_limit, math.max(this.low_limit, this.value) ) --math.clamp(this.low_limit, this.high_limit, this.value)
	    	end
        end
    end

    this:init()

    return this
end

