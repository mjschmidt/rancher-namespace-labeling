
#if [ -z "$quickscriptspass" ]; then
#read -s -p "Enter password:" quickscriptspass
#fi

rancher projects | grep -v "ID                NAME                STATE     DESCRIPTION" > supporting-temp-files/rancher-projects-file


while read field1 field2 field3 field4; do

  #echo $field1 | cut -c 9-;
  projectId=$(echo $field1 | cut -c 9-)
  #echo $projectId
  #echo $field1 | cut -c -7;
  custerId=$(echo $field1 | cut -c -7)
  #echo $field2
  projectName=$(echo $field2)

  #echo "the project id is: " $projectId " the cluster id is: " $custerId " the project name is: " $projectName;

  sleep .5 

  echo
  echo "Namepaces in projectId " $projectId
  rancher kubectl get ns -l field.cattle.io/projectId=$projectId
  #echo
  #echo
  #echo Now we get the labels on the project
  echo
  sleep .5
  echo 
  echo "Labels in project " $projectId " are"
  rancher inspect --type project  $custerId:$projectId --format json | jq '.labels' | grep -v "{" | grep -v "}" | sed 's/ //g' | sed 's/,//g' | grep -v '"cattle.io/creator":"norman"' | grep -v "authz.management.cattle.i" > supporting-temp-files/namespace-labels-file

  for f in `cat ./supporting-temp-files/namespace-labels-file`;
  do
    sleep 2
    echo
    echo
    echo "HEY LOOK OVER HERE AT "$f
    key=$(echo $f | sed 's/"//g' | sed 's/:.*//')
    value=$(echo $f | sed 's/"//g' | sed 's/.*://')
    echo the key is $key
    echo the value is $value
    rancher kubectl label ns -l field.cattle.io/projectId=$projectId  kubecost/$key=$value
  done


  echo
  echo
  echo
  sleep 1
  echo "@TODO put the labels into variabless and add the labels to namespaces"
  echo
  echo
  sleep .5
  echo Add projectName label to the namespaces
  rancher kubectl label ns -l field.cattle.io/projectId=$projectId  field.cattle.io/projectName=$projectName

done < supporting-temp-files/rancher-projects-file
