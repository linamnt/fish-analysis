import numpy as np
import pandas as pd
import csv
from itertools import takewhile

fname = '/home/lina/Downloads/20190531.csv' 

def parse_df(df):
    df = df.iloc[::2].reset_index(drop=True)
    df = (df.rename(columns=df.iloc[0])
            .drop(df.index[0])
            .replace(r'^\s*$', np.nan, regex=True)
            .dropna(axis=1,how='all') 
         )
    return df

def parse_csv(fname):
    with open(fname, 'r') as f:
        table = {}
        animals = []
        reader = csv.reader(f)
        for i in range(2):
            curr=next(reader)
        while True: 
            try:
                curr = next(reader)
                if "Subject Identification" in curr:
                    animal = curr[3]
                    animals.append(animal)
                    take = True
            except StopIteration:
                break 
            while take: 
                try:
                    trial = takewhile(lambda row: all(["Execution end" not in i for i in row]), reader)
                    table[animal] = [x for x in trial]
                    take = False
                    _ = next(reader)
                except StopIteration:
                    break

    dfs = []
    for df in table:
        dfs.append(pd.DataFrame(table[df][2:]))

    dfs = [parse_df(df) for df in dfs]
    for i,df in enumerate(dfs):
        df.to_csv("{}.csv".format('20190531-'+animals[i]), header=True)


parse_csv(fname)

