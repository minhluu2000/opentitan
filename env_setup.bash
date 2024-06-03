SYNOPSYS_ROOT=/opt/coe/synopsys
VCS_ROOT=$SYNOPSYS_ROOT/vcs/
VERDI_ROOT=$SYNOPSYS_ROOT/verdi/
VCS_VERSION=V-2023.12-1
VERDI_VERSION=V-2023.12-1 # OLD VERSION
HELP2MAN_PATH=/home/grads/m/minh.luu/.local/tools/help2man/1.49.3/bin
VERILATOR_PATH=/home/grads/m/minh.luu/.local/tools/verilator/5.024/bin
EXTRA_PATH=/home/grads/m/minh.luu/.local/tools/extra

# Ibex
export IBEX_HOME=/mnt/shared-scratch/Hu_J/minh.luu/github/designs/tamu_ibex
export RISCV_TOOLCHAIN=$IBEX_HOME/lowrisc-toolchain-gcc-rv32imcb-20230427-1
export RISCV_GCC="$RISCV_TOOLCHAIN/bin/riscv32-unknown-elf-gcc"
export RISCV_OBJCOPY="$RISCV_TOOLCHAIN/bin/riscv32-unknown-elf-objcopy"
export OVPSIM_PATH=$IBEX_HOME/imperas-riscv-ovpsim-plus/riscv-ovpsim-plus/bin/Linux64
export SPIKE_INSTALL_DIR=$IBEX_HOME/spike-cosim
export SPIKE_PATH=$SPIKE_INSTALL_DIR/bin
export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:$SPIKE_INSTALL_DIR/lib/pkgconfig
export EXTRA_COSIM_CFLAGS=""
LD_LIBRARY_PATH=${SPIKE_INSTALL_DIR}/lib:${LD_LIBRARY_PATH}

# OpenTitan setup
export REPO_TOP=/mnt/shared-scratch/Hu_J/minh.luu/github/designs/opentitan_1
export TOOLCHAIN_PATH="$RISCV_TOOLCHAIN"

# Synopsys setup
export VCS_HOME=$VCS_ROOT$VCS_VERSION
export VERDI_HOME=$VERDI_ROOT$VERDI_VERSION
export UVMHOME=$VCS_HOME/etc/uvm
source $VCS_HOME/setup.vcs.sh
export PATH=$VERDI_HOME/bin:$PATH
export LD_LIBRARY_PATH=$VERDI_HOME/share/FsdbWriter/LINUX64/:$VERDI_HOME/share/FsdbReader/LINUX64/:$LD_LIBRARY_PATH

# Anaconda setup
export ANACONDA_INSTALL_DIR=/home/grads/m/minh.luu/anaconda3
export ANACONDA_PATH=$ANACONDA_INSTALL_DIR/bin
export PYTHON_PATH=$ANACONDA_INSTALL_DIR/envs/lowRISC/bin

# Add to PATH
PATH=${ANACONDA_PATH}:${PATH}
PATH=${PYTHON_PATH}:${PATH}

#You can uncomment out the below line after installing Python 3.9.6 with Anaconda
# source activate lowRISC

echo "Done Sourcing!"
