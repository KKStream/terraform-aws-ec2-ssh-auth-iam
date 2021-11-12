#!/bin/bash

apt-get update
apt-get install git awscli -y

export SSHD_CONFIG_FILE="/etc/ssh/sshd_config"
export AUTHORIZED_KEYS_COMMAND_FILE="/opt/authorized_keys_command.sh"
export IMPORT_USERS_SCRIPT_FILE="/opt/import_users.sh"
export MAIN_CONFIG_FILE="/etc/aws-ec2-ssh.conf"

export IAM_GROUPS="${iam_groups}"
export SUDO_GROUPS="${iam_groups}"
export LOCAL_GROUPS=""
export ASSUME_ROLE=""
export USERADD_PROGRAM=""
export USERADD_ARGS=""

# check if AWS CLI exists
if ! which aws; then
    echo "aws executable not found - exiting!"
    exit 1
fi

tmpdir=$(mktemp -d)

cd "$tmpdir"

git clone -b "${lib_version}" https://github.com/widdix/aws-ec2-ssh.git

cd "$tmpdir/aws-ec2-ssh"

cp authorized_keys_command.sh $AUTHORIZED_KEYS_COMMAND_FILE
cp import_users.sh $IMPORT_USERS_SCRIPT_FILE

if [ -n "$IAM_GROUPS" ]
then
    echo "IAM_AUTHORIZED_GROUPS=\"$IAM_GROUPS\"" >> $MAIN_CONFIG_FILE
fi

if [ -n "$SUDO_GROUPS" ]
then
    echo "SUDOERS_GROUPS=\"$SUDO_GROUPS\"" >> $MAIN_CONFIG_FILE
fi

if [ -n "$LOCAL_GROUPS" ]
then
    echo "LOCAL_GROUPS=\"$LOCAL_GROUPS\"" >> $MAIN_CONFIG_FILE
fi

if [ -n "$ASSUME_ROLE" ]
then
    echo "ASSUMEROLE=\"$ASSUME_ROLE\"" >> $MAIN_CONFIG_FILE
fi

if [ -n "$USERADD_PROGRAM" ]
then
    echo "USERADD_PROGRAM=\"$USERADD_PROGRAM\"" >> $MAIN_CONFIG_FILE
fi

if [ -n "$USERADD_ARGS" ]
then
    echo "USERADD_ARGS=\"$USERADD_ARGS\"" >> $MAIN_CONFIG_FILE
fi

./install_configure_selinux.sh

./install_configure_sshd.sh

cat > /etc/cron.d/import_users << EOF
SHELL=/bin/bash
PATH=/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/opt/aws/bin
MAILTO=root
HOME=/
*/30 * * * * root $IMPORT_USERS_SCRIPT_FILE
EOF
chmod 0644 /etc/cron.d/import_users

$IMPORT_USERS_SCRIPT_FILE

Ec2InstanceConnect="/lib/systemd/system/ssh.service.d/ec2-instance-connect.conf"

if [ -f "$Ec2InstanceConnect" ]; then
    echo "File $file exists."
    sed -i 's/^/#/' $Ec2InstanceConnect
    systemctl daemon-reload
fi

./install_restart_sshd.sh
