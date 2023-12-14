#!/usr/bin/bash
BBVer=alpha2
BBRoot=/boot/BB
bbenv=$BBRoot/BoughBootEnv.txt
nextbootEnv=$BBRoot/NextBootEnv.txt

[ -h $bbenv ] && bbenv=/BoughBootEnv.txt
[ -h $nextbootEnv ] && nextbootEnv=/NextBootEnv.txt

NBEnvs=$BBRoot/NBEnvs
cd $(dirname "$0")

lines=`tput lines`
cols=`tput cols`
export boxheight=`bc <<< "scale=0; ($lines/16)*13"`
export listheight=`bc <<< "scale=0; ($lines/16)*9"`
export width=`bc <<< "scale=0; ($cols/16)*14"`
BBEnvLoaded=1