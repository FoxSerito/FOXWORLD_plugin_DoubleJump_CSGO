#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <sdktools_functions>
new bool:g_bAccess[MAXPLAYERS + 1];

public Plugin:myinfo =
{
	name = "[FOXWORLD] Double Jump",
	author = "FoxSerito",
	version = "1.0"
	url = "https://foxw.ru/"
};

public OnPluginStart()
{
	CreateConVar("double_jumps_disable", "0");
}

public OnMapStart()
{
	SetConVarInt(FindConVar("double_jumps_disable"), 0);
	CreateTimer(60.0, anonc_jumps_disabled, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	AddFileToDownloadsTable("particles/ex_myjump.pcf");
	PrecacheGeneric("particles/ex_myjump.pcf",true);
}

public OnClientConnected(client)
{
	g_bAccess[client] = false;
}

public Action:anonc_jumps_disabled(Handle:hn_anonc_jumps_disabled_timer)
{
	if (GetConVarInt(FindConVar("double_jumps_disable")) == 1)
	{
		PrintToChatAll("[\x09FOXWORLD\x01] \x05На текущей карте \x07отключен\x05 двойной прыжок для баланса.");
	}
}

public Action:OnPlayerRunCmd(iClient, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon)
{
	if (IsPlayerAlive(iClient) && GetConVarInt(FindConVar("double_jumps_disable")) != 1)
	{
		static g_fLastButtons[MAXPLAYERS+1], g_fLastFlags[MAXPLAYERS+1], g_iJumps[MAXPLAYERS+1], fCurFlags, fCurButtons;
		fCurFlags	 = GetEntityFlags(iClient);
		fCurButtons = GetClientButtons(iClient);
		if (g_fLastFlags[iClient] & FL_ONGROUND && !(fCurFlags & FL_ONGROUND) && !(g_fLastButtons[iClient] & IN_JUMP) && fCurButtons & IN_JUMP)
		{
			g_iJumps[iClient] = 1;
		}
		else if(fCurFlags & FL_ONGROUND)
		{
			g_iJumps[iClient] = 1;
		}
		else if(!(g_fLastButtons[iClient] & IN_JUMP) && fCurButtons & IN_JUMP && g_iJumps[iClient] == 1)
		{
			jump_effect(iClient);
			g_iJumps[iClient]++;
			decl Float:vVel[3];
			GetEntPropVector(iClient, Prop_Data, "m_vecVelocity", vVel);
			vVel[2] = 250.0;
			TeleportEntity(iClient, NULL_VECTOR, NULL_VECTOR, vVel);
		}
		else if(!(g_fLastButtons[iClient] & IN_JUMP) && fCurButtons & IN_JUMP && (g_iJumps[iClient] == 2))
		{
			jump_effect(iClient);
			g_iJumps[iClient]++;
			decl Float:vVel[3];
			GetEntPropVector(iClient, Prop_Data, "m_vecVelocity", vVel);
			vVel[2] = 250.0;
			TeleportEntity(iClient, NULL_VECTOR, NULL_VECTOR, vVel);
		}


		g_fLastFlags[iClient] = fCurFlags;
		g_fLastButtons[iClient]	= fCurButtons;
	}
	return Plugin_Continue;
}

jump_effect(iClient) {
	decl Float:pos[3];
	GetClientAbsOrigin(iClient, pos);
	new iEntity = CreateEntityByName("info_particle_system", -1);
	DispatchKeyValue(iEntity, "effect_name", "JumpEX");
	DispatchKeyValueVector(iEntity, "origin", pos);
	DispatchSpawn(iEntity);
	SetVariantString("!activator");
	//AcceptEntityInput(iEntity, "SetParent", iClient);
	ActivateEntity(iEntity);
	AcceptEntityInput(iEntity, "Start");
	SetVariantString("OnUser1 !self:kill::1.5:1");
	AcceptEntityInput(iEntity, "AddOutput");
	AcceptEntityInput(iEntity, "FireUser1");
}