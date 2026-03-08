# genome duplication pipeline
##  wgd v2.0.38
mafft v7.525 (2024/Mar/13)
FastTree 2.2.0
mcl 22-282
diamond version 2.0.6

ewdsssssss555555 // tangens

# data
Auricularia_delicata.fasta
- 1531 scaffolds
- 74920203 bp
- 69053340 bp w/o N
````bash N DISTRIBUTION
cat Auricularia_delicata.fasta | grep -oP 'N{10,}' | awk '{print length($0)}' | sort -n | uniq -c
# N distribution
    107 10N
    128 11N
     79 12N
    110 13N
     90 14N
    122 15N
    118 16N
    110 17N
    125 18N
    117 19N
    322 20N
     87 21N
    107 22N
     91 23N
    101 24N
     85 25N
     97 26N
     97 27N
     99 28N
     97 29N
    101 30N
     92 31N
     97 32N
     87 33N
     86 34N
     84 35N
     81 36N
     82 37N
    105 38N
     92 39N
     97 40N
     73 41N
    115 42N
     83 43N
     73 44N
     96 45N
    108 46N
    100 47N
    100 48N
    102 49N
     91 50N
     66 51N
     87 52N
     90 53N
     92 54N
     83 55N
     89 56N
     88 57N
     95 58N
    104 59N
  94934 60N
````

Aurde1_AssemblyScaffolds.fasta.gz
- 666 scaffolds
- 74920203 bp
- 69053340 bp w/o N
````bash N DISTRIBUTION
     76 10N
     92 11N
     96 12N
     99 13N
     89 14N
     79 15N
     93 16N
     78 17N
     95 18N
     92 19N
    327 20N
     83 21N
     98 22N
     71 23N
     64 24N
     72 25N
     74 26N
     63 27N
     94 28N
     80 29N
     80 30N
     81 31N
     79 32N
     87 33N
     81 34N
     60 35N
     77 36N
     83 37N
     78 38N
     89 39N
     75 40N
     65 41N
     82 42v
     74 43N
     69 44N
     92 45N
     98 46N
     87 47N
     99 48N
    108 49N
     84 50N
     77 51N
     83 52N
     82 53N
     82 54N
     70 55N
     69 56N
     89 57N
     88 58N
     81 59N
     83 60N
     79 61N
     69 62N
     74 63N
     80 64N
     90 65N
     77 66N
     88 67N
     90 68N
     81 69N
  80915 70N
````


# wgd

````bash
nohup wgd dmd ../Data/Aurde1/auri.fasta -o Auri_dmd/ &
 nohup wgd dmd ../Data/Exigl1/exig.fasta -o Exig_dmd/


nohup wgd ksd ../DMD/Auri_dmd/auri.fasta.tsv ../../Data/Aurde1/auri.fasta -o Auri_ksd &
````