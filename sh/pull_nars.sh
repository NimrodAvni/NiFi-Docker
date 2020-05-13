#!/usr/bin/env bash
if ! ( [ -z ${NAR_GIT_REPO} ] || [ -z ${NAR_GIT_USER} ] || [ -z ${NAR_GIT_TOKEN} ] ); then
    git_branch=${NAR_GIT_BRANCH:-"master"}
    nar_directory=${NAR_GIT_DIRECTORY:-${NIFI_HOME}"/lib2"}
    repo=$(echo $NAR_GIT_REPO | sed -re "s|(https?://)|\1${NAR_GIT_USER}:${NAR_GIT_TOKEN}@|")
    `git clone ${repo} -b ${git_branch} ${nar_directory}`
fi