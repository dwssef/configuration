# python ~/.calDate.py 20220224 20220525
import datetime, sys

def cal_date(s):
    d1 = datetime.datetime(int(s[1][:4]),int(s[1][4:6]),int(s[1][6:]))
    d2 = datetime.datetime(int(s[2][:4]),int(s[2][4:6]),int(s[2][6:]))
    interval = d2 - d1
    print(interval.days)

cal_date(sys.argv)
test
