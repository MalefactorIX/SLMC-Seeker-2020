string texture = "b3377724-7e2a-db60-df07-66d8229a1ae0";
particle()
{
    llParticleSystem([
PSYS_PART_FLAGS,(0
|PSYS_PART_EMISSIVE_MASK
|PSYS_PART_INTERP_COLOR_MASK
|PSYS_PART_INTERP_SCALE_MASK
|PSYS_PART_FOLLOW_SRC_MASK),
PSYS_PART_START_COLOR,llGetColor(0),
PSYS_PART_END_COLOR,llGetColor(0),
PSYS_PART_START_ALPHA,0.50000,
PSYS_PART_END_ALPHA,0.000000,
PSYS_PART_START_SCALE,<3.00000, 3.00000, 0.00000>,
PSYS_PART_END_SCALE,<3.0000, 3.00000, 0.00000>,
PSYS_PART_MAX_AGE,1.00000,
PSYS_PART_START_GLOW,0.10000,
PSYS_PART_END_GLOW,0.00000,
PSYS_SRC_ACCEL,<0.00000, 0.00000, 0.30000>,
PSYS_SRC_PATTERN,8,
PSYS_SRC_TEXTURE,texture,
PSYS_SRC_BURST_RATE,0.030000,
PSYS_SRC_BURST_PART_COUNT,1,
PSYS_SRC_BURST_RADIUS,0.100000,
PSYS_SRC_BURST_SPEED_MIN,0.10000,
PSYS_SRC_BURST_SPEED_MAX,0.200000,
PSYS_SRC_MAX_AGE,0.000000,
PSYS_SRC_OMEGA,<10.00000, -100.00000, 10.00000>,
PSYS_SRC_ANGLE_BEGIN,1.0,
PSYS_SRC_ANGLE_END,1.0]);
}
string spark = "2ad28de8-91b4-1c9b-df30-56e2e57ad116";
particley()
{
    llLinkParticleSystem(2,[
PSYS_PART_FLAGS,(0
|PSYS_PART_EMISSIVE_MASK
|PSYS_PART_INTERP_COLOR_MASK
|PSYS_PART_INTERP_SCALE_MASK ),
//|PSYS_PART_FOLLOW_SRC_MASK),
PSYS_PART_START_COLOR,llGetColor(0),
PSYS_PART_END_COLOR,llGetColor(0),
PSYS_PART_START_ALPHA,0.50000,
PSYS_PART_END_ALPHA,0.000000,
PSYS_PART_START_SCALE,<0.10000, 0.100000, 0.00000>,
PSYS_PART_END_SCALE,<0.0000, 0.00000, 0.00000>,
PSYS_PART_MAX_AGE,1.00000,
PSYS_PART_START_GLOW,0.30000,
PSYS_PART_END_GLOW,0.00000,
PSYS_SRC_ACCEL,<0.00000, 0.00000, 0.00000>,
PSYS_SRC_PATTERN,2,
PSYS_SRC_TEXTURE,spark,
PSYS_SRC_BURST_RATE,0.050000,
PSYS_SRC_BURST_PART_COUNT,10,
PSYS_SRC_BURST_RADIUS,3.00000,
PSYS_SRC_BURST_SPEED_MIN,0.20000,
PSYS_SRC_BURST_SPEED_MAX,0.300000,
PSYS_SRC_MAX_AGE,0.000000,
PSYS_SRC_OMEGA,<0.00000, 0.00000, 0.00000>,
PSYS_SRC_ANGLE_BEGIN,PI,
PSYS_SRC_ANGLE_END,PI]);
}
purge(integer hex,key targ, string name)
{
    llRegionSayTo(o,-1995,"lba:"+name+":Interception:"+llKey2Name(llGetOwnerKey(targ)));
    if(hex)llRegionSayTo(targ,hex,(string)targ+",0");
    else llRegionSayTo(targ,-500,(string)targ+",damage,0");
}
key o;
default
{
    state_entry()
    {
        particle();
        particley();
    }
    on_rez(integer p)
    {
        if(p)
        {
            llSensorRepeat("","",10,50.0,PI,0.5);
            llSetTimerEvent(10.0);
            o=llGetOwner();
        }
    }
    sensor(integer d)
    {
        vector pos=llGetPos();
        while(d--)
        {
            vector epos=llDetectedPos(d);
            key oid=llDetectedKey(d);
            list ray=llCastRay(pos,epos,[RC_DATA_FLAGS,RC_GET_ROOT_KEY,RC_REJECT_TYPES,RC_REJECT_AGENTS,RC_DATA_FLAGS,RC_GET_ROOT_KEY,RC_MAX_HITS,1]);
            key hit=llList2Key(ray,0);
            if(llList2Vector(ray,1)==ZERO_VECTOR||hit==oid)
            {
                string desc=llList2String(llGetObjectDetails(oid,[OBJECT_DESC]),0);
                if(llGetSubString(desc,0,1)=="v."||llGetSubString(desc,0,5)=="LBA.v.")
                {
                    if(llList2String(llCSV2List(desc),-1)=="SKR")
                    {
                        integer hex=(integer)("0x" + llGetSubString(llMD5String(oid,0), 0, 3));
                        if(llGetSubString(desc,0,5)!="LBA.v.")hex=0;
                        purge(hex,oid,llDetectedName(d));
                    }
                }
            }
        }
    }
    timer()
    {
        llDie();
    }
}
