--set local variables
--as long as its running, it needs absolute control over the screen
running = false

--retrieve radar settings:
settings.load()
--refresh rate, how long to sleep between screen draws.
refreshRate = settings.get("gpsRefresh", 0.2)

--fuzzy ration: how unprecise the depth meter and radar should be
depthFuzzy = settings.get("gpsDepthFuzzy", 3)
radarFuzzy = settings.get("gpsRadarFuzzy", 10)

--position variables
posX = 0
posY = 0
posZ = 0

--target variables. NOTE: these arent exact target position, but the distance towards
targetX = 0
targetY = 0
targetZ = 0

--target set: prevents first target drawn to screen
targetSet = false
--GPS status: 0 = loading, -1 is error, 1 is correctly loaded
gpsConnect = 0

--screen drawing variables:
--set internal variables: center of cross
crossCenterX = 12
crossCenterY = 14
--limits of cross
crossLimitMinX = 1
crossLimitMaxX = 23
crossLimitMinY = 8
crossLimitMaxY = 20

--set internal variables: center of depth meter
depthCenterX = 26
depthCenterY = 14
--limits of depth meter
depthLimitMinY = 8
depthLimitMaxY = 20

--radar rotation: default is 0. 1= 90 degrees. 2 = 180 degrees. 3 = 270 degrees
radarRotation = 0


function start(locName, target)
	running = true
	timeout = os.startTimer(refreshRate)
	while(running) do
		event, button, mouseX, mouseY = os.pullEvent()
		if event == "timer" and button == timeout then
			gpsUpdate()
			distanceCalculation(target)
			screenDraw(locName, target)
			timeout = os.startTimer(refreshRate)
		elseif(event == "mouse_click")then
			if(mouseX >= 21) and (mouseY == 1) then
				running = false
				term.clear()
				term.setCursorPos(1,1)
				--timeout = os.startTimer(refreshRate)
			elseif(mouseX == 1) and (mouseY == 7) then
				radarRotation = radarRotation - 1
				if(radarRotation < 0)then
					radarRotation = 3
				end
			elseif(mouseX == 24) and (mouseY == 7) then
				radarRotation = radarRotation + 1
				if(radarRotation > 3)then
					radarRotation = 0
				end
			end
		end
	end
end

function screenDraw(locName, target)
	term.clear()
	term.setTextColor(colors.white)
	term.setCursorPos(1, 1)
	term.write("Locating: " .. locName)
	term.setCursorPos(1, 2)
	if(gpsConnect == 1) then	
		term.write("GPS: Connected")
	elseif (gpsConnect == -1) then
		term.setTextColor(colors.red)
		term.write("GPS: Connection failed")
	else
		term.write("GPS: Please wait...")
	end
	term.setTextColor(colors.white)
	term.setCursorPos(1, 3)
	if(gpsConnect == 1) then	
		term.write("Pos X: " .. tostring(math.floor(posX)))
	else
		term.setTextColor(colors.red)
		term.write("Pos X: Null")
	end
	term.setCursorPos(1, 4)
	if(gpsConnect == 1) then	
		term.write("Pos Y: " .. tostring(math.floor(posY)))
	else
		term.setTextColor(colors.red)
		term.write("Pos Y: Null")
	end
	term.setCursorPos(1, 5)
	if(gpsConnect == 1) then	
		term.write("Pos Z: " .. tostring(math.floor(posZ)))
	else
		term.setTextColor(colors.red)
		term.write("Pos Z: Null")
	end
	
	term.setTextColor(colors.white)
	term.setCursorPos(14, 3)
	term.write("Trgt X: " .. tostring(math.floor(target.x)))
	term.setCursorPos(14, 4)
	term.write("Trgt Y: " .. tostring(math.floor(target.y)))
	term.setCursorPos(14, 5)
	term.write("Trgt Z: " .. tostring(math.floor(target.z)))
	
	--draw cross
	if(gpsConnect >= 0) then
		term.setTextColor(colors.gray)
	else 
		term.setTextColor(colors.red)
	end
	

	for drawY=1,13 do
		term.setCursorPos(12, 7 + drawY)
		term.write("|")
	end
	for drawX=1,21 do
		term.setCursorPos(1 + drawX, 14)
		term.write("-")
	end
	
	term.setCursorPos(12, 14)
	term.write("+")
	if(radarRotation == 0)then
		compassColor(1)
		term.setCursorPos(12, 8)
		term.write("N")
		
		compassColor(0)
		term.setCursorPos(23, 14)
		term.write("E")
		
		compassColor(2)
		term.setCursorPos(12, 20)
		term.write("S")
		
		compassColor(0)
		term.setCursorPos(1, 14)
		term.write("W")
	elseif(radarRotation == 1)then
		compassColor(0)	
		term.setCursorPos(12, 8)
		term.write("W")
		
		compassColor(1)	
		term.setCursorPos(23, 14)
		term.write("N")
		
		compassColor(0)	
		term.setCursorPos(12, 20)
		term.write("E")
		
		compassColor(2)	
		term.setCursorPos(1, 14)
		term.write("S")
	elseif(radarRotation == 2)then
		compassColor(2)	
		term.setCursorPos(12, 8)
		term.write("S")
		
		compassColor(0)	
		term.setCursorPos(23, 14)
		term.write("W")
		
		compassColor(1)	
		term.setCursorPos(12, 20)
		term.write("N")
		
		compassColor(0)	
		term.setCursorPos(1, 14)
		term.write("E")
	else
		compassColor(0)	
		term.setCursorPos(12, 8)
		term.write("E")
		
		compassColor(2)	
		term.setCursorPos(23, 14)
		term.write("S")
		
		compassColor(0)	
		term.setCursorPos(12, 20)
		term.write("W")
		
		compassColor(1)	
		term.setCursorPos(1, 14)
		term.write("N")
	end
	
	compassColor(0)	
	
	--add depth meter
	for drawY=1,13 do
		term.setCursorPos(26, 7 + drawY)
		term.write("|")
	end
	for drawY=1,13,6 do
		term.setCursorPos(25, 7 + drawY)
		term.write("-")
	end
	
	--draw back button
	term.setTextColor(colors.white)
	term.setBackgroundColor(colors.gray)
	term.setCursorPos(21, 1)
	term.write("Return")
	
	--draw arrow buttons:
	term.setCursorPos(1, 7)
	term.write("<")
	term.setCursorPos(24, 7)
	term.write(">")
	term.setBackgroundColor(colors.black)
	
	--draw target markers:
	if(targetSet) and (gpsConnect == 1) then
	
		term.setTextColor(colors.yellow)
		--draw depth meter
		--ensure its not 0. then divide by 2
		if(targetY == 0) == false then
			targetY = targetY / depthFuzzy
		end
		
		--add screen center to target
		targetY = depthCenterY + targetY
		
		--round target
		--targetY = math.floor(targetY + .5) -1
		
		--ensure target is within screen limits
		if(targetY > depthLimitMaxY) then
			targetY = depthLimitMaxY
		elseif(targetY < depthLimitMinY) then
			targetY = depthLimitMinY
		end
		
		--draw target
		term.setCursorPos(depthCenterX, targetY)
		term.write("X")
		
		--draw cross target
		--ensure its not 0. then divide by 2
		
		if(targetX == 0) == false then
			targetX = targetX / radarFuzzy
		end
		if(targetZ == 0) == false then
			targetZ = targetZ / radarFuzzy
		end
		
		--add screen center to target
		targetX = crossCenterX + targetX
		targetZ = crossCenterY + targetZ
		
		--round number
		targetX = math.floor(targetX + .5)
		targetZ = math.floor(targetZ + .5)
		
		--ensure target is within screen limits
		if(targetX > crossLimitMaxX) then
			targetX = crossLimitMaxX
		elseif(targetX < crossLimitMinX) then
			targetX = crossLimitMinX
		end
		if(targetZ > crossLimitMaxY) then
			targetZ = crossLimitMaxY
		elseif(targetZ < crossLimitMinY) then
			targetZ = crossLimitMinY
		end
		
		--draw target
		term.setCursorPos(targetX, targetZ)
		term.write("X")
		targetSet = false
	end
end

function gpsUpdate()
	x, y, z = gps.locate(5)
	if x == nil then
		--gps unavailable. print error message!
		gpsConnect = -1
		return
	end
	--gps connected succesfully. retrieve and store location!
	posX = math.floor(x + .5) + .5
	posY = math.floor(y + .5) + .5 - 2
	posZ = math.floor(z + .5) + .5
	gpsConnect = 1
end

function distanceCalculation(target)
	--calculates distance between gps position and given target position
	--calculate distance
	
	targetY = posY - target.y
	
	if(radarRotation == 0)then
		targetX = target.x - posX
		targetZ = target.z - posZ
	elseif(radarRotation == 1)then
		--targetX = posX - target.x
		--targetZ = target.z - posZ
		targetX = posZ - target.z
		targetZ = target.x - posX
	elseif(radarRotation == 2)then
		targetX = posX - target.x
		targetZ = posZ - target.z
	else
		targetX = target.z - posZ
		targetZ = posX - target.x
	end
	--target has been set!
	targetSet = true
end



function compassColor(status)
	if(gpsConnect)then
		if(status == 1)then
			term.setTextColor(colors.red)
		elseif(status == 2)then
			term.setTextColor(colors.white)
		else
			term.setTextColor(colors.gray)
		end
	else
		term.setTextColor(colors.red)
	end
end