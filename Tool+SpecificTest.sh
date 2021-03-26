file="apps+tests.csv"

while IFS=, read -u 9 apk package apkN activity apktest sdk ; do

  java -cp  DynamicVerification.jar Main instrumentation -a $sdk -o apkOutputs/ $apk -p $package
  
  jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1  -storepass "motdepasse123"  -keypass "motdepasse123" -keystore my-release-key.keystore apkOutputs/$apkN alias_name

  jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1  -storepass "motdepasse123"  -keypass "motdepasse123" -keystore my-release-key.keystore $apktest alias_name  
   
  ./test-specifique.sh apkOutputs/$apkN $apktest
   package=`aapt dump badging $PWD/apkOutputs/$apkN | grep package | awk '{print $2}' | sed s/name=//g | sed s/\'//g`
   adb shell pm uninstall $package 
   java -cp  DynamicVerification.jar Main  analyse  -a  $sdk  -t  $apktest.txt -o  csvOutputs/  -p  $package apkOutputs/$apkN
 
done 9< $file
