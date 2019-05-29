local VaultDoor
local CodeEnteredCorrect = false; PlayerList =  {}
local Terminal = {['x'] = 253.3081, ['y'] = 228.4226, ['z'] = 101.6833}

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		VaultDoor = GetClosestObjectOfType(Terminal.x, Terminal.y, Terminal.z, 25.0, GetHashKey('V_ILEV_BK_VAULTDOOR'), 0, 0, 0)
		if Vdist(GetEntityCoords(PlayerPedId(), true), Terminal.x, Terminal.y, Terminal.z) <= 0.5 then
			if VaultDoor ~= nil and VaultDoor ~= 0 then
				FreezeEntityPosition(VaultDoor, true)
				if not CodeEnteredCorrect and CodeNeeded then
					DisplayHelpText('Press ~INPUT_CONTEXT~ to begin hacking')
					if GetIsControlJustReleased(51) and (UpdateOnscreenKeyboard() ~= 0)then
							TriggerEvent("mhacking:show") --This line is where the hacking even starts
							TriggerEvent("mhacking:start",3,19,mycb) --This line is the difficulty and tells it to start. First number is how long the blocks will be the second is how much time they have is.
						--local EnteredCode = KeyboardInput('Enter the Code', '', Code:len() + 10, false)
						if EnteredCode then
							if EnteredCode:lower() == Code:lower() then
								drawNotification('~g~The entered Code is correct!')
								CodeEnteredCorrect = true
							else
								drawNotification('~r~The entered Code is not correct!')
								CodeEnteredCorrect = false
							end
						end
					end
					function mycb(success, timeremaining)
					if success then
						print('Success with '..timeremaining..'s remaining.')
						CodeEnteredCorrect = true --this is what allows the vault to be opened
						TriggerEvent('mhacking:hide')
					else
						print('Failure')
						TriggerEvent('mhacking:hide')
						end
					end	
				elseif CodeEnteredCorrect or not CodeNeeded then
					GetPlayerList()
					local CurrentHeading = GetEntityHeading(VaultDoor)
					if (round(CurrentHeading, 1) == 158.7) then
						CurrentHeading = CurrentHeading - 0.1
					end
					if (round(CurrentHeading, 1) > 0.0) and (round(CurrentHeading, 1) < 160.0) then
						DisplayHelpText('Hold ~INPUT_CELLPHONE_LEFT~ to Open the Vault~n~Hold ~INPUT_CELLPHONE_RIGHT~ to Close the Vault')
					elseif (round(CurrentHeading, 1) == 0.0) then
						DisplayHelpText('Hold ~INPUT_CELLPHONE_RIGHT~ to Close the Vault')
					elseif (round(CurrentHeading, 1) == 160.0) then
						DisplayHelpText('Hold ~INPUT_CELLPHONE_LEFT~ to Open the Vault')
					end
					while GetIsControlPressed(174) and (round(CurrentHeading, 1) > 0.0) and (UpdateOnscreenKeyboard() ~= 0) do -- Open
						Citizen.Wait(0)
						for k, i in ipairs(PlayerList) do
							if i ~= PlayerId() then
								if Vdist(GetEntityCoords(GetPlayerPed(i), true), Terminal.x, Terminal.y, Terminal.z) <= 20.0 then
									TriggerServerEvent('VaultDoorSystem:MoveDoorServer', GetPlayerServerId(i), round(CurrentHeading, 1) - Speed)
									CurrentHeading = GetEntityHeading(VaultDoor)
									if not (round(CurrentHeading, 1) > 0.0) then
										TriggerServerEvent('VaultDoorSystem:MoveDoorServer', GetPlayerServerId(i), 0.0)
									end
								end
							end
						end
						CurrentHeading = GetEntityHeading(VaultDoor)
						SetEntityHeading(VaultDoor, round(CurrentHeading, 1) - Speed)
						if not (round(CurrentHeading, 1) > 0.0) then
							SetEntityHeading(VaultDoor, 0.0)
						end
					end
					while GetIsControlPressed(175) and (round(CurrentHeading, 1) < 160.0) and (UpdateOnscreenKeyboard() ~= 0) do -- Close
						Citizen.Wait(0)
						for k, i in ipairs(PlayerList) do
							if i ~= PlayerId() then
								if Vdist(GetEntityCoords(GetPlayerPed(i), true), Terminal.x, Terminal.y, Terminal.z) <= 20.0 then
									TriggerServerEvent('VaultDoorSystem:MoveDoorServer', GetPlayerServerId(i), round(CurrentHeading, 1) + Speed)
									CurrentHeading = GetEntityHeading(VaultDoor)
									if not (round(CurrentHeading, 1) < 160.0) then
										TriggerServerEvent('VaultDoorSystem:MoveDoorServer', GetPlayerServerId(i), 160.0)
									end
								end
							end
						end
						CurrentHeading = GetEntityHeading(VaultDoor)
						SetEntityHeading(VaultDoor, round(CurrentHeading, 1) + Speed)
						if not (round(CurrentHeading, 1) < 160.0) then
							SetEntityHeading(VaultDoor, 160.0)
						end
					end
				end
			else
				DisplayHelpText('~r~ERROR!~n~Technical problem with the Vault Door!')
			end
		else
			CodeEnteredCorrect = false
		end
	end
end)

RegisterNetEvent('VaultDoorSystem:MoveDoorClient')
AddEventHandler('VaultDoorSystem:MoveDoorClient', function(Heading)
	if VaultDoor ~= nil and VaultDoor ~= 0 then
		SetEntityHeading(VaultDoor, Heading)
	end
end)

function GetPlayerList()
	PlayerList = {}
	
	for i = 0, MaxPlayer - 1 do
		if NetworkIsPlayerConnected(i) and NetworkIsPlayerActive(i) then
			table.insert(PlayerList, i)
		end
	end
end

function DisplayHelpText(Text)
	BeginTextCommandDisplayHelp('STRING')
	AddTextComponentSubstringPlayerName(Text)
	EndTextCommandDisplayHelp(0, 0, 1, -1)
end

function drawNotification(text)
	SetNotificationTextEntry('STRING')
	AddTextComponentSubstringPlayerName(text)
	DrawNotification(false, true)
end

function round(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
end

function GetIsControlJustReleased(Control)
	if IsControlJustReleased(1, Control) or IsDisabledControlJustReleased(1, Control) then
		return true
	end
	return false
end

function GetIsControlPressed(Control)
	if IsControlPressed(1, Control) or IsDisabledControlPressed(1, Control) then
		return true
	end
	return false
end

function KeyboardInput(TextEntry, ExampleText, MaxStringLenght, NoSpaces)
	AddTextEntry(GetCurrentResourceName() .. '_KeyboardHead', TextEntry)
	DisplayOnscreenKeyboard(1, GetCurrentResourceName() .. '_KeyboardHead', '', ExampleText, '', '', '', MaxStringLenght)
	blockinput = true

	while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
		if NoSpaces == true then
			drawNotification('~y~NO SPACES!')
		end
		Citizen.Wait(0)
	end
	
	if UpdateOnscreenKeyboard() ~= 2 then
		local result = GetOnscreenKeyboardResult()
		Citizen.Wait(500)
		blockinput = false
		return result
	else
		Citizen.Wait(500)
		blockinput = false
		return nil
	end
end

function Draw(text, r, g, b, alpha, x, y, width, height, layer, center, font)
	SetTextColour(r, g, b, alpha)
	SetTextFont(font)
	SetTextScale(width, height)
	SetTextWrap(0.0, 1.0)
	SetTextCentre(center)
	SetTextDropshadow(0, 0, 0, 0, 0)
	SetTextEdge(1, 0, 0, 0, 205)
	SetTextEntry('STRING')
	AddTextComponentSubstringPlayerName(text)
	Set_2dLayer(layer)
	DrawText(x, y)
end

