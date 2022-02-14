FROM ubuntu:20.04

RUN apt-get -y update && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install wget unzip xvfb openjdk-8-jre python3-pip && \
    apt-get clean

RUN pip3 install pandas
        
# Install the MCR
RUN wget -nv https://ssd.mathworks.com/supportfiles/downloads/R2019b/Release/6/deployment_files/installer/complete/glnxa64/MATLAB_Runtime_R2019b_Update_6_glnxa64.zip \
     -O /opt/mcr_installer.zip && \
     unzip /opt/mcr_installer.zip -d /opt/mcr_installer && \
    /opt/mcr_installer/install -mode silent -agreeToLicense yes && \
    rm -r /opt/mcr_installer /opt/mcr_installer.zip

# Copy the pipeline code
COPY matlab /opt/eprime-3PRL/matlab
COPY src /opt/eprime-3PRL/src
COPY README.md /opt/eprime-3PRL/README.md

# Matlab env
ENV MATLAB_SHELL=/bin/bash
ENV MATLAB_RUNTIME=/usr/local/MATLAB/MATLAB_Runtime/v97

# Add pipeline to system path
ENV PATH /opt/eprime-3PRL/src:/opt/eprime-3PRL/matlab/bin:${PATH}

# Matlab executable must be run now to extract the CTF archive
RUN run_matlab_entrypoint.sh ${MATLAB_RUNTIME} quit

# Entrypoint
ENTRYPOINT ["pipeline_entrypoint.sh"]
