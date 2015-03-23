# To start PowerShell scripts first start PowerShell as Administrator
# to allow unsigned scripts to be executed. To do so enter:
# Set-ExecutionPolicy remotesigned
# Close the PowerShell window (you don't need Administrator privileges to run the scripts)
# Right click on the * .ps1 file and select Run with PowerShell

$AMIID=aws ec2 describe-images --filters "Name=description, Values=Amazon Linux AMI 2014.09.2 x86_64 HVM EBS" --query "Images[0].ImageId" --output text
$VPCID=aws ec2 describe-vpcs --filter "Name=isDefault, Values=true" --query "Vpcs[0].VpcId" --output text
$SUBNETID=aws ec2 describe-subnets --filters "Name=vpc-id, Values=$VPCID" --query "Subnets[0].SubnetId" --output text
$SGID=aws ec2 create-security-group --group-name mysecuritygroup --description "My security group" --vpc-id $VPCID --output text
aws ec2 authorize-security-group-ingress --group-id $SGID --protocol tcp --port 22 --cidr 0.0.0.0/0
$INSTANCEID=aws ec2 run-instances --image-id $AMIID --key-name mykey --instance-type t2.micro --security-group-ids $SGID --subnet-id $SUBNETID --query "Instances[0].InstanceId" --output text
Write-Host "waiting for $INSTANCEID ..."
aws ec2 wait instance-running --instance-ids $INSTANCEID
$PUBLICNAME=aws ec2 describe-instances --instance-ids $INSTANCEID --query "Reservations[0].Instances[0].PublicDnsName" --output text
Write-Host "$INSTANCEID is accepting SSH connections under $PUBLICNAME"
Write-Host "ssh -i mykey.pem ec2-user@$PUBLICNAME"
Write-Host "Press [Enter] key to terminate $INSTANCEID ..."
Read-Host
aws ec2 terminate-instances --instance-ids $INSTANCEID
Write-Host "terminating $INSTANCEID ..."
aws ec2 wait instance-terminated --instance-ids $INSTANCEID
aws ec2 delete-security-group --group-id $SGID
Write-Host "done."
Write-Host "Press [Enter] key to exit ..."
