local QBCore = exports['qb-core']:GetCoreObject()

RegisterServerEvent("electrojob:addMoney", function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        Player.Functions.AddMoney('cash', amount)
    end
end)

RegisterServerEvent("electrojob:server:payPlayer", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        local amount = math.random(50, 150)
        Player.Functions.AddMoney('cash', amount)
        QBCore.Functions.Notify(src, "You have earned $" .. amount .. " for completing the job!", "success")
    end
end)
