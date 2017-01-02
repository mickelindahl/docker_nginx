export HOME=/opt/apps/docker_nginx

declare -a arr=("{domain/subdomain}" "{subdomain}" ... etc)

## now loop through the above array
for i in "${arr[@]}"
do

  echo "Copying cert and key for $i"
  $HOME/copy_cert.sh $i $HOME

   # or do whatever with individual element of the array
done
