#!/bin/bash -l
#SBATCH -p debug     
#SBATCH -N 1
#SBATCH -t 00:30:00  
#SBATCH -J my_job    
#SBATCH -L SCRATCH
#SBATCH -C haswell 

# HYPRE library uses OMP and possibly using max threads by default so
# make sure OMP is running single threaded.
export OMP_NUM_THREADS=1

make test
