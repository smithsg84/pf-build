#!/bin/bash
#SBATCH -N 1
#SBATCH -t 06:00:00
#SBATCH -A oflash 
#SBATCH -p pbatch
#SBATCH -o sbatch-test-out

echo 'STARTING JOB'

export SLURM_OVERCOMMIT=1
make check

echo 'ALL DONE'
