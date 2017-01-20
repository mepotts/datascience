import sys
import csv
import glob
import pandas as pd

import os

mypath =r'C:\_workspace\2016'

file_paths = []  # List which will store all of the full filepaths.

# Walk the tree.
for root, directories, files in os.walk(mypath):
    for filename in files:
        # Join the two strings in order to form the full filepath.
        filepath = os.path.join(root, filename)
        file_paths.append(filepath)  # Add it to the list.



files_xls = [f for f in file_paths if f[-4:] == 'xlsx']

df2 = pd.DataFrame()

for f in files_xls:
    try:
        data = pd.read_excel(f, 'Leads')
        date = f[-11:-5]
        data['DateBilled'] = date
        data = data[['SCANCODE', 'CPL', 'DateBilled']]
        data = data[data['SCANCODE'].notnull()]
        df2 = df2.append(data)
    except:
        pass

scancodes = df2["SCANCODE"]
x = df2[scancodes.isin(scancodes[scancodes.duplicated()])].sort_values(by = ["DateBilled", "SCANCODE"])

#x = df2[df2.duplicated(['SCANCODE'], keep=False)].groupby(('SCANCODE')).min()

x.to_csv('billedleadsdups.csv', encoding='utf-8')
