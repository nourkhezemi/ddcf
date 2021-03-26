#move to home diractory
#cd /home/nour
#give the apk path
#read -p "give the apk name"  apk
#give the main activity name
#read -p "give the main activity name"  activity
#give the package name
#read -p "give the package name"  package

#remplacer les apk, activity, package dans test.py and create a copie

#create another test.py
cp /home/nour/Android/Sdk/tools/test.py /home/nour/Android/Sdk/tools/test1.py
#change the apk name
sed -i "s|/home/nour/APKS/App_Lambda_App.apk|$1|g" /home/nour/Android/Sdk/tools/test1.py

#change the main activity name
sed -i "s/com.core.lambdaapp.MainActivity/$2/g" /home/nour/Android/Sdk/tools/test1.py

#change the package name 
sed -i "s/com.core.lambdaapp/$3/g" /home/nour/Android/Sdk/tools/test1.py
#
cd /home/nour/Android/Sdk/tools/bin
adb logcat -c
#run the monkey runner
./monkeyrunner /home/nour/Android/Sdk/tools/test1.py
#generate the logs
cd /home/nour

adb logcat -d >> $1.txt
 
echo "finish"


