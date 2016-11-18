# coding:utf-8
import sys
import json

TIME = "HH:MM:SS"
KEBPS_IN = "Kbps in"
KBPS_OUT = "Kbps out"


def get_dict(time,kin,kout):
    d = {}
    d[TIME] = time
    d[KEBPS_IN] = kin
    d[KBPS_OUT] = kout
    return d

def run(myfile):
    dicts_list = []
    with open(myfile,'r') as f:
        lines = f.readlines()
        for i,v in enumerate(lines):
            if i % 24 == 0 or i % 24 == 1:
                continue
            else:
                time,kin,kout = v.strip().split()
                dicts_list.append(get_dict(time,kin,kout))
    str_out = json.dumps(dicts_list)
    with open(sys.argv[1]+"out.json",'w') as f:
        f.write(str_out)
        f.flush()



if __name__ == '__main__':
    filename = sys.argv[1]
    run(filename)
