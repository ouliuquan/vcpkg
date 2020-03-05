include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO harfbuzz/harfbuzz
    REF 2.5.3
    SHA512 d541463b3647fc2c7ddaa29aedcea1c3bde5e26e0d529384d66d630af3aaf2a4befb3c4d47c93833f099339a0f951fb132011a02c57fc00ba543bd1b17026ffa
    HEAD_REF master
    PATCHES
        0001-fix-cmake-export.patch
        0002-fix-uwp-build.patch
        0003-remove-broken-test.patch
        # This patch is required for propagating the full list of static dependencies from freetype
        find-package-freetype-2.patch
        # This patch is required for propagating the full list of dependencies from glib
        glib-cmake.patch
)

file(READ ${SOURCE_PATH}/CMakeLists.txt _contents)

if("${_contents}" MATCHES "include \\(FindFreetype\\)")
    message(FATAL_ERROR "Harfbuzz's cmake must not directly include() FindFreetype.")
endif()

if("${_contents}" MATCHES "find_library\\(GLIB_LIBRARIES")
    message(FATAL_ERROR "Harfbuzz's cmake must not directly find_library() glib.")
endif()

SET(HB_HAVE_ICU "OFF")
if("icu" IN_LIST FEATURES)
    SET(HB_HAVE_ICU "ON")
endif()

SET(HB_HAVE_GRAPHITE2 "OFF")
if("graphite2" IN_LIST FEATURES)
    SET(HB_HAVE_GRAPHITE2 "ON")
endif()

## Unicode callbacks

# Builtin (UCDN)
set(BUILTIN_UCDN OFF)
if("ucdn" IN_LIST FEATURES)
    set(BUILTIN_UCDN ON)
endif()

# Glib
set(HAVE_GLIB OFF)
if("glib" IN_LIST FEATURES)
    set(HAVE_GLIB ON)
endif()

# At least one Unicode callback must be specified, or harfbuzz compilation fails
if(NOT (BUILTIN_UCDN OR HAVE_GLIB))
    message(FATAL_ERROR "Error: At least one Unicode callback must be specified (ucdn, glib).")
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DHB_HAVE_FREETYPE=ON
        -DHB_BUILTIN_UCDN=${BUILTIN_UCDN}
        -DHB_HAVE_ICU=${HB_HAVE_ICU}
        -DHB_HAVE_GLIB=${HAVE_GLIB}
        -DHB_HAVE_GRAPHITE2=${HB_HAVE_GRAPHITE2}
        -DHB_BUILD_TESTS=OFF
    OPTIONS_DEBUG
        -DSKIP_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets()

vcpkg_copy_pdbs()

return()

if (HAVE_GLIB)
    # Propagate dependency on glib downstream
    file(READ "${CURRENT_PACKAGES_DIR}/share/harfbuzz/harfbuzzConfig.cmake" _contents)
    file(WRITE "${CURRENT_PACKAGES_DIR}/share/harfbuzz/harfbuzzConfig.cmake" "
include(CMakeFindDependencyMacro)
find_dependency(unofficial-glib CONFIG)
    
${_contents}
")
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/harfbuzz RENAME copyright)

vcpkg_test_cmake(PACKAGE_NAME harfbuzz)
