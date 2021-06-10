
--Should be passed a list of options. will return the option chosen or 'nil' if no option was selected

--displays a list of options and returns whatever option is selected on the menu.
--optionTable: the list of options to display.
--sideOption: sets what to show on the empty side bar to the left:
	--0: shows nothing
	--1: shows programmed decals. warning: decals overwrite on screen text
	--2: shows moreInfoTable on the side for extra info.
	--3: places a second row of options on the empty side. warning: 13 character limit
--moreInfoTable: shows extra options for each option on screen. only functional in mode 2
--extraOptions: displays buttons at the top of the screen unaffected by scrolling. can only have 1 or 2 buttons
--listName: displays the name at the top left corner of the screen. useful for showing what the screen is
--showUpperBar: if set to false, does not draw top most bar

scrolling = 0
maxScrolling = 0
maxString = 26

imageData = {}
freeTextData = {} 	

function displayList(optionTable, sideOption, moreInfoTable, extraOptions, listName)
	running = true
	--scrolling = 0
	
	--calculate maximum scrolling bound:
	maxScrolling = #optionTable - 18
	maxString = 26
	if(sideOption == 3)then
		maxScrolling = math.ceil(#optionTable / 2) - 15
		maxString = 13
	end
	--start handling screen:
	while(running) do
		screenDraw(optionTable, sideOption, moreInfoTable, extraOptions, listName)
		event, button, mouseX, mouseY = os.pullEvent()
		if(event == "mouse_click")then
			--check location
			result = buttonCheck(mouseX, mouseY, optionTable, sideOption, extraOptions)
			if(result ~= nil)then
			--if a option has been selected, reset scrolling
				scrolling = 0
			end
			return result, mouseX, mouseY
		elseif(event == "mouse_scroll")then
			--deal with scrolling
			newScrolling = scrolling + button
			
			if(sideOption == 3)then
			--if double display. scroll twice as fast!
				newScrolling = newScrolling + button
			end
			
			--apply scrolling value within bounds
			if(newScrolling >= 0) and (newScrolling <= maxScrolling) then
				scrolling = newScrolling
			end
		end
	end
end

function buttonCheck(mouseX, mouseY, optionTable, sideOption, extraOptions)
	--called when screen is pressed. returns whatever option has been selected, or nil if no option was selected
	if(mouseY == 1)then
		if(extraOptions ~= nil)then
			if(extraOptions[1] ~= nil)then
				if(mouseX <= string.len(extraOptions[1]))then
					return extraOptions[1]
				end
			end
			if(extraOptions[2] ~= nil)then
				minPosX = 27 - string.len(extraOptions[2])
				if(mouseX >= minPosX)then
					return extraOptions[2]
				end
			end
		end
	else
		if(sideOption == 3)then
			--text is parallel. need better way of handling it
			selectedButton = nil
			offset = 0
			buttonRow = nil
			if(mouseX < 13)then
			--first row was clicked
				buttonRow = (((mouseY - 2) * 2) + scrolling) - 1
			else
			--second row was selected
				buttonRow = (((mouseY - 2) * 2) + scrolling)
				offset = 13
			end
			--if selected button is in range of option table
			if(buttonRow <= #optionTable)then
			--check if option is not nil
				if(optionTable[buttonRow] ~= nil)then
					--check string lenght to calculate button lenght
					stringLenght = string.len(optionTable[buttonRow])
					if(mouseX <= (stringLenght  + offset))then
					--button was pressed. select button
						selectedButton = optionTable[buttonRow]
					end
				end
			end
			return(selectedButton)
		else
			selectedButton = nil
			buttonRow = (mouseY - 2) + scrolling
			if(buttonRow <= #optionTable)then
				if(optionTable[buttonRow] ~= nil)then
					--option table is large enough
					stringLenght = string.len(optionTable[buttonRow])
					if(mouseX <= stringLenght)then
						selectedButton = optionTable[buttonRow]
					end
				end
			end
			return(selectedButton)
		end
	end
	return nil
end

function fullReset()
--fully resets this api, erasing all set data from memory
	scrolling = 0
	maxScrolling = 0
	imageData = {}
	freeTextData = {}
	term.clear()
	term.setCursorPos(1,1)
	term.setTextColor(colors.white)
	term.setBackgroundColor(colors.black)
end

function screenDraw(optionTable, sideOption, moreInfoTable, extraOptions, listName)
	--draw options to screen:
	term.clear()
	tableIndex = 1 + scrolling
	for i=3,20 do
		drawHandler(optionTable, sideOption, moreInfoTable, tableIndex, 1, i)
		tableIndex = tableIndex + 1
		if(sideOption == 3)then
			--write next bit of information
			drawHandler(optionTable, sideOption, moreInfoTable, tableIndex, 14, i)
			tableIndex = tableIndex + 1
		end
	end
	term.setBackgroundColor(colors.black)
	
	--draw image if requested:
	if(sideOption == 1)then
		drawIcon()
	end

	--draw upper menu
	term.setBackgroundColor(colors.black)
	term.setTextColor(colors.white)
	
	--handle list name. check if nil:
	--if(listName == nil)then
	--	listName = ""
	--end
	
	--draw line
	if(extraOptions ~= nil) or (listName ~= nil) then
		term.setCursorPos(1,2)
		term.write("--------------------------")
		term.setCursorPos(1,2)
		term.write(listName)
	end
	
	
	term.setBackgroundColor(colors.gray)
	--handle extra options:
	if(extraOptions ~= nil)then
		if(extraOptions[1] ~= nil)then
			term.setCursorPos(1,1)
			term.write(extraOptions[1])
		end
		if(extraOptions[2] ~= nil)then
			term.setCursorPos(27 - string.len(extraOptions[2]),1)
			term.write(extraOptions[2])
		end
	end
	term.setBackgroundColor(colors.black)
	term.setTextColor(colors.white)
	
		--draw free text to the screen:
	for i=1,#freeTextData do
		posX = freeTextData[i][1]
		posY = freeTextData[i][2]
		text = freeTextData[i][3]
		frontPaint = colorTranslation(freeTextData[i][4])
		backPaint = colorTranslation(freeTextData[i][5])
		
		--ensure color data is correct:
		if(frontPaint == nil)then
			frontPaint = colors.white
		end
		if(backPaint == nil)then
			backPaint = colors.black
		end
		
		--write text to screen
		term.setTextColor(frontPaint)
		term.setBackgroundColor(backPaint)
		term.setCursorPos(posX, posY)
		term.write(text)
	end
	
	--reset colors to default
	term.setBackgroundColor(colors.black)
	term.setTextColor(colors.white)
end

function drawHandler(optionTable, sideOption, moreInfoTable, tableIndex, xOffset, yOffset)
	if(tableIndex > #optionTable) then
		--end of table is reached. break out of loop
		return
	end
	menuOption = optionTable[tableIndex]
	moreInfo = ""
	if(moreInfoTable ~= nil)then
		moreInfo = moreInfoTable[tableIndex]
	end
	term.setCursorPos(xOffset, yOffset)
	drawOption(menuOption, sideOption, moreInfo)
end

function drawOption(menuOption, sideOption, moreInfo)
	--first draw option:
	term.setTextColor(colors.white)
	term.setBackgroundColor(colors.gray)
	
	--check if string is within limit:
	if(string.len(tostring(menuOption)) > maxString) then
		error("large string:" .. tostring(menuOption))
	end
	
	--write string
	term.write(tostring(menuOption))
	
	--now deal with what comes after:
	if(sideOption == 0)then
		--0 = do nothing
		--fillEmpty(menuOption)
	elseif(sideOption == 2)then	
		if(moreInfo ~= nil)then
			term.setBackgroundColor(colors.black)
			term.write(": " .. moreInfo)
		end
	end
end
		
function fillEmpty(menuOption)
	for fill=string.len(menuOption),maxString-1 do
		term.write(" ")
	end
end

function drawIcon()
	--draws icon to screen
	for imageIndex=1,#imageData do
		position = {}
		position[1] = imageData[imageIndex][1] --retrieve image X pos
		position[2] = imageData[imageIndex][2] --retrieve image Y pos
		--loop though vertical lines. start at 3 or you read position data
		for drawY=3,#imageData[imageIndex] do
		--for every vectical line, loop though hosizontal line
			for drawX=1,#imageData[imageIndex][drawY] do
				--draw pixel:
				pixelData = colorTranslation(imageData[imageIndex][drawY][drawX])
				if(pixelData == nil)then
					term.setBackgroundColor(colors.black)
					term.setTextColor(colors.red)
				else
					term.setBackgroundColor(pixelData)
					term.setTextColor(pixelData)
				end
				term.setCursorPos((drawX + position[1]) - 1, (drawY + position[2]) - 3)
				term.write("X")
			end
		end
	end
	term.setBackgroundColor(colors.black)
end

function colorTranslation(paint)
	paint = tostring(paint)
	if(paint == "0") then return(1)
	elseif(paint == "1") then return(2)
	elseif(paint == "2") then return(4)
	elseif(paint == "3") then return(8)
	elseif(paint == "4") then return(16)
	elseif(paint == "5") then return(32)
	elseif(paint == "6") then return(64)
	elseif(paint == "7") then return(128)
	elseif(paint == "8") then return(256)
	elseif(paint == "9") then return(512)
	elseif(paint == "a") then return(1024)
	elseif(paint == "b") then return(2048)
	elseif(paint == "c") then return(4096)
	elseif(paint == "d") then return(8192)
	elseif(paint == "e") then return(16384)
	elseif(paint == "f") then return(32768)
	else return(nil)
	end
end

function setImage(image, index)
	imageData[index] = {}
	imageData[index] = image
end

function eraseImage(index)
	table.remove (imageData, index)
end

function clearImage()
	imageData = {}
end

function setFreeText(text, paint, backPaint, index, posX, posY)
	freeTextData[index] = {}
	freeTextData[index][1] = posX
	freeTextData[index][2] = posY
	freeTextData[index][3] = text
	freeTextData[index][4] = paint
	freeTextData[index][5] = backPaint
end

function eraseFreeText(index)
	table.remove (freeTextData, index)
end

function clearFreeText()
	freeTextData = {}
end