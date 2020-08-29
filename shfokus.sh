#!/bin/bash
#
# @author Rio Astamal <rio@rioastamal.net>
# @desc shFokus is Bash script to make you focus and stay productive by
#       blocking distracting websites suchs Facebook, Youtube etc.
# @url https://github.com/rioastamal/shfokus

readonly FOKUS_SCRIPT_NAME=$(basename $0)

FOKUS_VERSION="2020-08-27"
FOKUS_DRY_RUN="no"
FOKUS_MINUTES="0"

[[ -z "$FOKUS_FILE" ]] && FOKUS_FILE="~/.shfokus"
[[ -z "$MINUTES" ]] && MINUTES="0"
[[ -z "$HOSTS_FILE" ]] && HOSTS_FILE="/etc/hosts"

shfokus_help()
{
    echo "\
Usage: $0 [OPTIONS]

Where OPTIONS:
  -a ACTION     Specify action name using ACTION.
  -f FILE       List of blocked websites from FILE. Default is ~/.shfokus. Will
                be created if not exists.
  -h            Print this help and exit.
  -r            Dry run mode. Print the content that will be written to hosts
                file.
  -t MINUTES    Specify how long in MINUTES sites should be blocked. Default
                is '0' which means blocked forever. Make sure there is no other
                shfokus instance running.
  -v            Display shFokus version.

List of available ACTION:
  - block    -> block website
  - unblock  -> release block

Example of ~/.shfokus (one website per line):
  youtube.com
  www.youtube.com
  facebook.com
  www.facebook.com

Example 1 - Block distraction websites:

  $ sudo bash ./shfokus.sh -a block

Example 2 - Block distraction websites in 30 minutes:

  $ sudo bash ./shfokus.sh -a block -t 30

Example 3 - Unblock distraction websites.

  $ sudo bash ./shfokus.sh -a unblock

-------------------------------- About shFokus --------------------------------

shFokus is Bash script to make you focus and stay productive by blocking
distracting websites suchs Facebook, Youtube etc.

shFokus is free software licensed under MIT. Visit the project homepage
at https://github.com/rioastamal/shfokus."
}

shfokus_see_help()
{
    echo "Try '$FOKUS_SCRIPT_NAME -h' for more information."
}

shfokus_ctrl_c()
{
    echo -e "\n"
    echo "----- Interupted by CTRL+C -----"
    shfokus_unblock
    exit 0
}

shfokus_block_in_minutes()
{
    # Catch CTRL+C and call unblock function
    trap shfokus_ctrl_c INT

    # convert minutes to seconds
    local SECONDS_LEFT=$(( $FOKUS_MINUTES * 4 ))

    while (( $SECONDS_LEFT >= 0 ))
    do
        # clear line
        echo -ne "\033[K"
        echo -ne "\rBlock will be released in ${SECONDS_LEFT} sec... CTRL+C to unblock"
        sleep 1
        SECONDS_LEFT=$(( $SECONDS_LEFT - 1 ))
    done

    shfokus_unblock
}

shfokus_write_hosts_file()
{
    local MODE="block"
    [[ ! -z "$1" ]] && MODE="$1"

    # Content to write to HOSTS file
    local FOKUS_CONTENT=
    # Used for dry-run mode
    local DRY_RUN_FILE=$HOSTS_FILE

    read -r -d '' FOKUS_CONTENT << EOF
# shfokus_begin - DO NOT TOUCH
$( echo 0.0.0.0 $( <$FOKUS_FILE ) )
# shfokus_end
EOF

    [[ "$FOKUS_DRY_RUN" == "yes" ]] && DRY_RUN_FILE="/dev/stdout"

    [[ ! -w "$HOSTS_FILE" && "$FOKUS_DRY_RUN" != "yes" ]] && {
        echo "Error: Can not write to HOSTS file $DRY_RUN_FILE." >&2
        echo "Make sure it is writeable by running as root." >&2
        exit 403
    }

    # Output the content inside sub-shell because we are
    # reading and writing the same file
    echo "$(
      echo "$( <$HOSTS_FILE )" | \
      sed "/^# shfokus_begin/,/^# shfokus_end/d"
    )" > $DRY_RUN_FILE

    [[ "$MODE" == "unblock" ]] && {
        echo ""
        echo "Distracting websites has been unblocked -- Enjoy your day :)"
        return 0
    }

    # Append our blocked site config at the end of Hosts file
    echo "${FOKUS_CONTENT}" >> $DRY_RUN_FILE
    echo "Stay focus and productive -- Have a great day :)"

    [[ "$FOKUS_MINUTES" != "0" ]] && shfokus_block_in_minutes
}

shfokus_block()
{
    shfokus_write_hosts_file "block"
}

shfokus_unblock()
{
    shfokus_write_hosts_file "unblock"
}

shfokus_init()
{
    # Issue for expanding "~" because treated as string literal
    # Simple hack is replacing "~" with the value of $HOME
    FOKUS_FILE=$( echo "$FOKUS_FILE" | sed "s#~#$HOME#" )

    local FOKUS_DIR="$( dirname $FOKUS_FILE )"
    [[ ! -w "$FOKUS_DIR" ]] && {
        echo "Error: Directory $FOKUS_DIR is not writeable. Make sure it is writeable by running as root." >&2
        exit 403
    }

    # Write shfokus file if it not exists
    [[ ! -f "$FOKUS_FILE" ]] && {
        cat <<EOF > $FOKUS_FILE
www.youtube.com
youtube.com
www.facebook.com
facebook.com
www.instagram.com
instagram.com
EOF
    }

    [[ ! -w "$FOKUS_FILE" ]] && {
        echo "Error: File $FOKUS_FILE is not writeable. Make sure it is writeable by running as root." >&2
        exit 403
    }
}

# Parse the arguments
while getopts a:f:hrt:v FOKUS_OPT;
do
    case $FOKUS_OPT in
        a)
            FOKUS_ACTION="$OPTARG"
        ;;

        f)
            FOKUS_FILE="$OPTARG"
        ;;

        h)
            shfokus_help
            exit 0
        ;;

        r)
            FOKUS_DRY_RUN="yes"
        ;;

        t)
            FOKUS_MINUTES="$OPTARG"
        ;;

        v)
            echo "shFokus version $FOKUS_VERSION"
            exit 0
        ;;

        \?)
            shfokus_see_help
            exit 1
        ;;
    esac
done

shfokus_init

case $FOKUS_ACTION in
    block)
        shfokus_block
    ;;

    unblock)
        shfokus_unblock
    ;;

    *)
        echo -e "Unrecognized action.\n" >&2
        shfokus_see_help
        exit 1
    ;;
esac

exit 0