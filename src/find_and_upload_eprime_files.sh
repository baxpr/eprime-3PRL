#!/usr/bin/env bash
#
# Given a directory, search it and all its subdirectories for EPrime txt files:
#    <mrid>_<subjid>_<timepoint>.txt
# e.g.
#    123456_10000_B.txt
#
# For each file found, call the upload_single_gf_eprime_to_xnat.py python script
# to upload it to the EPRIME_TXT resource of the correct subject, session, scan
# on XNAT based on the filename. By default, upload will be skipped if the resource
# already exists on XNAT.
#
# This must be run in a python environment where DAX is installed:
# https://dax.readthedocs.io/en/latest/installing_dax_in_a_virtual_environment.html
#
# Usage:
#
#    find_and_upload_eprime_files.sh --project <XNAT_project> --dir <directory>
#
# Optionally, to limit the file search to the past N days, use
#        --days N
#
# Optionally, to overwrite existing resources, use
#        --overwrite True
#
#
# The --project option defaults to WISEUP if not specified. The --dir option 
# is required.
#
# This bash script looks for the python script in the path, then in the directory 
# it's run from. Easiest may be to run this script from the directory where both of 
# these files exist:
#    This one                 find_and_upload_eprime_files.sh
#    Python upload script     upload_single_gf_eprime_to_xnat.py


# Defaults
project=WISEUP
overwrite=False
dir=
days=all

# Parse inputs
while [[ $# -gt 0 ]]
do
	key="$1"
	case $key in
		--project)
			project="$2"; shift; shift ;;
		--dir)
			dir="$2"; shift; shift ;;
		--overwrite)
			overwrite="$2"; shift; shift ;;
		--days)
			days="$2"; shift; shift ;;
		*)
			echo "Ignoring unknown input ${1}"; shift ;;
	esac
done

# If we don't have a valid dir, fail
if [[ -z "${dir}" ]]; then
	echo "No --dir specified"
	exit 1
fi
if [[ ! -d "${dir}" ]]; then
	echo "Specified directory ${dir} not found"
	exit 1
fi

# If we can't find the python script, fail
upload_cmd=upload_single_3prl_eprime_to_xnat.py
w=$(which "${upload_cmd}")
if [[ -z "${w}" ]]; then
	upload_cmd=./upload_single_3prl_eprime_to_xnat.py
fi
w=$(which "${upload_cmd}")
if [[ -z "${w}" ]]; then
	echo "Cannot find upload_single_gf_eprime_to_xnat.py"
	exit 1
fi

# Info
echo "Uploading from ${dir} to ${project}"

# Create days option
if [[ "${days}" == "all" ]]; then
	daybit=""
else
	daybit="-mtime -$days"
fi

# Find all relevant .txt files in dir and upload each one
# https://stackoverflow.com/a/8677566
while IFS= read -r -d $'\0' file; do
	echo Checking $file
	"${upload_cmd}" --eprime_txt "${file}" --project "${project}" --overwrite "${overwrite}"
done < <(find "${dir}" ${daybit} \( -name ??????_?????_?.txt \) -print0)

echo Done.
