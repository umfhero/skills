using { /Fortnite.com/UI }
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using {/Verse.org/Colors}
using { /UnrealEngine.com/Temporary/SpatialMath }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
playtime_award_manager := class(creative_device):

    var PlaytimeMap : [player]int = map{}

    var UiMap : [player]tuple(texture_block, texture_block) = map{}

    @editable
    Accolade1 : ?accolades_device = false

    @editable
    Accolade2 : ?accolades_device = false

    @editable
    PositionFromTopLeft : vector2 = vector2{}

    <#
    @editable
    FirstSliderColor : color = NamedColors.Green

    @editable
    FirstSliderOpacity : type {_X:float where 0.000000 <= _X, _X <= 1.000000} = 0.8

    @editable
    SecondSliderColor : color = NamedColors.Blue

    @editable
    SecondSliderOpacity : type {_X:float where 0.000000 <= _X, _X <= 1.000000} = 0.8 #>

    var MinSizeX : float = 0.01

    @editable
    var MaxSizeX : float = 445.0

    @editable
    var SizeY : float = 37.0

    @editable
    XMultiple : float = 1.0

    @editable
    YMultiple : float = 1.0

    @editable
    FirstMins : int = 20

    @editable
    SecondMins : int = 30


    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        spawn{CountPlaytime()}

    UpdateUI(Player : player):void=
        if(Widgets := UiMap[Player]):
            if(PlayTime := PlaytimeMap[Player]):
                if(Wid1Time := Mod[PlayTime,60*FirstMins]):
                    Widgets(0).SetDesiredSize(vector2{X:=MinSizeX * XMultiple+ (XMultiple*(MaxSizeX - MinSizeX)*1.0*Wid1Time)/(60.0*FirstMins),Y:=SizeY*YMultiple})
                if(Wid2Time := Mod[PlayTime,60*SecondMins]):
                    Widgets(1).SetDesiredSize(vector2{X:=MinSizeX * XMultiple+ (XMultiple*(MaxSizeX - MinSizeX)*1.0*Wid2Time)/(60.0*SecondMins),Y:=SizeY*YMultiple})
                Print("Player widget updated with playtime: {PlayTime}")
        else:
            GenerateWidget(Player)

    GenerateWidget(Player : player):void=

        #SliderWidget:=slider_regular:
        #    DefaultMinValue := 0.0
        #    DefaultMaxValue := 30.0
        #    DefaultStepSize := 1.0/60.0

        SliderWidget1 := texture_block:
            DefaultImage := XP_UI.GreenLoadingBar
            DefaultDesiredSize := vector2{X:=MinSizeX * XMultiple,Y:=SizeY * YMultiple}
            DefaultHorizontalTiling := image_tiling.Repeat

        SliderBackground1 := texture_block:
            DefaultImage := XP_UI.GreyLoadingBar
            DefaultDesiredSize := vector2{X:=MaxSizeX * XMultiple,Y:=SizeY * YMultiple}
            DefaultHorizontalTiling := image_tiling.Repeat

        SliderWidget2 := texture_block:
            DefaultImage := XP_UI.BlueLoadingBar
            DefaultDesiredSize := vector2{X:=MinSizeX * XMultiple,Y:=SizeY * YMultiple}
            DefaultHorizontalTiling := image_tiling.Repeat

        SliderBackground2 := texture_block:
            DefaultImage := XP_UI.GreyLoadingBar
            DefaultDesiredSize := vector2{X:=MaxSizeX * XMultiple,Y:=SizeY * YMultiple}
            DefaultHorizontalTiling := image_tiling.Repeat

        BackgroundImage := texture_block:
            DefaultImage := XP_UI.PlaytimeUIBackground
            DefaultDesiredSize := vector2{X:=806.0 * XMultiple,Y:=680.0 * YMultiple}
            
        Overlay := overlay:
            Slots:=array:
                overlay_slot:
                    Widget:=BackgroundImage
                    HorizontalAlignment:=horizontal_alignment.Fill
                    VerticalAlignment:=vertical_alignment.Fill

        CanvPanel := canvas:
            Slots:=array:
                canvas_slot:
                    Offsets:= margin{Left:=0.0 + PositionFromTopLeft.X,Top:=0.0 + PositionFromTopLeft.Y,Right:=806.0 * XMultiple,Bottom:=680.0 * YMultiple}
                    Widget:=BackgroundImage
                    ZOrder:=0
                canvas_slot:
                    Offsets:= margin{Left:=180.0 * XMultiple+PositionFromTopLeft.X,Top:=312.0 * YMultiple+PositionFromTopLeft.Y}
                    Widget:=SliderWidget1
                    ZOrder:=2
                canvas_slot:
                    Offsets:= margin{Left:=180.0 * XMultiple+PositionFromTopLeft.X,Top:=450.0 * YMultiple+PositionFromTopLeft.Y}
                    Widget:=SliderWidget2
                    ZOrder:=2
                canvas_slot:
                    Offsets:= margin{Left:=180.0 * XMultiple+PositionFromTopLeft.X,Top:=312.0 * YMultiple+PositionFromTopLeft.Y}
                    Widget:=SliderBackground1
                    ZOrder:=1
                canvas_slot:
                    Offsets:= margin{Left:=180.0 * XMultiple+PositionFromTopLeft.X,Top:=450.0 * YMultiple+PositionFromTopLeft.Y}
                    Widget:=SliderBackground2
                    ZOrder:=1

        if(PlayerUI := GetPlayerUI[Player]):
            PlayerUI.AddWidget(CanvPanel)
            if(set UiMap[Player] = (SliderWidget1,SliderWidget2)){}



    CountPlaytime()<suspends>:void=
        loop:
            for(Player : GetPlayspace().GetPlayers()):
                if(Time := PlaytimeMap[Player]):
                    if(Time > 10 and Mod[Time,60*FirstMins] = 0):
                        if(Accolade1Actual := Accolade1?):
                            Accolade1Actual.Award(Player)
                    if(Time > 10 and Mod[Time,60*SecondMins] = 0):
                        if(Accolade2Actual := Accolade2?):
                            Accolade2Actual.Award(Player)
                    if(set PlaytimeMap[Player] = Time + 1):
                else:
                    if(set PlaytimeMap[Player] = 1):
                UpdateUI(Player)
            Sleep(1.0)
                        
