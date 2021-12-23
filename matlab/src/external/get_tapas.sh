#!/usr/bin/env bash
#
# Copy tapas v5.1.2 source code here so we have a snapshot to use for compiling the matlab
# executable

wget https://github.com/translationalneuromodeling/tapas/archive/refs/tags/v5.1.2.tar.gz
tar -zxf v5.1.2.tar.gz
rm v5.1.2.tar.gz
