key o;
integer trigger;
integer drawn;
string lock;
fire()
{
    rotation rot=llGetCameraRot();
    vector pos=llGetCameraPos();
    list ray=llCastRay(pos,pos+<3.0,0.0,0.0>*llGetCameraRot(),[RC_REJECT_TYPES,RC_REJECT_AGENTS]);
    if(llList2Vector(ray,1))
    {
        llOwnerSay("Sight obstructed");
        return;
    }
    llSetObjectDesc(lock);
    llTriggerSound("1545f0c0-24c9-c87b-5590-203acbbe34c8",1.0);
    llRezObject("[Spectra]Rocket",pos+<5.0,0.0,0.0>*rot,<80.0,0.0,0.0>*rot,<0.00000, 0.70711, 0.00000, 0.70711>*rot,1);
    lock="";
    llPlaySound("1137030f-9aa0-b5db-c8c5-9c47d3c8c885",1.0);
    llResetTime();
}
beam()
{
    vector pos=llGetCameraPos();
    list ray=llCastRay(pos,pos+<1000.0,0.0,0.0>*llGetCameraRot(),[RC_DATA_FLAGS,RC_GET_ROOT_KEY,RC_REJECT_TYPES,RC_REJECT_AGENTS]);
    key hit=llList2Key(ray,0);
    if(hit!=lock)
    {
        string desc=llList2String(llGetObjectDetails(hit,[OBJECT_DESC]),0);
        if(llGetSubString(desc,0,1)=="v."||llGetSubString(desc,0,5)=="LBA.v.")
        {
            if(llList2String(llCSV2List(desc),-1)=="AIR")
            {
                llRegionSayTo(llGetOwnerKey(lock),-1567,"break");
                llParticleSystem([PSYS_PART_FLAGS,( 0
                 |PSYS_PART_INTERP_COLOR_MASK
                 |PSYS_PART_INTERP_SCALE_MASK
                 |PSYS_PART_RIBBON_MASK
                 |PSYS_PART_EMISSIVE_MASK
                 |PSYS_PART_TARGET_POS_MASK ),
                 PSYS_SRC_PATTERN,PSYS_SRC_PATTERN_DROP,
                 PSYS_PART_BLEND_FUNC_SOURCE,PSYS_PART_BF_SOURCE_ALPHA,
                 PSYS_PART_BLEND_FUNC_DEST,PSYS_PART_BF_ONE_MINUS_SOURCE_ALPHA,
                 PSYS_PART_START_ALPHA,1.0,
                 PSYS_PART_END_ALPHA,1.0,
                 PSYS_PART_START_COLOR, <1.0,0.0,0.0>,
                 PSYS_PART_END_COLOR,<1.0,0.0,0.0>,
                 PSYS_PART_START_GLOW,0.2,
                 PSYS_PART_END_GLOW,0.2,
                 PSYS_PART_START_SCALE,<0.8,4.0,2.0>,
                 PSYS_PART_END_SCALE,<0.8,4.1,2.0>,
                 PSYS_PART_MAX_AGE,0.2,
                 PSYS_SRC_ACCEL,<0.0,0.0,0.0>,
                 PSYS_SRC_BURST_PART_COUNT,1,
                 PSYS_SRC_BURST_RADIUS,0.1,
                 PSYS_SRC_BURST_RATE,0.09,
                 PSYS_SRC_BURST_SPEED_MIN,200.0,
                 PSYS_SRC_BURST_SPEED_MAX,200.0,
                 PSYS_SRC_ANGLE_BEGIN,0.0,
                 PSYS_SRC_ANGLE_END,0.0,
                 PSYS_SRC_OMEGA,<0.0,0.0,0.0>,
                 PSYS_SRC_MAX_AGE, 2.0,
                 PSYS_SRC_TEXTURE, "ef728e1e-4122-560e-7dcf-3e9525f8068d",
                 PSYS_SRC_TARGET_KEY,hit]);
                lock=hit;
                llRegionSayTo(llGetOwnerKey(hit),-1567,"lock");
            }
        }
    }
}
stop()
{
    llLinkParticleSystem(-1,[]);
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
        llListen(9003,"",o,"");
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
        else if(c&&trigger)
        {
            llRegionSayTo(llGetOwnerKey(lock),-1567,"break");
            stop();
        }
    }
    timer()
    {
        integer m=llGetAgentInfo(o)&AGENT_MOUSELOOK;
        if(m!=last)switch(m);
    }
}
