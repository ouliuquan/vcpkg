include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY ONLY_DYNAMIC_CRT)

file(GLOB OSG_PLUGINS_SUBDIR ${CURRENT_INSTALLED_DIR}/tools/osg/osgPlugins-*)
list(LENGTH OSG_PLUGINS_SUBDIR OSG_PLUGINS_SUBDIR_LENGTH)
if(0)
    message(FATAL_ERROR "Could not determine osg version")
endif()
string(REPLACE "${CURRENT_INSTALLED_DIR}/tools/osg/" "" OSG_PLUGINS_SUBDIR "${OSG_PLUGINS_SUBDIR}")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gwaldron/osgearth
    REF osgearth-2.10.2
    SHA512 fa306a82374716dafae9d834ed0fb07a7369ae0961696de36b6e2af45bc150040295985d9b9781ab713fd0707691451a6a8f173b34253749ab22764f51e60045
    HEAD_REF master
    PATCHES 
		RocksDB.patch
)

return()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

#Release
set(OSGEARTH_TOOL_PATH ${CURRENT_PACKAGES_DIR}/tools/osgearth)
set(OSGEARTH_TOOL_PLUGIN_PATH ${OSGEARTH_TOOL_PATH}/${OSG_PLUGINS_SUBDIR})

file(MAKE_DIRECTORY ${OSGEARTH_TOOL_PATH})
file(MAKE_DIRECTORY ${OSGEARTH_TOOL_PLUGIN_PATH})

file(GLOB OSGEARTH_TOOLS ${CURRENT_PACKAGES_DIR}/bin/*.exe)
file(GLOB OSGDB_PLUGINS ${CURRENT_PACKAGES_DIR}/bin/osgdb*.dll)

file(COPY ${OSGEARTH_TOOLS} DESTINATION ${OSGEARTH_TOOL_PATH})
file(COPY ${OSGDB_PLUGINS} DESTINATION ${OSGEARTH_TOOL_PLUGIN_PATH})

file(REMOVE_RECURSE ${OSGEARTH_TOOLS})
file(REMOVE_RECURSE ${OSGDB_PLUGINS})

#Debug
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

set(OSGEARTH_DEBUG_TOOL_PATH ${CURRENT_PACKAGES_DIR}/debug/tools/osgearth)
set(OSGEARTH_DEBUG_TOOL_PLUGIN_PATH ${OSGEARTH_DEBUG_TOOL_PATH}/${OSG_PLUGINS_SUBDIR})

file(MAKE_DIRECTORY ${OSGEARTH_DEBUG_TOOL_PATH})
file(MAKE_DIRECTORY ${OSGEARTH_DEBUG_TOOL_PLUGIN_PATH})

file(GLOB OSGEARTH_DEBUG_TOOLS ${CURRENT_PACKAGES_DIR}/debug/bin/*.exe)
file(GLOB OSGDB_DEBUG_PLUGINS ${CURRENT_PACKAGES_DIR}/debug/bin/osgdb*.dll)

file(COPY ${OSGEARTH_DEBUG_TOOLS} DESTINATION ${OSGEARTH_DEBUG_TOOL_PATH})
file(COPY ${OSGDB_DEBUG_PLUGINS} DESTINATION ${OSGEARTH_DEBUG_TOOL_PLUGIN_PATH})

file(REMOVE_RECURSE ${OSGEARTH_DEBUG_TOOLS})
file(REMOVE_RECURSE ${OSGDB_DEBUG_PLUGINS})


# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/osgearth)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/osgearth/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/osgearth/copyright)
