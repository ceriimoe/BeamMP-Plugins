-- Bouncer v1 by cerii.moe
-- simple whitelist script for BeamMP

-- Settings
local DoNotKick = false -- When true, instead of kicking unwhitelisted players, Bouncer will not allow them to spawn vehicles.
local Admins = {"ceriimoe"} -- Add a list of admins here who can use chat commands.

function Initialise()
    if FS.Exists("whitelist/players") == false then
        print("(BOUNCER) Creating directory since it doesn't exist...")
        FS.CreateDirectory("whitelist/players")
    end
    print("Bouncer by cerii.moe loaded...")
end

function CheckWhitelistKick(plrID) --checked on player joining, only done if DoNotKick is set to false
    for _,name in pairs(Admins) do
        if string.lower(name) == string.lower(MP.GetPlayerName(plrID)) then --this is absolutely hideous but it does the job
            return --let them join as usual
        end
    end

    if DoNotKick == false then

        print(FS.ListDirectories("whitelist/players"))

        if FS.ListDirectories("whitelist/players") == nil then
            MP.DropPlayer(plrID,"(Kicked by Bouncer) There are no names in the whitelist, please contact the server administrator!")
        else
            for _,name in pairs(FS.ListDirectories("whitelist/players")) do
                if string.lower(name) == string.lower(MP.GetPlayerName(plrID)) then --this is absolutely hideous but it does the job
                    return --let them join as usual
                end
            end

            MP.DropPlayer(plrID,"(Kicked by Bouncer) You are not whitelisted to join this server!")
        end

    end
end

function CheckWhitelistVehicle(plrID,vehID,data) --checked on player spawning a vehicle, only done if DoNotKick is set to true
    if DoNotKick == true then

        for _,name in pairs(Admins) do
            if string.lower(name) == string.lower(MP.GetPlayerName(plrID)) then --this is absolutely hideous but it does the job
                return --let them spawn as usual
            end
        end

        if FS.ListDirectories("whitelist/players") == nil then
            MP.SendChatMessage(plrID,"(Bouncer) There are no names in the whitelist!")
            return 1 --cancels the spawn
        else
            for _,name in pairs(FS.ListDirectories("whitelist/players")) do

                if string.lower(name) == string.lower(MP.GetPlayerName(plrID)) then --this is absolutely hideous but it does the job
                    return --let them spawn as usual
                end
            end

            MP.SendChatMessage(plrID,"(Bouncer) You cannot spawn cars on this server!")
            return 1 --cancels the spawn
        end

    end
end

function AddToWhitelist(plrID,name,msg) --!addwl, checked on chat message being sent, only possible by admins
    if msg == "!addwl" or msg == "!addwl " then
        MP.SendChatMessage(plrID,"(Bouncer) !addwl (name) - Add a player to the whitelist.")
        return 1
    else
        for _,tname in pairs(Admins) do
            if tname == name then
                if string.sub(msg, 1, 7) == "!addwl " then
                    local ToAdd = string.sub(msg, 8, -1)

                    local error, errmsg = FS.CreateDirectory("whitelist/players/"..ToAdd)
                    
                    if error == false then
                        MP.SendChatMessage(plrID,"(Bouncer) Unable to add "..ToAdd.." to the whitelist - "..errmsg)
                        return 1
                    else
                        MP.SendChatMessage(plrID,"(Bouncer) Added "..ToAdd.." to the whitelist.")
                        return 1
                    end
                end
            end
        end
    end
end

function RemoveFromWhitelist(plrID,name,msg) --!removewl, checked on chat message being sent, only possible by admins
    if msg == "!removewl" or msg == "!removewl " then
        MP.SendChatMessage(plrID,"(Bouncer) !removewl (name) - Remove a player from the whitelist.")
        return 1
    else
        for _,tname in pairs(Admins) do
            if string.lower(tname) == string.lower(name) then
                if string.sub(msg, 1, 10) == "!removewl " then
                    local ToAdd = string.sub(msg, 11, -1)

                    local error, errmsg = FS.Remove("whitelist/players/"..ToAdd)

                    if error == false then
                        MP.SendChatMessage(plrID,"(Bouncer) Unable to remove "..ToAdd.." from the whitelist - "..errmsg)
                        return 1
                    else
                        MP.SendChatMessage(plrID,"(Bouncer) Removed "..ToAdd.." from the whitelist.")

                        if DoNotKick == true then
                            for index,tname2 in pairs(MP.GetPlayers()) do
                                if string.lower(tname2) == string.lower(ToAdd) then
                                    for index2,data in pairs(MP.GetPlayerVehicles(index)) do
                                        MP.RemoveVehicle(index,index2)
                                        MP.SendChatMessage(plrID,"(Bouncer) You cannot spawn cars on this server!")
                                    end
                                end
                            end
                        elseif DoNotKick == false then
                            for index,tname2 in pairs(MP.GetPlayers()) do
                                if string.lower(tname2) == string.lower(ToAdd) then
                                    MP.DropPlayer(index,"(Kicked by Bouncer) You have been removed from the whitelist!")
                                end
                            end
                        end
                        
                        return 1
                    end

                end
            else
                return
            end
        end
    end
end

MP.RegisterEvent("onInit","Initialise")
MP.RegisterEvent("onPlayerJoin", "CheckWhitelistKick")
MP.RegisterEvent("onVehicleSpawn", "CheckWhitelistVehicle")
MP.RegisterEvent("onChatMessage", "AddToWhitelist")
MP.RegisterEvent("onChatMessage", "RemoveFromWhitelist")