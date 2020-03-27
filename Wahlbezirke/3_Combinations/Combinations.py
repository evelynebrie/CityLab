#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Mar 25 12:18:18 2020

@author: evelynebrie
"""


def sorted_k_partitions(seq, k):
    n = len(seq)
    groups = []  # a list of lists, currently empty

    def generate_partitions(i):
        if i >= n:
            yield list(map(tuple, groups))
        else:
            if n - i > k - len(groups):
                for group in groups:
                    group.append(seq[i])
                    yield from generate_partitions(i + 1)
                    group.pop()

            if len(groups) < k:
                groups.append([seq[i]])
                yield from generate_partitions(i + 1)
                groups.pop()

    result = generate_partitions(0)

    # Sort the parts in each partition in shortlex order
    result = [sorted(ps, key = lambda p: (len(p), p)) for ps in result]
    # Sort partitions by the length of each part, then lexicographically.
    result = sorted(result, key = lambda ps: (*map(len, ps), ps))

    return result

#%%
    
seq = list(range(1, 1033))

#%%

k = 123

#%%

x = sorted_k_partitions(seq, k)

#%%

import csv

with open("/Users/evelynebrie/Dropbox/CityLab/Combinations_Python.csv", "w", newline="") as f:
    writer = csv.writer(f)
    writer.writerows(x)
    
