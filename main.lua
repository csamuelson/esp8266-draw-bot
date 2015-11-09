print("main.lua")
left_stepper_pins = {8,6,5,7}
right_stepper_pins = {4,2,1,3}
pen_pin = 12
pen_up_value = 35
pen_down_value = 18
wheel_dia = 68.5
wheel_base = 112.5
steps_rev = 512
pen_pwm_freq = 25 -- probably don't change this, it might not be good for the servos
ms_between_steps = 6
servo_time = 30 -- time in ms for servo to move / ms_between_steps
backward_order = {{1,0,1,0},{0,1,1,0},{0,1,0,1},{1,0,0,1}}
forward_order = {{1,0,0,1},{0,1,0,1},{0,1,1,0},{1,0,1,0}}
direction = "forward"
active = 0
step = 1
final_run = 0
drawing = 0
remember_pen = 0

-- setup pwm

pwm.setup(pen_pin,pen_pwm_freq,pen_up_value)
pwm.start(pen_pin)
direction = "pen"
active = servo_time

function release()
   for pin=1,4 do
      tmr.wdclr()
      gpio.mode(left_stepper_pins[pin],gpio.OUTPUT)
      gpio.write(left_stepper_pins[pin],0)
      gpio.mode(right_stepper_pins[pin],gpio.OUTPUT)
      gpio.write(right_stepper_pins[pin],0)
   end
end

function get_steps(distance)
   return distance * steps_rev / (wheel_dia * 3.1412)
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
      step = step + 1
      if step > 4 then step = 1 end
      for pin=1,4 do
	 gpio.write(right_stepper_pins[pin],backward_order[step][pin])
	 gpio.write(left_stepper_pins[pin],backward_order[step][pin])
      end
      active = active - 1
   elseif dir == "right" then
      step = step + 1
      if step > 4 then step = 1 end
      for pin=1,4 do
	 gpio.write(right_stepper_pins[pin],forward_order[step][pin])
	 gpio.write(left_stepper_pins[pin],forward_order[step][pin])
      end
      active = active - 1
   elseif dir == "pen" then
      active = active - 1
--      print("active = " .. active)
      if active == 1 then
	 pwm.stop(pen_pin)
      end
   end
end

function pen_up()
   print('pen up func')
   pwm.setduty(pen_pin,pen_up_value)
end

function pen_down()
   print('pen down func')
   pwm.setduty(pen_pin,pen_down_value)
end

function start_drawing()
   if drawing == 0 then
      print('start drawing')
      file.open("commands.logo","r")
      final_run = 0
      drawing = 1
   end
end

function stop_drawing()
   drawing = 0
   file.close()
   release()
   pen_up()
   direction = "pen"
   active = servo_time
end

-- make sure the motors are off

release()

-- setup web service

srv=net.createServer(net.TCP)
srv:listen(80,function(conn)
	      conn:on("receive",function(conn,payload)
			 print(payload)
			 postparse={string.find(payload,"start=")}
			 httpparse={string.find(payload," HTTP")}
			 start = "no"
			 if postparse[2] ~= nil then
			    start = string.sub(payload,postparse[2]+1,httpparse[1])
			    print("start = " .. start .. ".")
			 end
			 conn:send("<h1>Draw Bot</h1><h2><a href='index.html?start=yes'>Start</a></h2><h2><a href='index.html?start=no'>Stop</a></h2>")
			 if string.find(start,"yes") then
			    direction = "pen"
			    active = 500
			    start_drawing()
			 elseif string.find(start,"no") then
			    stop_drawing()
			 end
			 conn.close(conn)
	      end)
end)

-- open the drawing file



-- timer loop to execute drawing actions

tmr.alarm(1, ms_between_steps, 1, function()
	     if drawing == 1 then
		if active > 0 then
		   move(direction)
		else
		   if final_run == 1 then
--		      tmr.stop(1)
		      --		   node.dsleep(0,4)
		   else
		      line = file.readline()
		      if line == nil then
			 release()
			 pen_up()
			 direction = "pen"
			 active = servo_time
			 final_run = 1
		      else
			 print("line: " .. line)
			 direction = string.match(line, "%a+")
			 if direction == "pen" then
			    if string.sub(line,5,6) == "up" then
			       pen_up()
			       active = servo_time
			    elseif string.sub(line,5,8) == "down" then
			       print("going going down")
			       pen_down()
			       active = servo_time
			    end
			 else
			    active = tonumber(string.match(line, "%d+"))
			    if active == nil then
			       active = 0
			    elseif direction == "right" then
			       rotation = active / 360.0
			       distance = wheel_base * 3.1412 * rotation
			       steps = get_steps(distance)
			       active = steps * 4
			    elseif direction == "left" then
			       rotation = active / 360.0
			       distance = wheel_base * 3.1412 * rotation
			       steps = get_steps(distance)
			       active = steps * 4
			    end
			 end
		      end
		   end
		end
	     else
		if direction == "pen" and active > 0 then
		   print('pen upping')
		   move(direction)
		end
	     end
end)
