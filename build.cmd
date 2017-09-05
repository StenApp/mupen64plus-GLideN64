msbuild mupen64plus-core/projects/VisualStudio2013/mupen64plus-core.vcxproj /p:Configuration=Release /p:Platform=%myarch%

msbuild mupen64plus-rsp-cxd4/projects/VisualStudio2013/mupen64plus-rsp-cxd4.vcxproj /p:Configuration=Release /p:Platform=%myarch%

msbuild mupen64plus-input-sdl/projects/VisualStudio2013/mupen64plus-input-sdl.vcxproj /p:Configuration=Release /p:Platform=%myarch%

msbuild mupen64plus-audio-sdl/projects/VisualStudio2013/mupen64plus-audio-sdl.vcxproj /p:Configuration=Release /p:Platform=%myarch%

msbuild mupen64plus-ui-console/projects/VisualStudio2013/mupen64plus-ui-console.vcxproj /p:Configuration=Release /p:Platform=%myarch%

REM do gui here

msbuild GLideN64/projects/msvc12/GLideN64.sln /p:Configuration=Release_mupenplus
