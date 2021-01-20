//Note: This is designed around a rocket aligned with the Z-Axis, ie. the size profile would be something like <0.1,0.1,4.0>
boom(vector pos)
{
    //Add extra shit here
    llSetLinkPrimitiveParamsFast(-1,[PRIM_PHYSICS,0,PRIM_PHANTOM,1,PRIM_COLOR,-1,ZERO_VECTOR,0.0,PRIM_GLOW,-1,0.0]);
    llStopSound();
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
    if(target)purge();
}
float velocity=80.0;//How fast the rocket goes as it tracks
key target;
lock()
{
    vector target_pos=llList2Vector(llGetObjectDetails(target,[OBJECT_POS]),0);
    vector pos=llGetPos();
    if(target_pos!=ZERO_VECTOR)
    {
        if(llVecDist(target_pos,pos)<5.0)boom(target_pos);//Deadzone, assume the rocket hit the target if it reached within this radius of it.
        llLookAt(target_pos,.15,1);//Rotates rocket towards target position
        llSetVelocity(llVecNorm(target_pos-pos)*velocity,0);//Change velocity
    }
    else
    {
        llLookAt(pos+(llGetVel()*1000.0),.15,1);//Locks rotation to current direction.
        llSetTimerEvent(0.0);//Target an-hero'd or went off-sim, either way there is nothing left to track.
    }
}
integer hex;
purge()
{
    llRegionSayTo(llGetOwner(),-1995,"lba:"+llKey2Name(target)+":45:"+llKey2Name(llGetOwnerKey(target)));
    if(hex)llRegionSayTo(target,hex,(string)target+",45");
    else llRegionSayTo(target,-500,(string)target+",damage,45");
}
default
{
    state_entry()
    {
        llLoopSound("1bd2d48b-c8ff-d8ab-859f-a60b3f6cd4d5",1.0);//Woosh
    }
    link_message(integer s, integer n, string m, key id)
    {
        if(n)target=id;//Redirect target
        else
        {
            llLookAt(llGetPos()+(llGetVel()*1000.0),.15,1);//Locks rotation to current direction.
            llSetTimerEvent(0.0);//Kill tracker
        }
    }
    on_rez(integer p)
    {
        if(p)
        {

            string data=(string)llGetObjectDetails(llGetKey(),[OBJECT_REZZER_KEY]);
            data=(string)llGetObjectDetails(data,[OBJECT_DESC]);//We store the target's UUID in the launcher's description.
            target=data;//Then store it here so the rocket knows what to target.
            string desc=llList2String(llGetObjectDetails(target,[OBJECT_DESC]),0);
            hex=(integer)("0x" + llGetSubString(llMD5String(target,0), 0, 3));
            if(llGetSubString(desc,0,5)!="LBA.v.")hex=0;
            if(target)llOwnerSay("/me tracking "+llKey2Name(target));//Initial target message
            llRegionSayTo(llGetOwnerKey(target),-1567,"missile");
            llSetTimerEvent(0.1);//0.1 is 10 times a second. That should be good enough to track most legal aircraft.
        }
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
    timer()
    {
        lock();
    }
}
