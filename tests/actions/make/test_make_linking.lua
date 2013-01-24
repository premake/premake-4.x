--
-- tests/actions/make/test_make_linking.lua
-- Validate library references in makefiles.
-- Copyright (c) 2010-2013 Jason Perkins and the Premake project
--

	T.gcc_linking = {}
	local suite = T.gcc_linking
	local cpp = premake.make.cpp

--
-- Setup
--

	local sln, prj

	function suite.setup()
		_OS = "linux"
		sln, prj = test.createsolution()
	end

	local function prepare()
		premake.bake.buildconfigs()
		cfg = premake.getconfig(prj, "Debug")
		cpp.linker(cfg, premake.gcc)
	end


--
-- Check linking to a shared library sibling project. Should add the library
-- path using -L, and link using the base name with -l flag.
--

	function suite.onSharedLibrarySibling()
		links { "MyProject2" }
		test.createproject(sln)
		kind "SharedLib"
		targetdir "libs"
		prepare()
		test.capture [[
  ALL_LDFLAGS   += $(LDFLAGS) -Llibs -s
  LIBS      += -lMyProject2
  LDDEPS    += libs/libMyProject2.so
		]]
	end


--
-- Check linking to a static library sibling project. Should use the full
-- decorated library name, relative path, and no -l flag.
--

	function suite.onStaticLibrarySibling()
		links { "MyProject2" }
		test.createproject(sln)
		kind "StaticLib"
		targetdir "libs"
		prepare()
		test.capture [[
  ALL_LDFLAGS   += $(LDFLAGS) -Llibs -s
  LIBS      += libs/libMyProject2.a
  LDDEPS    += libs/libMyProject2.a
		]]
	end


--
-- If an executable is listed in the links, no linking should happen (a
-- build dependency would have been created at the solution level)
--

	function suite.onConsoleAppSibling()
		links { "MyProject2" }
		test.createproject(sln)
		kind "ConsoleApp"
		targetdir "libs"
		prepare()
		test.capture [[
  ALL_LDFLAGS   += $(LDFLAGS) -s
  LIBS      +=
  LDDEPS    +=
		]]
	end


--
-- Make sure that project locations are taken into account when building
-- the path to the library.
--


	function suite.onProjectLocations()
		location "MyProject"
		links { "MyProject2" }

		test.createproject(sln)
		kind "SharedLib"
		location "MyProject2"
		targetdir "MyProject2"

		prepare()
		test.capture [[
  ALL_LDFLAGS   += $(LDFLAGS) -L../MyProject2 -s
  LIBS      += -lMyProject2
  LDDEPS    += ../MyProject2/libMyProject2.so
		]]
	end

