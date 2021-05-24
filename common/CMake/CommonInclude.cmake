# 开启nasm支持
if (ENABLE_ASM)
    set(CMAKE_NASM_LINK_EXECUTABLE "ld <LINK_FLAGS> <OBJECTS> -o <TARGET> <LINK_LIBRARIES>")
    set(CAN_USE_ASSEMBLER TRUE)
    set(CMAKE_ASM_NASM_OBJECT_FORMAT elf64)
    enable_language(ASM_NASM)

    # 开启gas(at&t)支持
    enable_language(ASM)
    if (UNIX)
        set(CMAKE_ASM${ASM_DIALECT}_OUTPUT_EXTENSION .o)
    else ()
        set(CMAKE_ASM${ASM_DIALECT}_OUTPUT_EXTENSION .obj)
    endif ()

    set(CMAKE_ASM${ASM_DIALECT}_COMPILE_OBJECT "<CMAKE_ASM${ASM_DIALECT}_COMPILER> <INCLUDES> <FLAGS> -o <OBJECT> <SOURCE>")

    set(CMAKE_ASM${ASM_DIALECT}_CREATE_STATIC_LIBRARY
            "<CMAKE_AR> cr <TARGET> <LINK_FLAGS> <OBJECTS> "
            "<CMAKE_RANLIB> <TARGET> ")

    set(CMAKE_ASM${ASM_DIALECT}_LINK_EXECUTABLE
            "<CMAKE_LINKER> <FLAGS> <CMAKE_ASM${ASM_DIALECT}_LINK_FLAGS> <LINK_FLAGS> <OBJECTS> -o <TARGET> <LINK_LIBRARIES>")

    # to be done
    set(CMAKE_ASM${ASM_DIALECT}_CREATE_SHARED_LIBRARY)
    set(CMAKE_ASM${ASM_DIALECT}_CREATE_SHARED_MODULE)
endif ()
# build type
function(UnixFlag)
    set(THREAD_LIB "pthread" CACHE STRING "")
    message("cmake build type : ${CMAKE_BUILD_TYPE}")
    set(CMAKE_CXX_FLAGS "-fPIC ${CMAKE_CXX_FLAGS}")
    if ("${CMAKE_BUILD_TYPE}" STREQUAL "Debug")
        SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -ggdb3 -g3 -fno-omit-frame-pointer")
        SET(CMAKE_CXX_FLAGS "${CMAKE_C_FLAGS} -ggdb3 -g3 -fno-omit-frame-pointer")
    elseif ("${CMAKE_BUILD_TYPE}" STREQUAL "Release")
        # 开O3了
        SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O3")
        SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -O3")
    else ()
        message("unknow type:${CMAKE_BUILD_TYPE}")
    endif ()
    message("cmake cxx build flags:${CMAKE_CXX_FLAGS}\n")
    message("THREAD_LIB : ${THREAD_LIB}")
endfunction()

if (WIN32)
    MESSAGE(STATUS "Now is windows")
elseif (APPLE)
    MESSAGE(STATUS "Now is Apple systens.")
    UnixFlag()
elseif (UNIX)
    MESSAGE(STATUS "Now is UNIX-like OS's.")
    UnixFlag()
endif ()

#配置版本号的映射文件，方便代码中使用
configure_file(
        "${BOOTSTRAP_DIR}/common/common_include/common_configure.h.in"
        "${PROJECT_BINARY_DIR}/convent/common_configure.h"
)
## 复制配置
file(COPY ${BOOTSTRAP_DIR}/common/data DESTINATION ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/)
file(COPY ${CONFIG_DIR} DESTINATION ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/)
# 头文件
include_directories(${BOOTSTRAP_DIR}/common/common_include)

include_directories(${PROJECT_BINARY_DIR}/convent)
# 通用cpp文件
set(common_cpps "")

#boost dynamic
if (boost_static)
    message("boost log static")
    set(Boost_USE_STATIC_LIBS ON)
else ()
    message("boost log DYN")
    set(Boost_USE_STATIC_LIBS OFF)
    add_definitions(-DBOOST_ALL_DYN_LINK)
    add_definitions(-DBOOST_LOG_DYN_LINK)
endif ()
