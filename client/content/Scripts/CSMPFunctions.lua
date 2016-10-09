--TODO: add play solo

EnforceMaxPlayers=false;
SysopConnections={};
IPBannedlist={};

function IncommingConnection(Peer, Replicator)
	for Index,Value in pairs(IPBannedlist) do
		if (Value == Replicator.MachineAddress) then
			Replicator:CloseConnection();
		end
	end
end

function CSServer(Port,Limit)
	assert((type(Port)~="number" or tonumber(Port)~=nil or Port==nil),"CSRun Error: Port must be nil or a number.");
	local NetworkServer=game:GetService("NetworkServer");
	if (Limit) then
		NetworkServer:SetOutgoingKBPSLimit(Limit)
	end
	pcall(NetworkServer.Stop,NetworkServer);
	NetworkServer:Start(Port);
	game:GetService("Players").PlayerAdded:connect(function(Player)
		Player:LoadCharacter();
		Player.Changed:connect(function(Property)
			if (Property=="Character") and (Player.Character~=nil) then
				local Character=Player.Character;
				local Humanoid=Character:FindFirstChild("Humanoid");
				if (Humanoid~=nil) then
					Humanoid.Died:connect(function() delay(5,function() Player:LoadCharacter() end) end)
				end
			end
		end)
	end)
	game:GetService("RunService"):Run();
	pcall(function() game.Close:connect(function() NetworkServer:Stop(); end) end);
	-- ChildAdded is being a retard. Sorry for inefficient code.
	--[[while wait(0.1) do
		print("OMG",#game.NetworkServer:children())
		for Index,Child in pairs(NetworkServer:GetChildren()) do
			if (Child.className == "") then
				IncommingConnection(nil, Child);
			end
		end
	end]]
	NetworkServer.IncommingConnection:connect(IncommingConnection);
end

function CSConnect(UserID,ServerIP,ServerPort,PlayerName,Ticket,Limit)
	pcall(function()
		game:GetService("GuiService").Changed:connect(function()
			pcall(function() game:GetService("GuiService").ShowLegacyPlayerList=true; end);
			pcall(function() game.CoreGui.RobloxGui.PlayerListScript:Remove(); end);
			pcall(function() game.CoreGui.RobloxGui.PlayerListTopRightFrame:Remove(); end);
			pcall(function() game.CoreGui.RobloxGui.BigPlayerListWindowImposter:Remove(); end);
			pcall(function() game.CoreGui.RobloxGui.BigPlayerlist:Remove(); end);
		end);
	end)
	game:GetService("RunService"):Run();
	assert((ServerIP~=nil and ServerPort~=nil),"CSConnect Error: ServerIP and ServerPort must be defined.");
	local function SetMessage(Message) game:SetMessage(Message); end
	local Visit,NetworkClient,PlayerSuccess,Player,ConnectionFailedHook=game:GetService("Visit"),game:GetService("NetworkClient");

	local function GetClassCount(Class,Parent)
		local Objects=Parent:GetChildren();
		local Number=0;
		for Index,Object in pairs(Objects) do
			if (Object.className==Class) then
				Number=Number+1;
			end
			Number=Number+GetClassCount(Class,Object);
		end
		return Number;
	end

	local function RequestCharacter(Replicator)
		local Connection;
		Connection=Player.Changed:connect(function(Property)
			if (Property=="Character") then
				game:ClearMessage();
			end
		end)
		SetMessage("Requesting character...");
		Replicator:RequestCharacter();
		SetMessage("Waiting for character...");
	end

	local function Disconnection(Peer,LostConnection)
		if (LostConnection==true) then
			SetMessage("You have lost connection to the game");
		else
			SetMessage("You have lost connection to the game");
		end
	end

	local function ConnectionAccepted(Peer,Replicator)
		Replicator.Disconnection:connect(Disconnection);
		local RequestingMarker=true;
		game:SetMessageBrickCount();
		local Marker=Replicator:SendMarker();
		Marker.Received:connect(function()
			RequestingMarker=false;
			RequestCharacter(Replicator)
		end)
		while RequestingMarker do
			Workspace:ZoomToExtents();
			wait(0.5);
		end
	end

	local function ConnectionFailed(Peer,Code)
		SetMessage("Failed to connect to the Game. (ID="..Code..")");
	end

	pcall(function() settings().Diagnostics:LegacyScriptMode(); end);
	pcall(function() game:SetRemoteBuildMode(true); end);
	SetMessage("Progress: Connecting to the server ...");
	NetworkClient.ConnectionAccepted:connect(ConnectionAccepted);
	ConnectionFailedHook=NetworkClient.ConnectionFailed:connect(ConnectionFailed);
	NetworkClient.ConnectionRejected:connect(function()
		pcall(function() ConnectionFailedHook:disconnect(); end);
		SetMessage("Failed to connect to the Game. (Connection rejected)");
	end)

	pcall(function() NetworkClient.Ticket=Ticket or ""; end) -- 2008 client has no ticket :O
	if (Limit) then
		NetworkClient:SetOutgoingKBPSLimit(Limit)
	end
	Player=game:GetService("Players"):CreateLocalPlayer(UserID);
	PlayerSuccess=pcall(function() return NetworkClient:Connect(ServerIP,ServerPort) end);

	if (not PlayerSuccess) then
		SetMessage("Failed to connect to the Game. (Invalid IP Address");
		NetworkClient:Disconnect();
	end

	if (not Player) then
		SetMessage("Failed to connect to the Game. (Player not found)");
		NetworkClient:Disconnect();
	end

	Player:SetSuperSafeChat(false);
	Player.CharacterAppearance=0;
	pcall(function() Player.Name=PlayerName or ""; end);
	pcall(function() Visit:SetUploadUrl(""); end);
end

_G.CSServer=CSServer;
_G.CSConnect=CSConnect;
