#!/usr/bin/env python3
import sys
path_gff = sys.argv[1]
path_out = sys.argv[2]
genes = {} # empty dict

with open(path_gff) as fin:
	for line in fin:
		parts = line.strip().split("\t")
		feature = parts[2] # following the gff format (https://www.ensembl.org/info/website/upload/gff.html)
		
		if feature not in ["CDS", "exon"]: # get rid of "start/stop codons"
			continue

		scaffold = parts[0] # seqname
		source = parts[1] # JGI
		start = int(parts[3]) # start position
		end = int(parts[4]) # end position
		score = parts[5]
		strand = parts[6]
		frame = parts[7]
		attribute = parts[8]
		if "name " not in attribute:
			continue

		gene = attribute.split('name "')[1].split('"')[0] # only get gene name

		if gene not in genes: # first time we stumple upon this gene...
			genes[gene] = [scaffold, source, start, end, score, strand, frame]

		else: # if we meet it again, update the position
			genes[gene][2] = min(genes[gene][2], start) # start with the first position
			genes[gene][3] = max(genes[gene][3], end) # end with the last

# write to file
with open(path_out, "w") as fout:
	for gene, (scaffold, source, start, end, score, strand, frame) in genes.items():
		fout.write(f"{scaffold}\t{source}\tgene\t{start}\t{end}\t{score}\t{strand}\t{frame}\tID={gene}\n")
