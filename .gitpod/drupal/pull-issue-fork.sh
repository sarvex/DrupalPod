#!/usr/bin/env bash
if [ -n "$DEBUG_DRUPALPOD" ]; then
    set -x
fi

# Check if workspace already initiated, to avoid overriding existing work in progress
if [ ! -f /workspace/drupalpod_initiated.status ]; then
    # Add git.drupal.org to known_hosts
    mkdir -p ~/.ssh
    host=git.drupal.org
    SSHKey=$(ssh-keyscan $host 2> /dev/null)
    echo "$SSHKey" >> ~/.ssh/known_hosts

    # Default settings (latest stable Drupal core)
    if [ -z "$DP_PROJECT_TYPE" ]; then
        DP_PROJECT_TYPE=project_core
    fi

    if [ -z "$DP_PROJECT_NAME" ]; then
        DP_PROJECT_NAME=drupal
    fi

    DEFAULT_CORE_VERSION="^9.2"
    if [ -z "$DP_CORE_VERSION" ]; then
        DP_CORE_VERSION=$DEFAULT_CORE_VERSION
    fi

    # Set WORK_DIR
    if [ "$DP_PROJECT_TYPE" == "project_core" ]; then
        BASE_PROJECT_DIR=web/core
        WORK_DIR="${GITPOD_REPO_ROOT}"/"$BASE_PROJECT_DIR"
    elif [ "$DP_PROJECT_TYPE" == "project_module" ]; then
        BASE_PROJECT_DIR=web/modules/contrib
        WORK_DIR="${GITPOD_REPO_ROOT}"/"$BASE_PROJECT_DIR"
    elif [ "$DP_PROJECT_TYPE" == "project_theme" ]; then
        BASE_PROJECT_DIR=web/themes/contrib
        WORK_DIR="${GITPOD_REPO_ROOT}"/"$BASE_PROJECT_DIR"
    fi

    # Require project
    if [ "$DP_CORE_VERSION" != "$DEFAULT_CORE_VERSION" ]; then
        rm composer.lock
    fi
    if [ "$DP_PROJECT_TYPE" == "project_core" ]; then
        composer require drupal/core:"$DP_CORE_VERSION"
    else
        composer require drupal/core:"$DP_CORE_VERSION" drupal/"$DP_PROJECT_NAME"
    fi

    # Dynamically generate .gitmodules file
    RELATIVE_WORK_DIR=$BASE_PROJECT_DIR/$DP_PROJECT_NAME
cat <<GITMODULESEND > .gitmodules
# This file was dynamically generated by a script
[submodule "Drupal"]
    path = web/core
    url = https://git.drupalcode.org/project/drupal.git
    ignore = dirty
GITMODULESEND
# Add another project, if this is not core
if [ "$DP_PROJECT_TYPE" != "project_core" ]; then
    {
    echo "[submodule \"$DP_PROJECT_NAME\"]"
    echo "path = $RELATIVE_WORK_DIR"
    echo "url = https://git.drupalcode.org/project/$DP_PROJECT_NAME.git"
    echo "ignore = dirty"
    } >> .gitmodules
fi

    if [ "$DP_PROJECT_TYPE" == "project_core" ]; then
        WORK_DIR="${GITPOD_REPO_ROOT}"/web/core
    else
        WORK_DIR="${GITPOD_REPO_ROOT}"/$RELATIVE_WORK_DIR
    fi

    # Checkout specific branch only if there's issue_fork
    if [ -n "$DP_ISSUE_FORK" ]; then
        # If branch already exist only run checkout,
        if cd "${WORK_DIR}" && git show-ref -q --heads "$DP_ISSUE_BRANCH"; then
            cd "${WORK_DIR}" && git checkout "$DP_ISSUE_BRANCH"
        else
            cd "${WORK_DIR}" && git remote add "$DP_ISSUE_FORK" https://git.drupalcode.org/issue/"$DP_ISSUE_FORK".git
            cd "${WORK_DIR}" && git fetch "$DP_ISSUE_FORK"
            cd "${WORK_DIR}" && git checkout -b "$DP_ISSUE_BRANCH" --track "$DP_ISSUE_FORK"/"$DP_ISSUE_BRANCH"
        fi
    fi

    if [ -n "$DP_PATCH_FILE" ]; then
        echo Applying selected patch "$DP_PATCH_FILE"
        cd "${WORK_DIR}" && curl "$DP_PATCH_FILE" | patch -p1
    fi

    # Save a file to mark workspace already initiated
    touch /workspace/drupalpod_initiated.status

    # Run site install using a Drupal profile if one was defined
    if [ -n "$DP_INSTALL_PROFILE" ] && [ "$DP_INSTALL_PROFILE" != "''" ]; then
        ddev drush si -y --account-pass=admin --site-name='drupalpod' "$DP_INSTALL_PROFILE"
        # Enable the module
        if [ "$DP_PROJECT_TYPE" != "project_core" ]; then
            ddev drush en -y "$DP_PROJECT_NAME"
        fi
    fi
fi

# Everyting is ready, now start ddev
ddev start

#Open preview browser
gp preview "$(gp url 8080)"
