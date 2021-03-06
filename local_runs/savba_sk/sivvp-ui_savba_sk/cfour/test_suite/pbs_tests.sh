#!/bin/sh

#PBS -S /bin/bash
#PBS -N CFOURtests
### Declare myprogram non-rerunable
#PBS -r n
#PBS -l nodes=1:ppn=12
#PBS -l walltime=6:00:00
#PBS -l mem=47g
#PBS -j oe
#PBS -q long

echo "Working host is: "; hostname -f

# load necessary modules
module load intel/2015
module load mkl/2015
#module load openmpi-intel/1.8.3
echo "My PATH=$PATH"
echo "Running on host `hostname`"
echo "Time is `date`"
echo "Directory is `pwd`"
echo "This jobs runs on the following processors:"
echo `cat $PBS_NODEFILE`
# Extract number of processors
NPROCS_PBS=`wc -l < $PBS_NODEFILE`
NPROCS=`cat /proc/cpuinfo | grep processor | wc -l`
echo "This node has $NPROCS CPUs."
echo "This node has $NPROCS_PBS CPUs allocated for PBS calculations."
echo "PBS_SERVER=$PBS_SERVER"
echo "PBS_NODEFILE=$PBS_NODEFILE"
echo "PBS_O_QUEUE=$PBS_O_QUEUE"
echo "PBS_O_WORKDIR=$PBS_O_WORKDIR"
# ...
export MKL_NUM_THREADS=$NPROCS_PBS
echo "MKL_NUM_THREADS=$MKL_NUM_THREADS"
#export MKL_DOMAIN_NUM_THREADS="MKL_BLAS=$NPROCS"
export OMP_NUM_THREADS=1
export MKL_DYNAMIC="FALSE"
export OMP_DYNAMIC="FALSE"

# distributed binaries
CFOUR=/shared/home/ilias/Work/software/cfour/cfour_v2.00beta_64bit_linux_serial
workdir=/scratch/tmp/$USER/$PBS_JOBID/CFOURrun_bin
mkdir -p $workdir

cd $workdir
echo -e "pwd=\c"; pwd

cp -R $CFOUR/testsuite $workdir/.
cp -R $CFOUR/bin       $workdir/.
cp -R $CFOUR/share     $workdir/.
cp -R $CFOUR/basis     $workdir/.

#
echo -e "\n \n Distributed CFOUR with binaries"
cd $workdir
export PATH=$CFOUR/bin:$PATH
echo -e "\n PATH=$PATH"
cd testsuite
xtester --all

/bin/rm -rf $workdir

exit 0
