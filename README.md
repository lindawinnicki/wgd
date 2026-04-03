# genome duplication pipeline
##  wgd v2.0.38
- mafft v7.525 (2024/Mar/13)
- FastTree 2.2.0
- mcl 22-282
- diamond version 2.0.6
- i-ADHoRe version 3.0 19 November 2007
- BUSCO 6.0.0
- BBtools 39.81 (3 March 2020)
# ewdsssssss555555 // tangens


## Auricularia_delicata.fasta
- 1531 scaffolds
- 74920203 bp
- 69053340 bp w/o N
- 169070 genes
````bash N DISTRIBUTION
cat Auricularia_delicata.fasta | grep -oP 'N{10,}' | awk '{print length($0)}' | sort -n | uniq -c
````

## Aurde1_AssemblyScaffolds.fasta.gz
- 666 scaffolds
- 74920203 bp
- 69053340 bp w/o N

## Exigl1_AssemblyScaffolds.fasta
- 1727 scaffolds
- 78171509 bp
- 71707041 bp w/o N
- 322147 genes 
  - (Exigl1_all_proteins_20130529.aa.fasta.gz)

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
# auricularia
sed 's/jgi|Aurde1|[0-9]*|//g' # remove jgi|Aurde1|literally + any number up until the next| (keeping only the gene name), and do this "globally" 
Aurde1_GeneCatalog_CDS_20110213.fasta.tsv > Aurde1_GeneCatalog_CDS_20110213_clean.fasta.tsv

sed 's/jgi|Aurde1|[0-9]*|//g' \\
Aurde1_GeneCatalog_CDS_20110213.fasta.tsv.ks.tsv > Aurde1_GeneCatalog_CDS_20110213_clean.fasta.tsv.ks.tsv

#exidia 

sed 's/jgi|Exigl1|[0-9]*|//g' \\
Exigl1_GeneCatalog_CDS_20130529.fasta.tsv > Exigl1_GeneCatalog_CDS_20130529_clean.fasta.tsv

sed 's/jgi|Exigl1|[0-9]*|//g' \\
Exigl1_GeneCatalog_CDS_20130529.fasta.tsv.ks.tsv > Exigl1_GeneCatalog_CDS_20130529_clean.fasta.tsv.ks.tsv

# calco
sed 's/jgi|Calco1|[0-9]*|//g' \\
Calco1_GeneCatalog_CDS_20130417.fasta.tsv > Calco1_GeneCatalog_CDS_20130417_clean.fasta.tsv

sed 's/jgi|Calco1|[0-9]*|//g' \\
Calco1_GeneCatalog_CDS_20130417.fasta.tsv.ks.tsv > Calco1_GeneCatalog_CDS_20130417_clean.fasta.tsv.ks.tsv
````

Another issue is that not any of the Exidia gff files match the gene names in our cleaned up files (nor the "raw" ones), so I made a pythonscript that creates a .gff file that will match:

````bash
python Scripts/gff_make_genes.py \\
Data/Exigl1/Exigl1_all_genes_20130529.gff \\
Data/Exigl1/exigl.gff

python Scripts/gff_make_genes.py \\
Data/Calco1/Calco1_all_genes_20130417.gff \\ #input
Data/Calco1/calco.gff # output
````
Now we can run the two wgd syn analysis:
````bash
nohup wgd syn \\
Results/CDS_DMD/Auri/Aurde1_GeneCatalog_CDS_20110213_clean.fasta.tsv \\
-a Name \\
-f gene \\
Data/Aurde1/Aurde1_GeneModels_FilteredModels1.gff3 \\
-ks Results/CDS_KSD/Auri/Aurde1_GeneCatalog_CDS_20110213_clean.fasta.tsv.ks.tsv \\
-o Results/CDS_SYN/Auri \\
-n 15 > Results/CDS_SYN/Auri/auri_syn.out 2>&1 &

nohup wgd syn \\
Results/CDS_DMD/Exig/Exigl1_GeneCatalog_CDS_20130529_clean.fasta.tsv \\
Scripts/exidia.gff \\
-ks Results/CDS_KSD/Exig/Exigl1_GeneCatalog_CDS_20130529_clean.fasta.tsv.ks.tsv \\
-o Results/CDS_SYN/Exig \\
-n 15 > Results/CDS_SYN/Exig/exig_syn.out 2>&1 &

nohup wgd syn \\
Results/CDS_DMD/Calco/Calco1_GeneCatalog_CDS_20130417_clean.fasta.tsv \\
Data/Calco1/calco.gff \\
-ks Results/CDS_KSD/Calco/Calco1_GeneCatalog_CDS_20130417_clean.fasta.tsv.ks.tsv \\
-o Results/CDS_SYN/Calco \\
-n 15 > Results/CDS_SYN/Calco/calco_syn.out 2>&1 &
````

# a bit weirdf order, but lets do a quality check using busco

````bash
nohup busco \\ #v6.0.0
-i Data/Exigl1/Exigl1_GeneCatalog_proteins_20130529.aa.fasta \\
-l agaricomycetes_odb12 \\
-o Results/2_quality/Exig \\
-m prot \\
-c 15 -f > Results/2_quality/Exig/exig_busco.out 2>&1 &
````
- C:94.3%[S:81.0%,D:13.3%],F:2.9%,M:2.9%,n:3398
````bash
nohup busco \\ #v6.0.0
-i Data/Aurde1/Aurde1_GeneCatalog_proteins_20110213.aa.fasta \\
-l agaricomycetes_odb12 \\
-o Results/2_quality/Auri \\
-m prot \\
-c 15 -f & # never got an .outfile from the cmd above
````
- C:91.0%[S:89.1%,D:2.0%],F:2.7%,M:6.3%,n:3398

````bash
nohup busco \\
-i Data/Calco1/Calco1_GeneCatalog_proteins_20130417.aa.fasta \\
-l basidiomycota_odb12 \\ # dacrymecetes has no linage in busco
-o Results/2_quality/Calco \\
-m prot \\
-c 15 \\
-f &
````

# statistics of each assembly using bbtools
````bash
# download bbtools
cd ~/bin
mkdir BBMap
cd BBMap
wget "https://sourceforge.net/projects/bbmap/files/BBMap_39.81b.tar.gz"
gunzip BBMap_39.81b.tar.gz
tar -xvf BBMap_39.81b.tar --strip-components=1

# statistics
cd wgd/Results/3_assembly_stats/

stats.sh \\ # auri
in=../../Data/Aurde1/Aurde1_AssemblyScaffolds.fasta.gz \\
out=Auri/auri_stats.txt

stats.sh \\ # exidia
in=../../Data/Exigl1/Exigl1_AssemblyScaffolds.fasta \\
out=Exig/exig_stats.txt

stats.sh \\ # calocera
in=../../Data/Calco1/Calco1_AssemblyScaffolds.fasta.gz \\
out=Calco/calco_stats.txt
````

# wgd analysis of all three species
this time, we run a sed to modify the jgi headers prior to analysis, to ease the downstream wgd tools
````bash
cd Data
mkdir Clean_Data
cd Clean_Data
mkdir Auri Calco Exig
sed 's/jgi|Exigl1|[0-9]*|//g' ../Exigl1/Exigl1_GeneCatalog_CDS_20130529.fasta > Exig/Exigl1_GeneCatalog_CDS_20130529_clean.fasta

sed 's/jgi|Aurde1|[0-9]*|//g' ../Aurde1/Aurde1_GeneCatalog_CDS_20110213.fasta > Auri/Aurde1_GeneCatalog_CDS_20110213_clean.fasta

sed 's/jgi|Calco1|[0-9]*|//g' ../Calco1/Calco1_GeneCatalog_CDS_20130417.fasta > Calco/Calco1_GeneCatalog_CDS_20130417_clean.fasta
````

# wgd viz ELMM 
````bash
wgd viz \\
-d Results/CDS_KSD/Auri/Aurde1_GeneCatalog_CDS_20110213_clean.fasta.tsv.ks.tsv \\ # kmd 
-o Results/CDS_VIZ/Auri/

nohup wgd viz -d Results/CDS_KSD/Exig/Exigl1_GeneCatalog_CDS_20130529_clean.fasta.tsv.ks.tsv -o Results/CDS_VIZ/Exig/ -n 15 > Results/CDS_VIZ/Exig/exig_viz.out 2>&1 &

nohup wgd viz -d Results/CDS_KSD/Calco/Calco1_GeneCatalog_CDS_20130417_clean.fasta.tsv.ks.tsv -o Results/CDS_VIZ/Calco/ -n 15 > Results/CDS_VIZ/Calco/calco_viz.out 2>&1 &
````

# cleaning up among the folders, easier for readability
````bash
for file in */*/*; do # for every file 1 folder downstream
shortname=$(echo "$file"|sed 's/GeneCatalog_CDS_[0-9_]*_//g') # remove the "GeneCatalog_CDS_..." from each file name
if [ "$file" != "$shortname" ]; then # if something changed, make it permanent, else skip
mv "$file" "$shortname"
fi
done
````