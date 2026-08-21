
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Characters }
using { /Fortnite.com/FortPlayerUtilities }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
respawn_backup := class(creative_device):

    @editable
    MaxReasonablePlayerHeight : float = 25000.0

    @editable
    RespawnLocation : ?vector3 = false

    @editable
    RespawnRotation : ?rotation = false

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        spawn{ RespawnPlayersThatAreTooHigh() }

    RespawnPlayersThatAreTooHigh()<suspends>:void=
        loop:
            Sleep(1.0)
            for(Player : GetPlayspace().GetPlayers()):
                if(FortChar := Player.GetFortCharacter[]):
                    if(FortChar.GetTransform().Translation.Z > MaxReasonablePlayerHeight):
                        if(RespawnLoc := RespawnLocation?):
                            var RespawnRot : rotation = rotation{}
                            if(BetterRespawnRot := RespawnRotation?):
                                set RespawnRot = BetterRespawnRot
                            Player.Respawn(RespawnLoc, RespawnRot)
                                