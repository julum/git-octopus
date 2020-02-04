#/bin/bash
DIR="$(dirname $0)"
called_in_dir="$(pwd)"

source "${DIR}/tools/setup_color.sh"

__usage() {
  echo "Welcome to the git octopus! This script updates all git repositories \
inside the current directory!"
  echo "For every subdirectory (not recursive) which is a git repository it performs the \
'git fetch' and 'git merge --ff-only' operations."
  echo "If no Fast-Forward Merge is possible, it does not merge."
  echo ""
  echo "Possible commands:"
  echo ""
  echo "  branches"
  echo "    Lists the current checked out branches of the subdirectories"
  echo ""
  echo ""
}

__is_git_repo() {
  local dir="$1"
  if [ -d "${dir}/.git" ]; then
    echo "1"
  else
    echo "0"
  fi
}

__print_repo() {
  local DIR="$1"
  echo ${YELLOW}"========================="
  echo "${DIR}"
  echo "==========================${RESET}"
  echo ""
}

__update_repo() {
  local dir="$1"
  local branch="$(git rev-parse --abbrev-ref HEAD)"
  sleep 1
  __print_repo "${dir}"
  echo "Current branch is ${GREEN}${branch}${RESET}"
  echo "> git fetch --all --force --prune --progress"
  git fetch --all --force --prune --progress --verbose
  echo "> git merge --ff-only"
  git merge --ff-only

  echo "Done."
}

__list_branches() {
    local dir="$1"
    local current_branch=$(git branch | grep \* | cut -d ' ' -f2)
    local COL="${GREEN}"

    if [ ! "${current_branch}" = "master" ]; then
        COL="${YELLOW}"
    fi

    echo "${dir} ➜ ${COL}${current_branch}${RESET}"
}

__checkout_master() {
    local dir="$1"
    __print_repo "${dir}"
    git checkout master && git merge origin/master --ff-only
    return $?
}


git-octopus() {
    setup_color

    local CMD="__update_repo"
    local TARGETDIRS="*"
    local PATTERN=""
    if [[ "$1" = "-h" || "$1" = "--help" ]]; then
        __usage
        return
    fi

    # Parse Arguments
    while [ $# -gt 0 ]; do
        case $1 in
                branches)
                    CMD="__list_branches"
                    ;;
                checkout-master)
                    CMD="__checkout_master"
                    ;;
                *)
                    PATTERN=$1
                    ;;
        esac
        shift
    done

    if [ "$1" = "branches" ]; then
        CMD="__list_branches"
        shift
    fi

    if [ "$1" = "checkout-master" ]; then
        CMD="__checkout_master"
        shift
    fi

    if [ $# -gt 0 ]; then
        PATTERN=$1
        shift
    fi

    if [ "$CMD" = "__update_repo" ]; then
        echo "${YELLOW}Updating Git repositories...${RESET}"
        echo ""
        echo "WARNING: Only merges fast forward merges. Only possible remote is origin"
    fi
    OUT=""

    for subdir in *; do
        if [[ $subdir == *"$PATTERN"*  ]]; then
            if [ -d "$subdir" ]; then
                is_repo=$(__is_git_repo "${subdir}")

                if [ "$is_repo" = "1" ]; then
                    cd ${subdir}
                    eval $CMD "${subdir}"
                    if [[ $? -ne 0 ]]; then
                        OUT="${OUT}${RED}${BOLD}X ${RESET}${RED}${subdir}${RESET}\n"
                    else
                        OUT="${OUT}${GREEN}\342\234\224 ${subdir}${RESET}\n"
                    fi
                    cd ${called_in_dir}
                    echo ""
                fi
        fi
    fi
  done
  echo
  echo
  echo "Summary:"
  printf "$OUT" | iconv -f UTF-8

  }
