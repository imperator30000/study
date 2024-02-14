cmake_minimum_required(VERSION 3.24)
project(untitled2 C)

set(CMAKE_C_STANDARD 99)

add_executable(untitled2 main.c return_codes.h)
include_directories(/opt/homebrew/Cellar/libdeflate/1.18/include)

target_link_libraries(untitled2 -L/opt/homebrew/Cellar/libdeflate/1.18/lib -ldeflate)