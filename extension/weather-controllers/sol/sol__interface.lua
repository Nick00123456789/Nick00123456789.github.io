--[[
Version 1.0

]]  

Interface = {}
function Interface:new(appID, interval)

    o = {}
    setmetatable(o, self)
    self.__index = self

    o.IN_counter = 0
    o.OUT_counter = 0
    o.debug__output = false

    o.appID = appID
    --reset the counter
    ac.store("sol.TO_"..o.appID, "#"..o.OUT_counter)
    ac.store("sol.FROM_"..o.appID, "#"..o.IN_counter)

    o.send__buffer = ""
    o.last_send = os.clock()
    o.update_interval = interval or 0.25 --4 times every second per default 
    
    o.lowPriorityStep = 0
    o.lowPriority = 4

    o.send_order_list = {} --table of outgoing orders
    o.order_executor_list = nil --table of functions to handle incomming orders

    o.clear_send_order_list = false

    o.executeAfterSendWasReceived = nil
    o.bResetAfterSendWasRecieved = false

    return o
end





function input__test()

    local msg = ""
    msg = msg.."#178"
    msg = msg.."$SET_VALUE:nerd__ambient_adjust.Level:2.00"
    msg = msg.."$SET_VALUE:nerd__ambient_adjust.Saturation:3.00"
    msg = msg.."#179"
    msg = msg.."$SET_VALUE:nerd__ambient_adjust.Hue:0.01"

    return msg
end


function Interface:setOrderExecutorList(list)

    if list then
        self.order_executor_list = table__deepcopy(list)
    end
end


function Interface:is_digit(c)

    if c=='0' or c=='1' or c=='2' or c=='3' or c=='4' or c=='5' or c=='6' or c=='7' or c=='8' or c=='9' then return true end
    return false
end

function Interface:split_string(s, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={}
    for str in string.gmatch(s, "([^"..sep.."]+)") do
        table.insert(t, str)
    end
    return t
end

function Interface:decodeValue(strg)
    if strg == "true" then
        return true
    elseif strg == "false" then
        return false
    else
        return tonumber(strg)
    end
end

function Interface:check_order(parts)

    local order = nil
    if parts and #parts>0 then
        if parts[1] == "SET_VALUE" then
            if parts[2] and parts[3] and parts[4] then
                order = {
                    type="SET_VALUE",
                    content = {
                        section=parts[2],
                        key=parts[3],
                        order = 0
                    },
                }

                order.content.value = self:decodeValue(parts[4])
            end
        elseif parts[1] == "CMD" then
            order = {
                type="CMD",
                content = {}
            }
            for i=1,#parts-1 do
                order.content["CMD"..i]=parts[i+1]
            end
        else

        end
    end
    return order
end

function Interface:generate_orders(command)

    local orders = {}
    
    local msg_orders = self:split_string(command, "$")
    for i, v in ipairs(msg_orders) do
        local msg_parts = self:split_string(v, ":")
        local tmp = self:check_order(msg_parts)
        if tmp then
            table.insert(orders, tmp)
        end
    end

    return orders
end

function Interface:execute_orders(orders)

    if self.order_executor_list then
        if orders then
            for i=1,#orders do
                if self.order_executor_list[orders[i].type] then
                    if self.order_executor_list[orders[i].type].call then
                        _G[self.order_executor_list[orders[i].type].call](orders[i])
                    end
                end
            end
        end
    end
end

function Interface:get_commandos(msg)

    local commandos = {}

    local msg_commandos = self:split_string(msg, "#")
    for i, v in ipairs(msg_commandos) do
        for ii = 1, #v do
            -- seperate counter
            if string.sub(v, ii, ii) == "$" then
                local temp = string.sub(v, 1, ii-1)
                if temp and #temp>0 then
                    local new_counter = tonumber(temp)
                    if type(new_counter) == "number" then
                        if new_counter > self.IN_counter or new_counter == 0 then -- counter may reset to 0
                            table.insert(commandos, string.sub(v, ii, #v))
                            self.IN_counter = new_counter
                        end
                    end
                end
                break
            end
        end
    end

    return commandos
end

function Interface:add_order(type, parts)

    if type and #type>0 then
        
        local n = #self.send_order_list
        local replace = 0

        if type=="SET_VALUE" or type == "INIT_VALUE" then

            if parts and #parts>=3 then
                for i=1,n do

                    if self.send_order_list[i][1] == type then
                        if self.send_order_list[i][2] == parts[1] then
                            if self.send_order_list[i][3] == parts[2] then
                                replace = i
                                break
                            end
                        end
                    end
                end

                order = ""..tostring(parts[3])
                if parts[4] then 
                    order = order..":relative"  
                end

                if replace > 0 then
                    self.send_order_list[replace] = { type, parts[1], parts[2], order }
                else
                    self.send_order_list[n+1] = { type, parts[1], parts[2], order }
                end
                
            end
        elseif type=="CMD" then
            
            if parts then
                
                for i=1,n do
                    local e = 0
                    if #parts == #self.send_order_list[i]-1 then
                        for ii=1,#parts-1 do
                            if self.send_order_list[i][ii+1] == parts[ii] then
                                e=e+1
                            end
                        end
                        if e == #parts-1 then
                            replace = i
                            break
                        end
                    end
                end

                if replace > 0 then
                    self.send_order_list[replace][#parts+1] = parts[#parts]
                else
                    self.send_order_list[n+1] = {}
                    self.send_order_list[n+1][1]="CMD"
                    for ii=1,#parts do
                        self.send_order_list[n+1][ii+1] = parts[ii]
                    end
                end
            end
        end
    end
end

function Interface:clear_order_list_after_send()
    self.clear_send_order_list = true
end

function Interface:receive()

    local msg = ac.load("sol.FROM_"..self.appID) --input__test()

    if msg and #msg > 0 then
        local cmds = self:get_commandos(msg)
        if cmds then
            for i=1,#cmds do
                local orders = self:generate_orders(cmds[i])
                if orders then
                    self:execute_orders(orders)
                end
            end
        else 
        end
    end

    -- tell data was received
    ac.store("sol.FROM_"..self.appID.."_CTS", "OK")

    -- clear the memory
    ac.store("sol.FROM_"..self.appID, "")
end


function Interface:build_message_from_table(t, msg)
--[[
    local k
    local v

    local temp = ""..msg
    
    if type(t) == "table" then
        for k, v in pairs(t) do
            if type(v) == "table" then 
                self:build_message_from_table(v, temp..tostring(k)..":")
            else
                self.send__buffer = self.send__buffer.."$"..temp..tostring(k)..":"..tostring(v)
                if self.debug__output then ac.debug(self.appID+" $"..temp..tostring(k), tostring(v)) end
            end
        end
    end
]]

    msg = ""
    for i=1,#t do
        msg = msg.."$"
        for ii=1,#t[i] do
            if ii>1 then msg = msg..":" end
            msg = msg..t[i][ii]
        end
    end

    self.send__buffer = self.send__buffer..msg
    
    return nil
end

function Interface:executeFunctionAfterSendWasRecieved(func)
    self.executeAfterSendWasReceived = func
end

function Interface:resetAfterSendWasRecieved()
    self.bResetAfterSendWasRecieved = true
end

function Interface:send(forced)

    forced = forced or false

    local msg = ac.load("sol.TO_"..self.appID.."_CTS")
    if forced or (msg and #msg > 0 and msg == "OK") then

        if #self.send_order_list > 0 then
            self:build_message_from_table(self.send_order_list, "")
            --_l_to_configAPP_orders = {}
            
            if self.send__buffer and #self.send__buffer>0 then
                
                self.OUT_counter = self.OUT_counter + 1
                if self.OUT_counter > 10000 then 
                    self.OUT_counter = 0
                end
                local msg_count = "#"..tostring(self.OUT_counter)

                ac.store("sol.TO_"..self.appID, msg_count..self.send__buffer)
                self.send__buffer = ""

                -- reset CTS status
                ac.store("sol.TO_"..self.appID.."_CTS", "WAITING")

                --if self.clear_send_order_list then
                    self.send_order_list = {}
                    self.clear_send_order_list = false
                --end
            end
        end
    --elseif (msg and #msg > 0 and msg == "SLEEPING")

    end
end

function Interface:update()
    
    if os.clock() - self.last_send > self.update_interval then
        self:receive()
        self:send()
        self.last_send = os.clock()

        if self.executeAfterSendWasReceived then
            msg = ac.load("sol.TO_"..self.appID.."_CTS")
            if msg == "OK" then
                -- tell data was received
                ac.store("sol.FROM_"..self.appID.."_CTS", "RESET")
                self.executeAfterSendWasReceived()
            end
        elseif self.bResetAfterSendWasRecieved then
            msg = ac.load("sol.TO_"..self.appID.."_CTS")
            if msg == "OK" then
                self.OUT_counter = self.OUT_counter + 1
                local msg_count = "#"..tostring(self.OUT_counter)
                ac.store("sol.FROM_"..self.appID.."_CTS", "RESET")
                ac.store("sol.TO_"..self.appID, msg_count.."$CMD:system:ResetWeatherFX")
            end
        end
    end
end





