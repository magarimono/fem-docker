FROM getfemdoc/getfem:stable
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update
RUN apt-get -y -f install
RUN apt-get -y install python3-pip

# install the notebook package
RUN apt-get -y install git wget
RUN apt-get -y install libgl1-mesa-dev
RUN pip3 install PyQt5
RUN apt-get -y install xvfb
RUN pip3 install --no-cache --upgrade pip && \
    pip3 install --no-cache jupyterlab && \
    pip3 install --no-cache pyvista && \
    pip3 install --no-cache pyvirtualdisplay

RUN ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh

RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh \
    && /bin/bash ~/miniconda.sh -b -p /opt/conda \
    && rm ~/miniconda.sh \
    && echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc \
    && echo "conda activate base" >> ~/.bashrc \
    && conda config --set always_yes yes \
    && conda config --add channels conda-forge \
    && conda install --freeze-installed \
        nomkl \
        sfepy=UNKNOWN \
        mayavi \
        scikit-umfpack \
        ipyevents \
        ipywidgets \
        itkwidgets \
        jupyterlab \
        notebook \
        "nodejs>=10.0.0"\
        tini

# create user with a home directory
ARG NB_USER
ARG NB_UID
ENV USER ${NB_USER}
ENV HOME /home/${NB_USER}
ENV PYVISTA_OFF_SCREEN true
ENV PYVISTA_USE_PANEL true
ENV PYVISTA_PLOT_THEME document
# This is needed for Panel - use with cuation!
ENV PYVISTA_AUTO_CLOSE false

RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    ${NB_USER}
WORKDIR ${HOME}
USER root
COPY . ${HOME}
RUN pip3 install -r requirements.txt
RUN chown -R ${NB_USER} ${HOME}
USER ${USER}
