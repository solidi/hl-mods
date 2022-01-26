# Dual Wield Process

1. Decompile model
1. Label as _dual_ in qc file
1. Create first skeleton snapshot at rest with left arm
    1. Create left arm by mirroring animation from front to back
    1. Open saved smd, copy right bone items to new smd file as left arm
1. For arm remapping, create key of old to new bone values
    1. Pad the number after replace so it doesnt overwrite other values.

## Example Key Mapping

Converting to SD arms,
pad with 0

Left
9 -> 17
10 -> 18
11 -> 19
12 -> 20
13 -> 21
14 -> 22
15 -> 23
16 -> 24
17 -> 25
18 -> 26
19 -> 27
20 -> 28
21 -> 29
22 -> 30
23 -> 31
24 -> 32
25 -> 33

Right
28 -> 9
29 -> 10
30 -> 35
31 -> 36
32 -> 37
33 -> 38
34 -> 39
35 -> 40
36 -> 41
37 -> 42
38 -> 43
39 -> 44
40 -> 45
41 -> 46
42 -> 47
43 -> 48
44 -> 49
