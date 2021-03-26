#!/bin/bash

# Display hardware listing for this computer

TempFile=$(mktemp)

ListType=`zenity --width=400 --height=275 --list --radiolist \
     --title 'Use Mode' \
     --text 'you want to:' \
     --column 'Select' \
     --column 'Use Type' TRUE "Instrument" FALSE "Analyse"`

if [[ $? -eq 1 ]]; then

# they pressed Cancel or closed the dialog window 
  zenity --error --title="Scan Declined" --width=200 \
       --text="Selection  skipped"
  exit 1
################################################Instrumentation ##########################################
elif [ $ListType == "Instrument" ]; then

  # they selected the Instrument radio button 
  Flag="--Instrument"
  ##select apk path
  OUTPUT=$(zenity --forms --title="Add parameters" --text="Enter parameters" --separator=","  --add-entry="Path of APK"  --add-entry="Package name"  --add-entry="APK name" --add-entry="main activity name" )
  
  accepted=$?
  if ((accepted != 0)); then
      echo "something went wrong"
      exit 1
  fi

  apk=$(awk -F, '{print $1}' <<<$OUTPUT)
  package=$(awk -F, '{print $2}' <<<$OUTPUT)
  apkN=$(awk -F, '{print $3}' <<<$OUTPUT)
  activity=$(awk -F, '{print $4}' <<<$OUTPUT)



  case $? in
      0)
         echo "Data added";;
      1)
          echo "No data added."
	  ;;
     -1)
          echo "An unexpected error has occurred."
	  ;;
   esac
   java -cp  DynamicVerification.jar Main instrumentation -a /home/nour/Android/Sdk/platforms/ -o apkOutputs/ $apk -p $package
   
   jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore my-release-key.keystore -storepass "motdepasse123"  -keypass "motdepasse123" apkOutputs/$apkN alias_name
   ListType=`zenity --width=400 --height=275 --list --radiolist \
      --title 'Analyse?' \
      --text 'you want to continue the analyse:' \
      --column 'Select' \
      --column 'option' TRUE "Yes" FALSE "No"`

   if [[ $? -eq 1 ]]; then

         # they pressed Cancel or closed the dialog window 
         zenity --error --title="Scan Declined" --width=200 \
            --text="Selection  skipped"
                 exit 1
#######CONTINUE ANALYSE 
   elif [ $ListType == "Yes" ]; then

        Flag="--Yes"
        
  ListType=`zenity --width=400 --height=275 --list --radiolist \
       --title 'Type of Test' \
       --text 'Which type of test you want to have:' \
       --column 'Select' \
       --column 'option' TRUE "Specific-tests" FALSE "random-tests"`
   if [[ $? -eq 1 ]]; then

      # they pressed Cancel or closed the dialog window 
      zenity --error --title="Scan Declined" --width=200 \
         --text="Selection  skipped"
      exit 1
   
   ####Specific tests 
   elif [ $ListType == "Specific-tests" ]; then
     
      OUTPUT=$(zenity --forms --title="Add parameters" --text="Enter parameters" --separator=","  --add-entry="PATH of apk of test"   )
    
      accepted=$?
      if ((accepted != 0)); then
          echo "something went wrong"
          exit 1
      fi
      apktest=$(awk -F, '{print $1}' <<<$OUTPUT)   
      jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore my-release-key.keystore -storepass "motdepasse123"  -keypass "motdepasse123" $apktest alias_name   
      ./test-specifique.sh apkOutputs/$apkN $apktest
      java -cp  DynamicVerification.jar Main  analyse  -a  /home/nour/Android/Sdk/platforms/  -t  $apktest.txt -o  csvOutputs/  -p  $package apkOutputs/$apkN
     
   ####MonkeyRunner 
    
   elif [ $ListType == "random-tests" ]; then
       cp  apkOutputs/$apkN /home/nour/APKS/$apkN
      ./monkey.sh  $apkN $activity $package
      
      java -cp  DynamicVerification.jar Main  analyse  -a  /home/nour/Android/Sdk/platforms/  -t  /home/nour/$apkN.txt  -o  csvOutputs/  -p  $package apkOutputs/$apkN
   fi
 
###### No ! abort! 
    else
         # they selected the NO radio button 
         Flag="No" 
         exit 1
    fi
      
      
################################################Analyse only###############################################
 
elif  [ $ListType == "Analyse" ]; then
  Flag="analyse" 
#######Tests to have logs

  ListType=`zenity --width=400 --height=275 --list --radiolist \
       --title 'Type of Test' \
       --text 'Which type of test you want to have:' \
       --column 'Select' \
       --column 'option' TRUE "Specific-tests" FALSE "random-tests"`
   if [[ $? -eq 1 ]]; then

      # they pressed Cancel or closed the dialog window 
      zenity --error --title="Scan Declined" --width=200 \
         --text="Selection  skipped"
      exit 1
   
   ####Specific tests 
   elif [ $ListType == "Specific-tests" ]; then
     
      OUTPUT=$(zenity --forms --title="Add parameters" --text="Enter parameters" --separator=","  --add-entry=" Apk Path" --add-entry="PATH of apk of test"  --add-entry="package name" )
      accepted=$?
      if ((accepted != 0)); then
          echo "something went wrong"
          exit 1
      fi
 
      apk=$(awk -F, '{print $1}' <<<$OUTPUT)
      apktest=$(awk -F, '{print $2}' <<<$OUTPUT)
      package=$(awk -F, '{print $3}' <<<$OUTPUT)
      jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore my-release-key.keystore -storepass "motdepasse123"  -keypass "motdepasse123" $apktest alias_name
      ./test-specifique.sh $apk $apktest
      java -cp  DynamicVerification.jar Main  analyse  -a  /home/nour/Android/Sdk/platforms/  -t  $apk.txt  -o  csvOutputs/  -p  $package $apk
     
   ####MonkeyRunner  
   elif [ $ListType == "random-tests" ]; then
   
     OUTPUT=$(zenity --forms --title="Add parameters" --text="Enter parameters" --separator=","  --add-entry="APK path" --add-entry=" Apk Name" --add-entry="Activity name" --add-entry="Package name"  )
      accepted=$?
      if ((accepted != 0)); then
          echo "something went wrong"
          exit 1
      fi
      apk=$(awk -F, '{print $1}' <<<$OUTPUT)
      apkN=$(awk -F, '{print $2}' <<<$OUTPUT)
      activity=$(awk -F, '{print $3}' <<<$OUTPUT)
      package=$(awk -F, '{print $4}' <<<$OUTPUT)
      ./monkey.sh  $apkN $activity $package
      java -cp  DynamicVerification.jar Main  analyse  -a  /home/nour/Android/Sdk/platforms/  -t  /home/nour/$apkN.txt  -o  csvOutputs/  -p  $package $apk
   fi
################################################END################################################

  
fi 
exit 0
