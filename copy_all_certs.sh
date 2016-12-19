echo "Copying cert and key for grassy.se"
/opt/apps/nginx/copy_cert.sh grassy.se /opt/apps/nginx

echo "Copying cert and key for jucie.grassy.se"
/opt/apps/nginx/copy_cert.sh juice.grassy.se /opt/apps/nginx

echo "Copying cert and key for jenkins.grassy.se"
/opt/apps/nginx/copy_cert.sh jenkins.grassy.se /opt/apps/nginx
