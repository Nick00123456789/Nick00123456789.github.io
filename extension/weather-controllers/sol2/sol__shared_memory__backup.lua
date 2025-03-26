function shared_memory_backup__Read(id, data)

    local msg = ac.load(id)
    if msg and #msg>0 then
        local t = split_string(msg, "$")
        local tt = {}
        if t then
            for i=1,#t do
                tt = split_string(t[i], ":")
                if tt and #tt==3 then
                    -- rebuild
                    if data[tt[1]] == nil then
                        data[tt[1]] = {}
                    end
                    data[tt[1]][tt[2]] = decodeValue(tt[3])
                end
            end
        end
    end

    return data
end

function shared_memory_backup__Write(id, data)

    local msg = ""
    local k, kk
    local v, vv

    for k, v in pairs(data) do
        if k then
            for kk, vv in pairs(v) do
                
                msg = msg.."$"..k..":"..kk..":"
                if type(vv) == "boolean" then
                    if vv then
                        msg = msg.."true"
                    else
                        msg = msg.."false"
                    end
                else
                    msg = msg..vv
                end
            end
        end
    end
    ac.store(id, msg)
end

function shared_memory_backup__Clear(id)
    ac.store(id, "")
end