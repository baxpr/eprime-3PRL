#!/usr/bin/env python
#
# Given the name of an E-PRIME .txt output file, parse the filename and upload the file
# to the appropriate EPRIME_TXT resource on XNAT. Specific to the 3PRL task.
#
# Requires a python 3 installation and DAX:
#    https://dax.readthedocs.io/en/latest/installing_dax_in_a_virtual_environment.html
#
#
# How filenames are parsed - bits marked with ^ are extracted.
# 
#    Filename as saved by E-PRIME:   123456_10000_B.txt
#                                    ^ 
#    Matching session on XNAT:       123456
#    Matching scan label on XNAT:    Run1
#
# In some scenarios nothing will be uploaded and a warning will be shown. These situations
# can be handled manually:
#    - A matching scan isn't found on XNAT
#    - More than one matching scan is found on XNAT
#    - One matching scan is found on XNAT, but it already has an EPRIME_TXT resource and
#          the --overwrite option was not specified


import re
import os
import sys
import dax
import argparse

# Parse arguments
parser = argparse.ArgumentParser(description='Upload an E-Prime .txt to XNAT')
parser.add_argument('--eprime_txt', help='E-Prime .txt filename',required=True)
parser.add_argument('--project', help='XNAT project',required=True)
parser.add_argument('--overwrite', help='Force overwrite if existing',default='False')
args = parser.parse_args()

expr = re.compile('^(?P<session>\d{6})_(?P<otherid>\d{5})_(?P<timepoint>.*)\.txt$')

project = args.project
overwrite = args.overwrite
eprime_txt = args.eprime_txt

r = expr.match(os.path.basename(eprime_txt))
if r is None:
    print(f'   WARNING: Could not parse filename. Skipping')
    sys.exit(0)

session = r.group('session')
subject = r.group('session')
scan_prefix = '3PRL_Run1'

# Connect to XNAT and upload
with dax.XnatUtils.get_interface() as xnat:
    
    # Get list of scans in this session
    scans = xnat.get_scans(project,session,subject)

    # Find scan(s) where scan_prefix matches scans['scan_type']
    match = [x for x in scans if x['scan_type']==scan_prefix and x['quality']!='unusable']
    
    # Only proceed if exactly one match is found
    if len(match) == 0:
        print(f'   WARNING: No matching scan. Skipping')
        sys.exit(0)
    elif len(match) > 1:
        print(f'   WARNING: Multiple matching scans found. Skipping')
        sys.exit(0)
    else:
        match = match[0]
        print('   Found single scan %s matching \'%s\'' % (match['scan_id'],scan_prefix))
        
    # If scan has resource warn and skip upload unless overwrite
    rsrc = xnat.select_scan_resource(project,session,subject,match['scan_id'],'EPRIME_TXT')
    if rsrc.exists() and not (overwrite.lower()=='true'):
        print(f'   WARNING: EPRIME_TXT resource already exists on XNAT, skipping')
        sys.exit(0)
    else:
        if not rsrc.exists():
            rsrc.create()
        rsrc.put([eprime_txt],overwrite=True)
        print(f'   Uploaded')

