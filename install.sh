#!/bin/sh

# Get the absolute path of the script folder
SCRIPT_FOLDER="$(dirname "$(readlink -f "$0")")"
HTPASSWD_FILE="$SCRIPT_FOLDER/.htpasswd"

# Use sed to replace "AuthUserFile .htpasswd" with "AuthUserFile /path/to/.htpasswd" if the .htaccess file does not exist
if [ ! -f "$SCRIPT_FOLDER/public_html/.htaccess" ]; then

	echo "Creating .htaccess file"
	sed "s|AuthUserFile .htpasswd|AuthUserFile $HTPASSWD_FILE|" "$SCRIPT_FOLDER/template.htaccess" >"$SCRIPT_FOLDER/public_html/.htaccess"

else

	echo ".htaccess file already exists. Will not overwrite."

fi

# Check if .htpasswd file exists, and if it does, ask the user if they want to overwrite it or add a new user
if [ -f "$HTPASSWD_FILE" ]; then

	echo "A password file already exists. Do you want to overwrite it? (y/n)"
	read -r delete_file

	if [ "$delete_file" != "y" ]; then

		# If the user does not want to overwrite the password file, ask if they want to add a new user
		echo "Do you want to add a new user? (y/n)"
		read -r append_user

		if [ "$append_user" != "y" ]; then
			exit 0
		fi

	else

		# Remove the password file and continue first time setup
		rm "$HTPASSWD_FILE"
		echo "Password file removed. Continuing..."

	fi

fi

# Check if the htpasswd command exists and make a password file if it does
if command -v htpasswd >/dev/null; then

	# Request a username from the user
	echo "Enter a username and press [ENTER]"
	read -r username

	# Hash the password using htpasswd and add it to the password file
	# We always append since the file cannot exist if unless we are appending
	htpasswd -n "$username" | sed '/^$/d' >>"$HTPASSWD_FILE"

# Check if the openssl command exists and make a password file if it does
elif command -v openssl >/dev/null; then

	# Request a username from the user
	echo "Enter a username and press [ENTER]"
	read -r username

	# Request a password from the user
	echo "Enter a password and press [ENTER]"
	stty -echo && {
		read -r password
		stty echo
	}

	# Request the password again to confirm
	echo "Re-enter the password and press [ENTER]"
	stty -echo && {
		read -r password2
		stty echo
	}

	# Verify that the passwords match
	if [ "$password" != "$password2" ]; then
		echo "Passwords do not match."
		exit 1
	fi

	# Hash the password using openssl and add it to the password file
	# We always append since the file cannot exist if unless we are appending
	printf '%s:%s\n' "$username" "$(openssl passwd -apr1 "$password")" >>"$HTPASSWD_FILE"

else

	# If neither htpasswd nor openssl exists, exit with an error message
	echo "htpasswd command not found. Please install apache2-utils (debian) or httpd-tools (rhel)."
	echo "(this script supports using openssl instead, but it is also not installed)"
	exit 1

fi
