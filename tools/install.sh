#/bin/bash

# This script should be run via curl:
#   sh -c "${curl -fsSL }"
set -e

# Default settings
GIT_OCTOPUS=${GIT_OCTOPUS:-~/.git-octopus}
REPO=${REPO:-julum/git-octopus}
REMOTE=${REMOTE:-https://github.com/${REPO}.git}
BRANCH=${BRANCH:-master}
RC_FILE=${RC_FILE:-~/.zshrc}

command_exists() {
	command -v "$@" >/dev/null 2>&1
}


error() {
	echo ${RED}"Error: $@"${RESET} >&2
}

setup_color() {
    # Only use colors if connected to a terminal
	if [ -t 1 ]; then
		RED=$(printf '\033[31m')
		GREEN=$(printf '\033[32m')
		YELLOW=$(printf '\033[33m')
		BLUE=$(printf '\033[34m')
		BOLD=$(printf '\033[1m')
		RESET=$(printf '\033[m')
	else
		RED=""
		GREEN=""
		YELLOW=""
		BLUE=""
		BOLD=""
		RESET=""
	fi
}

check_installation() {

    if [ -d "${GIT_OCTOPUS}" ]; then
        echo 1
    else
        echo 0
    fi

}

setup_gitoctopus() {
    echo "${BLUE}Cloning git-octopus...${RESET}"

    command_exists git || {
		error "git is not installed"
		exit 1
	}

    git clone \
        --depth=1 --branch "${BRANCH}" "${REMOTE}" "${GIT_OCTOPUS}" || {
        error "git clone of git-octopus repo failed"
        exit 1

    }

    echo
}

install_git_octopus() {

    echo "${BLUE}Looking for your Shell rc-File...${RESET}"

    echo "${YELLOW} Appending source ~/.git-octopus/git-octopus.sh to ${RC_FILE}${RESET}"
    echo "source ~/.git-octopus/git-octopus.sh" >> ${RC_FILE}

}

update_gitoctopus() {
    echo "Git Octopus is already installed. Please update it with "
    echo "  ${GREEN}git-octopus update${RESET}"
}


main() {

    # Parse Arguments
    while [ $# -gt 0 ]; do
        case $1 in
          --rc-file=*)
              RC_FILE="${1#*=}"
              ;;
        esac
        shift
    done

    setup_color
    INSTALLED=$(check_installation)
    if [[ $INSTALLED -eq 0 ]]; then
        setup_gitoctopus
        install_git_octopus

        printf "$GREEN"
    cat <<-'EOF'
        git-octopus successfully installed!

        Update all your repos instantly <3

	EOF
        printf "${RESET}"
    else
        update_gitoctopus
    fi
}

main "$@"
