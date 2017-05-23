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

# Appends to path if not path not already present
function appendToPath {
   echo $PATH | grep -q $1
   if [ $? -ne 0 ]
   then
      PATH=${PATH}:${1}
   fi
}

function prependToPath {
   echo $PATH | grep -q $1
   if [ $? -ne 0 ]
   then
      PATH=${1}:${PATH}
   fi
}

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

PARFLOW_CMAKE_ARGS="-DCMAKE_BUILD_TYPE=Release"

#=============================================================================
# Machine specific configuration 
#=============================================================================
case $(hostname) in

   cori*)
      # LBNL Cori
      # smith84@llnl.gov
      # 2017/05/22

      module load cray-hdf5
      module load cray-tpsl
      module unload darshan
      module load cmake/3.5.2

      # Cray sets the compiler up to find things but CMAKE probes don't understand 
      # this way of doing things. Use module statements to setup env and then use: 
      #
      # cc  -craype-verbose
      #
      # Examine -L paths to where things are installed at.
      export PARFLOW_SILO_DIR=/usr/common/software/silo/4.10.2/hsw/intel
      export PARFLOW_HYPRE_DIR=/opt/cray/pe/tpsl/16.07.1/INTEL/15.0/haswell
      export PARFLOW_SUNDIALS_DIR=/opt/cray/pe/tpsl/16.07.1/INTEL/15.0/haswell
      export PARFLOW_HDF5_DIR=/opt/cray/pe/hdf5/1.10.0/INTEL/15.0
      export PARFLOW_TCL_DIR=/usr/common/software/tcl/8.6.4/gnu
      export PARFLOW_SLURM_DIR=/usr/

      PARFLOW_CMAKE_ARGS="${PARFLOW_CMAKE_ARGS} -DTCL_TCLSH=${PARFLOW_TCL_DIR}/bin/tclsh8.6 -DPARFLOW_AMPS_LAYER=mpi1 -DPARFLOW_AMPS_SEQUENTIAL_IO=true"

      # Force shared library builds, by default Cori is doing static
      PARFLOW_CMAKE_ARGS="${PARFLOW_CMAKE_ARGS} -DPARFLOW_FORCE_SHARED_LIBS=true -DCMAKE_C_FLAGS='-dynamic'"

      PARFLOW_CMAKE_ARGS="${PARFLOW_CMAKE_ARGS} -DPARFLOW_ENABLE_SLURM=true"

      appendToLdPath $PARFLOW_SLURM_DIR/lib
      appendToLdPath $PARFLOW_PFTOOLS_HDF5_DIR/lib
      appendToLdPath $PARFLOW_TCL_DIR/lib
      ;;

   tux*)
      # LLNL Linux workstations
      # smith84@llnl.gov
      # 2015/11/06
      PARFLOW_MPI_DIR=/usr/casc/EBSim/apps/rh6/openmpi/1.10.0-gcc-4.9.1
      PARFLOW_SILO_DIR=$EBSIM_APPS_DIR/silo/4.10.2
      #PARFLOW_HYPRE_DIR=$EBSIM_APPS_DIR/hypre/2.10.1
      PARFLOW_HYPRE_DIR=$EBSIM_APPS_DIR/hypre/2.9.0b
      PARFLOW_HDF5_DIR=/usr/casc/EBSim/apps/rh6/hdf5/1.8.15p1
      PARFLOW_SUNDIALS_DIR=/usr/casc/EBSim/apps/rh6/sundials/R4475-pf

      PARFLOW_CC=mpicc
      PARFLOW_CXX=mpiCC
      PARFLOW_F77=mpif77
      PARFLOW_FC=mpif90

      PARFLOW_CMAKE_ARGS="${PARFLOW_CMAKE_ARGS} -DPARFLOW_AMPS_LAYER=mpi1 -DPARFLOW_AMPS_SEQUENTIAL_IO=true"

      PARFLOW_MAKE_OPTIONS="-j 12"
      ;;
   vulcan*)
      # LLNL Vulcan BG/Q machine
      # smith84@llnl.gov
      # 2016/06/17

      if [ -f /usr/local/tools/dotkit/init.sh ]; then
         . /usr/local/tools/dotkit/init.sh

	 use git
	 use tau
      fi

      export TAU_PROFILE_FORMAT=merged
      export TAU_MAKEFILE=/usr/global/tools/tau/training/tau-2.23.2b3/bgq/lib/Makefile.tau-bgqtimers-papi-mpi-pdt
      export TAU_OPTIONS="-optRevert"
      
      if true; then
	 PARFLOW_CC=mpixlcxx
	 PARFLOW_CXX=mpixlcxx
	 PARFLOW_F77=mpixlf77
	 PARFLOW_FC=mpixlf90
      else
	 PARFLOW_CC=tau_cc.sh
	 PARFLOW_CXX=tau_cxx.sh
	 PARFLOW_F77=tau_f77.sh
	 PARFLOW_FC=tau_f90.sh
      fi
	 

      PARFLOW_HYPRE_DIR=/usr/gapps/thcs/apps/bgqos_0/hypre/2.10.1
      PARFLOW_SILO_DIR=/usr/gapps/silo/4.10.3/bgqos_0_bgxlc
      PARFLOW_HDF5_DIR=/usr/gapps/silo/hdf5/1.8.10/bgqos_0_bgxlc
      PARFLOW_SZLIB_DIR=/usr/gapps/silo/szip/2.1/bgqos_0_bgxlc
      PARFLOW_ZLIB_DIR=/usr/gapps/silo/zlib/1.2.3/bgqos_0_bgxlc

      echo "Note: Should run pfconfigure on BG node"
      PARFLOW_CMAKE_ARGS="${PARFLOW_CMAKE_ARGS} -DPARFLOW_AMPS_LAYER=mpi1 -DPARFLOW_AMPS_SEQUENTIAL_IO=true"
      PFTOOLS_CONFIGURE_ARGS="--with-amps=mpi1"
      PFTOOLS_SILO_DIR=/usr/gapps/thcs/apps/bgqos_0/silo/4.10.3
      PFTOOLS_HDF5_DIR=/usr/gapps/thcs/apps/bgqos_0/hdf/2.10.1
      PFTOOLS_SZLIB_DIR=/usr/gapps/thcs/apps/bgqos_0/szip/2.1

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

	    if [ -f /usr/local/tools/dotkit/init.sh ]; then
               . /usr/local/tools/dotkit/init.sh

	       use cmake-3.4.1
	       use ic-16.0.210
	    fi

	    PARFLOW_MPI_DIR=/usr/local/bin
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
export PARFLOW_MPI_DIR 
export PARFLOW_HYPRE_DIR 
export PARFLOW_SILO_DIR 
export PARFLOW_HDF5_DIR 
export PARFLOW_SZLIB_DIR 
export PARFLOW_ZLIB_DIR
export PARFLOW_SLURM_DIR

export PARFLOW_CMAKE_ARGS

export PARFLOW_FC PARFLOW_F77 PARFLOW_CC PARFLOW_CXX 



