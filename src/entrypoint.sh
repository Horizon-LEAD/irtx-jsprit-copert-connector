#!/bin/bash

#Set fonts
NORM=`tput sgr0`
BOLD=`tput bold`
REV=`tput smso`

CURDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

function show_usage () {
    echo -e "${BOLD}Basic usage:${NORM} entrypoint.sh [-vh] FIN_CONF FIN_SCENARIO FIN_SOLUTION YEAR OUT_PATH"
}

function show_help () {
    echo -e "${BOLD}entrypoint.sh${NORM}: Runs the jsprit-2-copert model"\\n
    show_usage
    echo -e "\n${BOLD}Required arguments:${NORM}"
    echo -e "${REV}CONF_FILE${NORM}\t the configuration json file"
    echo -e "${REV}SCENARIO${NORM} \t the jsprit scenario file"
    echo -e "${REV}SOLUTION${NORM} \t the jsprit solution file"
    echo -e "${REV}YEAR${NORM}     \t the year to be used"
    echo -e "${REV}OUT_PATH${NORM} \t the output path"
    echo -e "${BOLD}Optional arguments:${NORM}"
    echo -e "${REV}-v${NORM}\tSets verbosity level"
    echo -e "${REV}-h${NORM}\tShows this message"
    echo -e "${BOLD}Examples:${NORM}"
    echo -e "entrypoint.sh -v configuration.json scenario.json solution.json 2022 ./output/"
}

##############################################################################
# GETOPTS                                                                    #
##############################################################################
# A POSIX variable
# Reset in case getopts has been used previously in the shell.
OPTIND=1

# Initialize vars:
verbose=0

# while getopts
while getopts 'hv' OPTION; do
    case "$OPTION" in
        h)
            show_help
            exit 1
            ;;
        v)
            verbose=1
            ;;
        ?)
            show_usage >&2
            exit 1
            ;;
    esac
done

shift "$(($OPTIND -1))"

leftovers=(${@})
CONF_FILE=${leftovers[0]}
SCENARIO=${leftovers[1]}
SOLUTION=${leftovers[2]}
YEAR=${leftovers[3]}
OUT_PATH=${leftovers[4]}

##############################################################################
# Input checks                                                               #
##############################################################################
if [ ! -f "${CONF_FILE}" ]; then
    echo -e "Give a ${BOLD}valid${NORM} path to the conversion configuration file\n${CONF_FILE}";
    show_usage;
    exit 1;
fi
if [ ! -f "${SCENARIO}" ]; then
    echo -e "Give a ${BOLD}valid${NORM} Path to the JSprit scenario definition file\n${SCENARIO}";
    show_usage;
    exit 1
fi
if [ ! -f "${SOLUTION}" ]; then
    echo -e "Give a ${BOLD}valid${NORM} Path to the JSprit solution file\n${SOLUTION}";
    show_usage;
    exit 1
fi

if [ ! -d "${OUT_PATH}" ]; then
    echo -e "Give a ${BOLD}valid${NORM} output directory\n${OUT_PATH}";
    show_usage;
    exit 1;
fi

##############################################################################
# Execution                                                                  #
##############################################################################
[ $verbose -eq 1 ] && echo "Starting model execution"

papermill ${CURDIR}/Convert.ipynb /dev/null \
  -pconfiguration_path ${CONF_FILE} \
  -pscenario_path ${SCENARIO} \
  -psolution_path ${SOLUTION} \
  -pyear ${YEAR} \
  -poutput_path ${OUT_PATH}
