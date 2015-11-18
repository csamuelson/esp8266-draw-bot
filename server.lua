-- setup web service

srv=net.createServer(net.TCP)
srv:listen(80,function(conn)
	      conn:on("receive",function(conn,payload)

			 -- stop the timer that runs the robot
			 
			 print(payload)

			 conn:send("<h1>Draw Bot</h1><h2><a href='index.html?start=yes'>Start</a></h2><h2><a href='index.html?start=no'>Stop</a></h2>")

			 conn.close(conn)
	      end)
end)
