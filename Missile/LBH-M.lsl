//This variant of the LBH parser is for use inside lock-on rockets.
die()//Explosion/Death
{
    //Add extra shit here
    llDie();
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
            if(amt>0)die();//Took damage so kill
            else if(amt<0)llMessageLinked(-4,0,"","");//LinkMessage, in this case the integer parameter determines if the lack is broken or redirected. 0 = No lock, 1 = Redirect
            else llMessageLinked(-4,1,"",id);//We send the ID with this message so the tracking script knows what to lock on to.
            //You can build this into an existing tracking system if you prefer. 
            //I just didn't have one I could easily implemented to use for this public example.
        }
    }
    collision_start(integer c)
    {
        die();
    }
    land_collision_start(vector c)
    {
        die();
    }
}
Make sure to read the notes
