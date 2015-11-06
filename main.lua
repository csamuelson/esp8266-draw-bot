function release()
   gpio.mode(4,gpio.OUTPUT)
   gpio.write(4,0)
   gpio.mode(3,gpio.OUTPUT)
   gpio.write(3,0)
   gpio.mode(2,gpio.OUTPUT)
   gpio.write(2,0)
   gpio.mode(1,gpio.OUTPUT)
   gpio.write(1,0)
end

function move(dir)
   if dir == "forward" then
      step = step + 1
      if step > 4 then step = 1 end
      for pin=1,4 do
	 gpio.write(stepper_pins[pin],forward_order[step][pin])
      end
      active = active - 1
   elseif dir == "backward" then
      step = step + 1
      if step > 4 then step = 1 end
      for pin=1,4 do
	 gpio.write(stepper_pins[pin],backward_order[step][pin])
      end
      active = active - 1
   elseif dir == "left" then
   elseif dir == "right" then
   end
      
end

release()

tmr.alarm(0, 1000, 1, function()
   if wifi.sta.getip() == nil then
      print("Connecting to AP...")
   else
      print('IP: ',wifi.sta.getip())
      tmr.stop(0)
   end
end)

stepper_pins = {4,2,1,3}
forward_order = {{1,0,1,0},{0,1,1,0},{0,1,0,1},{1,0,0,1}}
backward_order = {{1,0,0,1},{0,1,0,1},{0,1,1,0},{1,0,1,0}}
direction = "forward"
active = 0
step = 1

-- tmr.alarm(1, 6, 1, function()
-- 	     tmr.wdclr()
-- 	     if step == 4 then step=1 else step=step+1 end
-- 	     print(step)
-- 	     for pin=1, 4 do
-- 		mypin = stepper_pins[pin]
-- 		if mypin == nil then
-- 		   print("mypin " .. pin .. "is nil")
-- 		else
-- 		   gpio.write(stepper_pins[pin],forward_order[step][pin])
-- 		end
-- 	     end
-- end)

file.open("commands.logo","r")

tmr.alarm(1, 3, 1, function()
	     if active >0 then
		   move(direction)
	     else
		line = file.readline()
		if line == nil then
		   tmr.stop(1)
		   release()
		else
		   print(line)
		   active = tonumber(string.match(line, "%d+"))
		   direction = string.match(line, "%a+")
		end
	     end
end)




