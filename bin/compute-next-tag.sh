#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 Slavi Pantaleev
#
# SPDX-License-Identifier: AGPL-3.0-or-later

# Prints the tag that the currently checked out commit should be released as,
# or nothing at all if it does not warrant a release.
#
# Usage: bin/compute-next-tag.sh
#
# ---------------------------------------------------------------------------
# RSS-Bridge has no version to pin - read this before changing anything here
# ---------------------------------------------------------------------------
#
# Most roles in the fleet name their tags after the version of the software
# they install. This one cannot, because there is no such version to name:
#
# - docker.io/rssbridge/rss-bridge is rebuilt from `master` continuously. Each
#   rebuild is published as `sha-<short commit hash>` (`sha-bcf578a`) and moves
#   the `latest` tag. Of the ~1750 tags the repository carries, all but a
#   handful are of that form.
# - the handful that are not are dated release tags (`2025-08-05`), which
#   upstream cuts a couple of times a year and which `stable` points at. They
#   are not semver, they never produce a "patch" update, and following them
#   would pin this role to software many months behind what upstream's own
#   installation instructions hand people (`docker create ... rssbridge/rss-bridge`,
#   i.e. `latest`).
# - the running application reports the last dated release regardless of which
#   of the two it is, so even a pin would not be distinguishable at runtime.
#
# So `rssbridge_version` in defaults/main.yml is the literal `latest`, there is
# nothing for Renovate to bump (it has never opened a single pull request for
# it), and there is no version to name a tag after.
#
# The tags this repository has always used encode that absence as the
# placeholder version `2025.10.7`, with the release counter carrying all of the
# information: `v2025.10.7-0` through `v2025.10.7-7` at the time of writing.
#
# This script reproduces that naming rather than inventing a new one, by
# translating the `latest` sentinel into that placeholder. It still reads the
# version out of defaults/main.yml, so that the day RSS-Bridge starts
# publishing versions worth pinning and this role pins one, tagging follows
# along on its own: pinning `rssbridge_version: 1.2.3` starts a `v1.2.3-N`
# series with no change here.
#
# ---------------------------------------------------------------------------
#
# Tags look like `v<version>-<release>`:
#
# - if defaults/main.yml points at a version that has never been released,
#   the release counter restarts at 0 (`v1.2.3-0`)
# - otherwise the counter is incremented (`v2025.10.7-8`), but only if
#   something that actually affects the role has changed since the last release
#
# Determining the version from defaults/main.yml, rather than from the commit
# message of the pull request that got merged, makes the result independent of
# the order in which pull requests get merged, and lets any change to the role
# (bugfix, feature, dependency bump) release itself without a human tagging.

set -euo pipefail

repository_path="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd -- "$repository_path"

defaults_path='defaults/main.yml'

# The placeholder that stands in for the version RSS-Bridge does not publish.
# See the explanation at the top of this file.
unversioned_placeholder='2025.10.7'

# Paths that shape the behavior of the role for its consumers. A commit
# touching only other paths (a README fix, CI configuration, Molecule tests)
# does not change what a playbook run does, and releasing it would only create
# churn in the repositories that consume this role.
role_defining_paths=(
	'defaults'
	'meta'
	'tasks'
	'templates'
)

# Anchored at the start of the line, so that neither a commented-out example
# nor one of the several other variables ending in `_version` (such as
# `rssbridge_container_image_self_build_repo_version`) can be picked up
# instead.
#
# `rssbridge_version` is a literal value. Deriving the tag from a variable
# whose value is a Jinja expression would put that expression into the tag
# itself - a mistake that has produced tags such as `v{{-0` elsewhere in the
# fleet.
version="$(sed -nE 's|^rssbridge_version:[[:space:]]*"?([^"[:space:]]+)"?.*$|\1|p' "$defaults_path" | head -n1)"

if [ -z "$version" ]; then
	echo >&2 "Could not determine the RSS-Bridge version from $defaults_path"
	exit 1
fi

# See the explanation at the top of this file.
if [ "$version" = 'latest' ]; then
	version="$unversioned_placeholder"
fi

# The version value does not carry a leading `v`, but the tags do. Stripping
# any `v` before prepending one keeps this correct even if the version value
# ever starts carrying one.
tag_prefix="v${version#v}-"

# Of all releases of this version, the highest release number. Sorted
# numerically, so that -10 is recognized as newer than -9.
last_release="$(git tag --list "${tag_prefix}*" | sed -e "s|^${tag_prefix}||" | grep -E '^[0-9]+$' | sort -n | tail -n1 || true)"

if [ -z "$last_release" ]; then
	echo >&2 "Version $version has never been released"
	echo "${tag_prefix}0"
	exit 0
fi

previous_tag="${tag_prefix}${last_release}"

if git diff --quiet "$previous_tag" HEAD -- "${role_defining_paths[@]}"; then
	echo >&2 "Nothing affecting the role has changed since $previous_tag"
	exit 0
fi

echo >&2 "The role has changed since $previous_tag"
echo "${tag_prefix}$((last_release + 1))"
