#!/bin/bash  -l

#SBATCH -p debug

#SBATCH -N 1

#SBATCH -t 00:20:00

#SBATCH -J my_job

srun main.sh
sleep 60
