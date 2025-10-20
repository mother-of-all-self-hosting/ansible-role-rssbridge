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

# Setting up ConvertX

This is an [Ansible](https://www.ansible.com/) role which installs [ConvertX](https://github.com/C4illin/ConvertX) to run as a [Docker](https://www.docker.com/) container wrapped in a systemd service.

ConvertX is a self-hosted online file converter which supports a lot of different formats for pictures, video, images, document files, etc.

See the project's [documentation](https://github.com/C4illin/ConvertX/blob/main/README.md) to learn what ConvertX does and why it might be useful to you.

## Adjusting the playbook configuration

To enable ConvertX with this role, add the following configuration to your `vars.yml` file.

**Note**: the path should be something like `inventory/host_vars/mash.example.com/vars.yml` if you use the [MASH Ansible playbook](https://github.com/mother-of-all-self-hosting/mash-playbook).

```yaml
########################################################################
#                                                                      #
# convertx                                                             #
#                                                                      #
########################################################################

convertx_enabled: true

########################################################################
#                                                                      #
# /convertx                                                            #
#                                                                      #
########################################################################
```

### Set the hostname

To enable ConvertX you need to set the hostname as well. To do so, add the following configuration to your `vars.yml` file. Make sure to replace `example.com` with your own value.

```yaml
convertx_hostname: "example.com"
```

After adjusting the hostname, make sure to adjust your DNS records to point the domain to your server.

### Enable account registration (optional)

To use ConvertX you need to create an account and log in to it on the browser.

In order to prevent abuse, account registration will be disabled after the first user is created. You can enable it by adding the following configuration to your `vars.yml` file:

```yaml
convertx_environment_variables_account_registration: true
```

### Set a subpath (optional)

It is possible to serve the instance under a subpath by adding the following configuration to your `vars.yml` file.

```yaml
convertx_environment_variables_webroot: YOUR_SUBPATH_HERE
```

For example, setting this to `/convert` will have the website served on `https://example.com/convert/`.

>[!NOTE]
> The subpath cannot be specified with the `convertx_path_prefix` variable.

### Disabling authentication function

If the service is hosted locally or with an authentication service like [Tinyauth](https://tinyauth.app/), you can disable the authentication function of ConvertX in favor of it by adding the following configuration to your `vars.yml` file.

```yaml
convertx_environment_variables_allow_unauthenticated: true
```

### Extending the configuration

There are some additional things you may wish to configure about the component.

Take a look at:

- [`defaults/main.yml`](../defaults/main.yml) for some variables that you can customize via your `vars.yml` file. You can override settings (even those that don't have dedicated playbook variables) using the `convertx_environment_variables_additional_variables` variable

See [this section on the official documentation](https://github.com/C4illin/ConvertX/blob/main/README.md#environment-variables) for a complete list of ConvertX's config options that you could put in `convertx_environment_variables_additional_variables`.

## Installing

After configuring the playbook, run the installation command of your playbook as below:

```sh
ansible-playbook -i inventory/hosts setup.yml --tags=setup-all,start
```

If you use the MASH playbook, the shortcut commands with the [`just` program](https://github.com/mother-of-all-self-hosting/mash-playbook/blob/main/docs/just.md) are also available: `just install-all` or `just setup-all`

## Usage

After running the command for installation, ConvertX becomes available at the specified hostname like `https://example.com`. To use it, open the URL on the browser and create an account.

Note that it is not available to restore the password if it is lost. In this case, you will need to uninstall the service and reinstall it to start it over.

## Troubleshooting

### Check the service's logs

You can find the logs in [systemd-journald](https://www.freedesktop.org/software/systemd/man/systemd-journald.service.html) by logging in to the server with SSH and running `journalctl -fu convertx` (or how you/your playbook named the service, e.g. `mash-convertx`).
