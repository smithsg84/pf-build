#!/bin/bash -l

#SBATCH -p debug     
#SBATCH -N 1
#SBATCH -t 00:30:00  
#SBATCH -J my_job    
#SBATCH -L SCRATCH
#SBATCH -C haswell 


uname -a 
make test
