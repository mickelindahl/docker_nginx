export HOME=/opt/apps/nginx

declare -a arr=("juice.grassy.se" "jenkins.grassy.se" "greendrive.grassy.se" "piwik.grassy.se")

## now loop through the above array
for i in "${arr[@]}"
do

  echo "Copying cert and key for $i"
  $HOME/copy_cert.sh $i $HOME

   # or do whatever with individual element of the array
done
