#!/usr/bin/env bash
set -euo pipefail

# Usage: bootstrap.sh [-u USER] [--no-ask-pass]
# Defaults to the account you’re logged in as.
USER_ARG="$(id -un)"
ASK_PASS="-K"

while [[ $# -gt 0 ]]; do
  case "$1" in
    -u|--user)
      USER_ARG="$2"
      shift 2
      ;;
    --no-ask-pass)
      ASK_PASS=""
      shift
      ;;
    -h|--help)
      echo "Usage: $0 [-u USER] [--no-ask-pass]"
      exit 0
      ;;
    *)
      echo "Unknown arg: $1" >&2
      exit 2
      ;;
  esac
done

# cd to this script’s directory (the ansible folder)
cd "$(dirname "$0")"

# sanity checks
if ! command -v ansible-playbook >/dev/null 2>&1; then
  echo "ansible-playbook not found. Try: sudo apt install ansible" >&2
  exit 1
fi

echo ">> Running Ansible for user: ${USER_ARG}"

# If ASK_PASS is empty, this expands to nothing; if not, it passes -K
ansible-playbook -i hosts.ini site.yml \
  -e "sway_user=${USER_ARG}" \
  ${ASK_PASS}





# #!/usr/bin/env bash
# set -euo pipefail
# 
# # Usage: bootstrap.sh [-u USER] [--no-ask-pass]
# # Defaults to the account you’re logged in as.
# USER_ARG="$(id -un)"
# ASK_PASS="-K"
# 
# while [[ $# -gt 0 ]]; do
#   case "$1" in
#     -u|--user) USER_ARG="$2"; shift 2 ;;
#     --no-ask-pass) ASK_PASS=""; shift ;;
#     -h|--help)
#       echo "Usage: $0 [-u USER] [--no-ask-pass]"
#       exit 0
#       ;;
#     *) echo "Unknown arg: $1" >&2; exit 2 ;;
#   esac
# done
# 
# # cd to this script’s directory (the ansible folder)
# cd "$(dirname "$0")"
# 
# # sanity checks
# command -v ansible-playbook >/dev/null || {
#   echo "ansible-playbook not found. Try: sudo apt install ansible" >&2
#   exit 1
# }
# 
# # Run the play
# echo ">> Running Ansible for user: ${USER_ARG}"
# # ansible-playbook ${ASK_PASS} playbooks/debian_unstable.yml -e "sway_user=${USER_ARG}"
# # ansible-playbook ${ASK_PASS} playbooks/sway.yml -e "sway_user=${USER_ARG}"
# #
# #
# #ansible-playbook -i hosts.ini site.yml -e "sway_user=${USER_ARG}" -e "sway_session_path=/usr/local/bin/sway-session" ${ASK_PASS}
# ansible-playbook -i hosts.ini site.yml -e "sway_user=${USER_ARG}" -e "sway_session_path=/usr/local/bin/sway-session" ${ASK_PASS}
# 
# 
# 
