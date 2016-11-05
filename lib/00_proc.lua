if _G.proc then return end

local se = {}
_G.proc = {}

local re

proc.create = function(func, name)
  ret = #se+1
  se[ret] = {
    ["run"] = coroutine.create(func),
    ["name"] = name,
  }
  onlyCI("log", "debug", "Created a process with the id of "..tostring(#se+1))
  return ret
end

proc.kill = function(id)
  if not se[id] then
    error("A process with an id of '"..tostring(id).."' does not exist, so it cannot be killed.")
  end
  if se[id].veryImportant then
    error("The process with an id of '"..tostring(id).."' is important and cannot be killed!")
  end
  se[id] = nil
  onlyCI("log", "debug", "Killed a process with the id of "..tostring(#se+1))
end

local list
local idunno

local yieldTime
local yield = function()
        if yieldTime then -- check if it already yielded
                if os.clock() - yieldTime > 2 then -- if it were more than 2 seconds since the last yield
                        os.queueEvent("someFakeEvent") -- queue the event
                        os.pullEvent("someFakeEvent") -- pull it
                        yieldTime = nil -- reset the counter
                end
        else
                yieldTime = os.clock() -- store the time
        end
end

proc.list = function()
  list = {}
  for i=1, #se do
    idunno = se[i]
    list[i] = {
      ["name"] = idunno.name,
      ["status"] = coroutine.status(idunno.run),
      ["veryImportant"] = idunno.veryImportant
    }
  end
  return list
end

proc.getStatus = function(id)
  if not se[id] then
    error("A process with an id of '"..tostring(id).."' does not exist, so it cannot be killed.")
  end
  return coroutine.status( se[id].run )
end


local sysboot = proc.create(loadfile("/boot/init.lua"), "sysboot")
se[sysboot]["veryImportant"] = true

while true do
  for i=1, #se do
    if se[i] and se[i].run and coroutine.status(se[i].run) ~= "dead" then
      coroutine.resume(se[i].run)
    end
  end
  yield()
end