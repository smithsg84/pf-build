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

#=============================================================================
# Machine specific configuration 
#=============================================================================
case $(hostname) in
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
      PARFLOW_PFSIMULATOR_CONFIGURE_ARGS="--with-amps=mpi1 --with-amps-sequential-io --with-clm"

      PARFLOW_CC=mpicc
      PARFLOW_CXX=mpiCC
      PARFLOW_F77=mpif77
      PARFLOW_FC=mpif90

      PFTOOLS_TCL_DIR=/usr/casc/EBSim/apps/rh6/tcl/8.6.0
      PFTOOLS_CONFIGURE_ARGS="--with-amps=mpi1 --with-amps-sequential-io"
      PFTOOLS_CC=${PARFLOW_CC}

      PARFLOW_SVN_DIR=/usr/casc/EBSim/apps/rh6/svn/1.9.3

      if [ -f $PARFLOW_SVN_DIR/setup.sh ]
      then
	 . $PARFLOW_SVN_DIR/setup.sh
      fi

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
      PARFLOW_PFSIMULATOR_CONFIGURE_ARGS="--with-amps=mpi1 --with-clm"

      echo "Note: Should run pfconfigure on BG node"
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
	       # This is broke use vtune-2016
	       use vtune-2015.2
	    fi

	    PARFLOW_MPI_DIR=/usr/local/bin
	    PARFLOW_SILO_DIR=/usr/gapps/silo/4.10.2/chaos_5_x86_64_ib
	    PARFLOW_HYPRE_DIR=/usr/gapps/thcs/apps/hypre/2.10.1
	    PARFLOW_SUNDIALS_DIR=/usr/gapps/thcs/apps/sundials/R4475-pf
	    PARFLOW_HDF5_DIR=/usr/gapps/silo/hdf5/1.8.10/chaos_5_x86_64_ib
	    PARFLOW_SZLIB_DIR=/usr/gapps/silo/szip/2.1/chaos_5_x86_64_ib
	    PARFLOW_ZLIB_DIR=/usr
	    PARFLOW_PFSIMULATOR_CONFIGURE_ARGS="--with-amps=mpi1 --with-amps-sequential-io --with-clm --enable-opt=\"-O2 -g\" "

	    # LC wrappers take care of compilers/mpi with use statements
	    PARFLOW_CC=mpiicc
	    PARFLOW_CXX=mpiicpc
	    PARFLOW_F77=mpiifort
	    PARFLOW_FC=mpiifort

	    PFTOOLS_TCL_DIR=/usr
	    PFTOOLS_CONFIGURE_ARGS="--with-amps=mpi1 --with-amps-sequential-io"
	    PFTOOLS_CC=${PARFLOW_CC}
	    
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
appendToLdPath $PARFLOW_HDF5_DIR/lib
appendToLdPath $PARFLOW_SILO_DIR/lib

if [[ ${PARFLOW_SUNDIALS_DIR+x} ]]
then
   export PARFLOW_SUNDIALS_DIR
   appendToLdPath $PARFLOW_SUNDIALS_DIR/lib
fi

if [[ -z ${PFTOOLS_CC+x} ]]
then
   PFTOOLS_CC=${PARFLOW_CC}
fi

if [[ -z ${PFTOOLS_CXX+x} ]]
then
   PFTOOLS_CXX=${PARFLOW_CXX}
fi

if [[ -z ${PFTOOLS_HDF5_DIR+x} ]]
then
   PFTOOLS_HDF5_DIR=${PARFLOW_HDF5_DIR}
fi

if [[ -z ${PFTOOLS_SZLIB_DIR+x} ]]
then
   if [[ ${PARFLOW_SZLIB_DIR+x} ]]
   then
      PFTOOLS_SZLIB_DIR=${PARFLOW_SZLIB_DIR}
   fi
fi

if [[ -z ${PFTOOLS_ZLIB_DIR+x} ]]
then
   if [[ ${PARFLOW_ZLIB_DIR+x} ]]
   then
      PFTOOLS_ZLIB_DIR=${PARFLOW_ZLIB_DIR}
   fi
fi

if [[ ${PFTOOLS_SZLIB_DIR+x} ]]
then
   export PFTOOLS_SZLIB_DIR
   appendToLdPath $PFTOOLS_SZLIB_DIR/lib
fi

if [[ ${PFTOOLS_ZLIB_DIR+x} ]]
then
   export PFTOOLS_ZLIB_DIR
   appendToLdPath $PFTOOLS_ZLIB_DIR/lib
fi

if [[ ${PFTOOLS_TCL_DIR+x} ]]
then
   export PFTOOLS_TCL_DIR
   appendToLdPath $PFTOOLS_TCL_DIR/lib
fi

if [[ -z ${PFTOOLS_SILO_DIR+x} ]]
then
   echo Using default silo
   PFTOOLS_SILO_DIR=${PARFLOW_SILO_DIR}
fi


# Export variables
export PARFLOW_MPI_DIR PARFLOW_HYPRE_DIR 
export PARFLOW_SILO_DIR PARFLOW_HDF5_DIR PARFLOW_SZLIB_DIR PARFLOW_ZLIB_DIR
export PARFLOW_PFSIMULATOR_CONFIGURE_ARGS
export PARFLOW_FC PARFLOW_F77 PARFLOW_CC PARFLOW_CXX 

export PFTOOLS_CONFIGURE_ARGS
export PFTOOLS_SILO_DIR PFTOOLS_HDF5_DIR 
export PFTOOLS_CC PFTOOLS_CXX

