
using { /Fortnite.com/Devices }
using { /Fortnite.com/UI }
using { /Verse.org/Simulation }
using { /Verse.org/Colors }
using { /Verse.org/Assets }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }

Textures<public> := module:

playtime_hud_component := class:
    Canvas:canvas

    RewardPanelWidget:widget
    RewardReceivedWidget:widget
    RewardReceivedTextureBlock:texture_block
    RewardReceivedTextBlock:text_block

    HudDestroyedEvent:event()

playtime_component := class:
    StartSimTime:float

    Canvas:canvas
    TimeRemainingTextBlock:text_block
    AlertTextBlock:text_block
    RewardTexture:texture_block

    var RewardTimes:[]int = array{}

    UpdateTimes:event() = event(){}
    CancelEvent:event() = event(){}

playtime_reward_unlock := class<concrete>:
    @editable
    ClaimTrigger:trigger_device = trigger_device{}

    @editable
    PlaytimeSeconds:int = 30

    @editable
    RewardReceivedText:string = "50 Coins"

    @editable
    RewardReceivedTextColor:color = NamedColors.Gold

custom_playtime_margin := struct<concrete>:
    @editable
    Left<public>:float = 0.0
    @editable
    Top<public>:float = 0.0
    @editable
    Right<public>:float = 0.0
    @editable
    Bottom<public>:float = 0.0

playtime_reward_device := class(creative_device):

    PlaytimeRewardsTextures:[]texture = array:
        Giftbox.T_1
        Giftbox.T_GiftBox
        Giftbox.T_GiftBox
        Giftbox.T_GiftBox
        Giftbox.T_2
        Giftbox.T_GiftBox
        Giftbox.T_3
        Giftbox.T_GiftBox
        Giftbox.T_TreasureChest

    @editable
    PlaytimeRewardsList:[]playtime_reward_unlock = array{}

    @editable
    ShowPlaytimeRewardsButton:button_device = button_device{}
    @editable
    ShowPlaytimeRewardsButton2:button_device = button_device{}

    @editable
    HeaderColor:color = MakeColorFromHex("FBC14CFF")

    @editable
    BackgroundColor:color = MakeColorFromHex("1699F3FF")

    @editable
    BackgroundBottomColor:color = MakeColorFromHex("FF3832FF")

    @editable
    ClaimInButtonColor:color = MakeColorFromHex("58A8CAFF")

    @editable
    ClaimNowButtonColor:color = MakeColorFromHex("FF7A2CFF")

    @editable
    ClaimedButtonColor:color = MakeColorFromHex("565656FF")

    @editable
    ClaimInTextColor:color = MakeColorFromHex("FFFFFFFF")

    @editable
    ShowGiftAlertHud:logic = true

    @editable
    GiftAlertHudAnchors:vector2 = vector2{X := 0.0, Y := 1.0}

    @editable
    GiftAlertHudOffset:custom_playtime_margin = custom_playtime_margin{Left := 30.0, Top := -370.0}

    var PlaytimeHudPerAgent:[agent]playtime_hud_component = map{}
    var PlaytimePerAgent:[agent]playtime_component = map{}

    # String to Message
    PlayRewardStringToMessage<localizes>(value:string) : message = "{value}"

    OnBegin<override>()<suspends>:void=
        for(Player : GetPlayspace().GetPlayers()):
            OnPlayerJoined(Player)

        GetPlayspace().PlayerAddedEvent().Subscribe(OnPlayerJoined)
        GetPlayspace().PlayerRemovedEvent().Subscribe(OnPlayerRemoved)

        ShowPlaytimeRewardsButton.InteractedWithEvent.Subscribe(AddUI)  
        ShowPlaytimeRewardsButton2.InteractedWithEvent.Subscribe(AddUI)    

    OnPlayerJoined(Player:player):void=
        if(ShowGiftAlertHud = true):
            AddHUD(Player)
        spawn { StartRewardsCountdown(Player) }

    OnPlayerRemoved(Player:player):void=
        RemoveUI(Player)
        RemoveHUD(Player)

        var NewMap:[agent]playtime_component = map{}
        for (Key -> Value : PlaytimePerAgent, Key <> Player):
            set NewMap = ConcatenateMaps(NewMap, map{Key => Value})
        set PlaytimePerAgent = NewMap

    StartRewardsCountdown(Agent:agent)<suspends>:void=
        if(PlaytimeComponent := PlaytimePerAgent[Agent]):
            set PlaytimeComponent.RewardTimes = for(PlayReward : PlaytimeRewardsList) {PlayReward.PlaytimeSeconds}
            race:
                PlaytimeComponent.CancelEvent.Await()
                loop:
                    SimTime := GetSimulationElapsedTime()
                    var GiftsWaiting:int = 0
                    var LowestCooldown:int = 999999
                    var BestGiftTexture:texture = Giftbox.T_GiftBox
                    for(Index->RewardTime : PlaytimeComponent.RewardTimes, RewardTime >= 0, PlayReward := PlaytimeRewardsList[Index], RewardTexture := PlaytimeRewardsTextures[Index]):
                        if(NewTime := Max(PlayReward.PlaytimeSeconds - Floor[SimTime - PlaytimeComponent.StartSimTime], 0)):
                            if(set PlaytimeComponent.RewardTimes[Index] = NewTime) {}

                            if(NewTime = 0):
                                set GiftsWaiting += 1
                                set BestGiftTexture = RewardTexture
                            else if(NewTime > 0, NewTime < LowestCooldown, GiftsWaiting <= 0):
                                set LowestCooldown = NewTime
                                set BestGiftTexture = RewardTexture

                    PlaytimeComponent.UpdateTimes.Signal()

                    if(GiftsWaiting > 0):
                        PlaytimeComponent.AlertTextBlock.SetText(PlayRewardStringToMessage("{GiftsWaiting}"))
                        PlaytimeComponent.TimeRemainingTextBlock.SetText(PlayRewardStringToMessage("Ready"))
                        PlaytimeComponent.RewardTexture.SetImage(BestGiftTexture)
                    else if(LowestCooldown < 999999):
                        if:
                            Hour := Floor(LowestCooldown / 3600)
                            Minute := Mod[Floor(Mod[LowestCooldown, 3600] / 60), 10]
                            MinuteBoth := Floor(Mod[LowestCooldown, 3600] / 60)
                            TensMinute := Floor(Floor(Mod[LowestCooldown, 3600] / 60) / 10)
                            Second := Mod[Mod[LowestCooldown, 60], 10]
                            TensSecond := Floor(Mod[LowestCooldown, 60] / 10)
                        then:
                            if(Hour <= 0):
                                PlaytimeComponent.TimeRemainingTextBlock.SetText(PlayRewardStringToMessage("{MinuteBoth}:{TensSecond}{Second}"))
                            else:
                                PlaytimeComponent.TimeRemainingTextBlock.SetText(PlayRewardStringToMessage("{Hour}:{TensMinute}{Minute}:{TensSecond}{Second}"))

                        PlaytimeComponent.AlertTextBlock.SetText(PlayRewardStringToMessage("{0}"))
                        PlaytimeComponent.RewardTexture.SetImage(BestGiftTexture)
                    else:
                        PlaytimeComponent.Canvas.SetVisibility(widget_visibility.Collapsed)

                    Sleep(1.0)

    OnBackButton(WidgetMessage:widget_message):void=
        if(PlaytimeHudComponent := PlaytimeHudPerAgent[WidgetMessage.Player]):
            Visibility := PlaytimeHudComponent.RewardReceivedWidget.GetVisibility()
            if(Visibility = widget_visibility.Visible):
                PlaytimeHudComponent.RewardReceivedWidget.SetVisibility(widget_visibility.Collapsed)
                PlaytimeHudComponent.RewardPanelWidget.SetVisibility(widget_visibility.Visible)
                return

        RemoveUI(WidgetMessage.Player)

    AddHUD(Agent:agent):void=
        RemoveHUD(Agent)
        if:
            PlayerUI := GetPlayerUI[player[Agent]]
        then:
            PlaytimeComponent := CreateHUD(Agent)
            PlayerUI.AddWidget(PlaytimeComponent.Canvas)
            if(set PlaytimePerAgent[Agent] = PlaytimeComponent){}

    RemoveHUD(Agent:agent):void=
        if:
            PlayerUI := GetPlayerUI[player[Agent]]
            PlaytimeComponent := PlaytimePerAgent[Agent]
        then:
            PlayerUI.RemoveWidget(PlaytimeComponent.Canvas)

            PlaytimeComponent.CancelEvent.Signal()


            var NewMap:[agent]playtime_component = map{}
            for (Key -> Value : PlaytimePerAgent, Key <> Agent):
                set NewMap = ConcatenateMaps(NewMap, map{Key => Value})
            set PlaytimePerAgent = NewMap

    AddUI(Agent:agent):void=
        RemoveUI(Agent)
        if:
            PlayerUI := GetPlayerUI[player[Agent]]
        then:
            PlaytimeHudComponent := CreateUI(Agent)
            PlayerUI.AddWidget(PlaytimeHudComponent.Canvas, player_ui_slot{InputMode := ui_input_mode.All})
            if(set PlaytimeHudPerAgent[Agent] = PlaytimeHudComponent){}

    RemoveUI(Agent:agent):void=
        if:
            PlayerUI := GetPlayerUI[player[Agent]]
            PlaytimeHudComponent := PlaytimeHudPerAgent[Agent]
        then:
            PlayerUI.RemoveWidget(PlaytimeHudComponent.Canvas)

            PlaytimeHudComponent.HudDestroyedEvent.Signal()

            var NewMap:[agent]playtime_hud_component = map{}
            for (Key -> Value : PlaytimeHudPerAgent, Key <> Agent):
                set NewMap = ConcatenateMaps(NewMap, map{Key => Value})
            set PlaytimeHudPerAgent = NewMap
    
    AwaitClaimNow(Agent:agent, Index:int, RewardTexture:texture, RewardText:string, RewardTextColor:color, ClaimButton:playtime_reward_button, BackButton:playtime_reward_button, HudDestroyedEvent:event())<suspends>:void=
        if(PlaytimeComponent := PlaytimePerAgent[Agent], PlayReward := PlaytimeRewardsList[Index]):
            if(PlaytimeComponent.RewardTimes[Index] <= -1):
                ClaimButton.Icon.SetImage(Giftbox.T_PlaytimeRewards_ClaimedText)
                ClaimButton.BackgroundImage.SetTint(ClaimedButtonColor)
                ClaimButton.Icon.SetVisibility(widget_visibility.Visible)
                ClaimButton.Text.SetText(PlayRewardStringToMessage(""))
            else:
                race:
                    HudDestroyedEvent.Await()
                    loop:
                        if:
                            RewardTime := PlaytimeComponent.RewardTimes[Index]
                            Hour := Floor(RewardTime / 3600)
                            Minute := Mod[Floor(Mod[RewardTime, 3600] / 60), 10]
                            MinuteBoth := Floor(Mod[RewardTime, 3600] / 60)
                            TensMinute := Floor(Floor(Mod[RewardTime, 3600] / 60) / 10)
                            Second := Mod[Mod[RewardTime, 60], 10]
                            TensSecond := Floor(Mod[RewardTime, 60] / 10)
                        then:
                            if(RewardTime <= 0):
                                ClaimButton.BackgroundImage.SetTint(ClaimNowButtonColor)
                                ClaimButton.Text.SetText(PlayRewardStringToMessage(""))
                                ClaimButton.Icon.SetVisibility(widget_visibility.Visible)

                                ClaimButton.Button.OnClick().Await()

                                if(set PlaytimeComponent.RewardTimes[Index] = -1) {}
                                PlayReward.ClaimTrigger.Trigger(Agent)

                                ClaimButton.Icon.SetImage(Giftbox.T_PlaytimeRewards_ClaimedText)
                                ClaimButton.BackgroundImage.SetTint(ClaimedButtonColor)

                                if(PlaytimeHudComponent := PlaytimeHudPerAgent[Agent]):
                                    PlaytimeHudComponent.RewardReceivedTextureBlock.SetImage(RewardTexture)
                                    PlaytimeHudComponent.RewardReceivedTextBlock.SetText(PlayRewardStringToMessage("{RewardText}"))
                                    PlaytimeHudComponent.RewardReceivedTextBlock.SetTextColor(RewardTextColor)
                                    PlaytimeHudComponent.RewardReceivedWidget.SetVisibility(widget_visibility.Visible)
                                    PlaytimeHudComponent.RewardPanelWidget.SetVisibility(widget_visibility.Collapsed)
                                    race:
                                        BackButton.Button.OnClick().Await()
                                        block:
                                            Sleep(5.0)
                                            PlaytimeHudComponent.RewardReceivedWidget.SetVisibility(widget_visibility.Collapsed)
                                            PlaytimeHudComponent.RewardPanelWidget.SetVisibility(widget_visibility.Visible)
                                break

                            if(Hour <= 0):
                                ClaimButton.Text.SetText(PlayRewardStringToMessage("{MinuteBoth}:{TensSecond}{Second}"))
                            else:
                                ClaimButton.Text.SetText(PlayRewardStringToMessage("{Hour}:{TensMinute}{Minute}:{TensSecond}{Second}"))
                        PlaytimeComponent.UpdateTimes.Await()

    CreateHUD(Agent:agent):playtime_component=
        AlertTextBlock := text_block:
            DefaultJustification := text_justification.Center
            DefaultShadowOffset := option {vector2{X := 2.0, Y := 2.0}}
            DefaultTextColor := NamedColors.White
            DefaultShadowColor := NamedColors.Black
            DefaultText := PlayRewardStringToMessage("0")
        AlertTextBlock.SetShadowOpacity(1.0)
        
        TimeRemainingTextBlock := text_block:
            DefaultJustification := text_justification.Center
            DefaultShadowOffset := option {vector2{X := 2.0, Y := 2.0}}
            DefaultTextColor := NamedColors.White
            DefaultShadowColor := NamedColors.Black
            DefaultText := PlayRewardStringToMessage("00:00")
        TimeRemainingTextBlock.SetShadowOpacity(1.0)

        RewardTexture := texture_block:
            DefaultImage := Giftbox.T_GiftBox
            DefaultDesiredSize := vector2{X := 100.0, Y := 100.0}

        RewardsWaitingOverlay := overlay:
            Slots := array:

                overlay_slot:
                    HorizontalAlignment := horizontal_alignment.Fill
                    VerticalAlignment := vertical_alignment.Fill
                    Padding := margin{Top := 10.0, Bottom := 10.0, Left := 10.0, Right := 10.0}
                    Widget := texture_block:
                        DefaultImage := Giftbox.T_PlaytimeRewards_GiftWaitingBackground
                        DefaultTint := BackgroundColor
                        DefaultDesiredSize := vector2{X := 165.0, Y := 165.0}
                overlay_slot:
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin{Top := 10.0, Bottom := 10.0, Left := 10.0, Right := 10.0}
                    Widget := texture_block:
                        DefaultImage := Giftbox.T_PlaytimeRewards_GiftWaitingBackgroundBottom
                        DefaultTint := BackgroundBottomColor
                        DefaultDesiredSize := vector2{X := 159.0, Y := 159.0}

                overlay_slot:
                    HorizontalAlignment := horizontal_alignment.Right
                    VerticalAlignment := vertical_alignment.Top
                    Padding := margin{}
                    Widget := overlay:
                        Slots := array:

                            overlay_slot:
                                HorizontalAlignment := horizontal_alignment.Center
                                VerticalAlignment := vertical_alignment.Center
                                Widget := texture_block:
                                    DefaultImage := Giftbox.T_PlaytimeRewards_GiftWaitingAmount
                                    DefaultDesiredSize := vector2{X := 45.0, Y := 45.0}
                            overlay_slot:
                                HorizontalAlignment := horizontal_alignment.Center
                                VerticalAlignment := vertical_alignment.Center
                                Widget := AlertTextBlock
       
                overlay_slot:
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin{Top := 10.0, Bottom := 10.0, Left := 10.0, Right := 10.0}
                    Widget := stack_box:
                        Orientation := orientation.Vertical
                        Slots := array:
                            stack_box_slot:
                                HorizontalAlignment := horizontal_alignment.Center
                                VerticalAlignment := vertical_alignment.Center
                                Widget := RewardTexture
                            stack_box_slot:
                                HorizontalAlignment := horizontal_alignment.Center
                                VerticalAlignment := vertical_alignment.Center
                                Widget := TimeRemainingTextBlock

        MyCanvas := canvas:
            Slots := array:
      
                canvas_slot:
                    Anchors := anchors{Minimum := GiftAlertHudAnchors, Maximum := GiftAlertHudAnchors}
                    Offsets := margin{Left := GiftAlertHudOffset.Left, Top := GiftAlertHudOffset.Top, Right := GiftAlertHudOffset.Right, Bottom := GiftAlertHudOffset.Bottom}
                    Alignment := vector2{X:=0.0,Y:=0.5}
                    SizeToContent := true
                    Widget := RewardsWaitingOverlay

        PlaytimeComponent := playtime_component{StartSimTime := GetSimulationElapsedTime(), Canvas := MyCanvas, TimeRemainingTextBlock := TimeRemainingTextBlock, AlertTextBlock := AlertTextBlock, RewardTexture := RewardTexture}

        return PlaytimeComponent

    CreateUI(Agent:agent):playtime_hud_component=
        HudDestroyedEvent:event() = event(){}

    
        BackButton := playtime_reward_button:
            BackgroundTexture := Giftbox.T_PlaytimeRewards_Button
            BackgroundTextureSize := vector2{X := 187.5, Y := 70.0}
            IconTexture := option{ Giftbox.T_PlaytimeRewards_BackText }
            IconTextureSize := option{ vector2{X := 96.0, Y := 46.0} }
            ButtonPadding := margin{Top := 3.0, Bottom := 3.0, Left := 3.0, Right := 3.0}
        BackButton.Create()
        BackButton.Button.OnClick().Subscribe(OnBackButton)
        BackButton.BackgroundImage.SetTint(NamedColors.Red)

        ForegroundStackBox := stack_box:
            Orientation := orientation.Vertical
            Slots := array:
                
                stack_box_slot:
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Top
                    Padding := margin{Top := 25.0}
                    Widget := texture_block:
                        DefaultImage := Giftbox.T_PlaytimeRewards_Header
                        DefaultTint := HeaderColor
                        DefaultDesiredSize := vector2{X := 447.0, Y := 37.0}

        NumberOfRows := Ceil(PlaytimeRewardsList.Length / 3) or -1

        var CurrentIndex:int = 0
        for(Row := 1..NumberOfRows):
            RewardRowStackBox := stack_box:
                Orientation := orientation.Horizontal

            RewardRowStackBoxSlot := stack_box_slot:
                HorizontalAlignment := horizontal_alignment.Fill
                VerticalAlignment := vertical_alignment.Fill
                Padding := margin{Top := 15.0}
                Widget := RewardRowStackBox

            ForegroundStackBox.AddWidget(RewardRowStackBoxSlot)

            for(Column := 1..3, PlaytimeRewardsList.Length > CurrentIndex, RewardTexture := PlaytimeRewardsTextures[CurrentIndex], Reward := PlaytimeRewardsList[CurrentIndex]):
                ClaimButton := playtime_reward_button:
                    BackgroundTexture := Giftbox.T_PlaytimeRewards_Button
                    BackgroundTextureSize := vector2{X := 150.0, Y := 62.0}
                    IconTexture := option{ Giftbox.T_PlaytimeRewards_ClaimNowText }
                    IconTextureSize := option{ vector2{X := 119.0, Y := 27.0} }
                    TextColor := ClaimInTextColor
                    ButtonPadding := margin{Top := 3.0, Bottom := 3.0, Left := 3.0, Right := 3.0}

                ClaimButton.Create()
                ClaimButton.BackgroundImage.SetTint(ClaimInButtonColor)
                ClaimButton.Icon.SetVisibility(widget_visibility.Collapsed)

                RewardStackBox := stack_box:
                    Orientation := orientation.Vertical
                    Slots := array:
                        
                        stack_box_slot:
                            HorizontalAlignment := horizontal_alignment.Center
                            VerticalAlignment := vertical_alignment.Center
                            Widget := texture_block:
                                DefaultImage := RewardTexture
                                DefaultDesiredSize := vector2{X := 100.0, Y := 100.0}
                 
                        stack_box_slot:
                            HorizontalAlignment := horizontal_alignment.Center
                            VerticalAlignment := vertical_alignment.Center
                            Padding := margin{Top := 5.0}
                            Widget := overlay:
                                Slots := array:
                                 
                                    overlay_slot:
                                        HorizontalAlignment := horizontal_alignment.Center
                                        VerticalAlignment := vertical_alignment.Center
                                        Widget := ClaimButton.Widget

                RewardStackBoxSlot := stack_box_slot:
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin{Top := 10.0, Bottom := 10.0, Left := 10.0, Right := 10.0}
                    Widget := RewardStackBox

                RewardRowStackBox.AddWidget(RewardStackBoxSlot)

                spawn { AwaitClaimNow(Agent, CurrentIndex, RewardTexture, Reward.RewardReceivedText, Reward.RewardReceivedTextColor, ClaimButton, BackButton, HudDestroyedEvent) }

                set CurrentIndex += 1

 
        RewardReceivedTextureBlock := texture_block:
            DefaultImage := Giftbox.T_PlaytimeRewards_Background
            DefaultDesiredSize := vector2{X := 200.0, Y := 200.0}

        RewardReceivedTextBlockHeader := text_block:
            DefaultJustification := text_justification.Center
            DefaultTextColor := NamedColors.White
            DefaultShadowColor := NamedColors.Black
            DefaultText := PlayRewardStringToMessage("YOU RECEIVED")

        RewardReceivedTextBlock := text_block:
            DefaultJustification := text_justification.Center
            DefaultTextColor := NamedColors.White
            DefaultShadowColor := NamedColors.Black

        CollectRewardOverlay := overlay:
            Slots := array:
               
                overlay_slot:
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Top
                    Padding := margin{Top := 25.0}
                    Widget := texture_block:
                        DefaultImage := Giftbox.T_PlaytimeRewards_RewardHeader
                        DefaultTint := HeaderColor
                        DefaultDesiredSize := vector2{X := 193.0, Y := 50.0}
            
                overlay_slot:
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Center
                    Widget := stack_box:
                        Orientation := orientation.Vertical
                        Slots := array:
                            stack_box_slot:
                                HorizontalAlignment := horizontal_alignment.Center
                                VerticalAlignment := vertical_alignment.Center
                                Widget := RewardReceivedTextureBlock
                            stack_box_slot:
                                HorizontalAlignment := horizontal_alignment.Center
                                VerticalAlignment := vertical_alignment.Center
                                Widget := RewardReceivedTextBlockHeader
                            stack_box_slot:
                                HorizontalAlignment := horizontal_alignment.Center
                                VerticalAlignment := vertical_alignment.Center
                                Widget := RewardReceivedTextBlock

        CollectRewardOverlay.SetVisibility(widget_visibility.Collapsed)

        PlaytimeRewardsStackBox := stack_box:
            Orientation := orientation.Vertical
            Slots := array:
           
                stack_box_slot:
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Center
                    Widget := overlay:
                        Slots := array:
                       
                            overlay_slot:
                                HorizontalAlignment := horizontal_alignment.Center
                                VerticalAlignment := vertical_alignment.Center
                                Widget := texture_block:
                                    DefaultImage := Giftbox.T_PlaytimeRewards_Background
                                    DefaultTint := BackgroundColor
                                    DefaultDesiredSize := vector2{X := 588.0, Y := 686.0}
                            # Background Bottom
                            overlay_slot:
                                HorizontalAlignment := horizontal_alignment.Center
                                VerticalAlignment := vertical_alignment.Center
                                Widget := texture_block:
                                    DefaultImage := Giftbox.T_PlaytimeRewards_BackgroundBottom
                                    DefaultTint := BackgroundBottomColor
                                    DefaultDesiredSize := vector2{X := 576.0, Y := 674.0}
                            # Foreground
                            overlay_slot:
                                HorizontalAlignment := horizontal_alignment.Center
                                VerticalAlignment := vertical_alignment.Fill
                                Widget := ForegroundStackBox
                            # Reward Received
                            overlay_slot:
                                HorizontalAlignment := horizontal_alignment.Fill
                                VerticalAlignment := vertical_alignment.Fill
                                Widget := CollectRewardOverlay

        MyCanvas := canvas:
            Slots := array:
                # Playtime Reward Panel
                canvas_slot:
                    Anchors := anchors{Minimum:=vector2{X:=0.5,Y:=0.5},Maximum:=vector2{X:=0.5,Y:=0.5}}
                    Offsets := margin{Left := 0.0, Top := 0.0}
                    Alignment := vector2{X:=0.5,Y:=0.5}
                    SizeToContent := true
                    Widget := PlaytimeRewardsStackBox
                # Back Button
                canvas_slot:
                    Anchors := anchors{Minimum:=vector2{X:=0.5,Y:=0.5},Maximum:=vector2{X:=0.5,Y:=0.5}}
                    Offsets := margin{Top := 385.0}
                    Alignment := vector2{X:=0.5,Y:=0.5}
                    SizeToContent := true
                    Widget := BackButton.Widget

        PlaytimeHudComponent := playtime_hud_component:
            Canvas := MyCanvas
            RewardPanelWidget := ForegroundStackBox
            RewardReceivedWidget := CollectRewardOverlay
            RewardReceivedTextureBlock := RewardReceivedTextureBlock
            RewardReceivedTextBlock := RewardReceivedTextBlock
            HudDestroyedEvent := HudDestroyedEvent

        return PlaytimeHudComponent


PlaceholderText<localizes>:message = ""
playtime_reward_button := class:

    var Widget:overlay = overlay:
    
    BackgroundImage:texture_block = texture_block:
        DefaultImage := Giftbox.T_PlaytimeRewards_Background
    
    BackgroundTexture:texture
    BackgroundTextureSize:vector2
    IconTexture:?texture = false
    IconTextureSize:?vector2 = false
    TextColor:color = NamedColors.White
    ButtonPadding:margin = margin{}
    DefaultText:message = PlaceholderText
    
    Icon:texture_block = texture_block:
        DefaultImage := Giftbox.T_PlaytimeRewards_Background
    
    Text:text_block = text_block:
        DefaultText := PlaceholderText
        DefaultTextColor := NamedColors.White
    
    Button:button_quiet = button_quiet:
        DefaultText := PlaceholderText

    Create():void=
        set Widget = overlay:
            Slots := array:
                overlay_slot: 
                    Widget := BackgroundImage
                overlay_slot:
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Center
                    Widget := stack_box:
                        Orientation := orientation.Horizontal
                        Slots := array:
                            stack_box_slot:
                                Widget := Icon
                            stack_box_slot:
                                Widget := Text
                overlay_slot: 
                    HorizontalAlignment := horizontal_alignment.Fill
                    VerticalAlignment := vertical_alignment.Fill
                    Padding := ButtonPadding
                    Widget := Button
    
        BackgroundImage.SetImage(BackgroundTexture)
        BackgroundImage.SetDesiredSize(BackgroundTextureSize)

        if(FoundIconTexture := IconTexture?):
            Icon.SetImage(FoundIconTexture)

            if(FoundIconTextureSize := IconTextureSize?):
                Icon.SetDesiredSize(FoundIconTextureSize)
        else:
            Icon.SetVisibility(widget_visibility.Collapsed)

        Text.SetTextColor(TextColor)
        Text.SetText(DefaultText)