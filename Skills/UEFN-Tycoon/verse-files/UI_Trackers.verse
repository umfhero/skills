#Gold
#Gold per second
#Rebirths
#To-DO (we could change this to something else but i think it could be cool to link this to the verse device names eg Purchase barn)


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

#using { /Game/Athena/UI/InGame/Creative/PropertyEditor/Icon_Picker/Textures_V2/128x128/T_UI_IconLibrary_Cabin_128.T_UI_IconLibrary_Cabin_128 }

ui_system_tag := class(tag){}

Format(Num:int):string=
    if(Num < 1000):
        return "{Num}"
    else if(Num < 1000000):
        if(Rounded := Floor(Num/1000);Rem := Mod[Num,1000];AfterDecimal := Floor(Rem/100)):
            return "{Rounded}.{AfterDecimal}K"
    else if(Num < 1000000000):
        if(Rounded := Floor(Num/1000000);Rem := Mod[Num,1000000];AfterDecimal := Floor(Rem/100000)):
            return "{Rounded}.{AfterDecimal}M"
    else if(Num < 1000000000000):
        if(Rounded := Floor(Num/1000000000);Rem := Mod[Num,1000000000];AfterDecimal := Floor(Rem/100000000)):
            return "{Rounded}.{AfterDecimal}B"
    return "{Num}"

FormatTime(Sec : int):string=
    if(Sec < 60):
        return "{Sec} Seconds"
    else if(Sec < 3600):
        if(Minutes := Floor(Sec/60);Seconds := Mod[Sec,60]):
            return "{Minutes} Minutes {Seconds} Seconds"
    else if(Sec < 86400):
        if(Hours := Floor(Sec/3600);Minutes := Floor(Mod[Sec,3600]/60);Seconds := Mod[Sec,60]):
            return "{Hours} Hours {Minutes} Minutes {Seconds} Seconds"
    else if(Sec < 604800):
        if(Days := Floor(Sec/86400);Hours := Floor(Mod[Sec,86400]/3600);Minutes := Floor(Mod[Sec,3600]/60);Seconds := Mod[Sec,60]):
            return "{Days} Days {Hours} Hours {Minutes} Minutes {Seconds} Seconds"
    return "{Sec} Seconds"

# A Verse-authored creative device that can be placed in a level
UI_Trackers := class(creative_device):

    @editable PlaytimeStartingText : string = "Play-Time: 0 Seconds\nClaim a farm"

    @editable 
    RebirthToken : item_granter_device = item_granter_device{}
    @editable 
    GoldRemover : item_granter_device = item_granter_device{}

    RebirthTokenGranter(Agent : agent):void=
        RebirthToken.GrantItem(Agent)
            


    GetGold(Agent:agent):int=
        return ConditButton.GetItemCount(Agent,0)
 
    S2M<localizes>(S:string):message="{S}"
 
    @editable RefreshRate : float = 0.1
    @editable ConditButton : conditional_button_device = conditional_button_device{}
    var PlayerUIMap : [agent]?player_tycoon_ui_data = map{}
 
    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        GetPlayspace().PlayerAddedEvent().Subscribe(PlayerSpawned)
        for(Player : GetPlayspace().GetPlayers()):
            PlayerSpawned(Player)

    PlayerSpawned(Agent:agent):void=
        Print("Player Spawned")
        if(PlayerUIFromMap:=PlayerUIMap[Agent]?){}
        else:
            AssignUI(Agent)
 
    AssignUI(Agent:agent):void=
        Print("Assigning UI")
        MyCanvas:=MakeCanvas(Agent)
        if:
            PlayerUI:=GetPlayerUI[player[Agent]]
        then:
            PlayerUI.AddWidget(MyCanvas)
            spawn{RefreshUI(Agent)}
 
    RefreshUI(Agent:agent)<suspends>:void=
        Print("Starting to Refresh")
        if(Stats := PlayerUIMap[Agent]?):
            loop:
                Sleep(RefreshRate)
                MyResource := ConditButton.GetItemCount(Agent,0)
                #UpdateSecondsActive(Agent)
                Stats.GoldTextBlock.SetText(S2M("Gold: ${Format(MyResource)}"))
                Stats.GoldPerSecondTextBlock.SetText(S2M("Gold/Second: ${Format(Stats.GoldPerSecond)}"))
                Stats.RebirthsTextBlock.SetText(S2M("Rebirths: {Stats.Rebirths}"))
                Stats.ToDoTextBlock.SetText(S2M("To-Do: {Stats.ToDo}"))
                Stats.PlayTimeTextBlock.SetText(S2M("Play-Time: {FormatTime(Stats.SecondsActive)}"))
                if(Stats.SecondsActive < 1):
                    Stats.PlayTimeTextBlock.SetText(S2M("{PlaytimeStartingText}"))
                    #Print("Play time not running.")
    
    UpdateGoldPerSecond(Agent:agent,GoldPerSecond:int):void=
        if(Stats := PlayerUIMap[Agent]?):
            set Stats.GoldPerSecond = GoldPerSecond
        
    UpdateRebirths(Agent:agent,Rebirths:int):void=
        if(Stats := PlayerUIMap[Agent]?):
            set Stats.Rebirths = Rebirths
    
    UpdateToDoMultiple(Agent:agent,Items:[]string):void=
        var Str : string = ""
        Len := Items.Length
        if(Stats := PlayerUIMap[Agent]?):
            for(Index -> Item : Items):
                set Str += Item
                if(Index < Len-1):
                    set Str += ", "

    UpdateToDo(Agent:agent,ToDo:string):void=
        if(Stats := PlayerUIMap[Agent]?):
            set Stats.ToDo = ToDo

    UpdatePlaytime(Agent:agent,SecondsActive:int):void=
        if(Stats := PlayerUIMap[Agent]?):
            set Stats.SecondsActive = SecondsActive

    UpdateSecondsActive(Agent:agent):void=
        if(SecondsActive := PlayerProfileDataMap[player[Agent]].SecondsActive):
            if(Stats := PlayerUIMap[Agent]?):
                set Stats.SecondsActive = SecondsActive
        else:
            if(Stats := PlayerUIMap[Agent]?):
                set Stats.SecondsActive = 0
                
    ShowRebirthCooldown(Player:player, RemainingSeconds:float)<suspends>:void=
        if(Stats := PlayerUIMap[Player]?):
            OkButton:=button_regular:
                DefaultText:=S2M("OK")
            
            CooldownOverlay:=overlay:
                Slots:=array:
                    overlay_slot:
                        HorizontalAlignment:=horizontal_alignment.Center
                        VerticalAlignment:=vertical_alignment.Center
                        Widget:=
                            ZOrder := 9997000
                            BackgroundImage:=texture_block:
                                DefaultImage:=UI.Rebirth_Timer
                                DefaultDesiredSize:=vector2{X:=960.0,Y:=540.0}
                    overlay_slot:
                        Padding:=margin{Left:=50.0,Top:=0.0,Right:=0.0,Bottom:=0.0}
                        HorizontalAlignment:=horizontal_alignment.Center
                        VerticalAlignment:=vertical_alignment.Top
                        Widget:=
                            ZOrder := 99999000
                            CooldownText:=text_block:
                                DefaultText:=S2M("Please wait before rebirth again\nTime remaining: {RemainingSeconds} seconds")
                                DefaultTextColor:=NamedColors.White
                                DefaultShadowOffset:=option{vector2{X:=1.0,Y:=1.0}}
                    overlay_slot:
                        HorizontalAlignment:=horizontal_alignment.Center
                        VerticalAlignment:=vertical_alignment.Center
                        Padding:=margin{Left:=0.0,Top:=300.0,Right:=0.0,Bottom:=0.0}
                        Widget:=
                            ZOrder := 10000000
                            ButtonStackBox:=stack_box:
                                Orientation:=orientation.Horizontal
                                Slots:=array:
                                    stack_box_slot:
                                        HorizontalAlignment:=horizontal_alignment.Center
                                        VerticalAlignment:=vertical_alignment.Center
                                        Padding := margin{Left:=0.0,Top:=0.0,Right:=0.0,Bottom:=0.0}
                                        Widget:=OkButton

            UISlotForCooldown:=player_ui_slot:
                ZOrder:=2147483647
                InputMode:=ui_input_mode.All
            Stats.PlayerUI.AddWidget(CooldownOverlay,UISlotForCooldown)
            
            # Wait for player to click OK button
            OkButton.OnClick().Await()
            Stats.PlayerUI.RemoveWidget(CooldownOverlay)
            
    ConfirmRebirth(CurrencyManager : tycoon_currency_manager,Player:player)<suspends>:void=
        if(Stats := PlayerUIMap[Player]?):
            ConfirmButton:=button_regular:
                DefaultText:=S2M("Confirm")
                

            CancelButton:=button_regular:
                DefaultText:=S2M("Cancel")
                
############################################################################################################################################
###############This overlay could still use some work. Feel free to adjust any numbers######################################################
############################################################################################################################################
            RebirthOverlay:=overlay:
                        Slots:=array:
                            overlay_slot:
                                HorizontalAlignment:=horizontal_alignment.Center
                                VerticalAlignment:=vertical_alignment.Center
                                Widget:=
                                    ZOrder := 9997000
                                    BackgroundImage:=texture_block:
                                        DefaultImage:=UI.Rebirth_Warning
                                        DefaultDesiredSize:=vector2{X:=960.0,Y:=540.0}
                            overlay_slot:
                                Padding:=margin{Left:=50.0,Top:=0.0,Right:=0.0,Bottom:=0.0}
                                HorizontalAlignment:=horizontal_alignment.Center
                                VerticalAlignment:=vertical_alignment.Top
                                Widget:=
                                    ZOrder := 99999000
                                    RebirthText:=text_block:
                                        DefaultText:=S2M("Are you sure you want to rebirth?")
                                        DefaultTextColor:=NamedColors.White
                                        DefaultShadowOffset:=option{vector2{X:=1.0,Y:=1.0}}
                            overlay_slot:
                                HorizontalAlignment:=horizontal_alignment.Center
                                VerticalAlignment:=vertical_alignment.Center
                                Padding:=margin{Left:=0.0,Top:=300.0,Right:=0.0,Bottom:=0.0}
                                Widget:=
                                    ZOrder := 10000000
                                    ButtonsStackBox:=stack_box:
                                        Orientation:=orientation.Horizontal
                                        Slots:=array:
                                            stack_box_slot:
                                                HorizontalAlignment:=horizontal_alignment.Center
                                                VerticalAlignment:=vertical_alignment.Center
                                                Padding := margin{Left:=30.0,Top:=0.0,Right:=50.0,Bottom:=0.0}
                                                Widget:=ConfirmButton
                                            stack_box_slot:
                                                HorizontalAlignment:=horizontal_alignment.Center
                                                VerticalAlignment:=vertical_alignment.Center
                                                Padding := margin{Left:=30.0,Top:=0.0,Right:=50.0,Bottom:=0.0}
                                                Widget:=CancelButton              

            RebirthOverlaySlot:=canvas_slot: #not needed anymore
                Widget:=RebirthOverlay
                    
            UISlotForSettings:=player_ui_slot:
                ZOrder:=2147483647
                InputMode:=ui_input_mode.All
            Stats.PlayerUI.AddWidget(RebirthOverlay,UISlotForSettings)

            race:
                RebirthConfirmed(CurrencyManager,ConfirmButton,Player)
                RebirthCancelled(CurrencyManager,CancelButton)
            Stats.PlayerUI.RemoveWidget(RebirthOverlay)

            
    RebirthConfirmed(CurrencyManager : tycoon_currency_manager, ConfirmButton : text_button_base, Player : player)<suspends>:void=
        ConfirmButton.OnClick().Await() 
        RebirthTokenGranter(Player) 
        spawn{CurrencyManager.Rebirth(Player)}


    RebirthCancelled(CurrencyManager : tycoon_currency_manager, CancelButton : text_button_base)<suspends>:void=
        CancelButton.OnClick().Await()


                
                        
 
    MakeCanvas(Agent:agent):canvas=
        Print("Making Canvas")
        TextBlock1:=text_block:
            DefaultText:=S2M("Gold: ${Format(0)}")
            #DefaultFontSize:=32
            DefaultTextColor:=NamedColors.White
            DefaultShadowOffset:=option{vector2{X:=1.0,Y:=1.0}}
        TextBlock2:=text_block:
            DefaultText:=S2M("Gold/Second: ${Format(0)}")
            #DefaultFontSize:=32
            DefaultTextColor:=NamedColors.White
            DefaultShadowOffset:=option{vector2{X:=1.0,Y:=1.0}}
        TextBlock3:=text_block:
            DefaultText:=S2M("Rebirths: 0")
            #DefaultFontSize:=32
            DefaultTextColor:=NamedColors.White
            DefaultShadowOffset:=option{vector2{X:=1.0,Y:=1.0}}
        TextBlock4:=text_block:
            DefaultText:=S2M("To-Do: Claim your Island!")
            #DefaultFontSize:=32
            DefaultTextColor:=NamedColors.White
            DefaultShadowOffset:=option{vector2{X:=1.0,Y:=1.0}}
        TextBlock5:=text_block:
            DefaultText:=S2M("{PlaytimeStartingText}")
            #DefaultFontSize:=32
            DefaultTextColor:=NamedColors.White
            DefaultShadowOffset:=option{vector2{X:=1.0,Y:=1.0}}

        Slot1:=stack_box_slot:
            Padding:=margin{Left:=0.0,Top:=20.0,Right:=0.0,Bottom:=20.0}
            HorizontalAlignment:=horizontal_alignment.Left
            VerticalAlignment:=vertical_alignment.Fill
            Widget:=overlay:
                Slots:=array:
                    overlay_slot:
                        HorizontalAlignment:=horizontal_alignment.Fill
                        VerticalAlignment:=vertical_alignment.Fill
                        Widget:=
                            BackgroundImage1:=texture_block:
                                DefaultImage:=UI.Orange
                                DefaultDesiredSize:=vector2{X:=239.161682,Y:=91.964844}
                    overlay_slot:
                        Padding:=margin{Left:=10.0,Top:=0.0,Right:=30.0,Bottom:=0.0}
                        HorizontalAlignment:=horizontal_alignment.Left
                        VerticalAlignment:=vertical_alignment.Center
                        Widget:=
                            StackBox1:=stack_box:
                                Orientation:=orientation.Horizontal
                                Slots:=array:
                                    stack_box_slot:
                                        #Padding:=margin{}
                                        HorizontalAlignment:=horizontal_alignment.Fill
                                        VerticalAlignment:=vertical_alignment.Fill
                                        Widget:=
                                            Icon1:=texture_block:
                                                DefaultImage:=UI.GoldIcon
                                                DefaultDesiredSize:=vector2{X:=55.0,Y:=55.0}
                                    stack_box_slot:
                                        Padding:=margin{Left:=15.0,Top:=0.0,Right:=0.0,Bottom:=0.0}
                                        HorizontalAlignment:=horizontal_alignment.Fill
                                        VerticalAlignment:=vertical_alignment.Center
                                        Widget:=TextBlock1
        Slot2:=stack_box_slot:
            Padding:=margin{Left:=0.0,Top:=20.0,Right:=0.0,Bottom:=20.0}
            HorizontalAlignment:=horizontal_alignment.Left
            VerticalAlignment:=vertical_alignment.Fill
            Widget:=overlay:
                Slots:=array:
                    overlay_slot:
                        HorizontalAlignment:=horizontal_alignment.Fill
                        VerticalAlignment:=vertical_alignment.Fill
                        Widget:=
                            BackgroundImage2:=texture_block:
                                DefaultImage:=UI.Green_Button
                                DefaultDesiredSize:=vector2{X:=239.161682,Y:=91.964844}
                    overlay_slot:
                        Padding:=margin{Left:=10.0,Top:=0.0,Right:=30.0,Bottom:=0.0}
                        HorizontalAlignment:=horizontal_alignment.Left
                        VerticalAlignment:=vertical_alignment.Center
                        Widget:=
                            StackBox2:=stack_box:
                                Orientation:=orientation.Horizontal
                                Slots:=array:
                                    stack_box_slot:
                                        #Padding:=margin{}
                                        HorizontalAlignment:=horizontal_alignment.Fill
                                        VerticalAlignment:=vertical_alignment.Fill
                                        Widget:=
                                            Icon1:=texture_block:
                                                DefaultImage:=UI.GoldSecondicon
                                                DefaultDesiredSize:=vector2{X:=55.0,Y:=55.0}
                                    stack_box_slot:
                                        Padding:=margin{Left:=15.0,Top:=0.0,Right:=0.0,Bottom:=0.0}
                                        HorizontalAlignment:=horizontal_alignment.Fill
                                        VerticalAlignment:=vertical_alignment.Center
                                        Widget:=TextBlock2
        Slot3:=stack_box_slot:
            Padding:=margin{Left:=0.0,Top:=20.0,Right:=0.0,Bottom:=20.0}
            HorizontalAlignment:=horizontal_alignment.Left
            VerticalAlignment:=vertical_alignment.Fill
            Widget:=overlay:
                Slots:=array:
                    overlay_slot:
                        HorizontalAlignment:=horizontal_alignment.Fill
                        VerticalAlignment:=vertical_alignment.Fill
                        Widget:=
                            BackgroundImage3:=texture_block:
                                DefaultImage:=UI.Rebirth_Button
                                DefaultDesiredSize:=vector2{X:=239.161682,Y:=91.964844}
                    overlay_slot:
                        Padding:=margin{Left:=10.0,Top:=0.0,Right:=30.0,Bottom:=0.0}
                        HorizontalAlignment:=horizontal_alignment.Left
                        VerticalAlignment:=vertical_alignment.Center
                        Widget:=
                            StackBox3:=stack_box:
                                Orientation:=orientation.Horizontal
                                Slots:=array:
                                    stack_box_slot:
                                        #Padding:=margin{}
                                        HorizontalAlignment:=horizontal_alignment.Fill
                                        VerticalAlignment:=vertical_alignment.Fill
                                        Widget:=
                                            Icon3:=texture_block:
                                                DefaultImage:=UI.RestartGraphic
                                                DefaultDesiredSize:=vector2{X:=55.0,Y:=55.0}
                                    stack_box_slot:
                                        Padding:=margin{Left:=15.0,Top:=0.0,Right:=0.0,Bottom:=0.0}
                                        HorizontalAlignment:=horizontal_alignment.Fill
                                        VerticalAlignment:=vertical_alignment.Center
                                        Widget:=TextBlock3
        Slot4:=stack_box_slot:
            Padding:=margin{Left:=0.0,Top:=20.0,Right:=0.0,Bottom:=20.0}
            HorizontalAlignment:=horizontal_alignment.Left
            VerticalAlignment:=vertical_alignment.Fill
            Widget:=overlay:
                Slots:=array:
                    overlay_slot:
                        HorizontalAlignment:=horizontal_alignment.Fill
                        VerticalAlignment:=vertical_alignment.Fill
                        Widget:=
                            BackgroundImage4:=texture_block:
                                DefaultImage:=UI.Blue
                                DefaultDesiredSize:=vector2{X:=239.161682,Y:=91.964844}
                    overlay_slot:
                        Padding:=margin{Left:=10.0,Top:=0.0,Right:=30.0,Bottom:=0.0}
                        HorizontalAlignment:=horizontal_alignment.Left
                        VerticalAlignment:=vertical_alignment.Center
                        Widget:=
                            StackBox4:=stack_box:
                                Orientation:=orientation.Horizontal
                                Slots:=array:
                                    stack_box_slot:
                                        #Padding:=margin{}
                                        HorizontalAlignment:=horizontal_alignment.Fill
                                        VerticalAlignment:=vertical_alignment.Fill
                                        Widget:=
                                            Icon4:=texture_block:
                                                DefaultImage:=UI.Todo1
                                                DefaultDesiredSize:=vector2{X:=55.0,Y:=55.0}
                                    stack_box_slot:
                                        Padding:=margin{Left:=15.0,Top:=0.0,Right:=0.0,Bottom:=0.0}
                                        HorizontalAlignment:=horizontal_alignment.Fill
                                        VerticalAlignment:=vertical_alignment.Center
                                        Widget:=TextBlock4
        
            

        MainStackBox:=stack_box:
            Orientation:=orientation.Vertical
            Slots:=array:
                Slot1
                Slot2
                Slot3
                Slot4


        IslandCodeStackBox:=stack_box:
            Orientation:=orientation.Vertical
            Slots:=array:
                CodeOverlaySlot:=stack_box_slot:
                    Padding:=margin{Left:=0.0,Top:=20.0,Right:=0.0,Bottom:=20.0}
                    HorizontalAlignment:=horizontal_alignment.Left
                    VerticalAlignment:=vertical_alignment.Fill
                    Widget:=overlay:
                        Slots:=array:
                            overlay_slot:
                                Padding:=margin{Left:=10.0,Top:=0.0,Right:=30.0,Bottom:=0.0}
                                HorizontalAlignment:=horizontal_alignment.Left
                                VerticalAlignment:=vertical_alignment.Center
                                Widget:=
                                    InnerStackBox:=stack_box:
                                        Orientation:=orientation.Horizontal
                                        Slots:=array:
                                            stack_box_slot:
                                                HorizontalAlignment:=horizontal_alignment.Fill
                                                VerticalAlignment:=vertical_alignment.Fill
                                                Widget:=
                                                    Icon:=texture_block:
                                                        DefaultImage:=UI.SD_Card_Save_Locker_Graphic  #{Icon_Picker/Textures_V2/128x128/T_UI_IconLibrary_Cabin_128.T_UI_IconLibrary_Cabin_128}
                                                        DefaultDesiredSize:=vector2{X:=55.0,Y:=55.0}
                                            stack_box_slot:
                                                HorizontalAlignment:=horizontal_alignment.Fill
                                                VerticalAlignment:=vertical_alignment.Fill
                                                Widget:=
                                                    CodeImage:=texture_block:
                                                        DefaultImage:=UI.Island_code
                                                        DefaultDesiredSize:=vector2{X:=303.658539,Y:=55.0}


                                        
            
        MyCanvas:=canvas:
            Slots:=array:
                canvas_slot:
                    Alignment:=vector2{X:=0.000000,Y:=1.000000}
                    ZOrder := 10
                    Widget:=MainStackBox
                    Anchors:=anchors{Minimum:=vector2{X:=0.016468,Y:=0.739947},Maximum:=vector2{X:=0.016468,Y:=0.739947}}

        if(ThisPlayerUI := GetPlayerUI[player[Agent]]):
            UIData := player_tycoon_ui_data:
                PlayerUI:=ThisPlayerUI
                MainStackBox:=MainStackBox
                GoldTextBlock:=TextBlock1
                GoldPerSecondTextBlock:=TextBlock2
                RebirthsTextBlock:=TextBlock3
                ToDoTextBlock:=TextBlock4
                PlayTimeTextBlock:=TextBlock5
                PlayerGold:=GetGold(Agent)
                ToDo:="Claim your Island!"
                GoldPerSecond:=0
                Rebirths:=0
                SecondsActive:=0

            if(set PlayerUIMap[Agent] = option{UIData}){}
            
                        #Offsets:=margin{Left:=36.592609,Top:=511.1,Right:=1191.0,Bottom:=663.0}
                    #canvas_slot:
                    #    ZOrder:=1
                    #    Widget:=IslandCodeStackBox

        return MyCanvas



player_tycoon_ui_data := class:
    PlayerUI:player_ui
    MainStackBox:stack_box
    GoldTextBlock:text_block
    GoldPerSecondTextBlock:text_block
    RebirthsTextBlock:text_block
    ToDoTextBlock:text_block
    PlayTimeTextBlock:text_block
    var TempWidgets:[]widget=array{}
    var PlayerGold:int
    var GoldPerSecond:int
    var Rebirths:int
    var ToDo:string
    var SecondsActive:int



#live_player_info := class:
#    var PlayerGold:int
#    var GoldPerSecond:int
#    var Rebirths:int
#    var ToDo:string