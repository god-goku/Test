FROM ubuntu:latest

# Set timezone and install required packages
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y tzdata && \
    echo "America/New_York" > /etc/timezone && \
    dpkg-reconfigure -f noninteractive tzdata && \
    apt-get install -y wget git curl gnupg && \
    apt install sudo -y && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create a non-root user for the build process
RUN useradd -ms /bin/bash builder
USER builder
WORKDIR /home/builder

# Install required packages for Android ROM build
RUN wget https://raw.githubusercontent.com/akhilnarang/scripts/master/setup/android_build_env.sh && \
    chmod a+x android_build_env.sh && \
    bash android_build_env.sh && \
    rm -rf android_build_env.sh

# Define build environment variables
ENV ALLOW_MISSING_DEPENDENCIES=true
ENV LC_ALL=C
ENV USE_CCACHE=1
ENV CCACHE_COMPRESS=1
ENV CCACHE_DIR=/home/builder/.ccache
ENV CCACHE_EXEC=/usr/bin/ccache

# Job 1: Download LineageOS source code
WORKDIR /home/builder/android/lineage
RUN repo init --depth=1 -u https://github.com/LineageOS/android.git -b lineage-20.0
RUN repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j8

# Job 2: Download device tree repositories
WORKDIR /home/builder/android/lineage
RUN git clone https://github.com/LineageOS/android_device_asus_X00TD -b lineage-20 device/asus/X00TD
RUN git clone https://github.com/LineageOS/android_device_asus_sdm660-common -b lineage-20 device/asus/sdm660-common
RUN git clone https://github.com/asus-sdm660-devs/proprietary_vendor_asus vendor/asus

# Job 3: Download kernel tree repository
RUN git clone https://github.com/PixelExperience-Devices/kernel_asus_sdm660 -b thirteen-x00td sdm660

# Job 4: Build the ROM
WORKDIR /home/builder/android/lineage
CMD . b*/e*.sh && \
    lunch lineage_X00TD-userdebug && \
    mka bacon

# Job 5: Set up output directory
WORKDIR /home/builder
RUN mkdir -p /home/builder/android/out/target/product/X00TD
VOLUME /home/builder/android/out/target/product/X00TD
