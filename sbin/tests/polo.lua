local a = _G.MARCO_ID

sleep( 0.5 )

proc.ipm.send( a, "MARCO!" )

local _, mes = proc.ipm.receive()
print(_)

if mes == "POLO!" then
  print(_)
  print("mes:"..tostring(mes))
  _G.GOTPOLO = true
  print("POLO!")
  os.queueEvent("POLO!")
end

return
