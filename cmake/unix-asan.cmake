cmake_minimum_required(VERSION 3.6)

if("${CTEST_BUILD_NAME}" STREQUAL "")
    set(CTEST_BUILD_NAME "${CTEST_BUILD_TYPE}")
else()
    set(CTEST_BUILD_NAME "${CTEST_BUILD_TYPE}/${CTEST_BUILD_NAME}")
endif()

set(CTEST_SOURCE_DIRECTORY ".")
set(CTEST_BINARY_DIRECTORY "build")

set(CTEST_CMAKE_GENERATOR "Unix Makefiles")

set(CTEST_MEMORYCHECK_TYPE AddressSanitizer)
set(CTEST_MEMORYCHECK_SANITIZER_OPTIONS "print_stacktrace=1:halt_on_error=1")

set(CTEST_USE_LAUNCHERS 1)
set(Drafter_CONFIG_OPTIONS
    "-DCMAKE_CXX_FLAGS='-fsanitize=address'"
)

set(CTEST_MODEL "Continuous")

ctest_read_custom_files(${CTEST_BINARY_DIRECTORY})

ctest_start(${CTEST_MODEL} TRACK ${CTEST_MODEL})
ctest_configure(BUILD ${CTEST_BINARY_DIRECTORY} OPTIONS "${Drafter_CONFIG_OPTIONS}" RETURN_VALUE ret_con)
ctest_build(BUILD ${CTEST_BINARY_DIRECTORY} RETURN_VALUE ret_bld)

if(ret_bld EQUAL 0)
    ctest_test(BUILD ${CTEST_BINARY_DIRECTORY} RETURN_VALUE ret_tst)
endif()

if(ret_bld EQUAL 0)
    ctest_memcheck(BUILD ${CTEST_BINARY_DIRECTORY} EXCLUDE DrafterIntegration RETURN_VALUE ret_mem)
endif()

ctest_submit(RETURN_VALUE ret_sub)

if(NOT ret_con EQUAL 0)
    message(FATAL_ERROR "CI failing on config")
endif()

if(NOT ret_bld EQUAL 0)
    message(FATAL_ERROR "CI failing on build")
endif()

if(NOT ret_tst EQUAL 0)
    message(FATAL_ERROR "CI failing on tests")
endif()

if(NOT ret_mem EQUAL 0)
    message(FATAL_ERROR "CI failing on memcheck")
endif()

if(NOT ret_sub EQUAL 0)
    message(WARNING "Unable to submit results to CDash")
endif()

