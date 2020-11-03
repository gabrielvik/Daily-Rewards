DailyRewards.VGUI = DailyRewards.VGUI or {}

surface.CreateFont( "Rajdhani-Smaller", {
	font = "Rajdhani Regular",
	size = 32,
})

surface.CreateFont( "Rajdhani-Regular", {
	font = "Rajdhani Regular",
	size = 48,
})

surface.CreateFont( "Rajdhani-Bigger", {
	font = "Rajdhani SemiBold",
	size = 64,
})

surface.CreateFont( "Rajdhani-Huge", {
	font = "Rajdhani Bold",
	size = 128,
})

function DailyRewards.VGUI.OpenClaimMenu(data, isMilestone)
    DailyRewards.VGUI.ClaimMenu = {}
    DailyRewards.VGUI.ClaimMenu.MainFrame = vgui.Create("DFrame")
    DailyRewards.VGUI.ClaimMenu.MainFrame:SetSize(ScrW(), ScrH())
    DailyRewards.VGUI.ClaimMenu.MainFrame:MakePopup()
    DailyRewards.VGUI.ClaimMenu.MainFrame:SetDraggable(false)
    DailyRewards.VGUI.ClaimMenu.MainFrame:SetTitle("")
    DailyRewards.VGUI.ClaimMenu.MainFrame:ShowCloseButton(false)

    DailyRewards.VGUI.CloseButton = vgui.Create("DButton", DailyRewards.VGUI.ClaimMenu.MainFrame)
    DailyRewards.VGUI.CloseButton:SetSize(100, 40)
    DailyRewards.VGUI.CloseButton:SetPos(DailyRewards.VGUI.ClaimMenu.MainFrame:GetWide() - DailyRewards.VGUI.CloseButton:GetWide() - 5, 5)
    DailyRewards.VGUI.CloseButton:SetText("")


    DailyRewards.VGUI.CloseButton.Paint = function(self, w, h)
        surface.SetDrawColor(0, 0, 0, 155)
        surface.DrawRect(0, 0, w, h)
        draw.SimpleText("CLOSE X", "Rajdhani-Smaller", DailyRewards.VGUI.CloseButton:GetWide() / 2, DailyRewards.VGUI.CloseButton:GetTall() / 2, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    DailyRewards.VGUI.CloseButton.DoClick = function()
        DailyRewards.VGUI.ClaimMenu.MainFrame:Close()
    end

    local blur = Material("pp/blurscreen")
    DailyRewards.VGUI.ClaimMenu.MainFrame.Paint = function(self, w, h)
        surface.SetDrawColor(0, 0, 0, 130)
        surface.DrawRect(0, 0, w, h)

        surface.SetMaterial(blur)
        for i = 1, 5 do
            surface.SetDrawColor(0, 0, 0)

            blur:SetFloat('$blur', (i / 5) * 5)
            blur:Recompute()

            render.UpdateScreenEffectTexture()

            render.SetScissorRect(1, 0, (w + 1), (h + 1), true)
            surface.DrawTexturedRect(-1, -1 , w, h)
            render.SetScissorRect(0, 0, 0, 0, false)
        end
        if !isMilestone then
            draw.SimpleText("Daily Rewards", "Rajdhani-Huge", ScrW() / 2 , ScrH() / 8, Color(0, 0, 0, 155), TEXT_ALIGN_CENTER)
        else
            draw.SimpleText("MILESTONE REACHED", "Rajdhani-Huge", ScrW() / 2 , ScrH() / 8, Color(255, 190, 118, 100), TEXT_ALIGN_CENTER)
        end
        if !isMilestone then
            draw.SimpleText(LocalPlayer():GetNWInt("DailyRewards.ClaimedAmount", 0) .. "/" .. 25 .. " until milestone", "Rajdhani-Smaller", ScrW() / 2 , ScrH() / 3.5, Color(0, 0, 0, 155), TEXT_ALIGN_CENTER)
        end
        if isnumber(data) then
            draw.SimpleText("You can claim at " .. os.date("%c", data), "Rajdhani-Bigger", ScrW() / 2, ScrH() / 2, Color(0, 0, 0, 155), TEXT_ALIGN_CENTER)
        end
    end

    DailyRewards.VGUI.ClaimMenu.MilestoneStatus = vgui.Create("DPanel", DailyRewards.VGUI.ClaimMenu.MainFrame)
    DailyRewards.VGUI.ClaimMenu.MilestoneStatus:SetSize((32 * 25) + 10 * 32, 50)
    DailyRewards.VGUI.ClaimMenu.MilestoneStatus:SetPos(ScrW() / 2 - DailyRewards.VGUI.ClaimMenu.MilestoneStatus:GetWide() / 2, ScrH() / 3)

    local incomplete = Material("materials/daily_rewards/incomplete.png")
    local complete = Material("materials/daily_rewards/complete.png")
    local glow_complete = Material("materials/daily_rewards/glow_complete.png")
    local anim = 255
    start = SysTime()
    local breathing = true

    DailyRewards.VGUI.ClaimMenu.MilestoneStatus.Paint = function(self, w, h)
        if isMilestone then
            surface.SetDrawColor(Color(255, 190, 118, 100))
        else
            surface.SetDrawColor(Color(25,25,25, 155))
        end
        surface.DrawRect(0, 32 / 2, w, 2)
        local w = 10 * 4

        if anim >= 255 then
            breathing = true
        elseif anim <= 175  then
            breathing = false
        end
        if breathing == true then
            anim = anim - 0.1
        else
            anim = anim + 0.1
        end

        for i = 1, 25 do
            if !isMilestone then
                if i != tonumber(LocalPlayer():GetNWInt("DailyRewards.ClaimedAmount", 0)) then
                    surface.SetDrawColor(25, 25, 25, anim)
                else
                    surface.SetDrawColor(255, 255, 255, anim - 145)
                end
            else
                surface.SetDrawColor(255, 190, 118, 100, anim - 100)
            end

            if tonumber(LocalPlayer():GetNWInt("DailyRewards.ClaimedAmount", 0)) >= i then
                surface.SetMaterial(complete)
            else
                surface.SetMaterial(incomplete)
            end
            surface.DrawTexturedRect(w, 0, 32, 32)

            w = w + 32 + 10
        end
    end
    if istable(data) then
        local margin = 10
        local w = DailyRewards.VGUI.ClaimMenu.MilestoneStatus:GetPos() - margin
        local gradient = Material("materials/daily_rewards/radial_gradient.png")
        local rewardTbl = DailyRewards.Config.Rewards
        if isMilestone then
            rewardTbl = DailyRewards.Config.MilestoneRewards
        end
        for i = 1, #data do
            DailyRewards.VGUI.ClaimMenu.Item = vgui.Create("DPanel", DailyRewards.VGUI.ClaimMenu.MainFrame)
            DailyRewards.VGUI.ClaimMenu.Item:SetSize(DailyRewards.VGUI.ClaimMenu.MilestoneStatus:GetWide() / #data,DailyRewards.VGUI.ClaimMenu.MilestoneStatus:GetWide() / #data)
            DailyRewards.VGUI.ClaimMenu.Item:SetPos(w, ScrH() / #data + DailyRewards.VGUI.ClaimMenu.MilestoneStatus:GetTall() + margin)
            local reward = DailyRewards.Config.RewardTypes[data[1][2].type]
            local color = DailyRewards.Config.Rarities[data[i][1]].color
            local icon = Material("materials/daily_rewards/" .. reward.icon .. ".png")
            local text = reward.format(rewardTbl[data[i][1]][1].args[1])
            local display = reward.display

            DailyRewards.VGUI.ClaimMenu.Item.Paint = function(self, w, h)
                surface.SetDrawColor(0, 0, 0, 155)
                surface.DrawRect(0, 0, w, h)

                surface.SetDrawColor(color)
                surface.DrawOutlinedRect(0, 0, w, h, 2)


                surface.SetMaterial(gradient)
                surface.DrawTexturedRect(0, 0, w, h)

                surface.SetDrawColor(255,255,255, 155)
                surface.SetMaterial(icon)
                surface.DrawTexturedRect(DailyRewards.VGUI.ClaimMenu.Item:GetWide() / 2 - 128 / 2, DailyRewards.VGUI.ClaimMenu.Item:GetTall() / 2 - 128, 128, 128)

                draw.SimpleText(text, "Rajdhani-Regular", DailyRewards.VGUI.ClaimMenu.Item:GetWide() / 2, DailyRewards.VGUI.ClaimMenu.Item:GetTall() / 1.5, Color(255,255,255,255), TEXT_ALIGN_CENTER)
            end

            DailyRewards.VGUI.ClaimMenu.Claim = vgui.Create("DButton", DailyRewards.VGUI.ClaimMenu.Item)
            DailyRewards.VGUI.ClaimMenu.Claim:SetSize(DailyRewards.VGUI.ClaimMenu.Item:GetWide() - 4, 50)
            DailyRewards.VGUI.ClaimMenu.Claim:SetPos(2, DailyRewards.VGUI.ClaimMenu.Item:GetTall() - DailyRewards.VGUI.ClaimMenu.Claim:GetTall())
            DailyRewards.VGUI.ClaimMenu.Claim:SetText("Claim")
            DailyRewards.VGUI.ClaimMenu.Claim:SetFont("Rajdhani-Regular")

            DailyRewards.VGUI.ClaimMenu.Claim.Paint = function(self, w, h)
                surface.SetDrawColor(0, 0, 0, 155)
                surface.DrawRect(0, 0, w, h)
            end
            DailyRewards.VGUI.ClaimMenu.Claim.DoClick = function()
                net.Start("DailyRewards.SendClaimMenu")
                net.WriteInt(i, 3)
                net.SendToServer()

                data = 0
            end

            w = w + DailyRewards.VGUI.ClaimMenu.Item:GetWide() + margin
        end
    end
end

net.Receive("DailyRewards.SendClaimMenu", function()
    local b1 = net.ReadBool()
    local b2 = net.ReadBool()

    if b1 then
        DailyRewards.VGUI.OpenClaimMenu(net.ReadTable(), b2)
    else
        DailyRewards.VGUI.OpenClaimMenu(tonumber(net.ReadString()))
    end
end)

net.Receive("DailyRewards.Success", function()
    if IsValid(DailyRewards.VGUI.ClaimMenu.MainFrame) then
        DailyRewards.VGUI.ClaimMenu.MainFrame:Close()
    end
    DailyRewards.VGUI.OpenClaimMenu(tonumber(net.ReadString()))
end)

net.Receive("DailyRewards.NotifyAdminSuccess",  function()
  local yes = net.ReadBool()

  if yes == true then
    chat.AddText(Color(0, 255, 0), "You wiped " .. net.ReadString() .. "'s rewards")
  else
    chat.AddText(Color(255, 0, 0), "Could not find the player")
  end
end)
