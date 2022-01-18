#!/usr/bin/env bash
#
# Copy tapas v5.1.2 source code here so we have a snapshot to use for compiling the matlab
# executable

wget https://github.com/translationalneuromodeling/tapas/archive/refs/tags/v5.1.2.tar.gz
tar -zxf v5.1.2.tar.gz
rm v5.1.2.tar.gz

# Fix a typo in the PhysIO code that blocks compilation
cp -f tapas_physio_sort_images_by_cardiac_phase.m.fixed \
    tapas-5.1.2/PhysIO/code/assess/tapas_physio_sort_images_by_cardiac_phase.m

# Remove example code that also has syntax errors
rm -r tapas-5.1.2/h2gf/example
