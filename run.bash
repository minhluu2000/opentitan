#!/bin/bash -l
#SBATCH --job-name=titan_1                     # Job name
#SBATCH --mail-type=BEGIN,FAIL,END             # Mail Events (NONE,BEGIN,FAIL,END,ALL)
#SBATCH --mail-user=minh.luu@tamu.edu          # Replace with your email address
#SBATCH --ntasks=1                             # Number of tasks
#SBATCH --cpus-per-task=4                      # Number of CPU
#SBATCH --time=24:00:00                        # Time limit hh:mm:ss
#SBATCH --output=log/titan_1_%j.log            # Standard output and error log
#SBATCH --qos=olympus-cpu-research             # Change to ugrad for undergrads
#SBATCH --partition=cpu-research               # This job does not use a GPU
#SBATCH --nodelist=n07-artemis                 # Node to run the job on

source /mnt/shared-scratch/Hu_J/minh.luu/github/designs/opentitan_1/env_setup.bash
python3 /mnt/shared-scratch/Hu_J/minh.luu/github/sim_extract/design_titan/_job/data_extractor_1.py