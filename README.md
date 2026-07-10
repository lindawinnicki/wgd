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

# measurements / parameters of *Auricularia subglabra*
## Auricularia_delicata.fasta
- 1531 scaffolds
- 74920203 bp
- 69053340 bp w/o N
- 169070 genes
## GFF 
- 1425 scaffolds (cut -f1 Data/Aurde1/Aurde1_GeneModels_FilteredModels1.gff3|grep -v "#"|sort|uniq|wc -l)
````bash N DISTRIBUTION
cat Auricularia_delicata.fasta | grep -oP 'N{10,}' | awk '{print length($0)}' | sort -n | uniq -c
````

## Aurde1_AssemblyScaffolds.fasta.gz
- 666 scaffolds
- 74920203 bp
- 69053340 bp w/o N

# measurements / parameters of *Exidia glandulosa*

## Exigl1_AssemblyScaffolds.fasta
- 1727 scaffolds
- 78171509 bp
- 71707041 bp w/o N
- 322147 genes 
  - (Exigl1_all_proteins_20130529.aa.fasta.gz)
## GFF
- 1727 scaffolds

# measurements / parameters of *Calocidera cornea*
## GFF 
- 545 scaffolds

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
# ! run from Results directory !
for file in */*/*; do # for every file 2 folders downstream (from Results)
shortname=$(echo "$file"|sed 's/GeneCatalog_CDS_[0-9_]*//g') # remove the "GeneCatalog_CDS_..." from each file name
if [ "$file" != "$shortname" ]; then # if something could be changed, make it permanent, else skip
mv "$file" "$shortname"
fi
done
````

# synteny analysis showing homologs too
````bash
# bigger size regular, NO HOMOLOGS:
nohup wgd syn Results/CDS_DMD/Auri/Aurde1_clean.fasta.tsv -a Name -f gene Data/Aurde1/Aurde1_GeneModels_FilteredModels1.gff3 -ks Results/CDS_KSD/Auri/Aurde1_clean.fasta.tsv.ks.tsv -o Results/CDS_SYN/Auri/Bigger_size --dotsize 5 -n 15 > Results/CDS_SYN/Auri/auri_synbigdot.out 2>&1 &

nohup wgd syn Results/CDS_DMD/Exig/Exigl1_clean.fasta.tsv Scripts/exidia.gff -ks Results/CDS_KSD/Exig/Exigl1_clean.fasta.tsv.ks.tsv -o Results/CDS_SYN/Exig/Bigger_size --dotsize 5 -n 15 > Results/CDS_SYN/Exig/exig_synbigdot.out 2>&1 &

# with homologs
nohup wgd syn Results/CDS_DMD/Exig/Exigl1_clean.fasta.tsv Scripts/exidia.gff \\
-ks Results/CDS_KSD/Exig/Exigl1_clean.fasta.tsv.ks.tsv \\ # Ks
-o Results/CDS_SYN/Exig/With_homolog \\
--dotsize 5 \\
--apalpha 1 \\ # default
--hoalpha 0.6 \\ # now we show homologs too
-n 15 > Results/CDS_SYN/Exig/exig_synhomo.out 2>&1 &

nohup wgd syn \\
Results/CDS_DMD/Auri/Aurde1_clean.fasta.tsv \\
-a Name \\
-f gene \\
Data/Aurde1/Aurde1_GeneModels_FilteredModels1.gff3 \\
-ks Results/CDS_KSD/Auri/Aurde1_clean.fasta.tsv.ks.tsv \\
-o Results/CDS_SYN/Auri/With_homolog \\
--dotsize 5 \\
--apalpha 1 \\
--hoalpha 0.6 \\
-n 15 > Results/CDS_SYN/Auri/auri_synhomo.out 2>&1 &
````


So, until now, the params have been set to default values, meaning we have looked for WGDs within two fungal genomes with a software based on WGD events in plants. Now, we will tweak the params somewhat to be more fitting to a fungal search. 

## to create some organisation, lets create a new folder for synteny analysis that distinguishes default runs from the upcoming ones

````bash
~/wgd/Results$ mkdir SYN_params
cd SYN_params/
mkdir mkdir -p Auri/MinGene/5 Calco/MinGene/5 Exig/MinGene/5
````

## --mingenenum
because the software is based on plants which have bigger synteny blocks due to less rearrengements (compared to fungi), we lower the default value from 30 to values between 5-15
(Hane, J. K., Rouxel, T., Howlett, B. J., Kema, G. H., Goodwin, S. B., & Oliver, R. P. (2011). A novel mode of chromosomal evolution peculiar to filamentous Ascomycete fungi. Genome Biology, 12(5), R45. https://doi.org/10.1186/gb-2011-12-5-r45
)

````bash
# 5
nohup wgd syn \\
Results/CDS_DMD/Exig/Exigl1_clean.fasta.tsv \\
Scripts/exidia.gff \\
-ks Results/CDS_KSD/Exig/Exigl1_clean.fasta.tsv.ks.tsv \\
-o Results/SYN_params/Exig/MinGene/5 \\
--mingenenum 5 \\
--dotsize 5 \\
-n 15 > Results/SYN_params/Exig/MinGene/5/exig.out 2>&1 &

nohup wgd syn \\
Results/CDS_DMD/Auri/Aurde1_clean.fasta.tsv \\
-a Name \\
-f gene \\
Data/Aurde1/Aurde1_GeneModels_FilteredModels1.gff3 \\
-ks Results/CDS_KSD/Auri/Aurde1_clean.fasta.tsv.ks.tsv \\
-o Results/SYN_params/Auri/MinGene/5 \\
--mingenenum 5 \\
--dotsize 5 \\
-n 15 > Results/SYN_params/Auri/MinGene/5/auri.out 2>&1 &

nohup wgd syn \\
Results/CDS_DMD/Calco/Calco1_clean.fasta.tsv \\
Scripts/calco.gff \\
-ks Results/CDS_KSD/Calco/Calco1_clean.fasta.tsv.ks.tsv \\
-o Results/SYN_params/Calco/MinGene/5 \\
--mingenenum 5 \\
-n 15 > Results/SYN_params/Calco/MinGene/5/calco.out 2>&1 &

# 10
nohup wgd syn \\
Results/CDS_DMD/Exig/Exigl1_clean.fasta.tsv \\
Scripts/exidia.gff \\
-ks Results/CDS_KSD/Exig/Exigl1_clean.fasta.tsv.ks.tsv \\
-o Results/SYN_params/Exig/MinGene/10 
--mingenenum 10 \\
--dotsize 5 \\
-n 15 > Results/SYN_params/Exig/MinGene/10/exig.out 2>&1 &

nohup wgd syn \\
Results/CDS_DMD/Auri/Aurde1_clean.fasta.tsv \\
-a Name \\
-f gene \\
Data/Aurde1/Aurde1_GeneModels_FilteredModels1.gff3 \\
-ks Results/CDS_KSD/Auri/Aurde1_clean.fasta.tsv.ks.tsv \\
-o Results/SYN_params/Auri/MinGene/10 \\
--mingenenum 10 \\
--dotsize 5 \\
-n 15 > Results/SYN_params/Auri/MinGene/10/auri.out 2>&1 &

nohup wgd syn \\
Results/CDS_DMD/Calco/Calco1_clean.fasta.tsv \\
Scripts/calco.gff \\
-ks Results/CDS_KSD/Calco/Calco1_clean.fasta.tsv.ks.tsv \\
-o Results/SYN_params/Calco/MinGene/10 \\
--mingenenum 10 \\
--dotsize 5 \\
-n 15 > Results/SYN_params/Calco/MinGene/10/calco.out 2>&1

# bigger size
nohup wgd syn \\
Results/CDS_DMD/Calco/Calco1_clean.fasta.tsv \\
Scripts/calco.gff \\
-ks Results/CDS_KSD/Calco/Calco1_clean.fasta.tsv.ks.tsv \\
-o Results/SYN_params/Calco/MinGene/10/BigDot/ \\
--mingenenum 10 \\
--dotsize 5 \\
-n 15 > Results/SYN_params/Calco/MinGene/10/calco_dotsize.out 2>&1 &

# 15
#exig
nohup wgd syn \\
Results/CDS_DMD/Exig/Exigl1_clean.fasta.tsv \\
Scripts/exidia.gff \\
-ks Results/CDS_KSD/Exig/Exigl1_clean.fasta.tsv.ks.tsv \\
-o Results/SYN_params/Exig/MinGene/15 \\
--mingenenum 15 \\
--dotsize 5 \\
-n 15 > Results/SYN_params/Exig/MinGene/15/exig.out 2>&1 &

#auri
nohup wgd syn \\
Results/CDS_DMD/Auri/Aurde1_clean.fasta.tsv \\
-a Name \\
-f gene \\
Data/Aurde1/Aurde1_GeneModels_FilteredModels1.gff3 \\
-ks Results/CDS_KSD/Auri/Aurde1_clean.fasta.tsv.ks.tsv \\
-o Results/SYN_params/Auri/MinGene/15 \\
--mingenenum 15 \\
--dotsize 5 \\
-n 15 > Results/SYN_params/Auri/MinGene/15/auri.out 2>&1 &

#calco
nohup wgd syn \\
Results/CDS_DMD/Calco/Calco1_clean.fasta.tsv \\
Scripts/calco.gff -ks \\
Results/CDS_KSD/Calco/Calco1_clean.fasta.tsv.ks.tsv \\
-o Results/SYN_params/Calco/MinGene/15 \\
--mingenenum 15 \\
-n 15 > Results/SYN_params/Calco/MinGene/15/calco.out 2>&1
````


## --pairwise for wgd ksd
````bash
mkdir -p KSD_params/{Auri,Calco,Exig}

#auri
nohup wgd ksd \\
Results/CDS_DMD/Auri/Aurde1_.fasta.tsv \\
Data/Aurde1/Aurde1_GeneCatalog_CDS_20110213.fasta \\
--pairwise \\
-o Results/KSD_params/Auri \\
-n 15 > Results/KSD_params/Auri/auri_ksd2.out 2>&1 &

#exig
nohup wgd ksd \\
Results/CDS_DMD/Exig/Exigl1_.fasta.tsv \\
Data/Exigl1/Exigl1_GeneCatalog_CDS_20130529.fasta \\
--pairwise \\
-o Results/KSD_params/Exig/ \\
-n 15 > Results/KSD_params/Exig/exig_ksd.out 2>&1 &

#calco
nohup wgd ksd \\
Results/CDS_DMD/Calco/Calco1_.fasta.tsv \\
Data/Calco1/Calco1_GeneCatalog_CDS_20130417.fasta \\
--pairwise \\
-o Results/KSD_params/Calco/ \\
-n 15 > Results/KSD_params/Calco/calco_ksd.out 2>&1 &
````

### from the above pairwise comaprisons, we now do synteny analysis and see how it differs
````bash
nohup wgd syn \\
Results/CDS_DMD/Auri/Aurde1_clean.fasta.tsv \\
-a Name \\
-f gene \\
Data/Aurde1/Aurde1_GeneModels_FilteredModels1.gff3 \\
-ks Results/KSD_params/Auri/Aurde1_.fasta.tsv.ks.tsv \\
-o Results/KSD_params/Auri/MinGene/5 \\
--mingenenum 5 \\
--dotsize 5 \\
-n 15 > Results/KSD_params/Auri/MinGene/5/auri.out 2>&1 &


nohup wgd syn \\
Results/CDS_DMD/Exig/Exigl1_clean.fasta.tsv \\
Scripts/exidia.gff \\
-ks Results/KSD_params/Exig/Exigl1_.fasta.tsv.ks.tsv \\
-o Results/KSD_params/Exig/MinGene/5 \\
--mingenenum 5 \\
--dotsize 5 \\
-n 15 > Results/KSD_params/Exig/MinGene/5/exig.out 2>&1 & # be aware where it ends up!
````

# with homologs too for 10 min gene synteny

````bash
# exig
nohup wgd syn Results/CDS_DMD/Exig/Exigl1_clean.fasta.tsv Scripts/exidia.gff \\
-ks Results/CDS_KSD/Exig/Exigl1_clean.fasta.tsv.ks.tsv \\
-o Results/SYN_params/Exig/MinGene/10/With_Homolog \\
--dotsize 5 \\
--mingenenum 10 \\
--apalpha 1 \\
--hoalpha 0.3 \\
-n 15 > Results/SYN_params/Exig/MinGene/10/With_Homolog/exig_synhomo.out 2>&1 &

#auri
nohup wgd syn \\
Results/CDS_DMD/Auri/Aurde1_clean.fasta.tsv \\
-a Name \\
-f gene \\
Data/Aurde1/Aurde1_GeneModels_FilteredModels1.gff3 \\
-ks Results/KSD_params/Auri/Aurde1_.fasta.tsv.ks.tsv \\
-o Results/SYN_params/Auri/MinGene/10 \\
--mingenenum 10 \\
--dotsize 5 \\
--apalpha 1 \\
--hoalpha 0.3 \\
-n 15 > Results/SYN_params/Auri/MinGene/10/auri_synhomo.out 2>&1 &

#calco
nohup wgd syn \\
Results/CDS_DMD/Calco/Calco1_clean.fasta.tsv \\
Scripts/calco.gff \\
-ks Results/CDS_KSD/Calco/Calco1_clean.fasta.tsv.ks.tsv \\
-o Results/SYN_params/Calco/MinGene/10/With_Homolog \\
--mingenenum 10 \\
--dotsize 5 \\
--apalpha 1 \\
--hoalpha 0.3 \\
-n 15 > Results/SYN_params/Calco/MinGene/10/With_Homolog/calco.out 2>&1 &
````
# downloading data from ncbi
````bash
conda activate ncbi
conda install -c conda-forge ncbi-datasets-cli

datasets download genome accession GCA_025815895.1 --include gff3,rna,cds,protein,genome,seq-report
````
## dmd (gene families)
````bash
nohup wgd dmd \\
ncbi_dataset/data/GCA_018924745.1/cds_from_genomic.fna \\
-o ncbi_dataset/Results_Ncbi/DMD/ \\
-n 15 > ncbi_dataset/Results_Ncbi/DMD/ncbi_dmd.out 2>&1 &
````
## ksd
````bash
nohup wgd ksd \\
ncbi_dataset/Results_Ncbi/DMD/cds_from_genomic.fna.tsv \\
ncbi_dataset/data/GCA_018924745.1/cds_from_genomic.fna \\
-o ncbi_dataset/Results_Ncbi/KSD/ \\
-n 15 > ncbi_dataset/Results_Ncbi/KSD/ncbi_ksd.out 2>&1 &
````

# interspecific analysis
````bash
# because exidia and calcocera share names, we get a duplication error thrown by i-ADHoRE some steps later on, so we just add an id before every name for exidia
awk '$3=="gene" {gsub(/ID=/, "ID=SP2_")} {print}' Scripts/exidia.gff > Scripts/exidia_prefixed.gff # gff 

sed 's/^>/^>SP2_/' Data/Clean_Data/Exig/Exigl1_GeneCatalog_CDS_20130529_clean.fasta > Data/Clean_Data/Exig/Inter/Exigl1_GeneCatalog_CDS_20130529_inter.fasta # cds exig

sed 's/^>/>SP1_/' Data/Clean_Data/Auri/Aurde1_GeneCatalog_CDS_20110213_clean.fasta > Data/Clean_Data/Auri/Inter/Aurde1_GeneCatalog_CDS_20110213_inter.fasta # cds auri

awk '$3=="gene" {gsub(/Name=/, "Name=SP1_")} {print}' Data/Aurde1/Aurde1_GeneModels_FilteredModels1.gff3 > Scripts/auri_prefixed.gff

# dmd
nohup wgd dmd \\
-oo \\ # orthoinfer
-oi Data/Clean_Data/Auri/Inter/Aurde1_GeneCatalog_CDS_20110213_inter.fasta Data/Clean_Data/Exig/Inter/Exigl1_GeneCatalog_CDS_20130529_inter.fasta Data/Clean_Data/Calco/Calco1_GeneCatalog_CDS_20130417_clean.fasta \\
-o Results/InterSpecific/DMD \\
-n 15 > Results/InterSpecific/DMD/orthoinfer.out 2>&1 &

````
### from tmp file with all species having their own unique gene names: Results/InterSpecific/DMD/tmp/Orthogroups.genecount.tsv
  - 1 CopyType
  - 18648 multi-copy
  - 2024 single-copy

````bash
# inter ksd
nohup wgd ksd \\
Results/InterSpecific/DMD/Orthogroups.sp.tsv \\
Clean_Data/Auri/Inter/Aurde1_GeneCatalog_CDS_20110213_inter.fasta \\
Clean_Data/Exig/Inter/Exigl1_GeneCatalog_CDS_20130529_inter.fasta \\
Data/Clean_Data/Calco/Calco1_GeneCatalog_CDS_20130417_clean.fasta \\
-o Results/InterSpecific/KSD \\
-n 15 > Results/InterSpecific/KSD/inter_ksd.out 2>&1 &

# inter synteny
nohup wgd syn \\
Results/InterSpecific/DMD/Orthogroups.sp.tsv \\
-ks Results/InterSpecific/KSD/Orthogroups.sp.tsv.ks.tsv \\
Scripts/calco.gff \\
Scripts/auri2_prefixed.gff \\
Scripts/exidia_prefixed.gff \\
--dotsize 7 \\
--mingenenum 10 \\
-o Results/InterSpecific/SYN \\
-n 15 > Results/InterSpecific/SYN/inter_syn.out 2>&1 &

# inter viz reweigth
wgd viz -d Results/InterSpecific/KSD/Orthogroups.sp.tsv.ks.tsv \\ # family
-fa Exigl1_GeneCatalog_CDS_20130529_inter.fasta \\ # focal species
-ap Results/InterSpecific/SYN/iadhore-out/anchorpoints.txt \\
-sp Data/speciestree.nw \\ #(auri,exidia(cornea))
-o Results/InterSpecific/VIZ \\
--plotelmm \\
--plotapgmm \\
--reweight \\
-n 15 > Results/InterSpecific/VIZ/viz_reweigth.out 2>&1 &
````





## 25th may 2025, i will just do a quick test to see how the results look if we use more of the scaffolds
```bash
# auri
nohup wgd syn \\
Results/CDS_DMD/Auri/Aurde1_clean.fasta.tsv \\
-a Name \\
-f gene \\
Data/Aurde1/Aurde1_GeneModels_FilteredModels1.gff3 \\
-ks Results/KSD_params/Auri/Aurde1_.fasta.tsv.ks.tsv \\
-o Results/KSD_params/Auri/MinSeg/150 \\
--mingenenum 10 \\
--minlen -5 # 50% of longest scaffolds, just to see
--dotsize 5 \\
-n 15 > Results/KSD_params/Auri/MinSeg/50/auri.out 2>&1 &

# exig
nohup wgd syn \\
Results/CDS_DMD/Exig/Exigl1_clean.fasta.tsv \\
Scripts/exidia.gff \\
-ks Results/KSD_params/Exig/Exigl1_.fasta.tsv.ks.tsv \\
-o Results/KSD_params/Exig/MinSeg/50 \\
--mingenenum 10 \\
--minlen -5 \\
--dotsize 5 \\
-n 15 > Results/KSD_params/Exig/MinSeg/50/exig.out 2>&1 &

# calco
nohup wgd syn \\
Results/CDS_DMD/Calco/Calco1_.fasta.tsv \\
-ks Results/KSD_params/Calco/Calco1_.fasta.tsv.ks.tsv \\
-o Results/KSD_params/Calco/MinSeg/50 \\
--mingenenum 10 \\
--minlen -5 \\
--dotsize 5 \\
-n 15 > Results/KSD_params/Calco/MinSeg/50/calco_ksd.out 2>&1 &

# auri 100%
nohup wgd syn \\
Results/CDS_DMD/Auri/Aurde1_clean.fasta.tsv \\
-a Name \\
-f gene \\
Data/Aurde1/Aurde1_GeneModels_FilteredModels1.gff3 \\
-ks Results/KSD_params/Auri/Aurde1_.fasta.tsv.ks.tsv \\
-o Results/KSD_params/Auri/MinSeg/100 \\
--mingenenum 10 \\
--minlen -10 # 100% of longest scaffolds, still min length of 10000
--dotsize 5 \\
-n 15 > Results/KSD_params/Auri/MinSeg/100/auri.out 2>&1 &

# exig 100%
nohup wgd syn \\
Results/CDS_DMD/Exig/Exigl1_clean.fasta.tsv \\
Scripts/exidia.gff \\
-ks Results/KSD_params/Exig/Exigl1_.fasta.tsv.ks.tsv \\
-o Results/KSD_params/Exig/MinSeg/100 \\
--mingenenum 10 \\
--minlen -10 \\
--dotsize 5 \\
-n 15 > Results/KSD_params/Exig/MinSeg/100/exig.out 2>&1 &
```


## using wgd viz to recreate the plots but with custom color
```
# exidia
nohup wgd viz \\
-d Results/CDS_KSD/Exig/Exigl1_clean.fasta.tsv.ks.tsv
--segments Results/SYN_params/Exig/MinGene/10/iadhore-out/segments.txt \\
--anchorpoints Results/SYN_params/Exig/MinGene/10/iadhore-out/anchorpoints.txt \\
--multiplicon Results/SYN_params/Exig/MinGene/10/iadhore-out/multiplicon.txt \\
--genetable Results/SYN_params/Exig/MinGene/10/gene-table.csv \\
--mingenenum 10 \\
--plotapgmm \\
--plotelmm \\
--dotsize 5 \\
-o Results/SYN_params/Exig/MinGene/10/Red_and_Blue \\ # output
-n 15 > Results/SYN_params/Exig/MinGene/10/Red_and_Blue/exi.out 2>&1 &
#auri

nohup wgd viz \\
-ks Results/CDS_KSD/Auri/Aurde1_clean.fasta.tsv.ks.tsv \\
--segments Results/SYN_params/Auri/MinGene/10/iadhore-out/segments.txt \\
--anchorpoints Results/SYN_params/Auri/MinGene/10/iadhore-out/anchorpoints.txt \\
--multiplicon Results/SYN_params/Auri/MinGene/10/iadhore-out/multiplicon.txt \\
--genetable Results/SYN_params/Auri/MinGene/10/gene-table.csv \\
--mingenenum 10 \\
--plotapgmm \\
--plotelmm \\
--dotsize 5 \\
-o Results/SYN_params/Auri/MinGene/10/Red_and_Blue \\ # output
-n 15 > Results/SYN_params/Auri/MinGene/10/Red_and_Blue/auri.out 2>&1 &

# calco
nohup wgd viz \\
-d Results/CDS_KSD/Calco/Calco1_clean.fasta.tsv.ks.tsv \\
--segments Results/SYN_params/Calco/MinGene/10/iadhore-out/segments.txt \\
--anchorpoints Results/SYN_params/Calco/MinGene/10/iadhore-out/anchorpoints.txt d
--multiplicon Results/SYN_params/Calco/MinGene/10/iadhore-out/multiplicon.txt \\
--genetable Results/SYN_params/Calco/MinGene/10/gene-table.csv \\
--mingenenum 10 \\
--plotapgmm \\
--plotelmm \\
--dotsize 5 \\
-o Results/SYN_params/Calco/MinGene/10/Red_and_Blue \\
-n 15 > Results/SYN_params/Calco/MinGene/10/Red_and_Blue/calco.out 2>&1 &

```
# busco tables of duplications
````bash
cat Results/2_quality/Exig/run_agaricomycetes_odb12/full_table.tsv \\
|grep -v "#" \\
|cut -f2,3,4,5,6,7 \\
|grep "Duplicated"  \\
> Results/2_quality/Exig/run_agaricomycetes_odb12/exidia_duplicated.tsv

cat Results/2_quality/Exig/run_agaricomycetes_odb12/exidia_duplicated.tsv \\
|sed 's/jgi|Exigl1|[0-9]*|//g' \\
> Results/2_quality/Exig/run_agaricomycetes_odb12/exidia_duplicated_shortgenes.tsv

cat Results/2_quality/Exig/run_agaricomycetes_odb12/exidia_duplicated.tsv \\
|cut -f2 > Results/2_quality/Exig/run_agaricomycetes_odb12/exidia_duplicated_names.tsv

awk 'NR==FNR{ids[$1]=1; next} /^>/{header=substr($1,2); keep=(header in ids)} keep'  \\
Results/2_quality/Exig/run_agaricomycetes_odb12/exidia_duplicated_names.tsv  \\
Data/Exigl1/Exigl1_all_proteins_20130529.aa.fasta  \\
> Results/2_quality/Exig/run_agaricomycetes_odb12/exidia_duplicated_buscos.aa.fasta


cat Results/2_quality/Auri/run_agaricomycetes_odb12/full_table.tsv \\
|grep -v "#" \\
|cut -f2,3,4,5,6,7 \\
|grep "Duplicated"  \\
> Results/2_quality/Auri/run_agaricomycetes_odb12/auri_duplicated.tsv

cat Results/2_quality/Auri/run_agaricomycetes_odb12/auri_duplicated.tsv \\
|sed 's/jgi|Aurde1|[0-9]* \\
|//g' > Results/2_quality/Auri/run_agaricomycetes_odb12/auri_duplicated_shortgenes.tsv

cat Results/2_quality/Auri/run_agaricomycetes_odb12/auri_duplicated.tsv \\
|cut -f2  \\
> Results/2_quality/Auri/run_agaricomycetes_odb12/auri_duplicated_names.tsv

awk 'NR==FNR{ids[$1]=1; next} /^>/{header=substr($1,2); keep=(header in ids)} keep'  \\
Results/2_quality/Auri/run_agaricomycetes_odb12/auri_duplicated_names.tsv  \\
Data/Aurde1/Aurde1_GeneCatalog_proteins_20110213.aa.fasta  \\
> Results/2_quality/Auri/run_agaricomycetes_odb12/auri_duplicated_buscos.aa.fasta


cat Results/2_quality/Calco/run_basidiomycota_odb12/full_table.tsv \\
|grep -v "#" \\
|cut -f2,3,4,5,6,7 \\
|grep "Duplicated" >  \\
Results/2_quality/Calco/run_basidiomycota_odb12/calco_duplicated.tsv

cat Results/2_quality/Calco/run_basidiomycota_odb12/calco_duplicated.tsv \\
|sed 's/jgi|Calco1
|[0-9]*|//g'  \\
> Results/2_quality/Calco/run_basidiomycota_odb12/calco_duplicated_shortgenes.tsv

cat Results/2_quality/Calco/run_basidiomycota_odb12/calco_duplicated.tsv \\
|cut -f2 \\
> Results/2_quality/Calco/run_basidiomycota_odb12/calco_duplicated_names.tsv

awk 'NR==FNR{ids[$1]=1; next} /^>/{header=substr($1,2); keep=(header in ids)} keep' \\
Results/2_quality/Calco/run_basidiomycota_odb12/calco_duplicated_names.tsv \\
Data/Calco1/Calco1_GeneCatalog_proteins_20130417.aa.fasta \\
> Results/2_quality/Calco/run_basidiomycota_odb12/calco_duplicated_buscos.aa.fasta

````
