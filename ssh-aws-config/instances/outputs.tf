# terraform output command will display the public DNS and public IP of the EC2 instance after applying the configuration.

output "public_dns" {
  description = "DNS name of the EC2 instance"
  value       = aws_instance.ssh.public_dns
}


output "public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.ssh.public_ip
}

#terraform output public_ip command will display the public IP of the EC2 instance after applying the configuration.

#ssh -i ~/.ssh/terraform-lab admin@<public_ip>   (admin = default user on Debian)


#Please install nginx on the instance and then run the following command to check if the web server is running:
#curl http://<public_ip>/