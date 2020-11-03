DailyRewards = DailyRewards or {}
DailyRewards.Config = DailyRewards.Config or {}

-- How often will the player be able to claim reward (in seconds)
DailyRewards.Config.ClaimTime = 86400
-- Chat commands to open the reward menu
DailyRewards.Config.ChatCommands = {"!dailyrewards", "/dailyrewards"}
DailyRewards.Config.AdminCommand = "!resetrewards"

--[[
    Rarities with chance for it to be chosen
    Rarity is 0.00-1.00
    The most common has to be a 1
    That will say if the number generated is 0.05 and the lowest rarity is 0.1 it will be chosen
--]]
DailyRewards.Config.Rarities = {
    ["common"] = {
        rarity = 1,
        color = Color(52, 152, 219, 200)
    },
    ["rare"] = {
        rarity = 0.2,
        color = Color(243, 156, 18, 200)
    },
    ["legendary"] = {
        rarity = 0.1,
        color = Color(241, 196, 15, 200)
    },
}

--[[
    Func value is what to be called if choosen
    Icon is the picture that will be displayed on the client
    Display is whats before.. Example: display is "Case:" it will display - Case: Common case
]]
DailyRewards.Config.RewardTypes = {
    ["money"] = {
        func = function(ply, args)
            ply:addMoney(args[1])
        end,
        icon = "money_icon",
        format = function(arg)
          return DarkRP.formatMoney(arg)
        end
    },

}
--[[
    Type is the rewardtype to be called
    Args the arguments that the reward type the function will call
]]
DailyRewards.Config.Rewards = {
    ["common"] = {
        {type = "money", args = {5}},
    },
    ["rare"] = {
        {type = "money", args = {5000}}
    },
    ["legendary"] = {
        {type = "money", args = {50000}}
    },
}
--[[
    Same as previous but these rewards are for milestones
]]
DailyRewards.Config.MilestoneRewards = {
    ["common"] = {
        {type = "money", args = {5000000}}
    },
    ["rare"] = {
        {type = "money", args = {5000000000}}
    },
    ["legendary"] = {
        {type = "money", args = {50000000000}}
    },
}
