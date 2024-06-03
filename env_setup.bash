SYNOPSYS_ROOT=/opt/coe/synopsys
VCS_ROOT=$SYNOPSYS_ROOT/vcs/
VERDI_ROOT=$SYNOPSYS_ROOT/verdi/
VCS_VERSION=V-2023.12-1
VERDI_VERSION=V-2023.12-1

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
source activate lowRISC

echo "Done Sourcing!"
