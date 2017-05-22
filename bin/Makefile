# LLNS Copyright Start
# Copyright (c) 2017, Lawrence Livermore National Security
# This work was performed under the auspices of the U.S. Department 
# of Energy by Lawrence Livermore National Laboratory in part under 
# Contract W-7405-Eng-48 and in part under Contract DE-AC52-07NA27344.
# Produced at the Lawrence Livermore National Laboratory.
# All rights reserved.
# For details, see the LICENSE file.
# LLNS Copyright End

# Some simple build configurations for Parflow

SRC_DIR=parflow
BUILD_DIR=build
INSTALL_DIR=$(PARFLOW_DIR)

default: veryclean configure-mpi all install test

all:
	(pushd $(BUILD_DIR);make $(PARFLOW_MAKE_OPTIONS) all)

.PHONEY : configure-seq
configure-seq:
	mkdir -p $(BUILD_DIR)
	(pushd $(BUILD_DIR) && FC=$(PARFLOW_F77) CC=$(PARFLOW_CC) CXX=$(PARFLOW_CXX) cmake ../parflow \
	-DHYPRE_ROOT=$(PARFLOW_HYPRE_DIR) \
	-DHDF5_ROOT=$(PARFLOW_HDF5_DIR) \
	-DSILO_ROOT=$(PARFLOW_SILO_DIR) \
	-DSUNDIALS_ROOT=$(PARFLOW_SUNDIALS_DIR) \
	-DPARFLOW_ENABLE_TIMING=TRUE \
	-DPARFLOW_HAVE_CLM=ON \
	-DCMAKE_INSTALL_PREFIX=$(INSTALL_DIR)) 


# This is how to set the MPI compiler
#	-DMPI_C_COMPILER=${PARFLOW_CC} \
#	-DMPI_Fortran_COMPILER=${PARFLOW_F77} \

.PHONEY : configure-mpi
configure-mpi:
	mkdir -p $(BUILD_DIR)
	(pushd $(BUILD_DIR) && FC=$(PARFLOW_F77) CC=$(PARFLOW_CC) CXX=$(PARFLOW_CXX) cmake ../parflow \
        -DPARFLOW_AMPS_LAYER=mpi1 \
	-DHYPRE_ROOT=$(PARFLOW_HYPRE_DIR) \
	-DHDF5_ROOT=$(PARFLOW_HDF5_DIR) \
	-DSILO_ROOT=$(PARFLOW_SILO_DIR) \
	-DSZLIB_ROOT=$(PARFLOW_SZLIB_DIR) \
	-DSUNDIALS_ROOT=$(PARFLOW_SUNDIALS_DIR) \
	-DPARFLOW_ENABLE_TIMING=TRUE \
	-DPARFLOW_HAVE_CLM=ON \
	-DCMAKE_INSTALL_PREFIX=$(INSTALL_DIR)) 

.PHONEY : configure-mpi
configure-mpi-profile:
	mkdir -p $(BUILD_DIR)
	(pushd $(BUILD_DIR) && FC=$(PARFLOW_F77) CC=$(PARFLOW_CC) CXX=$(PARFLOW_CXX) cmake ../parflow \
        -DPARFLOW_AMPS_LAYER=mpi1 \
	-DHYPRE_ROOT=$(PARFLOW_HYPRE_DIR) \
	-DHDF5_ROOT=$(PARFLOW_HDF5_DIR) \
	-DSILO_ROOT=$(PARFLOW_SILO_DIR) \
	-DSUNDIALS_ROOT=$(PARFLOW_SUNDIALS_DIR) \
	-DPARFLOW_ENABLE_TIMING=TRUE \
	-DPARFLOW_HAVE_CLM=ON \
	-DPARFLOW_ENABLE_PROFILING=ON \
	-DCMAKE_INSTALL_PREFIX=$(INSTALL_DIR)) 

configure-oas3:
	mkdir -p $(BUILD_DIR)
	(pushd $(BUILD_DIR) && FC=$(PARFLOW_F77) CC=$(PARFLOW_CC) CXX=$(PARFLOW_CXX) cmake ../parflow \
	-DHYPRE_ROOT=$(PARFLOW_HYPRE_DIR) \
	-DHDF5_ROOT=$(PARFLOW_HDF5_DIR) \
	-DSILO_ROOT=$(PARFLOW_SILO_DIR) \
	-DCMAKE_BUILD_TYPE=Debug \
	-DPARFLOW_ENABLE_TIMING=TRUE \
	-DPARFLOW_HAVE_OAS3=ON \
	-DPARFLOW_AMPS_LAYER=oas3 \
	-DCMAKE_INSTALL_PREFIX=$(INSTALL_DIR)) 

.PHONEY : test
test:
	(pushd $(BUILD_DIR) && make test)
.PHONEY : install
install:
	(pushd $(BUILD_DIR) && make install)

.PHONEY : clean
clean:
	(pushd $(BUILD_DIR) && make clean)

.PHONEY : veryclean
veryclean:
	rm -fr $(BUILD_DIR) $(INSTALL_DIR)
