import os
# Common variables for SCons script
base ='#/src'

lSDL      = ['mingw32', 'SDL2main', 'SDL2']
lSDLimage = ['SDL2_image']
lSDLmixer = ['SDL2_mixer']
lSDLttf   = ['SDL2_ttf']
lOther    = [ 'freetype', 'vorbisfile', 'vorbis', 'ogg', 'jpeg', 'png', 'z', 'm',
              'dinput8', 'dxguid', 'dxerr8', 'user32',
              'gdi32', 'winmm', 'imm32', 'ole32', 'oleaut32',
              'shell32', 'version', 'uuid']



# Unchanged, but kept here for easy customizability.
# This shouldn't be committed to repo.
# Of not necessary, remove to keep clean.
lGL       = ['glew32', 'opengl32', 'glu32']
lBullet   = ['BulletDynamics', 'BulletCollision', 'LinearMath']
lFlite    = ['flite_voice_list',
             'flite_cmu_us_awb',
             'flite_cmu_us_rms',
             'flite_usenglish',
             'flite_cmulex',
             'flite']
lNoise    = ['noise']
lPolyVox  = ['PolyVoxCore', 'PolyVoxUtil']
lAngelScript = ['angelscript']
lAll  = (lBullet +
         lAngelScript +
         lFlite + lNoise + lPolyVox +
         lSDL + lSDLimage + lSDLmixer + lSDLttf +
         lGL + lOther)


# SDL, Bullet have changed to cross-compile directory
pathCrossTools = os.environ["CROSS_TOOLS_DIR"];
pathBoost      = os.environ["BOOST_DIR"];
pathGlm        = os.environ["GLM_DIR"];
pathCxxTest    = os.environ["CXXTEST"];
pathAngelScript = os.environ["ANGELSCRIPT_DIR"];

libpaths = ['#/lib/win/',
            pathCrossTools + '/lib']

# Macros definitions
macroDefinitions = [
   'USING_SDL',            # Should always be set in SDL projects.
#   'LOGGING_DISABLED',    # Disables all logging
#   'LOG2STREAM_DISABLED', # Disables logging to stream
#   'LOG2FILE_DISABLED',   # Disables logging to file
   'LOG_SDL_EVENTS_VERBOSELY'
]

gccWarningLevel = [
   '-Wall', '-Wextra', '-Wcast-align', '-Wcast-qual',
   '-Wconversion', '-Wdisabled-optimization', #'-Weffc++',
   '-Wfloat-equal', '-Wformat=2', '-Wimport', '-Winit-self',
   '-Winline', '-Winvalid-pch', '-Wlong-long',
   '-Wmissing-format-attribute', '-Wmissing-include-dirs',
   '-Wmissing-noreturn', '-Wpacked', '-Wpointer-arith',
   '-Wredundant-decls', '-Wshadow',
   '-Wstrict-aliasing=2', '-Wunreachable-code',
   '-Wunused',
   '-Wvariadic-macros', '-Wwrite-strings', '-pedantic',
   '-pedantic-errors', '-Woverloaded-virtual',
   '-Wswitch-enum', '-Werror'
   # # Clang unsupported flags.
   # '-fpermissive',
   # -Wunsafe-loop-optimizations'
   # '-Wstack-protector',
]




# CPPFLAGS
####################
cppflags = ['-O0', '-g', '-gdwarf-2']
#cppflags = ['-O3']
cppflags.extend(['-fno-strict-aliasing',
                 '-std=c++11',
                 '-D_REENTRANT',
                 '-Dmain=SDL_main',
                 '-DGLM_FORCE_RADIANS'])
cppflags.extend(['-isystem', pathBoost  + '/include',
                 '-isystem', pathCrossTools + '/include',
                 '-isystem', pathCrossTools + '/include/bullet',
                 '-isystem', 'external/',
                 '-isystem', pathGlm,
                 '-isystem', 'external/polyvox/library/PolyVoxCore/include',
                 '-isystem', pathAngelScript + '/include',
                 '-isystem', pathAngelScript + '/add_on',
                 '-isystem', pathCxxTest])
cppflags.extend(gccWarningLevel)
for macro in macroDefinitions:
   cppflags.append('-D' + macro)
if 'CPPFLAGS' in os.environ:
   cppflags.extend(os.environ['CPPFLAGS'].split())

# LINKFLAGS
####################
linkflags = ['--static', '-Wl,--no-undefined', '-static-libgcc', '-static-libstdc++']
# linkflags = []
if 'LDFLAGS' in os.environ:
   linkflags.extend(os.environ['LDFLAGS'].split())


# SOURCEPATHS
####################
sourcepaths = [
   base,
   '#/external/',
   '#/external/polyvox/library/PolyVoxCore/include/',
   '#/external/polyvox/library/PolyVoxUtil/include/',
   pathCrossTools + '/include',
   pathCrossTools + '/include/bullet/',
   pathAngelScript + '/include',
   pathAngelScript + '/add_on',
   pathBoost  + '/include',
   pathGlm,
   pathCxxTest]
