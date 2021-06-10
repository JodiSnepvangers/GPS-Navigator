--shows a editor panel that lets the user input a single line of text, a minimum of 1 character and a maximum of 26
--rules can be be applied, such as a minimum or maximum amount of characters. all rules must be true for the string to be confirmed
--custom rules can be applied by passing a function. the funtion is given the user input string and can output true or false to show if the rule passes or not
--a array of allowed characters can be passed to limit the input. 

editorDefaultRow = 2 -- at which row the editor panel starts. is scrolled down based on the amount of rules

--internal variables:
ruleTable = {} -- contains the rules: at position 1 is the rule string, at position 2 contains bool for last check results ,at position 3 is the function pointing at the rule.
writtenTable = {} -- contains the written word, each position only containing one character

--use this function to initialise editor!
--min character: the minimum amount of characters the result must have. default and limit to 1
--max character: the maximum amount of characters the result must have. default and limit to 26
--characterLimit: can either be provided a table or a number:
	--if provided a table filled with one character strings, only the characters on the list are allowed to be typed
	--if provided with a number, loads one of the default arrays:
		--unknown: allows every character
		--1: only allows numbers and minus sign and period
		--2: only allows numbers and minus sign
		--3: only allows numbers and period
		--4: only allows numbers
		--5: only allows letters
		--6: only allows lowercase letters
--customRules: allows program to provide custom rules which must be met for the result to be confirmed:
	--rules are a table:
		--index 1: string of the rule. displayed to the user at the top of the screen
		--index 2: contains a bool that is the last result of this rule when it was checked
		--index 3: points to the actual function of the rule. this function is passed the string entered, aswell as a table of the string. must return true or false based if the rule passed
function initialiseEditor(startingInput, editorName, minCharacters, maxCharacters, characterLimit, customRules)
	--ensure minimum and maximum bounderies are set:
	minimumLimit = math.max(1, minCharacters)
	maximumLimit = math.min(26, maxCharacters)
	
	--take starting string and prepare it for entry:
	startingInput = tostring(startingInput)
	writtenTable = {}
	for charIndex=1,string.len(startingInput) do
		writeLetter(string.sub(startingInput, charIndex, charIndex))
	end
	--append own rules to it:
	finalRules = {}
	finalRules[1] = {}
	finalRules[1][1] = "Minimum of " .. tostring(minimumLimit) .. " characters"
	finalRules[1][2] = false
	finalRules[1][3] = ruleMinimumCharacters
	finalRules[2] = {}
	finalRules[2][1] = "Maximum of " .. tostring(maximumLimit) .. " characters"
	finalRules[2][2] = false
	finalRules[2][3] = ruleMaximumCharacters
	
	--add number rule if numbers are only allowed character:
	if(characterLimit >= 1) and (characterLimit <= 4) then
		finalRules[3] = {}
		finalRules[3][1] = "Must be a number"
		finalRules[3][2] = false
		finalRules[3][3] = ruleForceNumber
	end
	
	--check if characterLimit is set correctly:
	if(type(characterLimit) ~= "table")then
		if(characterLimit == 1)then
			characterLimit = {"1","2","3","4","5","6","7","8","9","0","-","."}
		elseif(characterLimit == 2)then
			characterLimit = {"1","2","3","4","5","6","7","8","9","0","-"}
		elseif(characterLimit == 3)then
			characterLimit = {"1","2","3","4","5","6","7","8","9","0","."}
		elseif(characterLimit == 4)then
			characterLimit = {"1","2","3","4","5","6","7","8","9","0"}
		elseif(characterLimit == 5)then
			characterLimit = {"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"}
		elseif(characterLimit == 6)then
			characterLimit = {"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"}
		else
			characterLimit = nil
		end
	end
	
	--check if functions are correct, and throw out bad ones:
	if((customRules ~= nil) or (customRules ~= {}) and (type(customRules) == "table"))then
		--check rules:
		for ruleIndex=1,#customRules do
			if(type(customRules[ruleIndex][2]) ~= "function")then
				--table.remove(customRules, ruleIndex)
			end
		end
	else
		customRules = {}
	end
	
	--append own rules to it:
	for ruleIndex=1,#customRules do
		table.insert(finalRules, customRules[ruleIndex])
	end
	
	--save rule list:
	ruleTable = finalRules
	
	--everything is checked. start editor:
	return displayEditor(characterLimit, editorName)
end

function displayEditor(allowedKeysTable, editorName)
	--starts displaying the editor and handles key and mouse inputs!
	running = true
	while running do	
		--drawScreen:
		screenDraw(editorName)
		event, button, mouseX, mouseY = os.pullEvent()
		--handle events:
		if(event == "char") and (#writtenTable < 26)then
			allowed = true
			if(allowedKeysTable ~= nil)then
				allowed = false
				for key=1,#allowedKeysTable do
					if(button == allowedKeysTable[key])then
						allowed = true
						break
					end
				end
			end
			
			--check performed. write letter
			if(allowed)then
				writeLetter(button)
			end
			
		--handle the backspace!
		elseif(event == "key")then
			if(button == 14) and (#writtenTable > 0)then
				eraseLetter()
			elseif(button == 28)then
				--
				-- this checks one last time before confirming
				--
				allRulePassed = checkRules()
				if(allRulePassed)then
					return getString()
				end
				--
				--
				--
			end
			
			
		--handle mouse input
		elseif(event == "mouse_click") and (button == 1)then
			if(mouseY == 20)then
				if(mouseX <= 6)then
					return nil
				elseif(mouseX >= 20)then
					--
					-- this checks one last time before confirming
					--
					allRulePassed = checkRules()
					if(allRulePassed)then
						return getString()
					end
					--
					--
					--
				end
			end
		end
	end
end

function writeLetter(letter)
	if(#writtenTable < 26)then
		table.insert(writtenTable, letter)
	end
end

function eraseLetter()
	table.remove(writtenTable, #writtenTable)
end

function screenDraw(editorName)
	--reset terminal:
	term.clear()
	term.setCursorPos(1,1)
	term.setTextColor(colors.white)
	term.setBackgroundColor(colors.black)
	
	--check rules:
	allRulePassed = checkRules()
	
	--write rules to the screen:
	ruleHeight = 2
	for ruleIndex=1,#ruleTable do
		currentRule = ruleTable[ruleIndex]
		 --set text color:
		 if(currentRule[2])then
			--rule was true last check
			term.setTextColor(colors.green)
		else
			--rule was false last check
			term.setTextColor(colors.red)
		end
		
		--write rule text to screen:
		term.setCursorPos(1, ruleHeight)
		term.write(currentRule[1])
	
		--increment height:
		ruleHeight = ruleHeight + 1
	end
	

	
	--write written word to screen:
	term.setCursorPos(1,editorDefaultRow + ruleHeight)
	term.setTextColor(colors.white)
	term.setBackgroundColor(colors.gray)
	term.write("                          ")
	
	term.setBackgroundColor(colors.gray)
	term.setCursorPos(1,editorDefaultRow + ruleHeight)
	term.write(getString())
	term.setBackgroundColor(colors.lightGray)
	term.write(" ")
	
	--write buttons to the screen:
	term.setBackgroundColor(colors.gray)
	term.setTextColor(colors.white)
	term.setCursorPos(1,20)
	term.write("Cancel")
	
	--select color:
	if(allRulePassed == false)then
		term.setBackgroundColor(colors.black)
		term.setTextColor(colors.red)
	end
	term.setCursorPos(20,20)
	term.write("Confirm")
	
	
	
	
	--reset terminal colors
	term.setTextColor(colors.white)
	term.setBackgroundColor(colors.black)
	
	if(editorName ~= nil)then
		--write editor name:
		term.setCursorPos(1,1)
		term.write("Editing: " .. editorName)
	end
end

function checkRules()
	--will run though and check all rules. returns a global boolean that will return false if any of the rules returns false.
	writtenWord = getString()
	allRulePassed = true
	for ruleIndex=1,#ruleTable do
		currentRule = ruleTable[ruleIndex]
		currentRule[2] = currentRule[3](writtenWord, writtenTable)
		allRulePassed = allRulePassed and currentRule[2]
	end
	return allRulePassed
end

function getString()
	--returns the complete string currently in writing
	writtenText = ""
	for textIndex=1,#writtenTable do
		writtenText = writtenText .. writtenTable[textIndex]
	end
	return writtenText
end







--some default rules provided:
--true means the rule passed

--will limit the number of characters to a minimum of [minimumLimit]
minimumLimit = 1
function ruleMinimumCharacters(writtenWord, stringTable)
	return (#stringTable >= minimumLimit)
end

--will limit the number of characters to a maximum of [maximumLimit]
maximumLimit = 26
function ruleMaximumCharacters(writtenWord, stringTable)
	return (#stringTable <= maximumLimit)
end

--ensures the only input possible is correct number
function ruleForceNumber(writtenWord, stringTable)
	return (tonumber(writtenWord) ~= nil)
end