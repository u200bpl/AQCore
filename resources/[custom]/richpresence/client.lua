Citizen.CreateThread(function()
	while true do
        -- This is the Application ID (Replace this with you own)
		SetDiscordAppId(903971564150722570)

        -- the "large" icon.
		SetDiscordRichPresenceAsset('1024x1024_black')
		SetDiscordRichPresenceAssetText('AquaRP')
       
        -- the "small" icon.
		-- SetDiscordRichPresenceAssetSmall('logo_name')
		--SetDiscordRichPresenceAssetSmallText('This is a lsmall icon with text')

        --[[
			SetDiscordRichPresenceAction(0, "First Button!", "fivem://connect/localhost:30120")
			SetDiscordRichPresenceAction(1, "Second Button!", "fivem://connect/localhost:30120")
        ]]--

        -- It updates every minute just in case.
		Citizen.Wait(60000)
	end
end)