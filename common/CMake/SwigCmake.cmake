set(target ${build_dir_name})
set(cpps ${${build_temp}cpps})
message("cpps : ${cpps} ")
# 可执行文件
if (EXISTS "${dir}/main.cpp")
endif ()
add_executable(${target}_exe ${cpps})

set(gen_dir ${SWIG_OUT_BASE}/${relative_dir})
SetBinDir(${gen_dir})
# swig 动态库
#    file(GLOB_RECURSE swig_i "${src_dir}/*.i")
set(swig_i ${dir}/${target}.i)
message("swigs : ${swig_i}")
SET_SOURCE_FILES_PROPERTIES(${swig_i} PROPERTIES CPLUSPLUS ON)
SET_SOURCE_FILES_PROPERTIES(${swig_i} PROPERTIES SWIG_FLAGS "-py3")

SWIG_ADD_LIBRARY(${build_temp}
        TYPE SHARED
        LANGUAGE python
        OUTPUT_DIR ${gen_dir}
        OUTFILE_DIR ${gen_dir}
        SOURCES ${swig_i} ${cpps})
message("PYTHON_LIBRARY ${PYTHON_LIBRARY}")
SWIG_LINK_LIBRARIES(${build_temp} ${PYTHON_LIBRARY} "G:/programmer/pythonEnvs/python39/libs/python39.lib")
SetBinDir(${DEFAULT_BIN_DIR})