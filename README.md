# Using Ansible to setup Paperless-ngx on Arch Linux

## Goal

Install a [Paperless-ngx](https://docs.paperless-ngx.com/) docker container on a headless Arch linux server using [Ansible](https://docs.ansible.com/).

## Files

```txt
├── ansible.cfg                    # <- general ansible settings
├── ansible-inventory.cfg          # <- ansible inventory
├── playbook-arch-paperlessngx.yml # <- ansible playbook
├── README.md                      # <- this file
├── resources                      # <- resources copied by ansible from host to target
│   ├── docker-compose.env
│   └── docker-compose.yml
└── run-playbook-paperlessngx.sh   # <- start ansible
```

## Prerequisites

The prerequisites are minimal since we try to install everything using Ansible.

### Target machine

- Arch linux
- sudo user
- working ssh setup
- python


### Ansible host machine

- `pacman -S ansible python`

## Ansible basics

    Ansible is a radically simple IT automation system.

[https://github.com/ansible/ansible](https://github.com/ansible/ansible)

### Inventory basics

Ansible's inventory describes the target machines. The format can be either INI or YAML.

The inventory is read in the following order (first match wins):

- `$PWD/ansible.cfg`
- `~/.ansible.cfg`
- `/etc/ansible/hosts`

In addition to the default read order, an explicit path can be provided on the command line using `-i`.

### Playbook basics

A playbook describes the desired state of the target system. 

Playbooks are interpreted from top to bottom.

Playbooks can use a large number of libraries to interact with different aspects of the target system (f.ex. adding users, modifying files, interacting with package managers, etc.). These libraries are referred to as "modules".

A playbook is invoked with the `ansible-playbook` command.

Example:

```sh
ansible-playbook playbook-name.yml
```

See the script `run-playbook-paperlessngx.sh` for a usage example.

### Useful modules

TODO

### Variables, environments, vaults

TODO

### Ansible debugging strategies

#### The classic: "Print-Line Debugging"

TODO

#### Other strategies?

TODO


## Ansible challenges in this scenario

### AUR

How to interact with AUR?

For my own systems I've been using [yay](https://github.com/Jguer/yay). Its syntax is mostly compatible with `pacman`'s syntax.

So: How to install `yay` with Ansible?

#### Setup AUR with yay

We are going to create a dedicated user called `aur_builder`. 
This will be a user who can build AUR packages for pacman.

```yml
- name: Create the `aur_builder` user
  become: yes
  user:
    name: aur_builder
    create_home: yes
    group: wheel

- name: Allow the `aur_builder` user to run `sudo pacman` without a password
  become: yes
  lineinfile:
    path: /etc/sudoers.d/11-install-aur_builder
    line: 'aur_builder ALL=(ALL) NOPASSWD: /usr/bin/pacman'
    create: yes
    validate: 'visudo -cf %s'
```

The next step is tricky: We have to figure out, if `yay` is already installed.

There is a module called `package_facts`.

```yml
- name: Gather the package facts
  package_facts:
    manager: auto
```

We can ask this `manager`

```yml
- name: clone yay repository...
  when: "'yay-bin' not in ansible_facts.packages"
```

So: this is a conditional statement.
(`when` condition can probably be optimized...)

We are checking `package_facts` for a property.

Let's try that:

```yml
- name: clone yay repository...
  become: true
  become_user: aur_builder 
  git:
    repo: 'https://aur.archlinux.org/yay-bin.git'
    dest: ~/yay-bin
  when: "'yay-bin' not in ansible_facts.packages"

- name: create package yay if it hasn't been installed yet...
  become: true
  become_user: aur_builder 
  command: /usr/bin/makepkg -si --noconfirm
  args:
    chdir: ~/yay-bin
  when: "'yay-bin' not in ansible_facts.packages"
```

```yml
- name: update arch system
  aur:
    use: yay
    update_cache: true
    upgrade: true
  become: yes
  become_user: aur_builder

- name: Install shell-related packages using yay
  aur:
    use: yay
    name:
      - tmux
      - zsh
  become: yes
  become_user: aur_builder
```      

### Paperless setup

#### Docker

- install new user `paperless_user`
- add sudo priviledges for `paperless_user`
- install `docker`
- add `docker` group
- add `paperless_user` to `docker` group
- enable `docker` service

#### Configs

- copy `docker-compose.{yml,env}` from resource folder to target machine

NOTE: Admin user and password are stored in plain text in `docker-compose.env`. Since this application will only be running in the local intranet, this is not a big deal. In case we want to change this: Look into `ansible vault` and/or `docker secrets`.

#### Start docker compose

- use `community.docker.docker_compose`
- seems to also work with `docker-compose` v2.

