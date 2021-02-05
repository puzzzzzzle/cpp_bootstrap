# 获取目录的子目录
function(GetSubDirs Dir Result)
    message("get dirs in  ${Dir}")
    #    EXECUTE_PROCESS(
    #            COMMAND chmod +x ${CMAKE_SOURCE_DIR}/common/CMake/travel_dir.py
    #    )
    EXECUTE_PROCESS(
            COMMAND python3 ${BOOTSTRAP_DIR}/common/CMake/travel_dir.py ${Dir} d
            OUTPUT_VARIABLE DIRS
    )
    set(${Result} ${DIRS} PARENT_SCOPE)
    message("All dirs ${DIRS}")
endfunction()

include_directories(${SRC_DIR_ROOT})
function(AddAllSubDir)
    GetSubDirs(${SRC_DIR_ROOT} SubDir)
    message("SRC_DIR_ROOT: ${SRC_DIR_ROOT}")

    foreach (dir ${SubDir})
        if (NOT EXISTS "${dir}/CMakeLists.txt")
            continue()
        endif ()
        message("CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_ARCHIVE_OUTPUT_DIRECTORY}")
        string(REPLACE "${SRC_DIR_ROOT}/" "" relative_dir ${dir})
        get_filename_component(build_dir_name ${dir} NAME)
        string(REGEX REPLACE "/" "_" build_temp ${relative_dir})
        #        message("build_dir_name is:${build_dir_name}; relative_dir is:${relative_dir}; build_temp is: ${build_temp}")

        message("- ${build_temp}")
        add_subdirectory(${dir})
    endforeach ()
endfunction()

function(BuildProto Dir OutPutDir)
    message("build proto ")
    #    EXECUTE_PROCESS(
    #            COMMAND python3 ${BOOTSTRAP_DIR}/common/CMake/travel_dir.py ${Dir} build_proto ${OutPutDir}
    #            OUTPUT_VARIABLE TEMP_OUT
    #    )
    message("All proto ${TEMP_OUT}")

endfunction()

function(SetBinDir Dir)
    set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${Dir} PARENT_SCOPE)
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${Dir} PARENT_SCOPE)
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${Dir} PARENT_SCOPE)
endfunction()
