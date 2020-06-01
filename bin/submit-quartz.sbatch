#!/bin/bash
#SBATCH -N 1
#SBATCH -t 01:30:00
#SBATCH -A fabric 
#SBATCH -p pbatch

echo 'STARTING JOB'

#export SLURM_OVERCOMMIT=1

make check 
   
echo 'ALL DONE'
