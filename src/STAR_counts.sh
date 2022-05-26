#!/bin/bash
########## BATCH Lines for Resource Request ##########
#SBATCH --time=0:30:00                  # Limit of wall clock time - how long the job will run (same as -t)
#SBATCH --nodes=1                       # Number of different nodes - could be an exact number or a range of nodes (same as -N)
#SBATCH --ntasks=1                      # Number of tasks - how many tasks (nodes) that you require (same as -n)
#SBATCH --cpus-per-task=100             # Number of CPUs (or cores) per task (same as -c)
#SBATCH --mem=50G                       # Specify the real memory required per node. (20G)
#SBATCH --job-name STAR_mapping         # You can give your job a name for easier identification (same as -J)
#SBATCH -A egl

########## Load Modules #########
module purge
ml GCC/10.3.0 STAR/2.7.9a
################################

# Parameters notes:
## soloUMIdedup: 1MM_CR, all UMIs with 1 mismatch distance to each other are collapsed (i.e. counted once)
## soloCBmatchWLtype: 1MM_multi_Nbase_pseudocounts, same as 1MM_multi_pseudocounts, multimatching to 
##                    WL is allowed for CBs with N-bases. This option matches best with CellRanger >= 3.0.0
## soloUMIfiltering: MultiGeneUMI_CR, basic + remove lower-count UMIs that map to more than one gene,
##                   matching CellRanger > 3.0.0 . Only works with --soloUMIdedup 1MM_CR. 

# Input file: list of Samples and version class:
## SRR12046124     v3
## SRR12046067     v2

List_samples=$1



START_v2() {
        ## process 10x chemistry v2 of 3' 10x
        
        ## Files input ($1): File R1, eg: SRR12046049_S1_L001_R1_001.fastq.gz
        File1=$1; 
        File2=${1//_R1_/_R2_};

        name=$(echo $i | tr '_' '\t' | cut -f1); # set sample name
        
        # mapping
        STAR --soloType Droplet --runThreadN 100 \
                                --soloCBwhitelist 3M-february-2018.txt \
                                --genomeDir Index_TAIR11_STAR \
                                --readFilesIn $File2 $File1 --outFileNamePrefix ${name}_star. \
                                --outSAMtype BAM Unsorted --soloOutFileNames Counts_ --readFilesCommand gunzip -c \
                                --soloUMIdedup 1MM_CR \
                                --soloCBmatchWLtype 1MM_multi_Nbase_pseudocounts \
                                --soloUMIfiltering MultiGeneUMI_CR \
                                --clipAdapterType CellRanger4 \
                                --soloUMIdedup 1MM_CR \
                                --soloFeatures Gene GeneFull Velocyto \
                                --outFilterScoreMin 30 \
                                --soloCBstart 1 \
                                --soloCBlen 16 \
                                --soloUMIstart 17 \
                                --soloUMIlen 10 
                                
}

START_v3() {
        ## process 10x chemistry v3 of 3' 10x
        
        ## Files input ($1): File R1, eg: SRR12046049_S1_L001_R1_001.fastq.gz
        File1=$1; 
        File2=${1//_R1_/_R2_};

        name=$(echo $i | tr '_' '\t' | cut -f1); # set sample name
        
        # mapping
        STAR --soloType Droplet --runThreadN 100 \
                                --soloCBwhitelist 3M-february-2018.txt \
                                --genomeDir Index_TAIR11_STAR \
                                --readFilesIn $File2 $File1 --outFileNamePrefix ${name}_star. \
                                --outSAMtype BAM Unsorted --soloOutFileNames Counts_ --readFilesCommand gunzip -c \
                                --soloUMIdedup 1MM_CR \
                                --soloCBmatchWLtype 1MM_multi_Nbase_pseudocounts \
                                --soloUMIfiltering MultiGeneUMI_CR \
                                --clipAdapterType CellRanger4 \
                                --soloUMIdedup 1MM_CR \
                                --soloFeatures Gene GeneFull Velocyto \
                                --outFilterScoreMin 30 \
                                --soloCBstart 1 \
                                --soloCBlen 16 \
                                --soloUMIstart 17 \
                                --soloUMIlen 12 


}


while read -r -a line; do

	Input=${line[0]}_S1_L001_R1_001.fastq.gz #  add missing part of file name
        
        ## Ask if the sample class
	if [[ ${line[1]} == "v3" ]]; then 
	        START_v3 $Input
	elif [[ ${line[1]} == "v2" ]]; then
                START_v2 $Input
        else
                echo " .. Sample class missing .. ${line[0]}"
        fi
          
done < $List_samples         


# Potential error:
# EXITING because of FATAL ERROR in input read file: the total length of barcode sequence is 26 not equal to expected 28
