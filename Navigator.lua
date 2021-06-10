os.loadAPI("GpsData.lua")
os.loadAPI("GpsDisplay.lua")
os.loadAPI("GpsList.lua")
os.loadAPI("GpsLocHandler.lua")
os.loadAPI("GpsEditor.lua")


--connects all scripts together and provides the user with a input panel to which they can select options on what to do with the program
mainThreadRunning = true
mainEasterEgg = false
--start program here:
while mainThreadRunning do
	--load data into list api:
	mainOptions = {"Load", "Save", "Edit", "Delete", "", "", "Settings"}
	imageData = {}
	imageData[1] = 15 --image left top corner position X
	imageData[2] = 2 --image left top corner position Y
	imageData[3] = {"2","f","f","f","f","f","f","f","f","f","2"}
	imageData[4] = {"2","2","f","f","f","f","f","f","f","2","2"}
	imageData[5] = {"2","2","2","2","2","2","2","2","2","2","2"}
	imageData[6] = {"2","f","f","2","2","2","2","2","f","f","2"}
	imageData[7] = {"2","2","2","2","2","2","2","2","2","2","2"}
	imageData[8] = {"2","2","f","2","2","f","2","2","f","2","2"}
	imageData[9] = {"f","2","2","f","f","2","f","f","2","2","f"}
	imageData[10] = {"f","f","2","2","2","2","2","2","2","f","f"}
	GpsList.setImage(imageData, 1)
	
	--set custom texts:
	GpsList.setFreeText("Locations:", "2", "f", 1, 1, 2)
	GpsList.setFreeText("Made by: Kitty Soldier", "2", "f", 2, 1, 20)
	if(mainEasterEgg)then
		GpsList.setFreeText("Mrreow!", "2", "f", 3, 17, 2)
	end
	--display option list:
	mainResult, mouseX, mouseY = GpsList.displayList(mainOptions, 1, nil, nil, nil)
	
	if(mainResult ~= nil) then
		--a option was selected:
		GpsList.fullReset()
		mainEasterEgg = false
		if(mainResult == "Load")then
			GpsLocHandler.loadLocation()
		elseif(mainResult == "Save")then
			GpsLocHandler.saveLocation()
		elseif(mainResult == "Edit")then
			GpsLocHandler.editLocation()
		elseif(mainResult == "Delete")then
			GpsLocHandler.eraseLocation()
		elseif(mainResult == "Settings")then
			term.clear()
			term.setTextColor(colors.red)
			term.setBackgroundColor(colors.black)
			term.setCursorPos(1,1)
			term.write("This has not been")
			term.setCursorPos(1,2)
			term.write("implemented yet")
			os.sleep(2)
		end
	else
		if(mouseX >= 15) and (mouseX <= 21) and (mouseY >= 2) and (mouseY <= 9)then
			mainEasterEgg = true
		end
	end
end