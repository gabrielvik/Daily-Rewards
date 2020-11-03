if SERVER then
    include( "daily_rewards/config.lua" )
    AddCSLuaFile( "daily_rewards/config.lua" )
    AddCSLuaFile( "daily_rewards/cl_daily_rewards.lua" )
    include( "daily_rewards/sv_daily_rewards.lua" )
else
    include( "daily_rewards/config.lua" )
    include( "daily_rewards/cl_daily_rewards.lua" )
end