--provides api calls for saving and loading gps location names
fileName = "GPSLocation"
worldNameArray = settings.get("worldNameArray")
if worldNameArray == nil then
	settings.set("worldNameArray", {})
end

--saves location to disk
function locationSave(locName, position)
	--load file
	settings.load(fileName)
	--check if doesnt already exist:
	if(locationExist(locName))then
		--location already exists
		return
	end
	--turn vector into array
	array = {position.x, position.y, position.z}
	--set and save settings
	settings.set(locName, array)
	
	--update world table
	worldNameArray = settings.get("worldNameArray")
	table.insert(worldNameArray, locName)
	settings.set("worldNameArray", worldNameArray)
	settings.save(fileName)
end

--checks if location exists
function locationExist(locName)
	--load file
	settings.load(fileName)
	--retrieve location names, save in array
	worldNameArray = settings.get("worldNameArray")
	--for loop though them.
	for i=1,#worldNameArray do
		if worldNameArray[i] == locName then
			return true
		end
	end
	
	return false
end

function locationList()
	--load file
	settings.load(fileName)
	--retrieve location names, return
	return settings.get("worldNameArray")
end

function locationDelete(locName)
	--load file
	settings.load(fileName)
	--retrieve location names, save in array
	worldNameArray = settings.get("worldNameArray")
	--check if name exists:
	if locationExist(locName) == false then
	--doesnt exist. return
		return
	end
	--delete location
	settings.unset(locName)
	newArray = {}
	for i=1,#worldNameArray do
		string = worldNameArray[i]
		if string == locName then
			table.remove(worldNameArray, i)
		end
	end
	--save settings
	settings.set("worldNameArray", worldNameArray)
	settings.save(fileName)
end

function locationRetrieve(locName)
	--load file
	settings.load(fileName)
	--retrieve location names, save in array
	worldNameArray = settings.get("worldNameArray")
	--check if name exists:
	if locationExist(locName) == false then
	--doesnt exist. return
		return(nil)
	end
	vectorArray = settings.get(locName)
	return(vector.new(vectorArray[1], vectorArray[2], vectorArray[3]))
end