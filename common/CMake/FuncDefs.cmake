# 获取目录的子目录
function(GetSubDirs Dir Result)
    message("get dirs in  ${Dir}")
    EXECUTE_PROCESS(
            COMMAND python3 ${BOOTSTRAP_DIR}/common/CMake/travel_dir.py ${Dir} d
            OUTPUT_VARIABLE DIRS
    )
    set(${Result} ${DIRS} PARENT_SCOPE)
    message("All dirs ${DIRS}")
endfunction()

# 添加所有子目录到编译列表中
function(AddAllSubDir)
    foreach (SRC_DIR_ROOT ${SRC_DIR_ROOTS})
        message("add one dir ${SRC_DIR_ROOT}")
        include_directories(${SRC_DIR_ROOT})
        GetSubDirs(${SRC_DIR_ROOT} SubDir)
        message("SRC_DIR_ROOT: ${SRC_DIR_ROOT}")

        foreach (dir ${SubDir})
            if (NOT EXISTS "${dir}/CMakeLists.txt")
                continue()
            endif ()
            # 给个默认目标名字: 相对 CMAKE_SOURCE_DIR 路径
            string(REPLACE "${CMAKE_SOURCE_DIR}/" "" relative_dir ${dir})
            string(REGEX REPLACE "/" "_" build_temp ${relative_dir})

            message("- ${build_temp}")
            add_subdirectory(${dir})
        endforeach ()
    endforeach ()
endfunction()

function(SetBinDir Dir)
    set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${Dir} PARENT_SCOPE)
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${Dir} PARENT_SCOPE)
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${Dir} PARENT_SCOPE)
endfunction()

# 下载文件 和 hash
function(download_file_with_hash url filename hash_type hash)
    message(STATUS "Download to ${filename} ...")
    file(DOWNLOAD ${url} ${filename} EXPECTED_HASH ${hash_type}=${hash})
endfunction()

# 解压缩文件
function(extract_file filename extract_dir)
    message(STATUS "Extract to ${extract_dir} ...")

    # 创建临时目录，用来解压，如果已经存在，则删除
    # 这里用的解压命令，是 cmake 内部实现的解压命令，可以实现跨平台解压：
    # cmake -E tar -xf filename.tgz
    set(temp_dir ${CMAKE_BINARY_DIR}/tmp_for_extract.dir)
    if (EXISTS ${temp_dir})
        file(REMOVE_RECURSE ${temp_dir})
    endif ()
    file(MAKE_DIRECTORY ${temp_dir})
    execute_process(
            COMMAND ${CMAKE_COMMAND} -E tar -xf ${filename}
            WORKING_DIRECTORY ${temp_dir}
    )

    # 这里比较关键，解压之后的临时目录中，可能是单个文件夹，里面包含着我们需要的内容，
    # 也可能是直接就包含着我们需要的内容，因此，这里就统一处理，如果包含单独的文件夹
    # 则将安装源目录设置为临时目录的下级目录
    file(GLOB contents "${temp_dir}/*")
    list(LENGTH contents n)
    if (NOT n EQUAL 1 OR NOT IS_DIRECTORY "${contents}")
        set(contents "${temp_dir}")
    endif ()

    get_filename_component(contents ${contents} ABSOLUTE)
    # 这里选择 INSTALL 而不是 COPY，因为可以打印出文件拷贝的状态
    file(INSTALL "${contents}/" DESTINATION ${extract_dir})

    # 别忘删除临时目录
    file(REMOVE_RECURSE ${temp_dir})
endfunction()

# 下载并解压缩
function(download_and_extract)
    set(options REMOVE_EXTRACT_DIR_IF_EXISTS)
    set(oneValueArgs DESTINATION RENAME)
    set(multiValueArgs)
    set(oneValueArgs URL FILENAME HASH_TYPE HASH EXTRACT_DIR)
    cmake_parse_arguments(DAE "${options}" "${oneValueArgs}" "${multiValueArgs}"
            ${ARGN})
    if (NOT DEFINED DAE_URL)
        message(FATAL_ERROR "Missing URL")
    endif ()
    if (NOT DEFINED DAE_FILENAME)
        message(FATAL_ERROR "Missing FILENAME")
    endif ()
    if (NOT DEFINED DAE_HASH_TYPE)
        message(FATAL_ERROR "Missing HASH_TYPE")
    endif ()
    if (NOT DEFINED DAE_HASH)
        message(FATAL_ERROR "Missing HASH")
    endif ()
    if (NOT DEFINED DAE_EXTRACT_DIR)
        message(FATAL_ERROR "Missing EXTRACT_DIR")
    endif ()

    if (EXISTS ${DAE_EXTRACT_DIR})
        if (DAE_REMOVE_EXTRACT_DIR_IF_EXISTS)
            message(STATUS "${DAE_EXTRACT_DIR} already exists, removing...")
            file(REMOVE_RECURSE ${DAE_EXTRACT_DIR})
        else ()
            message(
                    STATUS "${DAE_EXTRACT_DIR} already exists, skip download & extract")
            return()
        endif ()
    endif ()

    if (EXISTS ${DAE_FILENAME})
        file(${DAE_HASH_TYPE} ${DAE_FILENAME} _ACTUAL_CHKSUM)

        if (NOT (${_EXPECT_HASH} STREQUAL ${_ACTUAL_CHKSUM}))
            message(STATUS "Expect ${DAE_HASH_TYPE}=${_EXPECT_HASH}")
            message(STATUS "Actual ${DAE_HASH_TYPE}=${_ACTUAL_CHKSUM}")
            message(WARNING "File hash mismatch, remove & retry ...")
            file(REMOVE ${DAE_FILENAME})
            download_file_with_hash(${DAE_URL} ${DAE_FILENAME} ${DAE_HASH_TYPE}
                    ${_EXPECT_HASH})
        else ()
            message(STATUS "Using exists local file ${DAE_FILENAME}")
        endif ()
    else ()
        download_file_with_hash(${DAE_URL} ${DAE_FILENAME} ${DAE_HASH_TYPE}
                ${_EXPECT_HASH})
    endif ()
    extract_file(${DAE_FILENAME} ${DAE_EXTRACT_DIR})
endfunction()

# 开启 asm 支持
function(OpenAsmSupport)
    set(CAN_USE_ASSEMBLER TRUE PARENT_SCOPE)

    # 开启nasm支持
    enable_language(ASM_NASM)

    # 开启gas(at&t)支持
    enable_language(ASM)


    # message("ASM_COMPILER : <CMAKE_ASM${ASM_DIALECT}_COMPILER>")
    # TODO
    set(CMAKE_ASM${ASM_DIALECT}_COMPILE_OBJECT "<CMAKE_ASM${ASM_DIALECT}_COMPILER> <INCLUDES> <FLAGS> -o <OBJECT> <SOURCE>" PARENT_SCOPE)
    set(CMAKE_ASM${ASM_DIALECT}_CREATE_STATIC_LIBRARY
            "<CMAKE_AR> cr <TARGET> <LINK_FLAGS> <OBJECTS> "
            "<CMAKE_RANLIB> <TARGET> " PARENT_SCOPE)
    set(CMAKE_ASM${ASM_DIALECT}_LINK_EXECUTABLE
            "<CMAKE_LINKER> <FLAGS> <CMAKE_ASM${ASM_DIALECT}_LINK_FLAGS> <LINK_FLAGS> <OBJECTS> -o <TARGET> <LINK_LIBRARIES>" PARENT_SCOPE)

    # TODO
    set(CMAKE_ASM${ASM_DIALECT}_CREATE_SHARED_LIBRARY PARENT_SCOPE)
    set(CMAKE_ASM${ASM_DIALECT}_CREATE_SHARED_MODULE PARENT_SCOPE)
endfunction()

# 设置常用编译选项
function(SetCommonBuildFlag)
    # 公用定义,需要在设定完成后include
    if (WIN32)
        MESSAGE(STATUS "Now is windows")
    elseif (UNIX OR APPLE)
        MESSAGE(STATUS "Now is UNIX-like OS's.")
        message("cmake build type : ${CMAKE_BUILD_TYPE}")
        if ("${CMAKE_BUILD_TYPE}" STREQUAL "Debug")
            set(CMAKE_CXX_FLAGS " -ldl ${CMAKE_CXX_FLAGS} -fPIC -ggdb3 -g3 -fno-omit-frame-pointer" PARENT_SCOPE)
            set(CMAKE_C_FLAGS " -ldl ${CMAKE_C_FLAGS} -fPIC -ggdb3 -g3 -fno-omit-frame-pointer" PARENT_SCOPE)
        elseif ("${CMAKE_BUILD_TYPE}" STREQUAL "Release")
            # 开O3了
            set(CMAKE_CXX_FLAGS "-ldl ${CMAKE_CXX_FLAGS} -fPIC -O3" PARENT_SCOPE)
            set(CMAKE_C_FLAGS "-ldl ${CMAKE_C_FLAGS} -fPIC -O3" PARENT_SCOPE)
        else ()
            message("unknow type:${CMAKE_BUILD_TYPE}")
        endif ()
        set(LINK_FLAGS "${LINK_FLAGS} -fPIC")

    endif ()

    if (STD_LOG_SYNC)
        message("std log use lock")
        add_definitions(-DSTD_LOG_SYNC)
    endif ()
endfunction()

# 打印编译选项
function(PrintCxxFlag)
    message("CMAKE_CXX_FLAGS flags:${CMAKE_CXX_FLAGS}")
    message("CMAKE_C_FLAGS flags:${CMAKE_C_FLAGS}")
endfunction()

# 打印所有变量
function(PrintAllVars)
    get_cmake_property(_variableNames VARIABLES)
    foreach (_variableName ${_variableNames})
        message(STATUS "${_variableName}=${${_variableName}}")
    endforeach ()
endfunction()

#配置版本号的映射文件，方便代码中使用
function(GenConfig)
    configure_file(
            "${BOOTSTRAP_DIR}/common/common_include/common_configure.h.in"
            "${PROJECT_BINARY_DIR}/convent/common_configure.h"
    )
    ## 复制配置
    message("${BOOTSTRAP_DIR} ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}")
    file(COPY ${CONFIG_DIR} DESTINATION ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/)
    # 头文件
    include_directories(${BOOTSTRAP_DIR}/common/common_include)

    include_directories(${PROJECT_BINARY_DIR}/convent)
endfunction()

#设置compiler版本信息
function(SetCompilerVersion)
    if (CMAKE_COMPILER_IS_GNUCC)
        execute_process(COMMAND ${CMAKE_C_COMPILER} -dumpfullversion -dumpversion
                OUTPUT_VARIABLE GCC_VERSION)
        string(REGEX MATCHALL "[0-9]+" GCC_VERSION_COMPONENTS ${GCC_VERSION})
        list(GET GCC_VERSION_COMPONENTS 0 GCC_MAJOR)
        list(GET GCC_VERSION_COMPONENTS 1 GCC_MINOR)
        message(STATUS "cmake version=${CMAKE_VERSION}")
        set(GCC_VERSION "${GCC_MAJOR}.${GCC_MINOR}" PARENT_SCOPE)
        message(STATUS "gcc version=${GCC_VERSION}")
        message(STATUS "gcc version major=${GCC_MAJOR}")
        message(STATUS "gcc version minor=${GCC_MINOR}")
    endif ()
    include(CheckCXXCompilerFlag)
    check_cxx_compiler_flag("-std=c++20" COMPILER_SUPPORTS_CXX20)

    if (COMPILER_SUPPORTS_CXX20)
        message("this compile support cxx 20")
        set(CMAKE_CXX_STANDARD 20 PARENT_SCOPE)
    else ()
        set(CMAKE_CXX_STANDARD 17 PARENT_SCOPE)
    endif ()
endfunction()

# 查找公用依赖
function(FindCommonLib)
    set(LIBS_LIST ${COMMON_LIBS})
    list(APPEND LIBS_LIST "pthread")

    if (USE_CONAN)
        # 加载conan
        set(CONAN_EXEC "conan install ..  --build missing  ${CONAN_ARGS} " PARENT_SCOPE)
        message("CONAN_EXEC at  ${CMAKE_CURRENT_SOURCE_DIR} : ${CONAN_EXEC}")
        execute_process(
                COMMAND conan install .. --build missing -s build_type=${CMAKE_BUILD_TYPE}
                OUTPUT_VARIABLE _RES
                ERROR_VARIABLE _RES
        )
        message("conan install end ${_RES}")
        include(${CMAKE_BINARY_DIR}/conanbuildinfo.cmake)
        conan_basic_setup()
        message("conan get libs\t${LIBS_LIST}\n")
    else ()
        find_package(GTest REQUIRED)
        message("GTest find ${GTEST_INCLUDE_DIRS} ${GTEST_LIBRARIES}")
        list(APPEND LIBS_LIST ${GTEST_LIBRARIES})
        #        if (GCC_VERSION GREATER "7")
        # 最新的gtest修复了这个问题， 不用再加这个选项了
        # gtest needs to be set “_GLIBCXX_USE_CXX11_ABI=0” if gcc version greater than 7
        #            message("gtest needs to be set “_GLIBCXX_USE_CXX11_ABI=0” if gcc version greater than 7")
        #            add_definitions(-D_GLIBCXX_USE_CXX11_ABI=0)
        #        endif ()
    endif ()
    message("LIBS_LIST ${LIBS_LIST}")
    set(COMMON_LIBS ${LIBS_LIST} PARENT_SCOPE)

endfunction()

# 查找boost
function(FindBoostLib components_list)
    add_definitions(-DBOOST_LIB_DIAGNOSTIC)
    if (BOOST_USE_STATIC_LINK)
        message("static link boost")
        set(Boost_USE_STATIC_LIBS ON)
    else ()
        message("dyn link boost")
#        add_definitions(-DBOOST_ALL_DYN_LINK)
    endif ()
    if (LOG_USE_BOOST)
        message("log use boost")
        add_definitions(-DLOG_BOOST)
        list(APPEND ${components_list} log log_setup)
    endif ()
    set(LIBS_LIST ${COMMON_LIBS})
    message("need boost components ${${components_list}}")
    find_package(Boost COMPONENTS ${${components_list}} REQUIRED)
    if (Boost_FOUND)
        include_directories(${Boost_INCLUDE_DIRS})
        message("boost find ${Boost_INCLUDE_DIRS} ${Boost_LIBRARIES}")
        list(APPEND LIBS_LIST ${Boost_LIBRARIES})
    endif ()
    set(COMMON_LIBS ${LIBS_LIST} PARENT_SCOPE)
endfunction()

# 开启协程
function(OpenCoroutine)
    if (APPLE)
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fcoroutines-ts" PARENT_SCOPE)
    elseif (WIN32 OR UNIX)
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fcoroutines" PARENT_SCOPE)
    endif ()
endfunction()