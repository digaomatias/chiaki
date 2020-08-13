# Find DEVKITPRO
if(NOT DEFINED ENV{DEVKITPRO})
	message(FATAL_ERROR "Please set DEVKITPRO env var before calling cmake. https://devkitpro.org/wiki/Getting_Started")
endif()

set(DEVKITPRO "$ENV{DEVKITPRO}")

if(NOT DEFINED ENV{PORTLIBS_PREFIX})
	# gess portlib prefix if not defined
	set(PORTLIBS_PREFIX "${DEVKITPRO}/portlibs/switch")
endif()


# /!\ disclaimer
# we are copying devkitpro's .cmake files (as last resort)
# since they are missing from official containers.
# Currently there is no proper way to use pacman durring CI. 
# https://devkitpro.org/viewtopic.php?f=15&t=9103#p16883
# downloads.devkitpro.org is 403 forbidden from github CI

# cmake sources: 
# * https://github.com/devkitPro/pacman-packages/tree/master/pkgbuild-scripts
# maybe cmake toolchain might be integrated in a futur release
# * https://github.com/devkitPro/docker

##########################################
# Copy of /opt/devkitpro/devkita64.cmake #
##########################################
cmake_minimum_required(VERSION 3.2)

set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_VERSION 1)
set(CMAKE_SYSTEM_PROCESSOR "aarch64")
set(CMAKE_CROSSCOMPILING 1)

# set(DEVKITPRO /opt/devkitpro)

set(TOOL_PREFIX ${DEVKITPRO}/devkitA64/bin/aarch64-none-elf-)

set(CMAKE_ASM_COMPILER ${TOOL_PREFIX}gcc    )
set(CMAKE_C_COMPILER   ${TOOL_PREFIX}gcc    )
set(CMAKE_CXX_COMPILER ${TOOL_PREFIX}g++    )
set(CMAKE_LINKER       ${TOOL_PREFIX}g++    )
set(CMAKE_AR           ${TOOL_PREFIX}ar     )
set(CMAKE_STRIP        ${TOOL_PREFIX}strip  )

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM BOTH)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

SET(BUILD_SHARED_LIBS OFF CACHE INTERNAL "Shared libs not available" )

##########################################
# Copy of /opt/devkitpro/switch.cmake    #
##########################################
# include(/opt/devkitpro/devkita64.cmake)

set (DKA_SWITCH_C_FLAGS "-D__SWITCH__ -march=armv8-a+crc+crypto -mtune=cortex-a57 -mtp=soft -ftls-model=local-exec -ffunction-sections -fdata-sections")
set(CMAKE_C_FLAGS   "${DKA_SWITCH_C_FLAGS}" CACHE STRING "")
set(CMAKE_CXX_FLAGS "${DKA_SWITCH_C_FLAGS}" CACHE STRING "")
set(CMAKE_ASM_FLAGS "${DKA_SWITCH_C_FLAGS}" CACHE STRING "")

set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -specs=${DEVKITPRO}/libnx/switch.specs" CACHE STRING "")

set(CMAKE_FIND_ROOT_PATH
  ${DEVKITPRO}/devkitA64
  ${DEVKITPRO}/tools
  ${DEVKITPRO}/portlibs/switch
  ${DEVKITPRO}/libnx
)

# Set pkg-config for the same
find_program(PKG_CONFIG_EXECUTABLE NAMES aarch64-none-elf-pkg-config HINTS "${DEVKITPRO}/portlibs/switch/bin")
if (NOT PKG_CONFIG_EXECUTABLE)
   message(WARNING "Could not find aarch64-none-elf-pkg-config: try installing switch-pkg-config")
endif()

set(NSWITCH TRUE)

set(CMAKE_POSITION_INDEPENDENT_CODE ON)

set(NX_ROOT ${DEVKITPRO}/libnx)

set(NX_STANDARD_LIBRARIES "${NX_ROOT}/lib/libnx.a")
set(CMAKE_C_STANDARD_LIBRARIES "${NX_STANDARD_LIBRARIES}" CACHE STRING "")
set(CMAKE_CXX_STANDARD_LIBRARIES "${NX_STANDARD_LIBRARIES}" CACHE STRING "")
set(CMAKE_ASM_STANDARD_LIBRARIES "${NX_STANDARD_LIBRARIES}" CACHE STRING "")

#for some reason cmake (3.14.3) doesn't appreciate having \" here
set(NX_STANDARD_INCLUDE_DIRECTORIES "${NX_ROOT}/include")
set(CMAKE_C_STANDARD_INCLUDE_DIRECTORIES "${NX_STANDARD_INCLUDE_DIRECTORIES}" CACHE STRING "")
set(CMAKE_CXX_STANDARD_INCLUDE_DIRECTORIES "${NX_STANDARD_INCLUDE_DIRECTORIES}" CACHE STRING "")
set(CMAKE_ASM_STANDARD_INCLUDE_DIRECTORIES "${NX_STANDARD_INCLUDE_DIRECTORIES}" CACHE STRING "")

#######################
# Chiaki project only #
#######################

# Enable gcc -g, to use
# /opt/devkitpro/devkitA64/bin/aarch64-none-elf-addr2line -e build_switch/switch/chiaki -f -p -C -a 0xCCB5C
# set(CMAKE_BUILD_TYPE Debug)
# set(CMAKE_POSITION_INDEPENDENT_CODE ON)
# set(BUILD_SHARED_LIBS OFF CACHE INTERNAL "Shared libs not available" )

# FIXME rework this file to use the toolchain only
# https://github.com/diasurgical/devilutionX/pull/764
set(ARCH "-march=armv8-a+crc+crypto -mtune=cortex-a57 -mtp=soft -ftls-model=local-exec")
set(CMAKE_C_FLAGS "-O2 -ffunction-sections ${ARCH}")
set(CMAKE_CXX_FLAGS "${CMAKE_C_FLAGS} -fno-rtti")
# workaroud force -fPIE to avoid
# aarch64-none-elf/bin/ld: read-only segment has dynamic relocations
set(CMAKE_EXE_LINKER_FLAGS "-specs=${DEVKITPRO}/libnx/switch.specs ${ARCH} -fPIE -Wl,-Map,Output.map")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++17")

# add portlibs to the list of include dir
include_directories("${PORTLIBS_PREFIX}/include")

# troubleshoot
message(STATUS "CMAKE_FIND_ROOT_PATH = ${CMAKE_FIND_ROOT_PATH}")
message(STATUS "PKG_CONFIG_EXECUTABLE = ${PKG_CONFIG_EXECUTABLE}")
message(STATUS "CMAKE_EXE_LINKER_FLAGS = ${CMAKE_EXE_LINKER_FLAGS}")
get_property(include_directories DIRECTORY PROPERTY INCLUDE_DIRECTORIES)
message(STATUS "INCLUDE_DIRECTORIES = ${include_directories}")
message(STATUS "CMAKE_C_COMPILER = ${CMAKE_C_COMPILER}")
message(STATUS "CMAKE_CXX_COMPILER = ${CMAKE_CXX_COMPILER}")

find_program(ELF2NRO elf2nro ${DEVKITPRO}/tools/bin)
if (ELF2NRO)
    message(STATUS "elf2nro: ${ELF2NRO} - found")
else()
    message(WARNING "elf2nro - not found")
endif()

find_program(NACPTOOL nacptool ${DEVKITPRO}/tools/bin)
if (NACPTOOL)
    message(STATUS "nacptool: ${NACPTOOL} - found")
else()
    message(WARNING "nacptool - not found")
endif()

function(__add_nacp target APP_TITLE APP_AUTHOR APP_VERSION)
    set(__NACP_COMMAND ${NACPTOOL} --create ${APP_TITLE} ${APP_AUTHOR} ${APP_VERSION} ${CMAKE_CURRENT_BINARY_DIR}/${target})

    add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${target}
            COMMAND ${__NACP_COMMAND}
            WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
            VERBATIM
            )
endfunction()

function(add_nro_target target title author version icon romfs)
    get_filename_component(target_we ${target} NAME_WE)
        if(NOT ${target_we}.nacp)
            __add_nacp(${target_we}.nacp ${title} ${author} ${version})
        endif()
        add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${target_we}.nro
            COMMAND ${ELF2NRO} $<TARGET_FILE:${target}>
                ${CMAKE_CURRENT_BINARY_DIR}/${target_we}.nro
            --icon=${icon}
            --nacp=${CMAKE_CURRENT_BINARY_DIR}/${target_we}.nacp
            --romfsdir=${romfs}
            DEPENDS ${target} ${CMAKE_CURRENT_BINARY_DIR}/${target_we}.nacp
            VERBATIM
        )
        add_custom_target(${target_we}_nro ALL SOURCES ${CMAKE_CURRENT_BINARY_DIR}/${target_we}.nro)
endfunction()


