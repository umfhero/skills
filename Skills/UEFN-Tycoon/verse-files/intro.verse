using { /Fortnite.com/Devices }
using { /Fortnite.com/UI }
using { /Verse.org/Simulation }
using { /Verse.org/Colors/NamedColors }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Simulation/Tags }
using { /Verse.org/Colors }
using { /majid@fortnite.com/MCSkyblockTycoon }

<# 
""""
WARNING: This verse code is protected by copyright law.
Unauthorized reproduction or distribution of this code, or any portion of it,
may result in severe civil and criminal penalties, and will be prosecuted
to the maximum extent possible under the law.

© 2024 Sam. All rights reserved.
""" 
#>

# A Verse-authored creative device that shows an intro texture for 5 seconds when triggered by spawn pad
intro_system := class(creative_device):

    @editable SpawnPad : player_spawner_device = player_spawner_device{}
    @editable IntroDisplayTime : float = 5.0
    
    var PlayerIntroMap : [agent]?player_ui = map{}
    
    S2M<localizes>(S:string):message="{S}"

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        # Subscribe to the spawn pad's player spawned event
        SpawnPad.SpawnedEvent.Subscribe(OnPlayerSpawned)

    OnPlayerSpawned(Agent:agent):void=
        Print("Player Spawned on Spawn Pad - Showing Intro")
        spawn{ShowIntroTexture(Agent)}
 
    ShowIntroTexture(Agent:agent)<suspends>:void=
        if(PlayerUI := GetPlayerUI[player[Agent]]):
            # Create the intro overlay with texture in the center - very high layer
            IntroOverlay:=overlay:
                Slots:=array:
                    overlay_slot:
                        HorizontalAlignment:=horizontal_alignment.Center
                        VerticalAlignment:=vertical_alignment.Center
                        Widget:=
                            ZOrder := 2147483647
                            IntroImage:=texture_block:
                                DefaultImage:=UI.intro
                                DefaultDesiredSize:=vector2{X:=1920.0,Y:=1080.0}

            # Create the UI slot for the intro with maximum priority
            IntroUISlot:=player_ui_slot:
                ZOrder:=2147483647
                InputMode:=ui_input_mode.None
            
            # Add the intro overlay to the player's UI
            PlayerUI.AddWidget(IntroOverlay, IntroUISlot)
            
            # Store the player UI reference
            if(set PlayerIntroMap[Agent] = option{PlayerUI}){}
            
            Print("Intro texture displayed for player")
            
            # Wait for the specified time
            Sleep(IntroDisplayTime)
            
            # Remove the intro overlay
            PlayerUI.RemoveWidget(IntroOverlay)
            
            # Remove from map
            if(set PlayerIntroMap[Agent] = false){}
            
            Print("Intro finished for player")
