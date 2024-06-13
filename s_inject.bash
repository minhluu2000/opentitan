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

# source env_setup.bash
# python3 /mnt/shared-scratch/Hu_J/minh.luu/github/sim_extract/design_titan/_job/data_extractor_1.py


cd ${RESEARCH_DIR}/github/designs/opentitan_1
source env_setup.bash
# Keep track of the number of bugs injected
BUGINJECTED="BUGINJECTED:"
for i in $(seq 1 2)
do
    util/dvsim/dvsim.py hw/ip/aes/dv/aes_base_sim_cfg.hjson -i all --fixed-seed=1 --waves fsdb --build-modes aes_masked --verbose debug --build-opts +define+BUGNUMCTRFSM$i
    BUGINJECTED="$BUGINJECTED $i"
done 
for i in $(seq 1 1)
do
    util/dvsim/dvsim.py hw/ip/aes/dv/aes_base_sim_cfg.hjson -i all --fixed-seed=1 --waves fsdb --build-modes aes_masked --verbose debug --build-opts +define+BUGNUMCTRFSM$iT
    BUGINJECTED="$BUGINJECTED $iT"
done 

python3 /mnt/shared-scratch/Hu_J/minh.luu/github/sim_extract/script_examples/sendmail.py "Bug Injection Done" "The following bugs have been injected: $BUGINJECTED" self