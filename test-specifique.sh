print_blue(){
    printf "\e[1;34m$1\e[0m"
}


#GET APK



#INSTALL APK
print_blue "\n\n\nInstalling APK"
adb install $1
adb install $2

#Run TESTS
print_blue "\n\n\nRunning Tests"
adb logcat -c
u="$(adb shell pm list instrumentation)"
part=(${u//instrumentation:/})
adb shell am instrument -w ${part[0]}
print_blue "Finish"

#SAVE LOGS
print_blue "\n\n\nSaving logs"
cd /home/nour
adb logcat -d >> $2.txt  

#UNISNTALL APP
print_blue "\n\n\nuninstalling app"
package1=`aapt dump badging $1 | grep package | awk '{print $2}' | sed s/name=//g | sed s/\'//g`
package2=`aapt dump badging $2 | grep package | awk '{print $2}' | sed s/name=//g | sed s/\'//g`
adb shell pm uninstall $package1
adb shell pm uninstall $package2

