#!/bin/bash

# ---------- Start -------------------- Start -------------------- Start -------------------- Start --------------------- Start --------------

# Shell Script by - TUSHAR SRIVASTAVA
# For Platform - ANSIBLE
# Description - SETUP FOR ANSIBLE CONTROLLER

touch /etc/script_status.txt         # to save all process status
SAVE_STATUS="/etc/script_status.txt"     # path of the file script_status.txt
echo -e "script_status.txt File Created Successfully\n" >> "$SAVE_STATUS"

# ---------- 1st step -------------------- 1st step -------------------- 1st step -------------------- 1st step ----------

# system update
echo "1st Step: Update Opeartion Start Successfully." >> "$SAVE_STATUS"
if yum update -y; then
    echo -e "Update Opeartion Completed Successfully. \n" >> "$SAVE_STATUS"
else
    echo "Error : Update Operation Failed //check commands!!" >> "$SAVE_STATUS"
fi

# ---------- 2nd step -------------------- 2nd step -------------------- 2nd step -------------------- 2nd step ----------

# install vim
echo "2nd Step: Install vim Opeartion Start Successfully." >> "$SAVE_STATUS"
if yum install -y vim; then
    echo -e "Install vim Opeartion Completed Successfully. \n" >> "$SAVE_STATUS"
else
    echo "Error : Install vim Operation Failed //check commands!!" >> "$SAVE_STATUS"
fi

# enable and start sshd service
systemctl enable sshd 
echo "sshd Enabled Successfully." >> "$SAVE_STATUS"
systemctl start sshd  
echo -e "sshd Started Successfully. \n" >> "$SAVE_STATUS"

# ---------- 3rd step -------------------- 3rd step -------------------- 3rd step -------------------- 3rd step ----------

# change in sshd_config & 50-cloud-init.conf
FILE1="/etc/ssh/sshd_config" # Path to the sshd_config file
sed -i '65s/#PasswordAuthentication yes/PasswordAuthentication yes/' "$FILE1"
echo "3rd Step: sshd_config Change Done Successfully." >> "$SAVE_STATUS"

FILE2="/etc/ssh/sshd_config.d/50-cloud-init.conf" # Path to the 50-cloud-init.conf
sed -i '1s/PasswordAuthentication no/PasswordAuthentication yes/' "$FILE2"
echo -e "50-cloud-init.conf Change Done Successfully. \n" >> "$SAVE_STATUS"

# restart sshd service
systemctl restart sshd
echo -e "sshd Restarted Successfully. \n" >> "$SAVE_STATUS"

# ---------- 4th step -------------------- 4th step -------------------- 4th step -------------------- 4th step ----------

# create new user | you can change user name
useradd ansible
echo "5th Step: user named 'ansible' Added Successfully." >> "$SAVE_STATUS"

# Set the password 'ansible' for the user 'ansible' | you can change password
echo -e "ansible\nansible" | passwd ansible
echo -e "password is 'ansible' set successfully. \n" >> "$SAVE_STATUS"

# ---------- 5th step -------------------- 5th step -------------------- 5th step -------------------- 5th step ----------

# install ansible
echo "4th Step: Install ansible Opeartion Start Successfully." >> "$SAVE_STATUS"
if yum install -y ansible*; then
    echo -e "Install ansible Opeartion Completed Successfully. \n" >> "$SAVE_STATUS"
else
    echo "Error : Install ansible Operation Failed //check commands!!" >> "$SAVE_STATUS"
fi

# ---------- 6th step -------------------- 6th step -------------------- 6th step -------------------- 6th step ----------

# save user & password in sudoers file
FILE3="/etc/sudoers" # Path to the sudoers file
sed -i "101a\ansible ALL=(ALL) NOPASSWD:ALL" "$FILE3"
echo -e "6th Step: user and password Added in Sudoers Successfully. \n" >> "$SAVE_STATUS"

# ---------- 7th step -------------------- 7th step -------------------- 7th step -------------------- 7th step ----------

# install these for auto fetch password
# install expect
echo "7th Step: Install Expect Operation Start Successfully." >> "$SAVE_STATUS"
if yum install -y expect; then
    echo -e "Install Expect Operation Completed Successfully. \n" >> "$SAVE_STATUS"
else
    echo "Error: Install Expect Operation Failed // check commands!!" >> "$SAVE_STATUS"
fi

# install sshpass
echo "Install SSHPass Operation Start Successfully." >> "$SAVE_STATUS"
if yum install -y sshpass; then
    echo -e "Install SSHPass Operation Completed Successfully. \n" >> "$SAVE_STATUS"
else
    echo "Error: Install SSHPass Operation Failed // check commands!!" >> "$SAVE_STATUS"
fi

# ---------- 8th step -------------------- 8th step -------------------- 8th step -------------------- 8th step ----------

# Switch to the ansible user and generate the SSH key without a passphrase
su - ansible -c "ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa"
echo -e "8th Step: Login into ansible and created ssh keygen successfully. \n" >> "$SAVE_STATUS"

# ---------- 9th step -------------------- 9th step -------------------- 9th step -------------------- 9th step ----------

# Define the path where the inventory_ip_add_in_hosts.sh script will be created
ANSIBLE_SCRIPT_PATH1="/home/ec2-user/inventory_ip_add_in_hosts.sh"
echo -e "9th Step: Created inventory_ip_add_in_hosts.sh File successfully. \n" >> "$SAVE_STATUS"

# Create inventory_ip_add_in_hosts.sh script
cat << 'EOF' > $ANSIBLE_SCRIPT_PATH1
#!/bin/bash

SAVE_STATUS="/etc/script_status.txt"
FILE4="/etc/ansible/hosts"

# Ask user for inventory name
read -p "Enter the Inventory Name: " inventory_name
sed -i "11a\[$inventory_name]" "$FILE4"
echo -e "Inventory name: $inventory_name Added Successfully. \n" >> "$SAVE_STATUS"

# Ask user for the number of private IP addresses
read -p "How many private IP addresses do you want to add? " num_ips

# Loop through the number of IP addresses and ask the user to input each one
for (( i=1; i<=num_ips; i++ ))
do
    read -p "Enter the private IP address of Node $i: " privateip
    line_number=$((11 + i))
    sed -i "${line_number}a\\$privateip" "$FILE4"
    echo "Private IP of Node $i: $privateip Added Successfully." >> "$SAVE_STATUS"
done

echo -e "\nAll IPs Added Successfully." >> "$SAVE_STATUS"
EOF

chmod +x $ANSIBLE_SCRIPT_PATH1

# ---------- 10th step -------------------- 10th step -------------------- 10th step -------------------- 10th step ----------

# Define the path where the connect_with_private_ip.sh script will be created
ANSIBLE_SCRIPT_PATH2="/home/ansible/connect_with_private_ip.sh"
echo -e "10th Step: Created connect_with_private_ip.sh File successfully. \n" >> "$SAVE_STATUS"

# Create connect_with_private_ip.sh script
cat << 'EOF' > $ANSIBLE_SCRIPT_PATH2
#!/bin/bash

# Ask the user how many nodes they have
read -p "How many nodes do you want to connect with controller? " num_nodes

# Loop to get the IP addresses for all nodes
for ((i=1; i<=num_nodes; i++))
do
    read -p "Enter the private IP address of Node $i: " privateip
    echo -e "yes\nansible" | ssh-copy-id ansible@"$privateip"
done
EOF

chmod +x $ANSIBLE_SCRIPT_PATH2

# ---------- 11th step -------------------- 11th step -------------------- 11th step -------------------- 11th step ----------

# Define the path where the connect_with_private_ip.sh script will be created
ANSIBLE_SCRIPT_PATH3="/home/ec2-user/change_username_password.sh"
echo -e "11th Step: Created change_username_password.sh File successfully. \n" >> "$SAVE_STATUS"

# Create change_username_password.sh script
cat << 'EOF' > $ANSIBLE_SCRIPT_PATH3
#!/bin/bash

SAVE_STATUS="/etc/script_status.txt"
FILE3="/etc/sudoers"

# Prompt for new username and password
read -p "Enter the current username: " old_username
read -p "Enter the new username: " new_username
read -sp "Enter the new password: " new_password
echo

# Check if old username exists
if id "$old_username" &>/dev/null; then
    # Lock the user account (optional but recommended)
    usermod -L "$old_username"
    
    # Change username
    usermod -l "$new_username" "$old_username"
    
    # Change the home directory name
    usermod -d "/home/$new_username" -m "$new_username"

    # Unlock the user account
    usermod -U "$new_username"

    # Set the new password
    echo -e "$new_password\n$new_password" | passwd "$new_username"

    echo "Username changed from '$old_username' to '$new_username' and password updated successfully." >> "$SAVE_STATUS"

    # Update the sudoers file
    sed -i "/$old_username/d" "$FILE3"
    sed -i "101a\\$new_username ALL=(ALL) NOPASSWD:ALL" "$FILE3"
    echo -e "User '$new_username' added in Sudoers file successfully.\n" >> "$SAVE_STATUS"
else
    echo "Error: User '$old_username' does not exist."
    exit 1
fi
EOF

chmod +x $ANSIBLE_SCRIPT_PATH3

# ---------- 12th step -------------------- 12th step -------------------- 12th step -------------------- 12th step ----------

# install firewall
echo "12th Step: Install Firewall Operation Start Successfully." >> "$SAVE_STATUS"
if yum install firewalld -y; then
    echo -e "Install Firewall Operation Completed Successfully. \n" >> "$SAVE_STATUS"
else
    echo "Error: Install Firewall Operation Failed // check commands!!" >> "$SAVE_STATUS"
fi

# enable & start firewalld services
systemctl enable firewalld 
echo "firewalld Enabled Successfully." >> "$SAVE_STATUS"
systemctl start firewalld  
echo -e "firewalld Started Successfully. \n" >> "$SAVE_STATUS"

# install ansible-posix from ansible-galaxy collection
echo "Install Ansible-Posix from Ansible-Galaxy Collection Operation Start Successfully." >> "$SAVE_STATUS"
if ansible-galaxy collection install ansible.posix; then
    echo -e "Install Ansible-Posix from Ansible-Galaxy Collection Operation Completed Successfully. \n" >> "$SAVE_STATUS"
else
    echo "Error: Install Ansible-Posix from Ansible-Galaxy Collection Operation Failed // check commands!!" >> "$SAVE_STATUS"
fi

# install community.general from ansible-galaxy collection
echo "Install Community-General from Ansible-Galaxy Collection Operation Start Successfully." >> "$SAVE_STATUS"
if ansible-galaxy collection install community.general; then
    echo -e "Install Community-General from Ansible-Galaxy Collection Operation Completed Successfully. \n" >> "$SAVE_STATUS"
else
    echo "Error: Install Community-General from Ansible-Galaxy Collection Operation Failed // check commands!!" >> "$SAVE_STATUS"
fi

# install community.docker from ansible-galaxy collection
echo "Install Community-Docker from Ansible-Galaxy Collection Operation Start Successfully." >> "$SAVE_STATUS"
if ansible-galaxy collection install community.docker; then
    echo -e "Install Community-Docker from Ansible-Galaxy Collection Operation Completed Successfully. \n" >> "$SAVE_STATUS"
else
    echo "Error: Install Community-Docker from Ansible-Galaxy Collection Operation Failed // check commands!!" >> "$SAVE_STATUS"
fi

# install community.kubernetes from ansible-galaxy collection
echo "Install Community-Kubernetes from Ansible-Galaxy Collection Operation Start Successfully." >> "$SAVE_STATUS"
if ansible-galaxy collection install community.kubernetes; then
    echo -e "Install Community-Kubernetes from Ansible-Galaxy Collection Operation Completed Successfully. \n" >> "$SAVE_STATUS"
else
    echo "Error: Install Community-Kubernetes from Ansible-Galaxy Collection Operation Failed // check commands!!" >> "$SAVE_STATUS"
fi

# install amazon.aws from ansible-galaxy collection
echo "Install Community-AWS from Ansible-Galaxy Collection Operation Start Successfully." >> "$SAVE_STATUS"
if ansible-galaxy collection install community.aws; then
    echo -e "Install Community-AWS from Ansible-Galaxy Collection Operation Completed Successfully. \n" >> "$SAVE_STATUS"
else
    echo "Error: Install Community-AWS from Ansible-Galaxy Collection Operation Failed // check commands!!" >> "$SAVE_STATUS"
fi

# save all ansible-galaxy collection installed list
ansible-galaxy collection list >> "$SAVE_STATUS"

# ---------- End -------------------- End -------------------- End -------------------- End -------------------- End --------------------