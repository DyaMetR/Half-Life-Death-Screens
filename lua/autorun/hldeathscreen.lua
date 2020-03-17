--[[--------------------
HALF-LIFE DEATH SCREENS
    Version 1.2.0
      19/10/19
By DyaMetR
]]----------------------

local NET = "hlds_falldamage";

if SERVER then
  util.AddNetworkString(NET);

  hook.Add("EntityTakeDamage", "hldscn_damage", function(ent, dmginfo)
    if not ent:IsPlayer() then return end
    if not dmginfo:IsFallDamage() or dmginfo:GetDamage() < ent:Health() then return end
    net.Start(NET);
    net.Send(ent);
  end);
end

if CLIENT then
  -- Configuration
  local enabled = CreateClientConVar("hldscn_cl_enabled", 1, true, true);
  local mode = CreateClientConVar("hldscn_cl_mode", 1, true, true);

  -- Variables
  local respawned = true;
  local fallDamage = false;

  -- Paint the screen black if HL2 mode is on and death was by fall damage
  hook.Add("HUDPaint", "hldscn_hl2_fall", function()
    if (enabled:GetInt() == 0) then return end
    if (LocalPlayer():Alive() and not respawned) then fallDamage = false; respawned = true; end
    if (not LocalPlayer():Alive() and mode:GetInt() == 1 and fallDamage) then
      draw.RoundedBox(0, 0, 0, ScrW(), ScrH(), Color(0, 0, 0));
      respawned = false;
    end
  end);

  -- Receive fall damage
  net.Receive(NET, function(len)
    fallDamage = true;
  end);

  -- Calc view
  hook.Add( "CalcView", "hldscn_CalcView", function(ply, pos, angles, fov)
    local view = {}
  	if enabled:GetInt() == 1 then
      view.origin = ply:GetPos() + Vector(0,0,5);
  		if mode:GetInt() == 0 then -- HL1 mode
  			view.angles = Angle(angles.p, angles.y, 90);
  		elseif mode:GetInt() ==  1 then
  			view.angles = Angle(angles.p, angles.y, angles.r);
  		end
      view.fov = fov;

  		if not LocalPlayer():Alive() then
  			if IsValid(LocalPlayer():GetRagdollEntity()) then
  				LocalPlayer():GetRagdollEntity():SetNoDraw(true);
  			end
  			return view;
  		end
  	else
  		return
  	end
  end);

  -- Hide damage indicator
  hook.Add("HUDShouldDraw", "hldscn_HUDhide", function(name)
    if mode:GetInt() == 0 and enabled:GetInt() == 1 then
  		if name == ("CHudDamageIndicator") and not LocalPlayer():Alive() then
  			return false;
  		end
  	end
  end);

  -- Create options menu
  hook.Add( "PopulateToolMenu", "hldscn_menu", function()
    spawnmenu.AddToolMenuOption( "Options", "DyaMetR", "hldscn", "Half-Life Death Screen", "", "", function(panel)
      panel:ClearControls();
    	panel:AddControl( "Label" , { Text = "Half-Life Death Screen Options", Description = ""} );
    	panel:AddControl( "Checkbox", {
    		Label = "Toggle",
    		Command = "hldscn_cl_enabled",
    		}
    	);

      panel:AddControl( "Checkbox", {
    		Label = "Half-Life 2 mode",
    		Command = "hldscn_cl_mode",
    		}
    	);
    end);
  end);
end
