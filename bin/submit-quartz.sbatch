#!/bin/bash
#SBATCH -N 1
#SBATCH -t 01:30:00
#SBATCH -A fabric 
#SBATCH -p pbatch

echo 'STARTING JOB'

#export SLURM_OVERCOMMIT=1

for i in $(seq 3)
do
   unset PARFLOW_USE_CLUSTERING
   make check > octree.$i.out
   
   export PARFLOW_USE_CLUSTERING=1
   make check > cluster.$i.out
done


echo 'ALL DONE'
