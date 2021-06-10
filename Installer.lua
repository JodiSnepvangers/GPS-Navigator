installer = {}
installer[1] = {"SSgH98Lg", "GpsData.lua", 1.0}
installer[2] = {"QkWzFTJ8", "GpsDisplay.lua", 1.0}
installer[3] = {"M9FgaBDY", "GpsEditor.lua", 1.0}
installer[4] = {"MMCX6ttP", "GpsList.lua", 1.0}
installer[5] = {"RBbAtaGx", "GpsLocHandler.lua", 1.0}
installer[6] = {"EaDj4Phf", "Navigator.lua", 1.0}

for i=1,#installer do
	fileName = installer[i][2]
	if not fs.exists(fileName) then
		shell.run("pastebin","get",installer[i][1],installer[i][2])
		print("installing: " .. installer[i][2] .. " ver: " .. installer[i][3])
	else
		print(installer[i][2] .. " already installed!")
	end
end