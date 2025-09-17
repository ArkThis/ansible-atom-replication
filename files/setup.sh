#!/bin/bash
# Make sure you have the hosts set as your ansible inventory?
# /etc/ansible/hosts

PAUSE="read -p 'press return...'"

# Fetch the role from upstream:
if [ ! -d "roles" ]; then
    ansible-galaxy install -f -p roles -r requirements.yml
    eval $PAUSE
fi

ANSIBLE_USER="artefactual"
ANSIBLE_KEY="$HOME/.ssh/id_rsa"
ANSIBLE_SUDO="artefactual.sudo"
ANSIBLE_SUDO_ETC="/etc/sudoers.d/$ANSIBLE_USER"
ATOM_EDIT="atom-edit.example.com"
ATOM_RO="atom-ro.example.com"

if [ ! -s "$ANSIBLE_SUDO_ETC" ]; then
    echo "Allowing '$ANSIBLE_USER' to sudo without password..."
    sudo cp -av $ANSIBLE_SUDO $ANSIBLE_SUDO_ETC
    eval $PAUSE
fi


# Create SSH key for ansible access later:
if [ ! -s $ANSIBLE_KEY ]; then
    echo "exists"
    ssh-keygen -t rsa -f $ANSIBLE_KEY
    eval $(ssh-agent)   # From: https://www.cyberciti.biz/faq/how-to-use-ssh-agent-for-authentication-on-linux-unix/
    ssh-add $ANSIBLE_KEY
    eval $PAUSE
fi

# TODO: Create user automatically.
adduser $ANSIBLE_USER
ssh-copy-id $ANSIBLE_USER@atom-edit.example.com
#ssh-copy-id $ANSIBLE_USER@atom-ro.example.com

echo ""
echo "List and ping hosts for line-check..."
echo ""

ansible all --list-hosts
ansible all -m ping
eval $PAUSE


echo ""
echo "Run the playbook..."
echo ""

ansible-playbook mgt.replication-aph-role.yml -e atom_replication_ansible_remote_server=atom-edit-server -t install-replication
eval $PAUSE

