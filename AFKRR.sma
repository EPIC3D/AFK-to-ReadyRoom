#include <amxmodx>
#include <fakemeta>
#include <ns>

#define IDLE_TIME 150.0 // idle time in seconds

new Float:g_LastActivity[33];
new g_cvarDebug;

public plugin_init() {
    register_plugin("NS AFK to ReadyRoom", "0.9", "Epicopy & ChatGPT-5");

    g_cvarDebug = register_cvar("afk_debug", "1"); // 1 = log to console

    register_forward(FM_CmdStart, "fw_CmdStart");
    set_task(10.0, "check_idle", _, _, _, "b"); // check every 10 seconds
}

// Forward for tracking player activity via button presses
public fw_CmdStart(id, uc_handle, seed) {
    if(!is_user_connected(id) || !is_user_alive(id))
        return FMRES_IGNORED;

    new buttons = get_uc(uc_handle, UC_Buttons);
    if(buttons) g_LastActivity[id] = get_gametime();

    return FMRES_IGNORED;
}

// Initialize activity when player joins
public client_putinserver(id) {
    g_LastActivity[id] = get_gametime();
}

// Reset activity when player disconnects
public client_disconnect(id) {
    g_LastActivity[id] = 0.0;
}

// Periodic idle check
public check_idle() {
    new Float:now = get_gametime();

    for(new id = 1; id <= 32; id++) {
        if(!is_user_connected(id) || !is_user_alive(id)) continue;

        new name[32]; get_user_name(id, name, charsmax(name));

        // Ignore bots and immunity admins
        if(is_user_bot(id)) {
            if(get_pcvar_num(g_cvarDebug))
                server_print("[AFK->RR] %s (#%d) ignored: bot.", name, id);
            continue;
        }
        if(get_user_flags(id) & ADMIN_IMMUNITY) {
            if(get_pcvar_num(g_cvarDebug))
                server_print("[AFK->RR] %s (#%d) ignored: immunity admin.", name, id);
            continue;
        }

        // Get team in NS mod
        new teamname[32];
        get_user_team(id, teamname, charsmax(teamname));

        // Ignore ReadyRoom and Spectator
        if(strcmp(teamname, "undefinedteam", false) == 0 || strcmp(teamname, "spectatorteam", false) == 0) {
            if(get_pcvar_num(g_cvarDebug))
                server_print("[AFK->RR] %s (#%d) ignored: %s.", name, id, teamname);
            continue;
        }

        // Check for idle time
        if(now - g_LastActivity[id] >= IDLE_TIME) {
            new userid = get_user_userid(id);
            if(userid > 0) {
                // Move player to ReadyRoom
                server_cmd("amx_readyroom #%d", userid);
                server_exec();

                client_print(id, print_chat, "[AFK] You have been moved to ReadyRoom due to inactivity!");

                // Safety check: get team again
                new newteam[32];
                get_user_team(id, newteam, charsmax(newteam));

                if(strcmp(newteam, "undefinedteam", false) != 0) {
                    server_print("[AFK->RR] Warning! %s (#%d) is still in %s after ReadyRoom command!", name, userid, newteam);
                } else if(get_pcvar_num(g_cvarDebug)) {
                    server_print("[AFK->RR] %s (#%d) successfully moved to ReadyRoom.", name, userid);
                }
            }

            g_LastActivity[id] = now; // reset to prevent spam
        }
    }
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
