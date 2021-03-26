#!/bin/bash
####Random Test####
fileName="apps.csv"

while IFS=, read -u 9 apk package apkN activity sdk ; do
   java -cp  DynamicVerification.jar Main instrumentation -a $sdk -o apkOutputs/ $apk -p $package
  ###
   jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1  -storepass "motdepasse123"  -keypass "motdepasse123" -keystore my-release-key.keystore apkOutputs/$apkN alias_name 
  ###
  
   sh  ./monkey.sh  "$PWD/apkOutputs/$apkN"  "$activity" "$package" 
   package=`aapt dump badging $PWD/apkOutputs/$apkN | grep package | awk '{print $2}' | sed s/name=//g | sed s/\'//g`
   adb shell pm uninstall $package  
   java -cp  DynamicVerification.jar Main  analyse  -a  $sdk  -t   $PWD/apkOutputs/$apkN.txt  -o  csvOutputs/  -p  $package apkOutputs/$apkN
   
   
done 9< $fileName
