local ply = FindMetaTable("Player")
util.AddNetworkString("DailyRewards.SendClaimMenu")
util.AddNetworkString("DailyRewards.Success")

function ply:GenerateRandomRewards(isMilestone)
    local finishedTbl = {}
    for i = 1, 3 do -- 3 rewards
        local random = math.random() -- Number between 0-1
        local rarity = ""
        for k, v in SortedPairsByMemberValue(DailyRewards.Config.Rarities, "rarity") do
            if(random <= v.rarity) then -- If rarity chance is above the number
                rarity = k  -- choose the rarity
                break
            end
        end
        local rewardTable = DailyRewards.Config.Rewards -- Reward table is normal rewards by defualt
        if isMilestone then
            rewardTable = DailyRewards.Config.MilestoneRewards -- If is claiming milestone then change the table
        end
        local tbl = table.Random(rewardTable[rarity]) -- Choose a random item frmo the reward table based on the rarity generated
        finishedTbl[i] = {rarity, tbl}
    end
    self:SetPData("DailyRewards.Rewards", util.TableToJSON(finishedTbl)) -- Set the rewards to PData so rewards will stay the same no matter what
end

function ply:CanClaimReward()
    if self:GetPData("DailyRewards.LastClaimed") == nil then -- User has never claimed reward
        return true
    end
    if self:GetPData("DailyRewards.LastClaimed") + DailyRewards.Config.ClaimTime < os.time() then -- Been more than a day
        return true
    end
    return false
end

function ply:NextClaimTime()
    return self:GetPData("DailyRewards.LastClaimed") + DailyRewards.Config.ClaimTime or os.time()
end

function ply:AttemptClaim()
    self:SetNWInt("DailyRewards.ClaimedAmount", self:GetPData("DailyRewards.ClaimedAmount"))

    if self:GetPData("DailyRewards.Rewards") == nil then
        if tonumber(self:GetPData("DailyRewards.ClaimedAmount")) == 25 then
            self:GenerateRandomRewards(true) -- If player is to receive milestone then write true
        else
            self:GenerateRandomRewards()
        end
    end
    local rewards = util.JSONToTable(self:GetPData("DailyRewards.Rewards")) -- Set the reward table to the pdata

    if not self:CanClaimReward() then
        net.Start("DailyRewards.SendClaimMenu")
        net.WriteBool(false) -- Can't claim the reward (will send the next claim time in a string)
        net.WriteBool(false) -- Can't claim milestone
        net.WriteString(self:NextClaimTime())
        net.Send(self)
        return
    else
        net.Start("DailyRewards.SendClaimMenu")
        net.WriteBool(true) -- Can claim the reward (send the reward table)

        if tonumber(self:GetPData("DailyRewards.ClaimedAmount")) == 25 then
            net.WriteBool(true) -- If milestone is reached write true
        else
            net.WriteBool(false)
        end
        net.WriteTable(rewards)
        net.Send(self)
    end

    net.Receive("DailyRewards.SendClaimMenu", function(len, ply)
        if not ply:CanClaimReward() then return end
        PrintTable(rewards)
        if not rewards then return end -- Means they haven't gone through previous steps
        local rewards = util.JSONToTable(self:GetPData("DailyRewards.Rewards"))[net.ReadInt(3)]
        local args = rewards[2]["args"] -- Args for the reward function
        PrintTable(rewards)
        DailyRewards.Config.RewardTypes[rewards [2]["type"]].func(ply, args) -- Call the reward function

        ply:SetPData("DailyRewards.LastClaimed", os.time()) -- Set last claimed to the current time
        if ply:GetPData("DailyRewards.ClaimedAmount") != nil and tonumber(ply:GetPData("DailyRewards.ClaimedAmount")) < 25 then
            ply:SetPData("DailyRewards.ClaimedAmount", ply:GetPData("DailyRewards.ClaimedAmount") + 1) -- If has claimed rewards before and if claimed amount is below milestone just add 1
        else
            ply:SetPData("DailyRewards.ClaimedAmount", 1) -- If it's nill set the claimed to 1
        end
        ply:RemovePData("DailyRewards.Rewards") -- Remove the rewards so new ones can be generated next reward
        self:SetNWInt("DailyRewards.ClaimedAmount", self:GetPData("DailyRewards.ClaimedAmount")) -- Set claimed amount to nw string for client ui

        net.Start("DailyRewards.Success") -- This will reopen the claim menu with the next time person can claim reawrd
        net.WriteString(self:NextClaimTime()) -- Send the next claim time
        net.Send(self)
    end)
end

hook.Add("PlayerInitialSpawn", "DailyRewards.FirstSpawn", function(ply)
    if ply:CanClaimReward() then -- If the player can claim the reward open the claim menu
        ply:AttemptClaim()
    end
end)

util.AddNetworkString("DailyRewards.NotifyAdminSuccess")
hook.Add("PlayerSay", "DailyRewards.ChatCommand", function(ply, text)
    -- Chat commands for rewards menu
    for k, v in pairs(DailyRewards.Config.ChatCommands) do
        if string.Replace(text, " ", "") == v then
            ply:AttemptClaim()
            return
        end
    end
    -- Admin command to remove and wipe rewards
    if !ply:IsSuperAdmin() then return end
    local textTbl = string.Explode(' ', text)
    local target = nil
    if textTbl[1] == DailyRewards.Config.AdminCommand then
        for k, v in pairs(player.GetAll()) do
          if string.Replace(textTbl[2], ' ', '') == v:Nick() then
            target = v
          end
        end
    end
    if target == nil then
      net.Start("DailyRewards.NotifyAdminSuccess")
      net.WriteBool(false)
      net.Send(ply)
      return
    end

    target:RemovePData("DailyRewards.Rewards")
    target:RemovePData("DailyRewards.LastClaimed")

    net.Start("DailyRewards.NotifyAdminSuccess")
    net.WriteBool(true)
    net.WriteString(target:Nick())
    net.Send(ply)
end)

concommand.Add("asd",function(ply)
  ply:RemovePData("DailyRewards.LastClaimed")
end)
