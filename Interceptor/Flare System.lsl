float duration=15.0;//How long the interceptor lasts
float radius=50.0;//How far it can intercept a missile from
string flare="0";//Reminder: 0 = Redirect, -1 =  Break-Lockon, 1 = Kill Missile.
//In summary:
//Flares should use 0
//EMPs should use -1
//ADS should use 1
list storage;//Stores targets we already hit so we aren't spamming them.
purge(integer hex,key targ, string name)
{
    llOwnerSay("Intercepted "+name);
    if(hex)llRegionSayTo(targ,hex,(string)targ+","+flare);
    else llRegionSayTo(targ,-500,(string)targ+",damage,"+flare);
}
default
{
    on_rez(integer p)
    {
        if(p)
        {
            llSensorRepeat("","",10,radius,PI,1.0);
            //Note that SensorRepeat starts working AFTER its activated not the MOMENT it is activated. This means you have to wait 1 second before the first sensor is fired. So panic-flares aren't going to be a thing.
            llSetTimerEvent(duration);
        }
    }
    sensor(integer d)
    {
    //Note: This does not feature line-of-sight checks. You will have to add your own.
        while(d--)
        {
            key hit=llDetectedKey(d);
            if(llListFindList(storage,[hit])<0)//Don't hit the same target multiple times
            {
                string data=(string)llGetObjectDetails(hit,[OBJECT_DESC]);//Get DESC
                list parse=llCSV2List(llToUpper(data));//Parse DESC, ToUpper is used to case sensitivity
                if(llList2String(parse,-1)=="SKR")//Look for missile flag
                {
                    integer hex=(integer)("0x" + llGetSubString(llMD5String(hit,0), 0, 3));
                    if(llGetSubString(llList2String(parse,0),0,5)!="LBA.v.")hex=0;//v1.X Detection
                    purge(hex,hit,llDetectedName(d));
                    storage+=hit;//store target in list
                }
            }
        }
    }
    timer()
    {
        llDie();
    }
}
Make sure to read the notes.
