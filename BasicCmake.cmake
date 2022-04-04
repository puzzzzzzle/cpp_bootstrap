
# 公用定义,需要在设定完成后include
include(${BOOTSTRAP_DIR}/common/CMake/CommonInclude.cmake)


add_definitions(-DBOOTSTRAP_DIR=${BOOTSTRAP_DIR})
include(${BOOTSTRAP_DIR}/common/CMake/FuncDefs.cmake)

if (NOT IGNORE_CONAN)
    # 加载conan
    set(CONAN_LIBS "")
    set(CONAN_EXEC "conan install ..  --build missing  ${CONAN_ARGS} ")
    message("CONAN_EXEC at  ${CMAKE_CURRENT_SOURCE_DIR} : ${CONAN_EXEC}")
    execute_process(
            COMMAND conan install .. --build missing -s build_type=${CMAKE_BUILD_TYPE}
            OUTPUT_VARIABLE _RES
            ERROR_VARIABLE _RES
    )
    message("conan install end ${_RES}")
#    set(CONAN_DISABLE_CHECK_COMPILER "true")
    include(${CMAKE_BINARY_DIR}/conanbuildinfo.cmake)
    conan_basic_setup()
    message("conan get libs\t${CONAN_LIBS}\n")
    add_definitions(-DUSE_CONAN)
else ()
    add_definitions(-DIGNORE_CONAN)
endif ()

if (CMAKE_COMPILER_IS_GNUCC)
    execute_process(COMMAND ${CMAKE_C_COMPILER} -dumpfullversion -dumpversion
            OUTPUT_VARIABLE GCC_VERSION)
    string(REGEX MATCHALL "[0-9]+" GCC_VERSION_COMPONENTS ${GCC_VERSION})
    list(GET GCC_VERSION_COMPONENTS 0 GCC_MAJOR)
    list(GET GCC_VERSION_COMPONENTS 1 GCC_MINOR)
    message(STATUS "cmake version=${CMAKE_VERSION}")
    set(GCC_VERSION "${GCC_MAJOR}.${GCC_MINOR}")
    message(STATUS "gcc version=${GCC_VERSION}")
    message(STATUS "gcc version major=${GCC_MAJOR}")
    message(STATUS "gcc version minor=${GCC_MINOR}")

    if (GCC_VERSION GREATER "7")
        # gtest needs to be set “_GLIBCXX_USE_CXX11_ABI=0” if gcc version greater than 7
        add_definitions(-D_GLIBCXX_USE_CXX11_ABI=0)
    endif()
endif()



# 编译ptoro, 所有proto 打包为一个定义 PTOTO_CPPS
# TODO 实现中
#set(PROTO_CPP_DIR ${CMAKE_BINARY_DIR}/proto)
#BuildProto(${CMAKE_SOURCE_DIR}/src ${PROTO_CPP_DIR})
#include_directories(${PROTO_CPP_DIR})
#aux_source_directory(${PROTO_CPP_DIR} PROTO_CPPS)



