#!/bin/bash -l
#SBATCH --job-name=titan_1                     # Job name
#SBATCH --ntasks=1                             # Number of tasks
#SBATCH --cpus-per-task=4                      # Number of CPU
#SBATCH --time=24:00:00                        # Time limit hh:mm:ss
#SBATCH --output=log/inject_%j.log            # Standard output and error log
#SBATCH --qos=olympus-cpu-research             # Change to ugrad for undergrads
#SBATCH --partition=cpu-research               # This job does not use a GPU

cd ${RESEARCH_DIR}/github/designs/opentitan
source env_setup.bash

# Current bug type
BUGTYPE="SRAMCON"
BEGIN_TRAIN=0
END_TRAIN=16
BEGIN_TEST=0
END_TEST=10
# Keep track of the number of bugs injected
BUGINJECTED=""
for i in $(seq $BEGIN_TRAIN $END_TRAIN)
do
    echo "Injecting bug BUGNUM${BUGTYPE}${i}"
     util/dvsim/dvsim.py hw/ip/sram_ctrl/dv/sram_ctrl_main_sim_cfg.hjson -i all --reseed 1 --verbose debug --build-opts +define+BUGNUM${BUGTYPE}${i}
    BUGINJECTED="$BUGINJECTED ${BUGTYPE}${i}"
done 
for i in $(seq $BEGIN_TEST $END_TEST)
do
    echo "Injecting bug BUGNUM${BUGTYPE}${i}T"
    util/dvsim/dvsim.py hw/ip/sram_ctrl/dv/sram_ctrl_main_sim_cfg.hjson -i all --reseed 1 --verbose debug --build-opts +define+BUGNUM${BUGTYPE}${i}T
    BUGINJECTED="$BUGINJECTED ${BUGTYPE}${i}T"
done 

python3 sendmail.py "Bug Injection Done" "Job number: ${SLURM_JOB_ID}. The following bugs have been injected: $BUGINJECTED" self