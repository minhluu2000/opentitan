#!/bin/bash -l
#SBATCH --job-name=titan_1                     # Job name
#SBATCH --ntasks=1                             # Number of tasks
#SBATCH --cpus-per-task=4                      # Number of CPU
#SBATCH --time=24:00:00                        # Time limit hh:mm:ss
#SBATCH --output=log/extract_%j.log            # Standard output and error log
#SBATCH --qos=olympus-cpu-research             # Change to ugrad for undergrads
#SBATCH --partition=cpu-research               # This job does not use a GPU

cd ${RESEARCH_DIR}/github/designs/opentitan_1
source env_setup.bash
python3 /mnt/shared-scratch/Hu_J/minh.luu/github/sim_extract/design_titan/_job/data_extractor_1.py
python3 /mnt/shared-scratch/Hu_J/minh.luu/github/sim_extract/script_examples/sendmail.py "Bug Extraction Done" "Job number: ${SLURM_JOB_ID}." self