--handles location display and data management compared to user input
--gives the option to load, save, or delete locations

function loadLocation()
	--loads selected location into GPS
	loadSuccesful, location = initialiseList("Load")
	if(loadSuccesful)then
		GpsDisplay.start(location[1], location[5])
	end
	GpsList.fullReset()
end

function eraseLocation()
	--erases selected location from memory
	keepDeleting = true
	while(keepDeleting)do
		loadSuccesful, location = initialiseList("Erase")
		if(loadSuccesful)then
			GpsList.setFreeText("DELETED: " .. location[1] .. "                    ", "e", "f", 1, 1, 20)
			GpsData.locationDelete(location[1])
		else
			keepDeleting = false
		end
	end
	GpsList.fullReset()
end




function initialiseList(pageName)
	settings.load()
	useGPS = settings.get("locationListUseGPS", true)
	posVector = nil
	if(useGPS)then
		posVector, useGPS = gpsRetrieveLocation()
	end
	return startList(useGPS, posVector, pageName)
end

function startList(useGPS, currentLocation, pageName)
	sideStatus = 1 --swaps between different views: 0 = simple view, 1 = duel view, 2 = distance view
	locationList, locationTable = prepareLocationArray()
	distanceTable = nil
	if(useGPS)then
		distanceTable = calculateDistanceTable(currentLocation, locationTable, locationList)
	end
	
	while true do
		selected = nil
		if(sideStatus == 0)then
			selected = GpsList.displayList(locationList, 0, nil, {"Back", "Dual View"}, pageName .. "-----Simple View")
		elseif(sideStatus == 1) and (useGPS)then
			selected = GpsList.displayList(locationList, 3, nil, {"Back", "Distance View"}, pageName .. "-----Dual View")
		elseif(sideStatus == 1) then
			selected = GpsList.displayList(locationList, 3, nil, {"Back", "Simple View"}, pageName .. "-----Dual View")
		elseif(sideStatus == 2) then
			selected = GpsList.displayList(locationList, 2, distanceTable, {"Back", "Simple View"}, pageName .. "-----Distance View")
		else
		error("unknown view type requested!")
		end
		
		--check options:
		if(selected ~= nil)then
			if(selected == "Back")then
				return false, nil
			elseif(selected == "Dual View")then
				sideStatus = 1
			elseif(selected == "Distance View")then
				sideStatus = 2
			elseif(selected == "Simple View")then
				sideStatus = 0
			else
				return true, locationTable[selected]
			end
		end
	end
end

function prepareLocationArray()
--loops though all locations and constructs a useable table out of it
	locationTable = {}
	locationList = GpsData.locationList()
	for index=1,#locationList do
		locationName = locationList[index]
		if(locationName ~= nil) and (GpsData.locationExist(locationName))then
			--location exist. save to list
			position = GpsData.locationRetrieve(locationName)
			locationTable[locationName] = {locationName, position.x, position.y, position.z, position}
		end
	end
	return locationList, locationTable
end

function calculateDistanceTable(position, locationTable, locationNames)
--recieves a locationTable and generates the distances to all locations given the position provided
	distanceTable = {}
	posX = position.x
	posY = position.y
	posZ = position.z
	for index=1,#locationNames do
		location = locationTable[locationNames[index]]
		locX = location[2]
		locY = location[3]
		locZ = location[4]
		distance = math.sqrt((posX - locX)^2 + (posY - locY)^2 + (posZ - locZ)^2)
		distanceTable[index] = math.floor(distance)
	end
	return distanceTable
end

















function editLocation()
	--displays list of options, and opens editor upon option selected
	
	loadSuccesful, location = initialiseList("Edit")
	if(loadSuccesful)then
		if(GpsData.locationExist(location[1]))then
			editorScreen(location[1])
			GpsList.fullReset()
		else
			term.clear()
			term.setCursorPos(1,1)
			term.setTextColor(colors.red)
			term.setBackgroundColor(colors.black)
			term.write("Error: invalid location")
			os.sleep(2)
		end
	end
end


function saveLocation()
	--opens editor screen and saves given location to memory
	editorScreen()
	GpsList.fullReset()
end

function editorScreen(oldLocation)
	running = true
	saved = true
	
	
	
	--setting temp vars:
	if(oldLocation == nil) or (GpsData.locationExist(oldLocation) == false)then
		oldName = ""
		tempName = ""
		tempPosX = 0
		tempPosY = 0
		tempPosZ = 0
	else
		tempVector = GpsData.locationRetrieve(oldLocation)
		tempName = oldLocation
		oldName = oldLocation
		tempPosX = tempVector.x
		tempPosY = tempVector.y
		tempPosZ = tempVector.z
	end
	
	settings.load()
	useGPS = settings.get("locationListUseGPS", true)
	if(useGPS)then
		posVector, useGPS = gpsRetrieveLocation()
	end

	extraList = {"<- Name.", nil, "<- X Position", nil, "<- Y Position", nil, "<- Z Position"}
	
	while running do
		--deal with written options:
		
		writtenName = tempName
		writtenPosX = tostring(tempPosX)
		writtenPosY = tostring(tempPosY)
		writtenPosZ = tostring(tempPosZ)
		
		while (string.len(writtenName) < 5)do
			writtenName = writtenName .. " "
		end
		
		while (string.len(writtenPosX) < 5)do
			writtenPosX = writtenPosX .. " "
		end
		
		while (string.len(writtenPosY) < 5)do
			writtenPosY = writtenPosY .. " "
		end
		
		while (string.len(writtenPosZ) < 5)do
			writtenPosZ = writtenPosZ .. " "
		end
		
		--save option list:
		if(useGPS)then
			optionList = {writtenName, "", writtenPosX, "", writtenPosY, "", writtenPosZ, "", "Use GPS", "", "Sequence Input",}
		else
			optionList = {writtenName, "", writtenPosX, "", writtenPosY, "", writtenPosZ, "", "Sequence Input",}
		end
		
		--prepare custom rule:
		customRule = {}
		customRule[1] = "Name must not exist"
		customRule[2] = false
		customRule[3] = ruleNameExists
		
		
		if(saved)then
			GpsList.eraseFreeText(1)
		else
			GpsList.setFreeText("Back", "e", "7", 1, 1, 1)
		end
		selected = nil
		selected, mouseX, mouseY = GpsList.displayList(optionList, 2, extraList, {"Back", "Save"}, "Create")
		
		--check selected option:
		if(selected ~= nil)then
			if(selected == "Back")then
				return false
			elseif(selected == "Save")then
				if(saved == false)then
					saved = true
					GpsData.locationDelete(oldName)
					GpsData.locationSave(tempName, vector.new(tempPosX, tempPosY, tempPosZ))
					oldName = tempName
				end
			elseif(selected == "Use GPS")then
				--retrieves location from GPS
				posVector = gpsRetrieveLocation()
				if(posVector.x ~= tempPosX)then
					saved = false
					tempPosX = posVector.x
				end
				if(posVector.y ~= tempPosY)then
					saved = false
					tempPosY = posVector.y
				end
				if(posVector.z ~= tempPosZ)then
					saved = false
					tempPosZ = posVector.z
				end
			elseif(selected == "Sequence Input")then
				--editing pos X
				input = GpsEditor.initialiseEditor(tempPosX, "Position X",1, 26, 1, nil)
				--editing name
				if(input ~= tostring(tempPosX)) and (input ~= nil) then
					saved = false
					tempPosX = tonumber(input)
				end
				
				--editing pos Y
				input = GpsEditor.initialiseEditor(tempPosY, "Position Y" ,1, 26, 1, nil)
				--editing name
				if(input ~= tostring(tempPosY)) and (input ~= nil) then
					saved = false
					tempPosY = tonumber(input)
				end
				
				--editing pos Z
				input = GpsEditor.initialiseEditor(tempPosZ, "Position Z" ,1, 26, 1, nil)
				--editing name
				if(input ~= tostring(tempPosZ)) and (input ~= nil) then
					saved = false
					tempPosZ = tonumber(input)
				end
			elseif(mouseY == 3)then
				localWorldNameList = GpsData.locationList()
				input = GpsEditor.initialiseEditor(tempName, "Location Name" ,1, 12, 0, {customRule})
				--editing name
				if(input ~= tempName) and (input ~= nil) then
					saved = false
					tempName = input
				end
			elseif(mouseY == 5)then
				--editing pos X
				input = GpsEditor.initialiseEditor(tempPosX, "Position X" ,1, 26, 1, nil)
				--editing name
				if(input ~= tostring(tempPosX)) and (input ~= nil) then
					saved = false
					tempPosX = tonumber(input)
				end
			elseif(mouseY == 7)then
				--editing pos Y
				input = GpsEditor.initialiseEditor(tempPosY, "Position Y" ,1, 26, 1, nil)
				--editing name
				if(input ~= tostring(tempPosY)) and (input ~= nil) then
					saved = false
					tempPosY = tonumber(input)
				end
			elseif(mouseY == 9)then
				--editing pos Z
				input = GpsEditor.initialiseEditor(tempPosZ, "Position Z" ,1, 26, 1, nil)
				--editing name
				if(input ~= tostring(tempPosZ)) and (input ~= nil) then
					saved = false
					tempPosZ = tonumber(input)
				end
			else
			end
		end
	end
end

function gpsRetrieveLocation()
	gpsAvailable = true
	term.clear()
	term.setCursorPos(1,1)
	term.setTextColor(colors.white)
	term.setBackgroundColor(colors.black)
	term.write("Please wait...")
	x, y, z = gps.locate(5)
	if x == nil then
		--gps unavailable. print error message!
		term.clear()
		term.setCursorPos(1,1)
		term.setTextColor(colors.red)
		term.write("Location Unavailable")
		gpsAvailable = false
		os.sleep(2)
	else
		return vector.new(x, y, z), gpsAvailable, x, y, z
	end
end



localWorldNameList = {}

function ruleNameExists(writtenWord, writtenTable)
	if(writtenWord == oldName)then
		return true
	else
		for i=1,#localWorldNameList do
			if localWorldNameList[i] == writtenWord then
				return false
			end
		end
		return true
	end
end

