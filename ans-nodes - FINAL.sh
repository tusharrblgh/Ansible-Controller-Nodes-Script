#!/bin/bash

# ---------- Start -------------------- Start -------------------- Start -------------------- Start -------------------- Start ----------

# Shell Script by - TUSHAR SRIVASTAVA
# For Platform - ANSIBLE
# Description - SETUP FOR ANSIBLE NODES

touch /etc/script_status.txt         # to save all process status
SAVE_STATUS="/etc/script_status.txt"     # path of the file script_status.txt
echo -e "script_status.txt File Created Successfully. \n" >> "$SAVE_STATUS"

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
    echo "Error : Install vim Operation Failed //check commands" >> "$SAVE_STATUS"
fi

# enable and start sshd service
systemctl enable sshd 
echo "sshd Enabled Successfully." >> "$SAVE_STATUS"
systemctl start sshd  
echo -e "sshd Started Successfully. \n" >> "$SAVE_STATUS"

# ---------- 3rd step -------------------- 3rd step -------------------- 3rd step -------------------- 3rd step ----------

FILE1="/etc/ssh/sshd_config" # Path to the sshd_config file
sed -i '65s/#PasswordAuthentication yes/PasswordAuthentication yes/' "$FILE1"
echo -e "3rd Step: sshd_config Change Done Successfully. \n" >> "$SAVE_STATUS"

FILE2="/etc/ssh/sshd_config.d/50-cloud-init.conf" # Path to the 50-cloud-init.conf
sed -i '1s/PasswordAuthentication no/PasswordAuthentication yes/' "$FILE2"
echo -e "50-cloud-init.conf Change Done Successfully. \n" >> "$SAVE_STATUS"

# restart sshd service
systemctl restart sshd
echo -e "sshd Restarted Successfully. \n" >> "$SAVE_STATUS"

# ---------- 4th step -------------------- 4th step -------------------- 4th step -------------------- 4th step ----------

# create new user | you can change user name
useradd ansible
echo -e "4th Step: user named 'ansible' Added Successfully. \n" >> "$SAVE_STATUS"

# Set the password 'ansible' for the user 'ansible' | you can change password
echo -e "ansible\nansible" | passwd ansible
echo -e "password is 'ansible' set successfully. \n" >> "$SAVE_STATUS"

# ---------- 5th step -------------------- 5th step -------------------- 5th step -------------------- 5th step ----------

# save user & password in sudoers file
FILE3="/etc/sudoers" # Path to the sudoers file
sed -i "101a\ansible ALL=(ALL) NOPASSWD:ALL" "$FILE3"
echo -e "5th Step: user and password Added in Sudoers Successfully. \n" >> "$SAVE_STATUS"

# ---------- 6th step -------------------- 6th step -------------------- 6th step -------------------- 6th step ----------

# Define the path where the change_username_password.sh script will be created
ANSIBLE_SCRIPT_PATH="/home/ec2-user/change_username_password.sh"
echo -e "6th Step: Created change_username_password.sh File successfully. \n" >> "$SAVE_STATUS"

# Create change_username_password.sh script
cat << 'EOF' > $ANSIBLE_SCRIPT_PATH
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

chmod +x $ANSIBLE_SCRIPT_PATH

# ---------- End -------------------- End -------------------- End -------------------- End -------------------- End ----------