# ===============================================================
# https://hub.docker.com/r/iamteacher/rails-start.media/tags
# ===============================================================
# 
# Rails Start (https://github.com/the-teacher/rails-start)
# Media Layer Image

# Ruby version to use
ARG RUBY_VERSION=3.4.6-bookworm

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# Software versions
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

# SEE: image_optim && image_optim_pack
# https://github.com/toy/image_optim
# https://github.com/toy/image_optim_pack/blob/main/Makefile
# https://github.com/toy/image_optim_pack/blob/main/Dockerfile

# https://github.com/shssoichiro/oxipng/releases
ARG OXIPNG_VERSION=9.1.5
# https://www.ijg.org/files
ARG JPEG_VERSION=9f
# https://github.com/mozilla/mozjpeg/releases
ARG MOZJPEG_VERSION=4.1.1
# https://github.com/danielgtaylor/jpeg-archive/releases
ARG JPEGARCHIVE_VERSION=2.2.0
# http://www.jonof.id.au/kenutils
ARG PNGOUT_VERSION=20200115
# https://github.com/amadvance/advancecomp/releases
ARG ADVANCECOMP_VERSION=2.6
# https://github.com/tjko/jpegoptim/releases
ARG JPEGOPTIM_VERSION=1.5.5
# https://developers.google.com/speed/webp/download
ARG WEBP_VERSION=1.6.0
# https://github.com/ImageMagick/ImageMagick/releases
ARG IMAGEMAGICK_VERSION=7.1.2-3
# https://www.lcdf.org/gifsicle/
ARG GIFSICLE_VERSION=1.96
# https://www.sentex.net/~mwandel/jhead/
ARG JHEAD_VERSION=3.04
# https://optipng.sourceforge.net/
# ARG OPTIPNG_VERSION=0.7.8
ARG OPTIPNG_VERSION=7.9.1
# https://pmt.sourceforge.net/pngcrush/
ARG PNGCRUSH_VERSION=1.8.13

# https://pngquant.org/releases.html
# https://raw.githubusercontent.com/kornelski/pngquant/main/CHANGELOG
# ARG PNGQUANT_VERSION=2.18.0

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# STAGE | BASE DEBIAN
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
FROM --platform=$BUILDPLATFORM ruby:${RUBY_VERSION} AS base_debian
RUN apt-get update && apt-get install -y build-essential cmake nasm bash findutils

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# STAGE | BASE RUST
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
FROM --platform=$BUILDPLATFORM rust:1 AS base_rust
RUN apt-get update && apt-get install -y build-essential

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# STAGE | OXIPNG
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
FROM base_rust AS oxipng

# amd 64 ? <jemalloc>: MADV_DONTNEED does not work (memset will be used instead)
# amd 64 ? <jemalloc>: (This is the expected behaviour if you are running under QEMU)
ARG OXIPNG_VERSION

RUN wget -O oxipng-${OXIPNG_VERSION}.tar.gz https://github.com/shssoichiro/oxipng/archive/refs/tags/v${OXIPNG_VERSION}.tar.gz
RUN tar -xvzf oxipng-${OXIPNG_VERSION}.tar.gz
WORKDIR /oxipng-${OXIPNG_VERSION}
RUN cargo build --release; exit 0
RUN cargo build --release
RUN install -c target/release/oxipng /usr/local/bin

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# STAGE | JPEGTRAN
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
FROM base_debian AS libjpeg

ARG JPEG_VERSION

RUN wget -O jpegsrc.v${JPEG_VERSION}.tar.gz https://www.ijg.org/files/jpegsrc.v${JPEG_VERSION}.tar.gz
RUN tar -xvzf jpegsrc.v${JPEG_VERSION}.tar.gz
RUN cd jpeg-${JPEG_VERSION} && \
    ./configure && \
    make install

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# STAGE | LIB MOZ JPEG (common)
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
FROM base_debian AS libmozjpeg

ARG MOZJPEG_VERSION

RUN wget -O mozjpeg-${MOZJPEG_VERSION}.tar.gz https://github.com/mozilla/mozjpeg/archive/v${MOZJPEG_VERSION}.tar.gz
RUN tar -xvzf mozjpeg-${MOZJPEG_VERSION}.tar.gz
RUN cd mozjpeg-${MOZJPEG_VERSION} && \
    cmake -DPNG_SUPPORTED=0 . && \
    make install

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# STAGE | JPEG-RECOMPRESS
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
FROM libmozjpeg AS jpegarchive

ARG JPEGARCHIVE_VERSION

RUN wget -O jpegarchive-${JPEGARCHIVE_VERSION}.tar.gz https://github.com/danielgtaylor/jpeg-archive/archive/v${JPEGARCHIVE_VERSION}.tar.gz
RUN tar -xvzf jpegarchive-${JPEGARCHIVE_VERSION}.tar.gz
RUN cd jpeg-archive-${JPEGARCHIVE_VERSION} && \
    CFLAGS=-fcommon make install

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# STAGE | PNGQUANT (OLD C version)
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# FROM base_debian AS pngquant
#
# ARG PNGQUANT_VERSION
# RUN wget -O pngquant-${PNGQUANT_VERSION}.tar.gz https://pngquant.org/pngquant-${PNGQUANT_VERSION}-src.tar.gz
# RUN tar -xvzf pngquant-${PNGQUANT_VERSION}.tar.gz
# RUN cd pngquant-${PNGQUANT_VERSION} && \
#     make install

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# STAGE | PNGQUANT (NEW Rust version)
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
FROM base_rust AS pngquant

# Install dependencies
RUN apt-get update && apt-get install -y \
    libpng-dev \
    zlib1g-dev

# Clone and build pngquant
RUN git clone --recursive https://github.com/kornelski/pngquant.git
WORKDIR /pngquant
RUN cargo build --release --features=lcms2
RUN install -c target/release/pngquant /usr/local/bin

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# STAGE | PNGOUT-STATIC
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
FROM base_debian AS pngout-static

ARG PNGOUT_VERSION

RUN wget -O pngout-${PNGOUT_VERSION}-linux-static.tar.gz http://www.jonof.id.au/files/kenutils/pngout-${PNGOUT_VERSION}-linux-static.tar.gz
RUN tar -xvzf pngout-${PNGOUT_VERSION}-linux-static.tar.gz
RUN cd pngout-${PNGOUT_VERSION}-linux-static && \
    cp amd64/pngout-static /usr/local/bin/pngout

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# STAGE | ADVPNG
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
FROM base_debian AS advancecomp

ARG ADVANCECOMP_VERSION

RUN wget -O advancecomp-${ADVANCECOMP_VERSION}.tar.gz https://github.com/amadvance/advancecomp/releases/download/v${ADVANCECOMP_VERSION}/advancecomp-${ADVANCECOMP_VERSION}.tar.gz
RUN tar -xvzf advancecomp-${ADVANCECOMP_VERSION}.tar.gz
RUN cd advancecomp-${ADVANCECOMP_VERSION} && \
    ./configure && \
    make install

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# STAGE | IMAGEMAGICK 7+
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
FROM base_debian AS imagemagick

ARG IMAGEMAGICK_VERSION

RUN apt-get update && apt-get install -y \
    libpng-dev libjpeg-dev libtiff-dev libwebp-dev libheif-dev libopenjp2-7-dev \
    libx11-dev libxext-dev zlib1g-dev liblcms2-dev libfontconfig1-dev libfreetype6-dev \
    libxml2-dev libltdl7-dev ghostscript

RUN wget -O ImageMagick-${IMAGEMAGICK_VERSION}.tar.gz https://github.com/ImageMagick/ImageMagick/archive/${IMAGEMAGICK_VERSION}.tar.gz
RUN tar -xvzf ImageMagick-${IMAGEMAGICK_VERSION}.tar.gz
WORKDIR /ImageMagick-${IMAGEMAGICK_VERSION}
RUN ./configure --with-modules --with-quantum-depth=16 --with-heic=yes --with-webp=yes
RUN make -j$(nproc)
RUN make install
RUN ldconfig /usr/local/lib

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# STAGE | GIFSICLE
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
FROM base_debian AS gifsicle

ARG GIFSICLE_VERSION

RUN apt-get update && apt-get install -y \
    autoconf \
    automake \
    libtool \
    make \
    gcc \
    libgif-dev

RUN wget -O gifsicle-${GIFSICLE_VERSION}.tar.gz https://www.lcdf.org/gifsicle/gifsicle-${GIFSICLE_VERSION}.tar.gz
RUN tar -xvzf gifsicle-${GIFSICLE_VERSION}.tar.gz
WORKDIR /gifsicle-${GIFSICLE_VERSION}
RUN ./configure && make install

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# STAGE | JHEAD
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
FROM base_debian AS jhead

ARG JHEAD_VERSION

RUN apt-get update && apt-get install -y \
    make \
    gcc

RUN wget -O jhead-${JHEAD_VERSION}.tar.gz https://www.sentex.net/~mwandel/jhead/jhead-${JHEAD_VERSION}.tar.gz
RUN tar -xvzf jhead-${JHEAD_VERSION}.tar.gz
WORKDIR /jhead-${JHEAD_VERSION}
RUN make
RUN cp jhead /usr/local/bin/

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# STAGE | OPTIPNG
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
FROM base_debian AS optipng

ARG OPTIPNG_VERSION

RUN apt-get update && apt-get install -y \
    make \
    gcc \
    libpng-dev \
    zlib1g-dev

RUN wget -O optipng-${OPTIPNG_VERSION}.tar.gz https://downloads.sourceforge.net/optipng/optipng-${OPTIPNG_VERSION}.tar.gz
RUN tar -xvzf optipng-${OPTIPNG_VERSION}.tar.gz
WORKDIR /optipng-${OPTIPNG_VERSION}
RUN ./configure
RUN make
RUN make install

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# STAGE | PNGCRUSH
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
FROM base_debian AS pngcrush

ARG PNGCRUSH_VERSION

RUN apt-get update && apt-get install -y \
    make \
    gcc \
    zlib1g-dev \
    libpng-dev

RUN wget -O pngcrush-${PNGCRUSH_VERSION}.tar.gz https://downloads.sourceforge.net/pmt/pngcrush-${PNGCRUSH_VERSION}.tar.gz
RUN tar -xvzf pngcrush-${PNGCRUSH_VERSION}.tar.gz
WORKDIR /pngcrush-${PNGCRUSH_VERSION}
RUN make
RUN cp pngcrush /usr/local/bin/

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# STAGE | JPEGOPTIM
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
FROM base_debian AS jpegoptim

ARG JPEGOPTIM_VERSION

RUN apt-get update && apt-get install -y \
    make \
    gcc \
    libjpeg-dev

RUN wget -O jpegoptim-${JPEGOPTIM_VERSION}.tar.gz https://github.com/tjko/jpegoptim/archive/v${JPEGOPTIM_VERSION}.tar.gz
RUN tar -xvzf jpegoptim-${JPEGOPTIM_VERSION}.tar.gz
WORKDIR /jpegoptim-${JPEGOPTIM_VERSION}
RUN ./configure && make install

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# STAGE | WEBP
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
FROM base_debian AS webp

ARG WEBP_VERSION

RUN apt-get update && apt-get install -y \
    wget

RUN wget -O libwebp-${WEBP_VERSION}-linux-x86-64.tar.gz https://storage.googleapis.com/downloads.webmproject.org/releases/webp/libwebp-${WEBP_VERSION}-linux-x86-64.tar.gz
RUN tar -xvzf libwebp-${WEBP_VERSION}-linux-x86-64.tar.gz
RUN cp -R libwebp-${WEBP_VERSION}-linux-x86-64/bin/* /usr/local/bin/

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# STAGE | MAIN
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
FROM iamteacher/rails-start.main:latest

# Switch to root for installing packages and copying binaries
USER root

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# PRECOMPILED IMG PROCESSORS
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

COPY --from=advancecomp   /usr/local/bin/advpng          /usr/bin
COPY --from=oxipng        /usr/local/bin/oxipng          /usr/bin
COPY --from=pngquant      /usr/local/bin/pngquant        /usr/bin
COPY --from=pngout-static /usr/local/bin/pngout          /usr/bin
COPY --from=gifsicle      /usr/local/bin/gifsicle        /usr/bin
COPY --from=jhead         /usr/local/bin/jhead           /usr/bin
COPY --from=optipng       /usr/local/bin/optipng         /usr/bin
COPY --from=pngcrush      /usr/local/bin/pngcrush        /usr/bin
COPY --from=jpegoptim     /usr/local/bin/jpegoptim       /usr/bin
COPY --from=webp          /usr/local/bin/cwebp           /usr/bin
COPY --from=webp          /usr/local/bin/dwebp           /usr/bin
COPY --from=webp          /usr/local/bin/gif2webp        /usr/bin
COPY --from=webp          /usr/local/bin/webpmux         /usr/bin
COPY --from=webp          /usr/local/bin/webpinfo        /usr/bin

COPY --from=jpegarchive  /usr/local/bin/jpeg-recompress  /usr/bin

COPY --from=libjpeg      /usr/local/bin/jpegtran         /usr/bin
COPY --from=libjpeg      /usr/local/lib/libjpeg.so.9     /usr/lib

# Copy ImageMagick files
COPY --from=imagemagick /usr/local/bin/magick /usr/bin/
COPY --from=imagemagick /usr/local/bin/convert /usr/bin/
COPY --from=imagemagick /usr/local/bin/identify /usr/bin/
COPY --from=imagemagick /usr/local/bin/mogrify /usr/bin/
COPY --from=imagemagick /usr/local/bin/composite /usr/bin/
COPY --from=imagemagick /usr/local/lib/ /usr/local/lib/
COPY --from=imagemagick /usr/local/include/ImageMagick-7/ /usr/local/include/ImageMagick-7/
COPY --from=imagemagick /usr/local/etc/ImageMagick-7/ /usr/local/etc/ImageMagick-7/

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# Install additional packages for media processing:
#
# Video/Audio tools:
#   - ffmpeg: Multimedia framework for handling video, audio, and other multimedia files
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Video/Audio tools
    ffmpeg \
    # Clean up
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Configure dynamic linker to find ImageMagick libraries
RUN ldconfig /usr/local/lib

SHELL ["/bin/bash", "--login", "-c"]

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# IMG PROCESSORS TEST
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

# Copy image processor test script directly to root and rails home directories
COPY checks/image_processors.sh /root/image_processors.sh
COPY checks/image_processors.sh /home/rails/image_processors.sh
RUN chown rails:rails /home/rails/image_processors.sh

# copy ruby environment check script
COPY checks/ruby-env.sh /root/ruby-env.sh
COPY checks/ruby-env.sh /home/rails/ruby-env.sh
RUN chown rails:rails /home/rails/ruby-env.sh

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# FINAL CONFIGURATION
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

# Switch back to rails user
USER rails:rails
WORKDIR /home/rails/app

# Default command
CMD ["bash"]

