left_stepper_pins = {8,6,5,7}
right_stepper_pins = {4,2,1,3}
pen_pin = 12
pen_up_value = 75
pen_down_value = 35
pen_pwm_freq = 50 -- probably don't change this, it might not be good for the servos
ms_between_steps = 3
servo_time = 50 -- time in ms for servo to move / ms_between_steps
backward_order = {{1,0,1,0},{0,1,1,0},{0,1,0,1},{1,0,0,1}}
forward_order = {{1,0,0,1},{0,1,0,1},{0,1,1,0},{1,0,1,0}}
direction = "forward"
active = 0
step = 1
final_run = 0

-- setup pwm

pwm.setup(pen_pin,pen_pwm_freq,pen_up_value)
pwm.start(pen_pin)
direction = "pen"
active = servo_time

function release()
   for pin=1,4 do
      gpio.mode(left_stepper_pins[pin],gpio.OUTPUT)
      gpio.write(left_stepper_pins[pin],0)
      gpio.mode(right_stepper_pins[pin],gpio.OUTPUT)
      gpio.write(right_stepper_pins[pin],0)
   end
end


function move(dir)
   tmr.wdclr()
   if dir == "forward" then
      step = step + 1
      if step > 4 then step = 1 end
      for pin=1,4 do
	 gpio.write(right_stepper_pins[pin],forward_order[step][pin])
	 gpio.write(left_stepper_pins[pin],backward_order[step][pin])
      end
      active = active - 1
   elseif dir == "backward" then
      step = step + 1
      if step > 4 then step = 1 end
      for pin=1,4 do
	 gpio.write(right_stepper_pins[pin],backward_order[step][pin])
	 gpio.write(left_stepper_pins[pin],forward_order[step][pin])
      end
      active = active - 1
   elseif dir == "left" then
   elseif dir == "right" then
   elseif dir == "pen" then
      print("active" .. active)
      print("final_run" .. final_run)
      if active == 1 then
	 print("pwm stop")
	 pwm.stop(pen_pin)
      end
      active = active - 1
   end
end

function pen_up()
   pwm.setduty(pen_pin,pen_up_value)
end

function pen_down()
   pwm.setduty(pen_pin,pen_down_value)
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



-- tmr.alarm(1, 6, 1, function()
-- tmr.wdclr()
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

tmr.alarm(1, ms_between_steps, 1, function()
	     if active > 0 then
		   move(direction)
	     else
		if final_run == 1 then
		   tmr.stop(1)		   
		else
		   line = file.readline()
		   if line == nil then
		      release()
		      pen_up()
		      direction = "pen"
		      active = servo_time
		      final_run = 1
		   else
		      print(line)
		      direction = string.match(line, "%a+")
		      if direction == "pen" then
			 if string.sub(line,5,6) == "up" then
			    pen_up()
			    active = servo_time
			 elseif string.sub(line,5,8) == "down" then
			    pen_down()
			    active = servo_time
			 end
		      else
			 active = tonumber(string.match(line, "%d+"))
			 if active == nil then
			    active = 0
			 end
		      end
		   end
		end
	     end
end)
