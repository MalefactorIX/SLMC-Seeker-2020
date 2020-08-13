//Note: This is designed around a rocket aligned with the Z-Axis, ie. the size profile would be something like <0.1,0.1,4.0>
boom(vector pos)
{
    llSetLinkPrimitiveParamsFast(-1,[PRIM_PHYSICS,0,PRIM_COLOR,-1,ZERO_VECTOR,0.0,PRIM_GLOW,-1,0.0]);
    //Add extra shit here
    llDie();
}
float velocity=100.0;
key target;
lock()
{
    vector target_pos=llList2Vector(llGetObjectDetails(target,[OBJECT_POS]),0);
    vector pos=llGetPos();
    if(target_pos!=ZERO_VECTOR)
    {
        if(llVecDist(target_pos,pos)>8.0)boom(target_pos);//Deadzone, assume the rocket hit the target if it reached within this radius of it.
        llLookAt(target_pos,.15,1);//Rotates rocket towards target position
        llSetVelocity(llVecNorm(target_pos-pos)*velocity,0);//Change velocity
    }
    else 
    {
        llLookAt(pos+(llGetVel()*1000.0),.15,1);//Locks rotation to current direction.
        llSetTimerEvent(0.0);//Target an-hero'd or went off-sim, either way there is nothing left to track.
    }
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
            llOwnerSay("/me tracking "+llKey2Name(target));//Initial target message
            llSetTimerEvent(0.1);//0.1 is 10 times a second. That should be good enough to track most legal aircraft.
        }
    }
    timer()
    {
        lock();
    }
}
Make sure to read notes.
