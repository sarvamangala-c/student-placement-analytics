import pandas as pd, sys, os
sys.path.insert(0, r'd:\data\student-placement-analytics\backend')
os.chdir(r'd:\data\student-placement-analytics\backend')

from analysis.analyzer import load_data, get_students

df = load_data()

print("=== All departments and counts ===")
print(df['department'].value_counts())
print()

for dept in ['EEE', 'MECH', 'CSE', 'IT', 'ECE']:
    result = get_students(df, department=dept)
    print(f"{dept}: {len(result)} students")

print()
print("=== EEE students raw ===")
eee = df[df['department'].str.upper() == 'EEE']
print(eee[['id','name','department']].to_string())

print()
print("=== MECH students raw ===")
mech = df[df['department'].str.upper() == 'MECH']
print(mech[['id','name','department']].to_string())
