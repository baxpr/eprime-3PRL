# E-Prime record parsing for 3PRL task

Study-specific parsing of E-Prime logs for a multi-armed bandit / reinforcement learning task 
consisting of 4 fMRI runs. Uses a hierarchical gaussian filter model of the learning process:

Frässle, S., et al. (2021). 
TAPAS: An Open-Source Software Package for Translational Neuromodeling and Computational Psychiatry. 
Frontiers in Psychiatry, 12:680811. 

https://doi.org/10.3389/fpsyt.2021.680811

https://github.com/translationalneuromodeling/tapas

## Basic usage

    pipeline_entrypoint.sh --eprime_txt <file.txt>

## Inputs

    --eprime_txt      Raw text log file from E-Prime
    --fmri_dcm        DICOM from the fMRI series, used to cross-check timestamps
    --timeoverride    Set to 1 to proceed even if timestamp check fails
    --out_dir         Where outputs will be stored

## Outputs

    eprime.csv           E-Prime log converted to CSV format
    trial_report.csv     Trial by trial report of responses, timing, model params
    full_summary.csv     Summary statistics and fitted model params
    hgf_results.mat	     Matlab format data structures from model fits
    report.pdf           Overview PDF for QA

