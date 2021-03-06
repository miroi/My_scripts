#!/bin/sh

#PBS -S /bin/bash
#PBS -N CFOURtestsown
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

# own compiled version
CFOUR=/shared/home/ilias/Work/software/cfour/cfour_v2.00beta
CFOURown=$CFOUR/build/intel_mklpar_i8

workdir=/scratch/tmp/$USER/$PBS_JOBID/CFOURrun_own
mkdir -p $workdir

cd $workdir
echo -e "pwd=\c"; pwd

cp -R $CFOUR/testsuite    $workdir/.

cp -R $CFOURown/bin       $workdir/.
cp -R $CFOURown/share     $workdir/.
cp -R $CFOURown/basis     $workdir/.

echo -e "\n \n Own compiled CFOUR !"
cd $workdir
export PATH=$CFOURown/bin:$PATH
echo -e "\n PATH=$PATH"
cd testsuite
xtester --all

/bin/rm -rd  $workdir

exit 0
