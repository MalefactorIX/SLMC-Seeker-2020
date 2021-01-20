key o;
integer trigger;
integer drawn;
string lock;
fire()
{
    rotation rot=llGetCameraRot();
    llSetObjectDesc(lock);
    llTriggerSound("1545f0c0-24c9-c87b-5590-203acbbe34c8",1.0);
    llRezObject("[Spectra]Rocket",llGetCameraPos()+<5.0,0.0,0.0>*rot,<80.0,0.0,0.0>*rot,<0.00000, 0.70711, 0.00000, 0.70711>*rot,1);
    lock="";
    llPlaySound("1137030f-9aa0-b5db-c8c5-9c47d3c8c885",1.0);
    llResetTime();
}
beam()
{
    vector pos=llGetCameraPos();
    list ray=llCastRay(pos,pos+<1000.0,0.0,0.0>*llGetCameraRot(),[RC_DATA_FLAGS,RC_GET_ROOT_KEY,RC_REJECT_TYPES,RC_REJECT_AGENTS,RC_DETECT_PHANTOM,1]);
    //Note to self: Update with multi-hit support so it doesn't get eaten by sim surroundings.
    key hit=llList2Key(ray,0);
    string desc=llList2String(llGetObjectDetails(hit,[OBJECT_DESC]),0);
    if(llGetSubString(desc,0,1)=="v."||llGetSubString(desc,0,5)=="LBA.v.")
    {
        if(llList2String(llCSV2List(desc),-1)=="AIR")lock=hit;
    }
}
stop()
{
    llStopMoveToTarget();
    trigger=0;
    llStopAnimation(locka);
}
integer last=2;
string aim="MERCINC stinger aim nolegst-ii";
string hold="MERCINC stinger hold nolegst-ii";
string locka="Crouchstance(tiltfix)";
switch(integer m)
{
    if(m)
    {
        llStartAnimation(aim);
        llStopAnimation(hold);
    }
    else
    {
        llStartAnimation(hold);
        llStopAnimation(aim);
    }
}
default
{
    state_entry()
    {
        o=llGetOwner();
        llListen(0,"",o,"");
        llListen(9001,"",o,"");
        llRequestPermissions(o,0x414);
    }
    listen(integer chan, string name, key id, string message)
    {
        message=llToLower(message);
        if(message=="rdraw"&&!drawn)llRequestPermissions(o,0x414);
        else if(message=="rsling"&&drawn)
        {
            llStopAnimation(hold);
            llStopAnimation(aim);
            llReleaseControls();
            llSetTimerEvent(0.0);
            llSetLinkAlpha(-1,0.0,-1);
            drawn=0;
        }
        else if(message=="rhsling")llRequestPermissions(o,0x30);
        else if(message=="rreset")llResetScript();
    }
    attach(key id)
    {
        if(id)
        {
            llSetObjectName("Stinger Launcher");
            if(id==o)llRequestPermissions(o,0x414);
            else
            {
                llTriggerSound("29be62e8-d2a6-1412-e931-d4518c16b8b1",1.0);
                llGiveInventory(id,"Commands");
                llResetScript();
            }
        }
    }
    run_time_permissions(integer p)
    {
        if(p&0x20)llDetachFromAvatar();
        else if(p)
        {
            ++drawn;
            llTakeControls(CONTROL_ML_LBUTTON|CONTROL_DOWN,1,1);
            last=2;
            llSetTimerEvent(0.1);
            llSetLinkAlpha(-1,1.0,-1);
            llOwnerSay("Ready");
        }
    }
    control(key id, integer h, integer c)
    {
        if(h&c&CONTROL_ML_LBUTTON)
        {
            if(llGetTime()>5.0)fire();
        }
        else if(h&c&CONTROL_DOWN)
        {
            if(llGetAgentInfo(o)&AGENT_IN_AIR)return;
            ++trigger;
            llResetTime();
            llStartAnimation(locka);
            llPlaySound("900083fb-1601-9dcb-6be3-f5e75a6afc7f",0.3);
            beam();
            llMoveToTarget(llGetPos(),.2);
        }
        else if(h&CONTROL_DOWN&&llGetTime()>2.0&&trigger)
        {
            if(lock=="")
            {
                llTriggerSound("8856d5fd-9253-8cfb-2bbe-b9e49d16b027",1.0);
                llOwnerSay("Lockon Failed");
            }
            else
            {
                llOwnerSay("/me locked on.");
                llPlaySound("97f3bc6f-17aa-d40f-7fa8-d3d24c88f6e7",1.0);
                fire();
            }
            stop();
        }
        else if(h&CONTROL_DOWN&&trigger)beam();
        else if(c&&trigger)stop();
    }
    timer()
    {
        integer m=llGetAgentInfo(o)&AGENT_MOUSELOOK;
        if(m!=last)switch(m);
    }
}
