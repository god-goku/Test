FROM ubuntu:22.04

# Set timezone and install required packages
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y tzdata && \
    echo "America/New_York" > /etc/timezone && \
    dpkg-reconfigure -f noninteractive tzdata && \
    apt-get install -y wget git curl gnupg && \
    apt install sudo -y && \
    wget https://raw.githubusercontent.com/akhilnarang/scripts/master/setup/android_build_env.sh && \
    chmod a+x android_build_env.sh && \
    ./android_build_env.sh && \
    apt-get remove -y wget && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* & \
    df -h && free

# Set up the build environment
RUN useradd -ms /bin/bash builder
USER builder
WORKDIR /home/builder

# Download LineageOS source code
RUN mkdir -p ~/android/lineage
WORKDIR /home/builder/android/lineage
RUN repo init --depth=1 -u https://github.com/LineageOS/android.git -b lineage-18.1
RUN repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j8

# Download device tree repositories
RUN git clone https://github.com/LineageOS/android_device_asus_X00TD -b lineage-20 device/asus/X00TD
RUN git clone https://github.com/LineageOS/android_device_asus_sdm660-common -b lineage-20 device/asus/sdm660-common
RUN git clone https://github.com/asus-sdm660-devs/proprietary_vendor_asus vendor/asus

# Download kernel tree repository
RUN git clone https://github.com/PixelExperience-Devices/kernel_asus_sdm660 -b thirteen-x00td kernel/asus/sdm660

# Set up build environment variables
ENV ALLOW_MISSING_DEPENDENCIES=true
ENV LC_ALL=C
ENV USE_CCACHE=1
ENV CCACHE_COMPRESS=1
ENV CCACHE_DIR=/home/builder/.ccache
ENV CCACHE_EXEC=/usr/bin/ccache

# Build the ROM
RUN . b*/e*.sh
RUN lunch lineage_X00TD-userdebug
RUN mka bacon


# Set up output directory
RUN mkdir -p /home/builder/android/out/target/product/X00TD
VOLUME /home/builder/android/out/target/product/X00TD
