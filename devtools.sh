#!/bin/bash

function showHelp() {
    echo "devtools - Shorthand commandline aliases
Possible targets:
    h,help                 Shows this message.
    b                      General build
    ba                     Builds android
    bap                    Builds android, pushes .apk on completion
    bl                     Builds linux
    bu                     Builds utils
    bal,bla,ball           Builds android and linux
    p                      Pushes android APK to device
    ra                     Runs android app on device
    sa                     Stops android app if running on device
    wa                     Auto-rebuild android on changes.
    wl                     Auto-rebuild linux on changes.
    ws                     Auto-validate shaders on changes.
    testl                  compile and run unit tests on linux
    lg,log                 adb logcat with SWL filter
    lga,loga               adb logcat with SWL, SDL, SDL/* filter
    lgall,logall           adb logcat with no filter
    clean                  removal of all build directories (use with caution)
    cleanl                 removal of all linux build directories (use with caution)
    cleana                 removal of all android build directories (use with caution)
    validate-gl-shaders    validates shaders for used OpenGL 4.3
    validate-es-shaders    validates shaders for used OpenGL 3.0 ES
    validate-shaders       validates shaders for used OpenGL 4.3 and OpenGL 3.0 ES
"
    exit
}



function echoerr() {
    echo -e "$@" 1>&2;
}

if test $# -eq 0 ; then
    showHelp
    exit
fi

while test $# -gt 0; do
    case "$1" in
        h|help)
            shift
            showHelp
            exit
            ;;
        b)
            shift
            ./compile.sh $@
            exit
            ;;
        ba)
            shift
            ./compile.sh a $@
            exit
            ;;
        bap)
            shift
            ./compile.sh a -p $@
            exit
            ;;
        bl)
            shift
            ./compile.sh l $@
            exit
            ;;
        bu)
            shift
            ./compile.sh utils $@
            exit
            ;;
        bal|bla|ball)
            shift
            ./compile.sh all $@
            exit
            ;;
        p)
            shift
            (cd android && ant debug install)
            exit
            ;;
        ra)
            shift
            (cd android && adb shell am start -n com.swarminglogic.swldev/.SWLdev)
            exit
            ;;
        sa) shift
            (cd android && adb shell am force-stop com.swarminglogic.swldev)
            exit
            ;;
        wa)
            shift
            watchfile -s "find ./src ./android/jni/ \
                -name '[!\.]*.cpp' -or \
                -name '[!\.]*.h'   -or \
                -name '[!\.]*.tpp' -or \
                -name '[!\.]*.mk'
               | xargs cat | md5sum" -e ./compile.sh a $@
             exit
             ;;
        wl)
            shift
            watchfile -s "find ./src ./SConstruct \
                -name '[!\.]*.cpp' -or \
                -name '[!\.]*.h'   -or \
                -name '[!\.]*.tpp' -or \
                -name 'SConscript*' -or \
                -name 'SConstruct' \
               | xargs cat | md5sum" -e ./compile.sh l $@
             exit
             ;;
        ws)
            shift
            watchfile -s "find ./assets/shaders \
                -name '[!\.]*.frag' -or \
                -name '[!\.]*.vert' \
               | xargs cat | md5sum" -e ./devtools.sh validate-shaders
             exit
             ;;
        testl)
            shift
            ./compile.sh l -t
            LD_LIBRARY_PATH=./lib/:$LD_LIBRARY_PATH
            if [[ $? ]] ; then
                for t in ./bin/tests/* ; do
                    ./$t
                done
            fi
            ;;
        lg|log)
            shift
            adb logcat -c && adb logcat -s "SWL"
            exit
            ;;
        lga|loga)
            shift
            adb logcat -c && adb logcat -s "SWL","SDL","SDL/APP",\
            "SDL/ERROR","SDL/SYSTEM","SDL/AUDIO","SDL/VIDEO",\
            "SDL/RENDER","SDL/INPUT"
            exit
            ;;
        lgall|logall)
            shift
            adb logcat -c && adb logcat
            exit
            ;;
        clean)
            shift
            ./devtools.sh cleanl
            ./devtools.sh cleana
            ;;
        cleanl)
            shift
            while true; do
                read -p "Remove linux build directories: \
./{bin,build,lib}/ ? [y/n] " yn
                case $yn in
                    [Yy]* )
                        rm -rf ./{bin,build,lib}/ ;
                        break
                        ;;
                    [Nn]* )
                        exit;;
                    * ) echo "Please answer yes or no.";;
                esac
            done
            exit
            ;;
        cleana)
            shift
            while true; do
                read -p "Remove android build directories: \
./android/{bin,gen,libs,obj}/ ? [y/n] " yn
                case $yn in
                    [Yy]* )
                        rm -rf android/{bin,gen,libs,obj}/ ;
                        break
                        ;;
                    [Nn]* )
                        exit;;
                    * ) echo "Please answer yes or no.";;
                esac
            done
            exit
            ;;
        validate-gl-shaders)
            shift
            ./validateshaders.sh GL 430 core
            exit
            ;;
        validate-es-shaders)
            shift
            ./validateshaders.sh ES 300 es
            exit
            ;;
        validate-shaders)
            shift
            ./devtools.sh validate-gl-shaders && \
            ./devtools.sh validate-es-shaders
            exit
            ;;
        *)
            echoerr "Error: Invalid parameter: $1\n"
            showHelp
            exit
            ;;
    esac
done
