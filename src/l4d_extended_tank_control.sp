#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <left4downtown>

//cvar handles
new Handle:	g_hLOSRange				= INVALID_HANDLE;
new Handle:	g_hLOSRangeCheckDelay	= INVALID_HANDLE;
new Handle: g_hValveLOSCvar			= INVALID_HANDLE;

new Float:	g_fDefaultLOSDelay = 2.0;
new bool:	g_bGameStarted = false;

public Plugin:myinfo =
{
    name = "L4D2 Extended Tank Control",
    author = "Stabby",
    version = "0.1",
    description = "Allows for customisation of rage values from different attacks, and makes tank LOS range-based. Also allows for a team to choose who will be tank in the current map."
};

public OnPluginStart()
{
	// Cvars
	g_hLOSRange = CreateConVar(				"tc_los_range",		"8192",
											"Range under which the tank stops getting frustrated while survivors are in LOS.",
											FCVAR_PLUGIN, true, 0.0, false);
	g_hLOSRangeCheckDelay = CreateConVar(	"tc_los_range_delay",	"2.5",
											"Delay between range checks. Lower values allow for higher precision but may decrease performance.",
											FCVAR_PLUGIN, true, 0.1, false);
	g_hValveLOSCvar = FindConVar("z_frustration_los_delay");
	HookConVarChange(g_hValveLOSCvar, ConVarChange_LOSDelay);
	//
	
	HookEvent("tank_spawn", PostTankSpawn);	
}

public OnMapStart()
{
	g_bGameStarted = true;
}

public ConVarChange_LOSDelay(Handle:cvar, const String:oldVal[], const String:newVal[])
{
	if (!g_bGameStarted)
	{
		g_fDefaultLOSDelay = StringToFloat(newVal);
	}
}

public PostTankSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	CreateTimer(GetConVarFloat(g_hLOSRangeCheckDelay), Timed_CheckRange, GetClientOfUserId(GetEventInt(event, "userid")), TIMER_REPEAT);
}

public Action:Timed_CheckRange(Handle:unused, any:newTank)
{
	if (GetClientTeam(newTank) == 3 && GetEntProp(newTank, Prop_Send, "m_zombieClass") == 8)
	{
		decl Float:	survPos[3];
		decl Float:	tankPos[3];
		GetClientEyePosition(newTank, tankPos);
		
		for (new n = 1; n <= MaxClients; n++)
		{
			if (GetClientTeam(n) == 2)
			{
				GetClientEyePosition(n, survPos);
				if (GetVectorDistance(survPos, tankPos) <= GetConVarFloat(g_hLOSRange))
				{
					SetConVarFloat(g_hValveLOSCvar, g_fDefaultLOSDelay);
					break;
				}
				else
				{
					SetConVarFloat(g_hValveLOSCvar, 0.0);
				}
			}
		}
		return Plugin_Continue;
	}
	return Plugin_Stop;
}






































