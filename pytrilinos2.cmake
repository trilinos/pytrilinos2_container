set(PYTHON3_EXECUTABLE "$ENV{PYTHON_ROOT}/bin/python3" CACHE FILEPATH "")

SET_BOOL_CACHE_VAR(Trilinos_ENABLE_PyTrilinos2 ON)
SET_BOOL_CACHE_VAR(PyTrilinos2_ENABLE_TESTS ON)
SET_BOOL_CACHE_VAR(PyTrilinos2_ENABLE_EXAMPLES ON)

SET_BOOL_CACHE_VAR(PyTrilinos2_BINDER_VERBOSE ON)

# SET_BOOL_CACHE_VAR(PyTrilinos2_ENABLE_Binder ON)
# set(PyTrilinos2_BINDER_EXECUTABLE "$ENV{BINDER_ROOT}/bin/binder" CACHE FILEPATH "")
# SET_BOOL_CACHE_VAR(PyTrilinos2_ENABLE_Update_Binder ON)

# set(PyTrilinos2_BINDER_GCC_TOOLCHAIN "$ENV{GCC_ROOT}" CACHE FILEPATH "")
# set(PyTrilinos2_BINDER_clang_include_dirs $ENV{LLVM_ROOT}/include CACHE FILEPATH "")
# set(PyTrilinos2_BINDER_LibClang_include_dir $ENV{LLVM_ROOT}/lib/clang/$ENV{LLVM_VERSION}/include CACHE FILEPATH "")
# set(PyTrilinos2_BINDER_FLAGS "-fopenmp;-I$ENV{OPENMPI_ROOT}/include" CACHE STRING "")

SET_BOOL_CACHE_VAR(ROL_ENABLE_PyROL ON)
SET_BOOL_CACHE_VAR(PyROL_ENABLE_ ON)

# SET_BOOL_CACHE_VAR(PyROL_ENABLE_Binder OFF)
# SET_BOOL_CACHE_VAR(PyROL_ENABLE_Update_Binder OFF)
# set(PyROL_BINDER_EXECUTABLE "$ENV{BINDER_PATH}/bin/binder" CACHE FILEPATH "")
# set(PyROL_BINDER_GCC_TOOLCHAIN "$ENV{GCC_ROOT}" CACHE FILEPATH "")
# set(PyROL_BINDER_FLAGS "-suppress-errors" CACHE STRING "")
# set(PyROL_BINDER_FLAGS "-fopenmp;-I/projects/sems/install/rhel7-x86_64/sems-compilers/tpl/gcc/7.3.0/gcc/4.8.5/base/odjqidm/lib/gcc/x86_64-pc-linux-gnu/7.3.0/include;-I/projects/sems/install/rhel7-x86_64/sems-compilers/tpl/gcc/7.3.0/gcc/4.8.5/base/odjqidm/include/c++/7.3.0/tr1" CACHE STRING "")
