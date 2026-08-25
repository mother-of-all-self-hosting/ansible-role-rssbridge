<!--
SPDX-FileCopyrightText: 2018-2026 Slavi Pantaleev
SPDX-FileCopyrightText: 2019-2022 Aaron Raimist
SPDX-FileCopyrightText: 2019-2023 MDAD project contributors
SPDX-FileCopyrightText: 2023 QEDeD
SPDX-FileCopyrightText: 2024 Fabio Bonelli
SPDX-FileCopyrightText: 2024 Nikita Chernyi
SPDX-FileCopyrightText: 2024-2026 Suguru Hirahara
SPDX-FileCopyrightText: 2026 spatterlight

SPDX-License-Identifier: AGPL-3.0-or-later
-->

# Molecule Testing

This role supports [Molecule](https://docs.ansible.com/projects/molecule/), an Ansible testing framework designed for developing and testing Ansible collections, playbooks, and roles.

## Prerequisites

To utilize Molecule you need to prepare several requirements:

- **x86** computer running one of these operating systems that make use of [systemd](https://systemd.io/):
  - **Archlinux**
  - **CentOS**, **Rocky Linux**, **AlmaLinux**, or possibly other RHEL alternatives (although your mileage may vary)
  - **Debian** (10/Buster or newer)
  - **Ubuntu** (18.04 or newer, although [20.04 may be problematic](https://github.com/mother-of-all-self-hosting/mash-playbook/blob/main/docs/ansible.md#supported-ansible-versions) if you run the Ansible playbook on it)
- `root` access on the computer which Molecule runs against
- [Ansible](http://ansible.com/) program
- [Python](https://www.python.org/)
  - Most distributions install Python by default, but some don't (e.g. Ubuntu 18.04) and require manual installation (something like `apt-get install python3`)
- [Docker](https://www.docker.com)
  - Access to Docker UNIX socket (`/var/run/docker.sock`) is required by default

## Installation

To set up the environment for using Molecule, run the command below on the terminal:

```bash
python3 -m venv ./molecule/venv
source ./molecule/venv/bin/activate
pip3 install -r ./molecule/requirements.txt
```

## Scenarios

Currently these testing scenarios are available:

### `default`

Tests a standard RSS-Bridge installation against the published container image.

Because the image serves a fully working RSS-Bridge when given no configuration at all — 200 on every page, every bridge enabled — the scenario first starts an *unconfigured* container of the same image and checks that it shows none of what the role is supposed to configure. Only then does it assert that the role's instance does: HTTP Basic authentication refuses an anonymous request and a wrong password, the `message` banner that only `rssbridge_config_additional_configurations` could have produced is on the page, the container's timezone is the one the role's env file names, and nginx is listening on the port `HTTP_PORT` moved it to.

It then has RSS-Bridge actually generate a feed. A static RSS fixture is bind-mounted into the container (through `rssbridge_container_additional_volumes_custom`, which the assertions also cover) where the instance's own nginx serves it, and `FeedMergeBridge` is asked to turn it into an Atom feed. The fetch stays on the container's loopback, so no third-party website is involved — RSS-Bridge's bridges almost all scrape one, which is exactly the kind of flakiness a test that gates automerge must not depend on.

### `default-selfbuild`

Tests a standard RSS-Bridge installation with self-building the container image.

The question this scenario answers is whether the image the role *built* is a working RSS-Bridge and is genuinely the one the container runs, so it checks the build's provenance — the image carries no RepoDigest, because it has never been in a registry, and the source tree it was built from is upstream's at a known commit — and then has that image produce a feed. The stock image's behaviour and the negative controls belong to the `default` scenario and are not repeated here.

This scenario clones and builds RSS-Bridge from source, so it only changes behavior when the version the role installs changes. CI therefore runs it on branches where `defaults/main.yml` changed a version, and on manual dispatch; run it locally with `molecule test --scenario-name default-selfbuild`.

## Running

By default it is configured to run the scenarios on Ubuntu 26.04.

```bash
molecule test --scenario-name default
```

You can utilize other distributions by setting one to the `MOLECULE_DISTRO` environment variable:

```bash
# Ubuntu 24.04
MOLECULE_DISTRO=ubuntu2404 molecule test --scenario-name default

# Debian 13
MOLECULE_DISTRO=debian13 molecule test --scenario-name default

# Debian 12
MOLECULE_DISTRO=debian12 molecule test --scenario-name default
```
