# genome duplication pipeline
##  wgd v2.0.38
mafft v7.525 (2024/Mar/13)
FastTree 2.2.0
mcl 22-282
diamond version 2.0.6

ewdsssssss555555 // tangens


# wgd

````bash
nohup wgd dmd ../Data/Aurde1/auri.fasta -o Auri_dmd/ &
 nohup wgd dmd ../Data/Exigl1/exig.fasta -o Exig_dmd/


nohup wgd ksd ../DMD/Auri_dmd/auri.fasta.tsv ../../Data/Aurde1/auri.fasta -o Auri_ksd &
````