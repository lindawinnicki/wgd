# genome duplication pipeline
##  wgd v2.0.38
- mafft v7.525 (2024/Mar/13)
- FastTree 2.2.0
- mcl 22-282
- diamond version 2.0.6

# ewdsssssss555555 // tangens


## Auricularia_delicata.fasta
- 1531 scaffolds
- 74920203 bp
- 69053340 bp w/o N
- 169070 genes
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

## Aurde1_AssemblyScaffolds.fasta.gz
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

## Exigl1_AssemblyScaffolds.fasta
- 1727 scaffolds
- 78171509 bp
- 71707041 bp w/o N
- 322147 genes 
  - (Exigl1_all_proteins_20130529.aa.fasta.gz)
````bash N DIST
     53 10N
     77 11N
     58 12N
     65 13N
     82 14N
     51 15N
     66 16N
     67 17N
     66 18N
     76 19N
     60 20N
     60 21N
     60 22N
     62 23N
     65 24N
     66 25N
     63 26N
     64 27N
     58 28N
     61 29N
     49 30N
     74 31N
     69 32N
     70 33N
     72 34N
     73 35N
     56 36N
     61 37N
     74 38N
     73 39N
     65 40N
     63 41N
     63 42N
     67 43N
     79 44N
     63 45N
     56 46N
     53 47N
     75 48N
     76 49N
     63 50N
     88 51N
     78 52N
     68 53N
     67 54N
     60 55N
     55 56N
     67 57N
     63 58N
     76 59N
     83 60N
     76 61N
     57 62N
     64 63N
     67 64N
     57 65N
     72 66N
     60 67N
     54 68N
     61 69N
  90072 70N
````
# wgd

````bash
# dmd
# for prot just add --prot
nohup wgd dmd \\
Data/Aurde1/Data/Aurde1/Aurde1_GeneCatalog_CDS_20110213.fasta \\ 
-o Results/CDS_DMD/Auri/ \\
-n 10 > Results/CDS_DMD/Auri/aurdi.out 2>&1 &

nohup wgd dmd \\
Data/Exigl1/Exigl1_GeneCatalog_CDS_20130529.fasta \\
-o Results/CDS_DMD/Exig \\
-n 10 > Results/CDS_DMD/Exig/exig.out 2>&1 &

nohup wgd dmd \\
Data/Calco1/Calco1_GeneCatalog_CDS_20130417.fasta \\
-o Results/CDS_DMD/Calco/ \\
-n 15 > Results/CDS_DMD/Calco/calco_dmd.out 2>&1 &

# ksd
nohup wgd ksd \\
Results/CDS_DMD/Auri/Aurde1_GeneCatalog_CDS_20110213.fasta.tsv \\
Data/Aurde1/Aurde1_GeneCatalog_CDS_20110213.fasta \\
-o Results/CDS_KSD/Auri/ \\
-n 15 > Results/CDS_KSD/Auri/auri_ksd.out 2>&1 &

nohup wgd ksd \\
Results/CDS_DMD/Exig/Exigl1_GeneCatalog_CDS_20130529.fasta.tsv \\
Data/Exigl1/Exigl1_GeneCatalog_CDS_20130529.fasta \\
-o Results/CDS_KSD/Exig/ \\
-n 15 > Results/CDS_KSD/Exig/exig_ksd.out 2>&1 &

nohup wgd ksd \\
Results/CDS_DMD/Calco/Calco1_GeneCatalog_CDS_20130417.fasta.tsv \\
Data/Calco1/Calco1_GeneCatalog_CDS_20130417.fasta \\
-o Results/CDS_KSD/Calco/ \\
-n 15 > Results/CDS_KSD/Calco/calco_ksd.out 2>&1 &
````
JGI has labeled their fasta file with headers like ">jgi|Aurde1|155376|gm1.1_g" instead of just "gm1.1_g" in their CDS-fasta files, but not the gff3 file. So we are using sed to update so they match when we use them in the synteny analysis. We do it fo the ks.tsv (wgd ksd) and .tsv (from wgd dmd), instead of in the fasta file so we don't have to rerun the analysis.

````bash
sed 's/jgi|Aurde1|[0-9]*|//g' # remove jgi|Aurde1|literally + any number up until the next| (keeping only the gene name), and do this "globally"
Aurde1_GeneCatalog_CDS_20110213.fasta.tsv > Aurde1_GeneCatalog_CDS_20110213_clean.fasta.tsv

sed 's/jgi|Aurde1|[0-9]*|//g' Aurde1_GeneCatalog_CDS_20110213.fasta.tsv.ks.tsv > Aurde1_GeneCatalog_CDS_20110213_clean.fasta.tsv.ks.tsv

sed 's/jgi|Exigl1|[0-9]*|//g' Exigl1_GeneCatalog_CDS_20130529.fasta.tsv > Exigl1_GeneCatalog_CDS_20130529_clean.fasta.tsv

sed 's/jgi|Exigl1|[0-9]*|//g' Exigl1_GeneCatalog_CDS_20130529.fasta.tsv.ks.tsv > Exigl1_GeneCatalog_CDS_20130529_clean.fasta.tsv.ks.tsv
````

Another issue is that not any of the Exidia gff files match the gene names in our cleaned up files (nor the "raw" ones), so I made a pythonscript that creates a .gff file that will match:

````bash
python Scripts/gff_make_genes.py
````
Now we can run the two wgd syn analysis:
````bash
nohup wgd syn Results/CDS_DMD/Auri/Aurde1_GeneCatalog_CDS_20110213_clean.fasta.tsv -a Name -f gene Data/Aurde1/Aurde1_GeneModels_FilteredModels1.gff3 -ks Results/CDS_KSD/Auri/Aurde1_GeneCatalog_CDS_20110213_clean.fasta.tsv.ks.tsv -o Results/CDS_SYN/Auri -n 15 > Results/CDS_SYN/Auri/auri_syn.out 2>&1 &

nohup wgd syn Results/CDS_DMD/Exig/Exigl1_GeneCatalog_CDS_20130529_clean.fasta.tsv Scripts/exidia.gff -ks Results/CDS_KSD/Exig/Exigl1_GeneCatalog_CDS_20130529_clean.fasta.tsv.ks.tsv -o Results/CDS_SYN/Exig -n 15 > Results/CDS_SYN/Exig/exig_syn.out 2>&1 &
````