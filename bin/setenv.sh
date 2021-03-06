#!/bin/bash
# LLNS Copyright Start
# Copyright (c) 2017, Lawrence Livermore National Security
# This work was performed under the auspices of the U.S. Department 
# of Energy by Lawrence Livermore National Laboratory in part under 
# Contract W-7405-Eng-48 and in part under Contract DE-AC52-07NA27344.
# Produced at the Lawrence Livermore National Laboratory.
# All rights reserved.
# For details, see the LICENSE file.
# LLNS Copyright End

#############################################################################
# Setup PF environment
#############################################################################
#
# Sets up the Parflow build environment for frequently used machines.
#
# If PARFLOW_DIR is set prior to sourcing this script will use user specified location
# for install.  Defauts to current ../install if not specified.


# Make sure this file is sourced not executed since this sets environment variables
if [[ ! "${BASH_SOURCE[0]}" != "${0}" ]] 
then
   echo "${0} should be sourced, not executed: source ${0}"
fi

export PROJECT="conus"

function appendToLdPath {

   if [[ -z ${LD_LIBRARY_PATH+x} ]]
   then
      export LD_LIBRARY_PATH=${1}
   else
      echo $LD_LIBRARY_PATH | grep -q $1
      if [ $? -ne 0 ]
      then
	 export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${1}
      fi
   fi
}

if [ ! -d parflow/pfsimulator ]
then
   echo "Source this script in the root of the parflow source directory"
fi

if [ -z "${SYS_TYPE+set}" ]; then
   PARFLOW_SYS_TYPE=$(uname -p)
else
   PARFLOW_SYS_TYPE=${SYS_TYPE}
fi 

export PARFLOW_SRC_DIR=${PWD}/parflow

#=============================================================================
# Set PARFLOW_DIR.
# This is where PF will be installed.
# Set by going to directory to get clean absolute path.
#=============================================================================
if [[ ${PARFLOW_DIR+x} ]]
then
   INSTALL_DIR=$PARFLOW_DIR
else
   INSTALL_DIR=./local/${PARFLOW_SYS_TYPE}
fi

mkdir -p $INSTALL_DIR
pushd $INSTALL_DIR &> /dev/null
export PARFLOW_DIR=${PWD}
popd &> /dev/null

echo "Setting up to install to : $PARFLOW_DIR"

#PARFLOW_CMAKE_ARGS="-DCMAKE_BUILD_TYPE=Release"
PARFLOW_CMAKE_ARGS=""

export PARFLOW_CFLAGS=""

#=============================================================================
# Machine specific configuration 
#=============================================================================
case $(hostname) in

   cori*)
      # LBNL Cori
      # smith84@llnl.gov
      # 2018/08/02

      module load cray-hdf5-parallel
      module load cray-netcdf-hdf5parallel
      module load cray-tpsl
      module unload darshan
      module load cmake/3.5.2

      # Cray sets the compiler up to find things but CMAKE probes don't understand 
      # this way of doing things. Use module statements to setup env and then use: 
      #
      # cc  -craype-verbose
      #
      # Examine -L paths to where things are installed at.
      #export PARFLOW_HDF5_DIR=/opt/cray/pe/hdf5-parallel/default/INTEL/16.0
      #export PARFLOW_NETCDF_DIR=/opt/cray/pe/netcdf-hdf5parallel/default/INTEL/16.0
      #export PARFLOW_HYPRE_DIR=/opt/cray/pe/tpsl/default/INTEL/16.0/haswell/
      #export PARFLOW_SUNDIALS_DIR=/opt/cray/pe/tpsl/default/INTEL/16.0/haswell/

      export PARFLOW_HYPRE_DIR=${CRAY_TPSL_DIR}/INTEL/${PE_TPSL_GENCOMPILERS_INTEL_x86_64}/haswell
      export PARFLOW_SUNDIALS_DIR=${CRAY_TPSL_DIR}/INTEL/${PE_TPSL_GENCOMPILERS_INTEL_x86_64}/haswell
      export PARFLOW_NETCDF_DIR=${CRAY_NETCDF_DIR}/INTEL/${PE_TPSL_GENCOMPILERS_INTEL_x86_64}
      export PARFLOW_HDF5_DIR=${CRAY_HDF5_DIR}/INTEL/${PE_TPSL_GENCOMPILERS_INTEL_x86_64}
      export PARFLOW_SILO_DIR=/usr/common/software/silo/4.10.2/hsw/intel
      export PARFLOW_TCL_DIR=/usr/common/software/tcl/8.6.4/gnu
      export PARFLOW_SLURM_DIR=/usr/

      # Maybe CMAKE_LINK_SEARCH_START_STATIC

      PARFLOW_CMAKE_ARGS="${PARFLOW_CMAKE_ARGS} -DTCL_TCLSH=${PARFLOW_TCL_DIR}/bin/tclsh8.6 -DPARFLOW_AMPS_LAYER=mpi1 -DPARFLOW_AMPS_SEQUENTIAL_IO=true"

      # Force shared library builds, by default Cori is doing static.  Need to set for both 
      # C and Fortran otherise Cmake will not build dynamic do to rules in the Cray cmake modules.
      PARFLOW_CMAKE_ARGS="${PARFLOW_CMAKE_ARGS} -DCMAKE_C_FLAGS='-dynamic' -DCMAKE_Fortran_FLAGS='-dynamic'"

      PARFLOW_CMAKE_ARGS="${PARFLOW_CMAKE_ARGS} -DPARFLOW_ENABLE_SLURM=true"

      # This was needed due to way Hypre was compiled, unresolved symbols if not used.
      PARFLOW_CMAKE_ARGS="${PARFLOW_CMAKE_ARGS} -DPARFLOW_LINKER_FLAGS='-parallel'"

      # Parallel build fails in CLM
      #PARFLOW_MAKE_OPTIONS="-j 8"
      PARFLOW_MAKE_OPTIONS=""

      export PARFLOW_CC=cc 
      export PARFLOW_CXX=CC 
      export PARFLOW_F77=ftn 
      export PARFLOW_FC=ftn

      export PARFLOW_CFLAGS='-dynamic'

      appendToLdPath $PARFLOW_SLURM_DIR/lib
      appendToLdPath $PARFLOW_PFTOOLS_HDF5_DIR/lib
      appendToLdPath $PARFLOW_TCL_DIR/lib
      ;;

   tux*)
      # LLNL Linux workstations
      # smith84@llnl.gov
      # 2019/01/28
      source $EBSIM_APPS_DIR/cmake/3.17.3/setup.sh
      source ${EBSIM_APPS_DIR}/uncrustify/0.67/setup.sh
      #source ${EBSIM_APPS_DIR}/rtags/2.37/setup.sh
      source ${EBSIM_APPS_DIR}/gcc/10.2.0/setup.sh
      source ${EBSIM_APPS_DIR}/clang/10.0.0/setup.sh

      source /usr/casc/EBSim/apps/rh7/valgrind/3.15.0/setup.sh

      if ( false )
      then
	 echo "Setting up debug env"

	 source $EBSIM_APPS_DIR/openmpi/3.0.0-debug/setup.sh
	 export PARFLOW_HYPRE_DIR=$EBSIM_APPS_DIR/openmpi/3.0.0-debug
	 export PARFLOW_HDF5_DIR=$EBSIM_APPS_DIR/openmpi/3.0.0-debug
	 export PARFLOW_NETCDF_DIR=$EBSIM_APPS_DIR/openmpi/3.0.0-debug
	 export NCDIR=$EBSIM_APPS_DIR/openmpi/3.0.0-debug
	 export PARFLOW_SILO_DIR=$EBSIM_APPS_DIR/openmpi/3.0.0-debug

	 export PARFLOW_MPIEXEC_EXTRA_FLAGS="--mca mpi_yield_when_idle 1 --oversubscribe"
      else
	 #module load mpi/openmpi-x86_64
	 #PARFLOW_SILO_DIR=/usr/casc/EBSim/apps/rh7/silo/4.10.2.openmpi
	 #module load mpi/mpich-x86_64
	 #PARFLOW_SILO_DIR=/usr/casc/EBSim/apps/rh7/silo/4.10.2.mpich
	 
	 source ${EBSIM_APPS_DIR}/openmpi/4.0.5/setup.sh
	 export PARFLOW_HYPRE_DIR=$EBSIM_APPS_DIR/openmpi/4.0.5
	 export PARFLOW_HDF5_DIR=$EBSIM_APPS_DIR/openmpi/4.0.5
	 export PARFLOW_NETCDF_DIR=$EBSIM_APPS_DIR/openmpi/4.0.5
	 export NCDIR=$EBSIM_APPS_DIR/openmpi/4.0.5
	 export PARFLOW_SILO_DIR=$EBSIM_APPS_DIR/openmpi/4.0.5
      fi

      PARFLOW_CC=mpicc
      PARFLOW_CXX=mpiCC
      PARFLOW_F77=mpif77
      PARFLOW_FC=mpif90

      export PARFLOW_TCL_DIR=$EBSIM_APPS_DIR/tcl/8.6.9
      appendToLdPath $PARFLOW_TCL_DIR/lib
      PARFLOW_CMAKE_ARGS="${PARFLOW_CMAKE_ARGS} -DTCL_TCLSH=${PARFLOW_TCL_DIR}/bin/tclsh8.6 -DTCL_LIBRARY=${PARFLOW_TCL_DIR}/lib/libtcl8.6.so -DTCL_INCLUDE_PATH=${PARFLOW_TCL_DIR}/include -DTK_LIBRARY=${PARFLOW_TCL_DIR}/lib/libtk8.6.so -DTK_INCLUDE_PATH=${PARFLOW_TCL_DIR}/include"
      
      PARFLOW_CMAKE_ARGS="${PARFLOW_CMAKE_ARGS} -DPARFLOW_AMPS_LAYER=mpi1 -DPARFLOW_AMPS_SEQUENTIAL_IO=true"
      #PARFLOW_CMAKE_ARGS="${PARFLOW_CMAKE_ARGS} -DPARFLOW_AMPS_LAYER=smpi -DPARFLOW_AMPS_SEQUENTIAL_IO=true"
      
      PARFLOW_MAKE_OPTIONS="-j 12"
      ;;
   *quartz*)
      # LLNL Quartz 
      # smith84@llnl.gov
      # 2017/09/12

      echo "Setting up for quartz"

      module load cmake/3.14.5

      PARFLOW_SILO_DIR=/usr/gapps/silo/4.10.2/${SYS_TYPE}
      PARFLOW_HYPRE_DIR=/usr/gapps/thcs/apps/${SYS_TYPE}/hypre/2.18.2-gcc
      PARFLOW_SUNDIALS_DIR=/usr/gapps/thcs/apps/${SYS_TYPE}/sundials/R4475-pf
      PARFLOW_HDF5_DIR=/usr/gapps/silo/hdf5/1.8.16/${SYS_TYPE}
      PARFLOW_SZLIB_DIR=/usr/gapps/silo/szip/2.1/${SYS_TYPE}
      PARFLOW_ZLIB_DIR=/usr
      PARFLOW_CMAKE_ARGS="${PARFLOW_CMAKE_ARGS} -DPARFLOW_AMPS_LAYER=mpi1 -DPARFLOW_AMPS_SEQUENTIAL_IO=true -DPARFLOW_HAVE_CLM=yes"
      
      if true; then
	 PARFLOW_CC=mpicc
	 PARFLOW_CXX=mpicxx
	 PARFLOW_F77=mpif77
	 PARFLOW_FC=mpifort
      else
	 # export TAU_PROFILE_FORMAT=merged
	 # export TAU_MAKEFILE=/usr/global/tools/tau/training/tau-2.23.2b3/bgq/lib/Makefile.tau-bgqtimers-papi-mpi-pdt
	 export TAU_OPTIONS="-optRevert"

	 if [ -f /usr/tce/packages/dotkit/init.sh ]; then
	    . /usr/tce/packages/dotkit/init.sh
	    use tau
	 fi

	 PARFLOW_CC=tau_cc.sh
	 PARFLOW_CXX=tau_cxx.sh
	 PARFLOW_F77=tau_f77.sh
	 PARFLOW_FC=tau_f90.sh
      fi
      
      PFTOOLS_CC=gcc
      PFTOOLS_CXX=g++
      
      PARFLOW_MAKE_OPTIONS="-j 8"
      ;;

   *flash*)
      # LLNL Flash
      # smith84@llnl.gov
      # 2018/08/27

      echo "Setting up for flash"

      #module load gcc/8.1.0
      module load cmake/3.14.5

      LOCAL_DIR=/usr/gapps/thcs/apps/${SYS_TYPE}

      PARFLOW_HYPRE_DIR=${LOCAL_DIR}/hypre/2.17.0-gcc
      PARFLOW_HDF5_DIR=${LOCAL_DIR}/hdf/1.8.21
      PARFLOW_SILO_DIR=${LOCAL_DIR}/silo/4.10.2
      PARFLOW_SZLIB_DIR=/usr

      PARFLOW_ZLIB_DIR=/usr
      PARFLOW_CMAKE_ARGS="${PARFLOW_CMAKE_ARGS} -DPARFLOW_AMPS_LAYER=mpi1 -DPARFLOW_AMPS_SEQUENTIAL_IO=true -DPARFLOW_HAVE_CLM=yes"
      
      if true
      then
	 PARFLOW_CC=mpicc
	 PARFLOW_CXX=mpicxx
	 PARFLOW_F77=mpif77
	 PARFLOW_FC=mpifort
      else

	 # export TAU_PROFILE_FORMAT=merged
	 # export TAU_MAKEFILE=/usr/global/tools/tau/training/tau-2.23.2b3/bgq/lib/Makefile.tau-bgqtimers-papi-mpi-pdt
	 # export TAU_OPTIONS="-optRevert"

	 if [ -f /usr/tce/packages/dotkit/init.sh ]; then
	    . /usr/tce/packages/dotkit/init.sh
	    use tau
	 fi

	 export TAU_OPTIONS=-optRevert

	 PARFLOW_CC=tau_cc.sh
	 PARFLOW_CXX=tau_cxx.sh
	 PARFLOW_F77=tau_f77.sh
	 PARFLOW_FC=tau_f90.sh
      fi
      
      PFTOOLS_CC=gcc
      PFTOOLS_CXX=g++

      appendToLdPath $PFTOOLS_HDF5_DIR/lib
      appendToLdPath $PFTOOLS_SILO_DIR/lib
      appendToLdPath $PFTOOLS_SZLIB_DIR/lib

      PARFLOW_MAKE_OPTIONS="-j 8"
      ;;
   *)
      # Checks based on uname.
      case $(uname -a) in
	 *chaos*)
	    # General LC

	    if [ -f /usr/local/tools/dotkit/init.sh ]; then
               . /usr/local/tools/dotkit/init.sh

	       use cmake-3.4.1
	       use ic-16.0.210
	    fi

	    PARFLOW_SILO_DIR=/usr/gapps/silo/4.10.2/chaos_5_x86_64_ib
	    PARFLOW_HYPRE_DIR=/usr/gapps/thcs/apps/hypre/2.10.1
	    PARFLOW_SUNDIALS_DIR=/usr/gapps/thcs/apps/sundials/R4475-pf
	    PARFLOW_HDF5_DIR=/usr/gapps/silo/hdf5/1.8.10/chaos_5_x86_64_ib
	    PARFLOW_SZLIB_DIR=/usr/gapps/silo/szip/2.1/chaos_5_x86_64_ib
	    PARFLOW_ZLIB_DIR=/usr

	    PARFLOW_CMAKE_ARGS="${PARFLOW_CMAKE_ARGS} -DPARFLOW_AMPS_LAYER=mpi1 -DPARFLOW_AMPS_SEQUENTIAL_IO=true"
	    PARFLOW_CMAKE_ARGS="${PARFLOW_CMAKE_ARGS} -DPARFLOW_ENABLE_SLURM=true"

	    PARFLOW_CC=icc
	    PARFLOW_CXX=icpc
	    PARFLOW_F77=ifort
	    PARFLOW_FC=ifort

	    PFTOOLS_TCL_DIR=/usr
	    PARFLOW_MAKE_OPTIONS="-j 8"
	    ;;
	  *Ubuntu*)
	    PARFLOW_CC=mpicc
	    PARFLOW_CXX=mpiCC
	    PARFLOW_F77=mpif77
	    PARFLOW_FC=mpif90

	    cores=$(grep 'cpu cores' /proc/cpuinfo | uniq | awk '{print $4}')
    	    PARFLOW_MAKE_OPTIONS="-j $cores"
	    ;;
	  *CYGWIN*)
	    PARFLOW_CC=mpicc
	    PARFLOW_CXX=mpic++
	    PARFLOW_F77=mpifort
	    PARFLOW_FC=mpif90
	    
	    export PARFLOW_MPIEXEC_EXTRA_FLAGS="--oversubscribe"
	    ;;
	 *)
	    echo "Don't know how to setup on $hostname"
	    exit 1
	    ;;
      esac
esac

#=============================================================================
# Generic configuration 
#=============================================================================



appendToPath $PARFLOW_DIR/bin

if [[ -n ${PARFLOW_SUNDIALS_DIR+x} ]]
then
   export PARFLOW_SUNDIALS_DIR
   appendToLdPath $PARFLOW_SUNDIALS_DIR/lib

   PARFLOW_CMAKE_ARGS="${PARFLOW_CMAKE_ARGS} -DSUNDIALS_ROOT=${PARFLOW_SUNDIALS_DIR}"
fi

if [[ -n ${PARFLOW_HDF5_DIR+x} ]]
then
   appendToLdPath $PARFLOW_HDF5_DIR/lib

   PARFLOW_CMAKE_ARGS="${PARFLOW_CMAKE_ARGS} -DHDF5_ROOT=${PARFLOW_HDF5_DIR}"
fi

if [[ -n ${PARFLOW_HYPRE_DIR+x} ]]
then
   PARFLOW_CMAKE_ARGS="${PARFLOW_CMAKE_ARGS} -DHYPRE_ROOT=${PARFLOW_HYPRE_DIR}"
fi

if [[ -n ${PARFLOW_SILO_DIR+x} ]]
then
   appendToLdPath $PARFLOW_SILO_DIR/lib

   PARFLOW_CMAKE_ARGS="${PARFLOW_CMAKE_ARGS} -DSILO_ROOT=${PARFLOW_SILO_DIR}"
fi

if [[ -n ${PARFLOW_SZLIB_DIR+x} ]]
then
   PARFLOW_CMAKE_ARGS="${PARFLOW_CMAKE_ARGS} -DSZLIB_ROOT=${PARFLOW_SZLIB_DIR}"
fi

if [[ -n  ${PARFLOW_ZLIB_DIR+x} ]]
then
   PARFLOW_CMAKE_ARGS="${PARFLOW_CMAKE_ARGS} -DZLIB_ROOT=${PARFLOW_ZLIB_DIR}"
fi

PARFLOW_CMAKE_ARGS="${PARFLOW_CMAKE_ARGS} -DCMAKE_INSTALL_PREFIX=${PARFLOW_DIR}"

# Export variables
export PARFLOW_HYPRE_DIR 
export PARFLOW_SILO_DIR 
export PARFLOW_HDF5_DIR 
export PARFLOW_SZLIB_DIR 
export PARFLOW_ZLIB_DIR
export PARFLOW_SLURM_DIR

export PARFLOW_CMAKE_ARGS
export PARFLOW_MAKE_OPTIONS

export PARFLOW_FC PARFLOW_F77 PARFLOW_CC PARFLOW_CXX 



