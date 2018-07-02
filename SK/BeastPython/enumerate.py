staff_data = [ ("William", "Shakespeare", "m", "1961-10-25"),
               ("Frank", "Schiller", "m", "1955-08-17"),
               ("Jane", "Wall", "f", "1989-03-14"),
               ]

for staff, p in enumerate(staff_data,3): #Start Index from 3
    print(staff,p)
    print
    
# OutPut
# 3 ('William', 'Shakespeare', 'm', '1961-10-25')
# 4 ('Frank', 'Schiller', 'm', '1955-08-17')
# 5 ('Jane', 'Wall', 'f', '1989-03-14')
