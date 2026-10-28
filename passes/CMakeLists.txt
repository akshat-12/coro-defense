# ~/workspace/coro-defense/passes/CMakeLists.txt
cmake_minimum_required(VERSION 3.20)
project(CoroDefensePasses)

find_package(LLVM REQUIRED CONFIG
    PATHS ~/workspace/llvm-install/lib/cmake/llvm NO_DEFAULT_PATH)

include(AddLLVM)
include_directories(${LLVM_INCLUDE_DIRS})
add_definitions(${LLVM_DEFINITIONS})

# Analysis printer plugin (for testing)
add_llvm_pass_plugin(CoroDefensePlugin
    AnalysisPlugin.cpp
    CoroAwareCFIPass.cpp
    CoroDefenseAnalysis.cpp)