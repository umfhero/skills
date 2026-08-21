using { /Fortnite.com/Devices }
using { /Fortnite.com/UI }
using { /Verse.org/Simulation }
using { /Verse.org/Colors/NamedColors }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Simulation/Tags }
 
gold_counter_tag := class(tag){}

# A Verse-authored creative device that can be placed in a level
GoldTracker := class(creative_device):

    GetGold(Agent:agent):int=
        return ConditButton.GetItemCount(Agent,0)
 
    S2M<localizes>(S:string):message="{S}"
 
    @editable PlayerSpawners : []player_spawner_device = array{}
    @editable RefreshRate : float = 0.1
    @editable ConditButton : conditional_button_device = conditional_button_device{}
    var ResourceTextBlockPerAgent : [agent]?text_block = map{}
 
    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        for(PS:PlayerSpawners):
            PS.SpawnedEvent.Subscribe(PlayerSpawned)

    PlayerSpawned(Agent:agent):void=
        Print("Player Spawned")
        if(MyTextBlock:=ResourceTextBlockPerAgent[Agent]?){}
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
        if(TextBlock := ResourceTextBlockPerAgent[Agent]?):
            loop:
                Sleep(RefreshRate)
                MyResource := ConditButton.GetItemCount(Agent,0)
                TextBlock.SetText(S2M("Gold: ${Format(MyResource)}"))
 
    #Format(Num:int):string=
    #    if(Num < 1000):
    #        return "{Num}"
    #    else if(Num < 1000000):
    #        if(Rounded := Floor(Num/1000);Rem := Mod[Num,1000];AfterDecimal := Floor(Rem/100)):
    #            return "{Rounded}.{AfterDecimal}K"
    #    else if(Num < 1000000000):
    #        if(Rounded := Floor(Num/1000000);Rem := Mod[Num,1000000];AfterDecimal := Floor(Rem/100000)):
    #            return "{Rounded}.{AfterDecimal}M"
    #    else if(Num < 1000000000000):
    #        if(Rounded := Floor(Num/1000000000);Rem := Mod[Num,1000000000];AfterDecimal := Floor(Rem/100000000)):
    #            return "{Rounded}.{AfterDecimal}B"
    #    return "{Num}"
 
 
    MakeCanvas(Agent:agent):canvas=
        Print("Making Canvas")
        MyTextBlock:=text_block:
            DefaultTextColor:=Green
 
        if(set ResourceTextBlockPerAgent[Agent] = option{MyTextBlock}){}
 
        MyCanvas:=canvas:
            Slots:=array:
                canvas_slot:
                    Widget:=MyTextBlock
                    Anchors:=anchors{Minimum:=vector2{X:=0.0,Y:=0.0},Maximum:=vector2{X:=1.0,Y:=1.0}}
                    Offsets:=margin{Left:=36.592609,Top:=511.1,Right:=1191.0,Bottom:=663.0}
 
        return MyCanvas