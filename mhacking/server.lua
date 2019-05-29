RegisterServerEvent('VaultDoorSystem:MoveDoorServer')
AddEventHandler('VaultDoorSystem:MoveDoorServer', function(Player, Heading)
	TriggerClientEvent('VaultDoorSystem:MoveDoorClient', Player, Heading)
end)

