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

default: all install
#default: veryclean cmake-mpi-tux all install test

all:
	(pushd $(BUILD_DIR);make $(PARFLOW_MAKE_OPTIONS) all)

# This is how to set the MPI compiler
#	-DMPI_C_COMPILER=${PARFLOW_CC} \
#	-DMPI_Fortran_COMPILER=${PARFLOW_F77} \

.PHONEY : spack
spack:
	bin/pfstack

.PHONEY : cmake
clang:
	echo $(PARFLOW_CMAKE_ARGS)
	mkdir -p $(BUILD_DIR)
	(pushd $(BUILD_DIR) && FC=gfortran CC=clang CXX=clang++ cmake ../parflow \
	-DPARFLOW_ENABLE_TIMING=TRUE \
	-DPARFLOW_HAVE_CLM=ON \
	-DPARFLOW_AMPS_SEQUENTIAL_IO=true \
	$(PARFLOW_CMAKE_ARGS))

gnu:
	echo $(PARFLOW_CMAKE_ARGS)
	mkdir -p $(BUILD_DIR)
	(pushd $(BUILD_DIR) && FC=gfortran CC=gcc CXX=g++ cmake ../parflow \
	-DCMAKE_C_FLAGS="-Wall" \
	-DPARFLOW_ENABLE_TIMING=TRUE \
	-DPARFLOW_HAVE_CLM=ON \
	-DPARFLOW_AMPS_SEQUENTIAL_IO=true \
	-DPARFLOW_AMPS_LAYER=seq \
	-DCMAKE_INSTALL_PREFIX=/home/smith84/projects/conus/metadata-168/pf-build/local/rh7)

cygwin:
	echo $(PARFLOW_CMAKE_ARGS)
	mkdir -p $(BUILD_DIR)
	(pushd $(BUILD_DIR) && FC=$(PARFLOW_F77) CC=$(PARFLOW_CC) CXX=$(PARFLOW_CXX) cmake ../parflow \
	-DPARFLOW_ENABLE_TIMING=TRUE \
	-DPARFLOW_HAVE_CLM=ON \
	-DPARFLOW_AMPS_SEQUENTIAL_IO=TRUE \
	-DPARFLOW_ENABLE_HYPRE=TRUE \
	-DPARFLOW_ENABLE_SILO=TRUE \
	-DPARFLOW_AMPS_LAYER=mpi1 \
	$(PARFLOW_CMAKE_ARGS))

#	-DPARFLOW_ENABLE_LATEX=TRUE \

lc:
	echo $(PARFLOW_CMAKE_ARGS)
	mkdir -p $(BUILD_DIR)
	(pushd $(BUILD_DIR) && FC=$(PARFLOW_F77) CC=$(PARFLOW_CC) CXX=$(PARFLOW_CXX) cmake ../parflow \
	-DPARFLOW_ENABLE_TIMING=TRUE \
	-DCMAKE_BUILD_TYPE=Release \
	-DPARFLOW_HAVE_CLM=ON \
	-DPARFLOW_ENABLE_HDF5=TRUE \
	-DPARFLOW_ENABLE_HYPRE=TRUE \
	-DPARFLOW_ENABLE_SUNDIALS=TRUE \
	-DSILO_ROOT=$(PARFLOW_SILO_DIR) \
	-DPARFLOW_ENABLE_DOXYGEN=ON \
	$(PARFLOW_CMAKE_ARGS))

lc-valgrind:
	echo $(PARFLOW_CMAKE_ARGS)
	mkdir -p $(BUILD_DIR)
	(pushd $(BUILD_DIR) && FC=$(PARFLOW_F77) CC=$(PARFLOW_CC) CXX=$(PARFLOW_CXX) cmake ../parflow \
	-DPARFLOW_ENABLE_TIMING=TRUE \
	-DCMAKE_BUILD_TYPE=Debug \
	-DPARFLOW_HAVE_CLM=ON \
	-DPARFLOW_ENABLE_HDF5=TRUE \
	-DPARFLOW_ENABLE_HYPRE=TRUE \
	-DPARFLOW_ENABLE_SUNDIALS=TRUE \
	-DSILO_ROOT=$(PARFLOW_SILO_DIR) \
	-DPARFLOW_ENABLE_DOXYGEN=ON \
        -DPARFLOW_ENABLE_VALGRIND=true \
	$(PARFLOW_CMAKE_ARGS))

.PHONEY : tux
tux:
	echo $(PARFLOW_CMAKE_ARGS)
	mkdir -p $(BUILD_DIR)
	(pushd $(BUILD_DIR) && FC=$(PARFLOW_F77) CC=$(PARFLOW_CC) CXX=$(PARFLOW_CXX) cmake ../parflow \
	-DCMAKE_C_FLAGS="-Wall -Werror" \
	-DCMAKE_EXPORT_COMPILE_COMMANDS=1 \
	-DPARFLOW_ENABLE_TIMING=TRUE \
	-DCMAKE_BUILD_TYPE=Release \
	-DPARFLOW_HAVE_CLM=ON \
	-DPARFLOW_ENABLE_HDF5=TRUE \
	-DPARFLOW_ENABLE_NETCDF=TRUE \
	-DNETCDF_INCLUDE_DIR=${PARFLOW_NETCDF_DIR}/include -DNETCDF_LIBRARY=${PARFLOW_NETCDF_DIR}/lib/libnetcdf.a \
	-DPARFLOW_ENABLE_HYPRE=TRUE \
	-DPARFLOW_ENABLE_SUNDIALS=TRUE \
	-DSILO_ROOT=$(PARFLOW_SILO_DIR) \
	-DPARFLOW_ENABLE_DOXYGEN=ON \
	-DPARFLOW_ENABLE_LATEX=TRUE \
	$(PARFLOW_CMAKE_ARGS))

#       -DPARFLOW_ENABLE_VALGRIND=true \
#		-DCMAKE_BUILD_TYPE=Release \

#	-DCMAKE_BUILD_TYPE=Debug \

#	-DCMAKE_C_FLAGS="-Wall -Werror" \

.PHONEY : docs
doc:
	(pushd $(BUILD_DIR) && make doxygen)

.PHONEY : tux-valgrind
tux-valgrind:
	echo $(PARFLOW_CMAKE_ARGS)
	mkdir -p $(BUILD_DIR)
	(pushd $(BUILD_DIR) && FC=$(PARFLOW_F77) CC=$(PARFLOW_CC) CXX=$(PARFLOW_CXX) cmake ../parflow \
	-DCMAKE_C_FLAGS="-Wall -Werror" \
	-DCMAKE_EXPORT_COMPILE_COMMANDS=1 \
	-DPARFLOW_ENABLE_TIMING=TRUE \
	-DCMAKE_BUILD_TYPE=Release \
	-DPARFLOW_HAVE_CLM=ON \
	-DPARFLOW_ENABLE_HDF5=TRUE \
	-DPARFLOW_ENABLE_HYPRE=TRUE \
	-DPARFLOW_ENABLE_SUNDIALS=TRUE \
	-DSILO_ROOT=$(PARFLOW_SILO_DIR) \
	-DPARFLOW_ENABLE_DOXYGEN=ON \
	-DPARFLOW_ENABLE_LATEX=TRUE \
        -DPARFLOW_ENABLE_VALGRIND=true \
	$(PARFLOW_CMAKE_ARGS))

# NetCDF is failing on Redhat 7.3
#	-DPARFLOW_ENABLE_NETCDF=TRUE \

.PHONEY : cmake-mpi-profile
cmake-mpi-profile:
	mkdir -p $(BUILD_DIR)
	(pushd $(BUILD_DIR) && FC=$(PARFLOW_F77) CC=$(PARFLOW_CC) CXX=$(PARFLOW_CXX) cmake ../parflow \
	-DPARFLOW_ENABLE_TIMING=TRUE \
	-DPARFLOW_ENABLE_PROFILING=ON \
	-DPARFLOW_HAVE_CLM=ON \
	$(PARFLOW_CMAKE_ARGS))

cmake-oas3:
	mkdir -p $(BUILD_DIR)
	(pushd $(BUILD_DIR) && FC=$(PARFLOW_F77) CC=$(PARFLOW_CC) CXX=$(PARFLOW_CXX) cmake ../parflow \
	-DHYPRE_ROOT=$(PARFLOW_HYPRE_DIR) \
	-DHDF5_ROOT=$(PARFLOW_HDF5_DIR) \
	-DSILO_ROOT=$(PARFLOW_SILO_DIR) \
	-DCMAKE_BUILD_TYPE=Debug \
	-DPARFLOW_ENABLE_TIMING=TRUE \
	-DPARFLOW_HAVE_OAS3=ON \
	-DPARFLOW_AMPS_LAYER=oas3 \
	$(PARFLOW_CMAKE_ARGS))


.PHONEY : cori
cori:
	@echo $(PARFLOW_CMAKE_ARGS)
	mkdir -p $(BUILD_DIR)
	(pushd $(BUILD_DIR) && FC=$(PARFLOW_F77) CC=$(PARFLOW_CC) CXX=$(PARFLOW_CXX) cmake ../parflow \
	-DCMAKE_BUILD_TYPE=Release \
        -DPARFLOW_ENABLE_TIMING=TRUE \
	-DPARFLOW_HAVE_CLM=ON \
	-DHYPRE_ROOT=$(PARFLOW_HYPRE_DIR) \
	-DHDF5_ROOT=$(PARFLOW_HDF5_DIR) \
	-DSILO_ROOT=$(PARFLOW_SILO_DIR) \
	-DNETCDF_INCLUDE_DIR=${PARFLOW_NETCDF_DIR}/include -DNETCDF_LIBRARY=${PARFLOW_NETCDF_DIR}/lib/libnetcdf.a \
	-DMPIEXEC='/usr/bin/srun' -DMPIEXEC_NUMPROC_FLAG='-n' \
	$(PARFLOW_CMAKE_ARGS))

.PHONEY : cori-wrf
cori-wrf:
	@echo $(PARFLOW_CMAKE_ARGS)
	mkdir -p $(BUILD_DIR)
	(pushd $(BUILD_DIR) && FC=$(PARFLOW_F77) CC=$(PARFLOW_CC) CXX=$(PARFLOW_CXX) cmake ../parflow \
	-DPARFLOW_ENABLE_TIMING=TRUE \
	-DHYPRE_ROOT=$(PARFLOW_HYPRE_DIR) \
	-DHDF5_ROOT=$(PARFLOW_HDF5_DIR) \
	-DSILO_ROOT=$(PARFLOW_SILO_DIR) \
	-DNETCDF_INCLUDE_DIR=${PARFLOW_NETCDF_DIR}/include -DNETCDF_LIBRARY=${PARFLOW_NETCDF_DIR}/lib/libnetcdf.a \
	$(PARFLOW_CMAKE_ARGS))

.PHONEY : test
test:
	(pushd $(BUILD_DIR) && make test)

.PHONEY : check
check: test

.PHONEY : install
install:
	(pushd $(BUILD_DIR) && make $(PARFLOW_MAKE_OPTIONS) install)

.PHONEY : clean
clean:
	(pushd $(SRC_DIR)/test && make clean)
	(pushd $(SRC_DIR)/test/clm && make clean)
	(pushd $(SRC_DIR)/examples && make clean)

.PHONEY : veryclean
veryclean: clean
	rm -fr $(BUILD_DIR) $(INSTALL_DIR)
