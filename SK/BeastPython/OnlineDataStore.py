
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
    mydb.commit()
    if old_count != new_count:    
        c2 = mydb.cursor(buffered=True)    
        c2.execute("Select ip,ip_id from xp_location where ip_id>'"+str(old_count)+"' AND ip_id<='"+str(new_count)+"'")
        for row in c2:    
            url = "http://api.ipstack.com/"+row[0].strip()+"?access_key=2f8c01c0484028dc8cb07748187bc350"
            row = str(row[0])
            print("\nNew IP found: {} \n".format(row))
            myResponse = requests.get(url)
            if(myResponse.ok):
                jData = json.loads(myResponse.content)
            
                ip= 'no' if jData['ip'] ==None else jData['ip']
                jtype = 'no' if jData['type'] ==None else jData['type']
                continent_code= 'no' if jData['continent_code'] ==None else jData['continent_code']
                continent_name='no' if jData['continent_name'] ==None else jData['continent_name']
                
                country_code= 'no' if jData['country_code'] ==None else jData['country_code']
                country_name= 'no' if jData['country_name'] ==None else jData['country_name']

                region_code = 'no' if jData['region_code'] ==None else jData['region_code']
                region_name = 'no' if jData['region_name'] ==None else jData['region_name']
                                
                city = 'no' if jData['city'] ==None else jData['city']
                jzip = 'no' if jData['zip'] ==None else jData['zip']

                latitude = 'no' if jData['latitude'] ==None else jData['latitude']
                longitude = 'no' if jData['longitude'] ==None else jData['longitude']
                
                sql = "UPDATE xp_location SET \
                        ip='"+str(ip)+"',\
                        type='"+str(jtype)+"',\
                        continent_code='"+str(continent_code)+"',\
                        continent_name='"+str(continent_name)+"',\
                        country_code='"+str(country_code)+"',\
                        country_name='"+str(country_name)+"',\
                        region_code='"+str(region_code)+"',\
                        region_name='"+str(region_name)+"',\
                        city='"+str(city)+"',\
                        zip='"+str(jzip)+"',\
                        latitude='"+str(latitude)+"',\
                        longitude='"+str(longitude)+"' WHERE ip='"+str(row)+"'"
                print(sql)
                c3 = mydb.cursor()
                c3.execute(sql)            
                print("\nRecord updated...!\n")
            else:
                myResponse.raise_for_status()
            
    with open("last_date.txt", "w") as f1:
        f1.write(str(new_count))
        mydb.commit()

print("Listening your databases..!")
while True:
    try:
        getLocation()
    except:
        getLocation()
