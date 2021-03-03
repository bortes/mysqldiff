#!/bin/bash

extract_arguments()
{
    if [ -f .env ]; then
        export $(cat .env | grep ^MYSQLDIFF_ | xargs)
    fi

    LEFT_HOSTNAME="${MYSQLDIFF_LEFT_HOSTNAME}"
    LEFT_USERNAME="${MYSQLDIFF_LEFT_USERNAME}"
    LEFT_PASSWORD="${MYSQLDIFF_LEFT_PASSWORD}"
    LEFT_DATABASE="${MYSQLDIFF_LEFT_DATABASE}"

    RIGHT_HOSTNAME="${MYSQLDIFF_RIGHT_HOSTNAME}"
    RIGHT_USERNAME="${MYSQLDIFF_RIGHT_USERNAME}"
    RIGHT_PASSWORD="${MYSQLDIFF_RIGHT_PASSWORD}"
    RIGHT_DATABASE="${MYSQLDIFF_RIGHT_DATABASE}"

    while [ -n "$1" ]; do
        if [[ "$1" =~ "=" ]]; then
            key="${1%%=*}"
            value="${1##*=}"
        else
            key="${1}"
            value="${2}"
            shift
        fi
        shift

        case "$key" in
            --left-database)
                LEFT_DATABASE="${value}"
                ;;
            --left-hostname)
                LEFT_HOSTNAME="${value}"
                ;;
            --left-password)
                LEFT_PASSWORD="${value}"
                ;;
            --left-user)
                LEFT_USERNAME="${value}"
                ;;
            --right-database)
                RIGHT_DATABASE="${value}"
                ;;
            --right-hostname)
                RIGHT_HOSTNAME="${value}"
                ;;
            --right-password)
                RIGHT_PASSWORD="${value}"
                ;;
            --right-user)
                RIGHT_USERNAME="${value}"
                ;;
        esac
    done

    if [ -z "$LEFT_HOSTNAME" ] | [ -z "$LEFT_USERNAME" ] | [ -z "$LEFT_DATABASE" ]; then
        show_helper
    fi

    if [ -z "$RIGHT_HOSTNAME" ] | [ -z "$RIGHT_USERNAME" ] | [ -z "$RIGHT_DATABASE" ]; then
        show_helper
    fi

    if [ -z "$LEFT_PASSWORD" ]; then
        read -p "Left database password: " LEFT_PASSWORD
    fi

    if [ -z "$RIGHT_PASSWORD" ]; then
        read -p "Right database password: " RIGHT_PASSWORD
    fi
}

show_helper()
{
   echo
   echo "Usage:"
   echo "  mysqldiff.sh --left-hostname <LEFT_HOSTNAME> --left-user <LEFT_USERNAME> --left-password <LEFT_PASSWORD> --left-database <LEFT_DATABASE> --right-hostname <RIGHT_HOSTNAME> --right-user <RIGHT_USERNAME> --right-password <RIGHT_PASSWORD> --right-database <RIGHT_DATABASE>"
   echo
   echo "Arguments:"
   echo "  --left-database   LEFT DB name"
   echo "  --left-hostname   LEFT DB hostname"
   echo "  --left-password   LEFT DB user password"
   echo "  --left-user       LEFT DB username"
   echo "  --right-database  RIGHT DB name"
   echo "  --right-hostname  RIGHT DB hostname"
   echo "  --right-password  RIGHT DB user password"
   echo "  --right-user      RIGHT DB username"
   echo
   echo "  All arguments can be setting by define a enviroment variable with argument name prefixed by \"MYSQLDIFF_\"."
   echo "  For example a variable named MYSQLDIFF_RIGHT_HOSTNAME will define the \"--right-hostname\" arguments."
   echo

   exit 1
}

logger()
{
    message="$1"
    context="$2"

    if [ ! -z "$context" ]; then
        message="$context : $message"
    fi

    echo "$(date --iso-8601=seconds) [INFO] $message"
}

dump_database()
{
    context="$1"
    hostname="$2"
    username="$3"
    password="$4"
    database="$5"

    rm -rf "output/$context"
    mkdir -p "output/$context/$database"
 
    filename="output/$context/$database/dump.sql"

    logger "dumping database from $hostname." $context

    logger "saving database $database." $context

    MYSQL_PWD=$password mysqldump --host "$hostname" --user "$username" --compact --skip-create-options --no-create-db --no-data --databases "$database" | grep --invert-match "40101 SET " | grep --invert-match "^USE " > "$filename"
}

dump_tables()
{
    context="$1"
    hostname="$2"
    username="$3"
    password="$4"
    database="$5"

    rm -rf "output/$context"
    mkdir -p "output/$context/$database"
 
    logger "dumping database from $hostname." $context

    logger "getting tables." $context

    tables=$(MYSQL_PWD=$password mysql --host "$hostname" --user "$username" --database "$database" --skip-column-names --silent --execute "SHOW TABLES;")

    total=$(echo "${tables}" | wc --lines)

    logger "found $total tables." $context

    for table in $tables; do
        filename="output/$context/$database/dump.$table.sql"

        logger "saving table $table." $context

        MYSQL_PWD=$password mysqldump --host "$hostname" --user "$username" --compact --skip-create-options --no-create-db --no-data --databases "$database" --tables "$table" | grep --invert-match "40101 SET " | grep --invert-match "^USE " > "$filename"
    done 
}

diff_dumps()
{
    logger "Comparing left and right databases."
    
    diff --color=always --unified=2 output/left/*/ output/right/*/
}

extract_arguments "$@"

dump_tables "left" "$LEFT_HOSTNAME" "$LEFT_USERNAME" "$LEFT_PASSWORD" "$LEFT_DATABASE"

dump_tables "right" "$RIGHT_HOSTNAME" "$RIGHT_USERNAME" "$RIGHT_PASSWORD" "$RIGHT_DATABASE"

diff_dumps
