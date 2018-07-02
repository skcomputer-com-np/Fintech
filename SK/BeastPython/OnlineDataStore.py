
####Online database stored 
from datetime import date, datetime, timedelta
import requests
from requests.auth import HTTPDigestAuth
import json
import mysql.connector

mydb = mysql.connector.connect(
    host="db4free.net",
    user="sksingh",
    password="Sudb@5277",
    database='demopython'
)

def getLocation():
    with open("last_date.txt", "r") as f2:
        old_count = f2.readline()
        
    c1 = mydb.cursor(buffered=True)
    c1.execute("Select max(ip_id) from xp_location")
    for x in c1:
        new_count =x[0] 


    print("Old Record No:{}".format(old_count))
    print("New Record No:{}".format(new_count))    

    mydb.commit()
    c2 = mydb.cursor(buffered=True)
    c2.execute("Select ip,ip_id from xp_location where ip_id>'"+str(old_count)+"' AND ip_id<='"+str(new_count)+"'")
    for row in c2:    
        url = "http://api.ipstack.com/"+row[0].strip()+"?access_key=2f8c01c0484028dc8cb07748187bc350"
        
        myResponse = requests.get(url)
        if(myResponse.ok):
            jData = json.loads(myResponse.content)
            sql = "UPDATE xp_location SET \
                    ip='"+jData['ip']+"',\
                    type='"+jData['type']+"',\
                    continent_code='"+jData['continent_code']+"',\
                    continent_name='"+jData['continent_name']+"',\
                    country_code='"+jData['country_code']+"',\
                    country_name='"+jData['country_name']+"',\
                    region_code='"+jData['region_code']+"',\
                    region_name='"+jData['region_name']+"',\
                    city='"+jData['city']+"',\
                    zip='"+jData['zip']+"', latitude='"+str(jData['latitude'])+"',longitude='"+str(jData['longitude'])+"' WHERE ip='"+str(row[0]).strip()+"'"
            print(sql)
            c3 = mydb.cursor()
            c3.execute(sql)
            print("\nNew recored updated...!\n")
        else:
            myResponse.raise_for_status()
        
    with open("last_date.txt", "w") as f1:
        f1.write(str(new_count))
    mydb.commit()
    
while True:
    try:
        getLocation()
    except TypeError:
        getLocation()
        
