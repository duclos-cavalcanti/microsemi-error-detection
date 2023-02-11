#!/bin/bash

usage() {
    local header="$1"
    [[ -n "$header" ]] && printf "${header}\n"
    printf "
      NAME: run.sh

      USAGE: ./run.sh [ARGS]

      ARGS:
      \n"
    exit 1
}

main() {
    if [[ $# -ne 0 ]]; then
        while [[ $# -gt 0 ]]; do
           case $1 in
                unit)
                    for f in $(ls test/tb*.py); do
                        python3 ${f}
                    done
                    shift
                    ;;

                test)
                    python3 main.py --mode test
                    shift
                    ;;

                debug)
                    python3 main.py --mode debug
                    shift
                    ;;

                demo)
                    python3 main.py
                    shift
                    ;;

                *)
                    shift
                    ;;
           esac
        done
    else
        usage "ERROR: No arguments passed!"
    fi
}

main $@
