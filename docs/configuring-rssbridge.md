<!--
SPDX-FileCopyrightText: 2020 - 2024 MDAD project contributors
SPDX-FileCopyrightText: 2020 - 2024 Slavi Pantaleev
SPDX-FileCopyrightText: 2020 Aaron Raimist
SPDX-FileCopyrightText: 2020 Chris van Dijk
SPDX-FileCopyrightText: 2020 Dominik Zajac
SPDX-FileCopyrightText: 2020 Mickaël Cornière
SPDX-FileCopyrightText: 2022 François Darveau
SPDX-FileCopyrightText: 2022 Julian Foad
SPDX-FileCopyrightText: 2022 Warren Bailey
SPDX-FileCopyrightText: 2023 Antonis Christofides
SPDX-FileCopyrightText: 2023 Felix Stupp
SPDX-FileCopyrightText: 2023 Pierre 'McFly' Marty
SPDX-FileCopyrightText: 2024 - 2025 Suguru Hirahara

SPDX-License-Identifier: AGPL-3.0-or-later
-->

# Setting up RSS-Bridge

This is an [Ansible](https://www.ansible.com/) role which installs [RSS-Bridge](https://rss-bridge.org/bridge01/) to run as a [Docker](https://www.docker.com/) container wrapped in a systemd service.

RSS-Bridge is a self-hosted online file converter which supports a lot of different formats for pictures, video, images, document files, etc.

See the project's [documentation](https://github.com/RSS-Bridge/rss-bridge/blob/master/README.md) to learn what RSS-Bridge does and why it might be useful to you.

## Adjusting the playbook configuration

To enable RSS-Bridge with this role, add the following configuration to your `vars.yml` file.

**Note**: the path should be something like `inventory/host_vars/mash.example.com/vars.yml` if you use the [MASH Ansible playbook](https://github.com/mother-of-all-self-hosting/mash-playbook).

```yaml
########################################################################
#                                                                      #
# rssbridge                                                            #
#                                                                      #
########################################################################

rssbridge_enabled: true

########################################################################
#                                                                      #
# /rssbridge                                                           #
#                                                                      #
########################################################################
```

### Set the hostname

To enable RSS-Bridge you need to set the hostname as well. To do so, add the following configuration to your `vars.yml` file. Make sure to replace `example.com` with your own value.

```yaml
rssbridge_hostname: "example.com"
```

After adjusting the hostname, make sure to adjust your DNS records to point the domain to your server.

### Enabling authentication

By default the service is public, and anyone can generate a feed to subscribe.

You can enable HTTP Basic authentication or token authentication by adding the following configuration to your `vars.yml` file:

```yaml
# Enable HTTP Basic authentication
rssbridge_config_authentication_enable: true
rssbridge_config_authentication_username: YOUR_USERNAME_HERE
rssbridge_config_authentication_password: YOUR_PASSWORD_HERE

# Enable token authentication
rssbridge_config_authentication_token: YOUR_TOKEN_HERE
```

Replace each placeholder with your own value, generated with `pwgen -s 64 1` or in another way.

### Extending the configuration

There are some additional things you may wish to configure about the component.

Take a look at:

- [`defaults/main.yml`](../defaults/main.yml) for some variables that you can customize via your `vars.yml` file. You can override settings (even those that don't have dedicated playbook variables) using the `rssbridge_config_additional_configurations` variable

See [`config.default.ini.php`](https://raw.githubusercontent.com/RSS-Bridge/rss-bridge/refs/heads/master/config.default.ini.php) for a complete list of FreshRSS's config options that you could put in `rssbridge_config_additional_configurations`.

## Installing

After configuring the playbook, run the installation command of your playbook as below:

```sh
ansible-playbook -i inventory/hosts setup.yml --tags=setup-all,start
```

If you use the MASH playbook, the shortcut commands with the [`just` program](https://github.com/mother-of-all-self-hosting/mash-playbook/blob/main/docs/just.md) are also available: `just install-all` or `just setup-all`

## Usage

After running the command for installation, RSS-Bridge becomes available at the specified hostname like `https://example.com`. To use it, open the URL on the browser and create an account.

Note that it is not available to restore the password if it is lost. In this case, you will need to uninstall the service and reinstall it to start it over.

## Troubleshooting

### Check the service's logs

You can find the logs in [systemd-journald](https://www.freedesktop.org/software/systemd/man/systemd-journald.service.html) by logging in to the server with SSH and running `journalctl -fu rssbridge` (or how you/your playbook named the service, e.g. `mash-rssbridge`).
