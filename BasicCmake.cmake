
add_definitions(-DBOOTSTRAP_DIR ${BOOTSTRAP_DIR})

if (NOT IGNORE_CONAN)
    # 加载conan
    set(CONAN_LIBS "")
    set(CONAN_EXEC "conan install ..  --build missing  ${CONAN_ARGS} ")
    message("CONAN_EXEC at  ${CMAKE_CURRENT_SOURCE_DIR} : ${CONAN_EXEC}")
    execute_process(
            COMMAND ${CONAN_EXEC}

            ECHO_OUTPUT_VARIABLE
            ECHO_ERROR_VARIABLE

    )
    message("conan install end ${_RES}")
    include(${CMAKE_BINARY_DIR}/conanbuildinfo.cmake)
    conan_basic_setup()
    message("conan get libs\t${CONAN_LIBS}\n")
    add_definitions(-DUSE_CONAN)
else()
    add_definitions(-DIGNORE_CONAN)
endif ()

include(${BOOTSTRAP_DIR}/common/CMake/FuncDefs.cmake)

# 公用定义,需要在设定完成后include
include(${BOOTSTRAP_DIR}/common/CMake/CommonInclude.cmake)


# 编译ptoro, 所有proto 打包为一个定义 PTOTO_CPPS
# TODO 实现中
set(PROTO_CPP_DIR ${CMAKE_BINARY_DIR}/proto)
BuildProto(${CMAKE_SOURCE_DIR}/src ${PROTO_CPP_DIR})
include_directories(${PROTO_CPP_DIR})
aux_source_directory(${PROTO_CPP_DIR} PROTO_CPPS)



