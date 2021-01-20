//This variant of the LBH parser is for use inside lock-on rockets.
die(vector pos)//Explosion/Death
{
    //Add extra shit here
    vector vel=llGetVel();
    llSetLinkPrimitiveParamsFast(-1,[PRIM_PHYSICS,0,PRIM_PHANTOM,1,PRIM_COLOR,-1,ZERO_VECTOR,0.0,PRIM_GLOW,-1,0.0]);
    llStopSound();
    list ray=llCastRay(pos-(vel*0.075),pos+(vel*0.075),[]);
    vector raypos=llList2Vector(ray,1);
    if(raypos)llSetRegionPos(raypos-(llVecNorm(vel)*0.5));
     llParticleSystem([
            PSYS_PART_FLAGS,            PSYS_PART_EMISSIVE_MASK|PSYS_PART_FOLLOW_VELOCITY_MASK|PSYS_PART_INTERP_COLOR_MASK|PSYS_PART_INTERP_SCALE_MASK,
            PSYS_SRC_PATTERN,           PSYS_SRC_PATTERN_EXPLODE,
            PSYS_PART_START_COLOR,    <1.0,0.75,0.5>,
            PSYS_PART_END_COLOR,      <1.0,0.75,0.5>,
            PSYS_PART_START_ALPHA,      0.5,
            PSYS_PART_END_ALPHA,        0.0,
            PSYS_PART_START_GLOW,        0.3,
            PSYS_PART_START_SCALE,      <9.0,9.0,0.0>,
            PSYS_PART_END_SCALE,        <9.0,9.0,0.0>,
            PSYS_PART_MAX_AGE,          0.5,
            PSYS_SRC_ACCEL,             <0.0,0.0,1.0>,
            PSYS_SRC_TEXTURE,           "8738201d-ec3d-288a-7d65-031211f9fee7",
            PSYS_SRC_BURST_RATE,        .05,
            PSYS_SRC_ANGLE_BEGIN,       0.0,
            PSYS_SRC_ANGLE_END,        PI,
            PSYS_SRC_BURST_PART_COUNT,  10,
            PSYS_SRC_BURST_RADIUS,      2.0,
            PSYS_SRC_BURST_SPEED_MIN,   1.0,
            PSYS_SRC_BURST_SPEED_MAX,   5.0,
            PSYS_SRC_MAX_AGE, 0.0]);
        llTriggerSound("01729e19-162b-699d-d45a-357a9d5e3656",1.0);
        llSensor("","",AGENT,5.0,PI);
}
key me;
integer hear;
boot()
{
    me=llGetKey();
    if(hear)llListenRemove(hear);//Clears old listen from when script is first ran
    integer hex=(integer)("0x" + llGetSubString(llMD5String((string)me,0), 0, 3));
    hear=llListen(hex,"","","");
    llSetObjectDesc("LBA.v.Missile,SKR");//Make sure this ends with ",SKR".  It's a painless change that prevents having to spam every LBA object in the detection radius with dummy messages. There is no reason not to do it and every ran to ban you for forgetting it.
}
purge(integer hex,key targ, string name,string fdmg)
{
    llRegionSayTo(llGetOwner(),-1995,"lba:"+name+":"+fdmg+":"+llKey2Name(llGetOwnerKey(targ)));
    if(hex)llRegionSayTo(targ,hex,(string)targ+","+fdmg);
    else llRegionSayTo(targ,-500,(string)targ+",damage,"+fdmg);
}
default
{
    state_entry()
    {
        boot();
    }
    on_rez(integer p)
    {
        boot();
    }
    listen(integer chan, string name, key id, string message)
    {
        //[ALWAYS] USE llRegionSayTo(). Do not flood the channel with useless garbage that'll poll every object in listening range.
        list parse=llParseString2List(message,[","],[" "]);
        if(llList2Key(parse,0)==me)//targetcheck
        {
            // In short: Damage = Kill rocket, Healing = Break Lockon, 0 = Redirect Rocket
            float amt=llList2Float(parse,-1);
            if(amt>0)die(llGetPos());//Took damage so kill
            else if(amt<0)llMessageLinked(-4,0,"","");//LinkMessage, in this case the integer parameter determines if the lack is broken or redirected. 0 = No lock, 1 = Redirect
            else llMessageLinked(-4,1,"",id);//We send the ID with this message so the tracking script knows what to lock on to.
            //You can build this into an existing tracking system if you prefer.
            //I just didn't have one I could easily implemented to use for this public example.
        }
    }
    collision_start(integer c)
    {
        die(llGetPos());
        key hit=llDetectedKey(0);
        string desc=llList2String(llGetObjectDetails(hit,[OBJECT_DESC]),0);
        if(llGetSubString(desc,0,1)=="v."||llGetSubString(desc,0,5)=="LBA.v.")
        {
            integer hex=(integer)("0x" + llGetSubString(llMD5String(hit,0), 0, 3));
            if(llGetSubString(desc,0,5)!="LBA.v.")hex=0;
            purge(hex,hit,llDetectedName(0),"50");
        }
    }
    land_collision_start(vector c)
    {
        die(c);
    }
    sensor(integer d)
    {
        key o=llGetOwner();
        integer chan=(integer)("0x" + llGetSubString(llMD5String(o,0), 0, 2));
        vector vel=llGetPos();
        while(d--)
        {
            key hit=llDetectedKey(d);
            vector tpos=llDetectedPos(d);
            list ray=llCastRay(tpos,vel,[RC_REJECT_TYPES,RC_REJECT_AGENTS]);
            if(llList2Vector(ray,1)==ZERO_VECTOR)
            {
                //llRezObject("Fragmentation Blast.DMG",vel,ZERO_VECTOR,ZERO_ROTATION,param);
                llRegionSayTo(o,chan+6,"dmg,"+llDetectedName(d)+","+(string)(115.0-(7.5*llVecDist(tpos,vel)))+","+(string)llDetectedKey(d));
            }
        }
        llSleep(1.0);
        llDie();
    }
    no_sensor()
    {
        llSleep(1.0);
        llDie();
    }
}
