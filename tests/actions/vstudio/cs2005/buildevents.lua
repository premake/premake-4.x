--
-- tests/actions/vstudio/cs2005/buildevents.lua
-- Validate the build events in Visual Studio 2005+ .csproj
-- Copyright (c) 2009-2014 Jason Perkins and the Premake project
--

	T.vstudio_cs2005_buildevents = { }
	local suite = T.vstudio_cs2005_buildevents
	local cs2005 = premake.vstudio.cs2005

--
-- Setup
--

	local sln, prj

	function suite.setup()
		sln = test.createsolution()
	end

	local function prepare()
		premake.bake.buildconfigs()
		prj = premake.solution.getproject(sln, 1)
		cs2005.buildevents(prj)
	end

--
-- Prebuild events
--

	function suite.prebuildEvents()
		prebuildcommands { "pre" }
		prepare()
		test.capture [[
  <PropertyGroup>
    <PreBuildEvent>pre</PreBuildEvent>
  </PropertyGroup>
		]]
	end

--
-- Postbuild events
--

	function suite.postbuildEvents()
		postbuildcommands { "post" }
		prepare()
		test.capture [[
  <PropertyGroup>
    <PostBuildEvent>post</PostBuildEvent>
  </PropertyGroup>
		]]
	end
