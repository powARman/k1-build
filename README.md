# Debian on Creality K1 series printers

⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️
**This will completely erase everything from your printer. It's strongly recommended to back up your `printer.cfg` and any other configuration files you've customized, as well as any files you don't want to lose.**

**This process has many quirks. You should read the entire guide first and decide if you're comfortable proceeding.**

**Most of this is untested. You're about to upload and customize software to a machine that can burn your house down. You should *really* know what you're doing.**
⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️

This guide is based on [https://github.com/k1-debian/images](https://github.com/k1-debian/images).

## Building the image

The build environment uses a devcontainer that contains all the dependencies to build the K1 Debian image.

1. Clone the repository including the submodules.
1. Open the directory in VS Code either locally or via remote SSH. Build and open the Dev Container.
1. Build U-Boot: ```./build_u-boot.sh```
1. Build Linux Kernel and modules: ```./build_linux.sh```
1. Build the root file system: ```./build_rootfs.sh```. This build the Debian system using debootstrap and installs the kernel modules into it. I also creates a default "printer" user with sudo rights (During the build the password needs to be entered).
1. Build the Ingenic flash image: ```./build_image.sh```
1. (Optional) Build the MCU firmware files: ```./build_mcu_fw.sh```

## Flashing the image

The build process creates the file `creality-k1-debian.ingenic` which can be flashed to the K1 control board using the Ingenic Cloner tool.

1. Get and install the Cloner tool: [Release v2.5.18](https://github.com/Ingenic-community/Cloner/releases/tag/v2.5.18). **You need version 2.5.18 exactly — no older or newer.**
1. Connect your board to your computer via a micro-USB cable (on Windows, install the drivers provided with the Cloner tool).
1. Load the `.ingenic` image into the Cloner tool and press Start. You should see four columns in the main table.
1. Reset the board into `usb boot` mode. With the micro-USB port facing down, the buttons are on the top left. The top button is `mode`, and the bottom is `reset`. Press and hold `mode`, press and release `reset`, then release `mode`. You should see activity in the Cloner tool.
1. Wait. It takes a significant amount of time to upload the image.
1. Once the upload is complete, **disconnect the Micro-USB cable**. Otherwise the USB port and the camera will not work.
1. If the upload was successful, you should eventually see the blue LED on the board blink in a `blink-blink-pause` pattern. If so, continue with configuring your Wi-Fi.

## Post installation configuration

### Configuring Wi-Fi

There's no user interface available at this point (unless you use a USB-to-serial converter for the serial console), so Wi-Fi must be configured via a USB flash drive.

1. Get a FAT32-formatted USB flash drive. Any should work.
1. Place a file named `wlan0.conf` in the root directory of the flash drive. Its content should be (replace `<your network name>` and `<your wi-fi password>` with your actual details):
    ```
    update_config=1
    ctrl_interface=DIR=/run/wpa_supplicant GROUP=netdev

    network={
        ssid="<your network name(SSID)>"
        psk="<your wi-fi password>"
    }
    ```
1. Insert the flash drive into the front USB port and wait.
1. Check your router for the IP address assigned to the printer and make a note of it.

Now that the printer is on the network and you know its IP address, you can continue by connecting to it via SSH.

### Connecting via SSH

With the IP address of the printer, you'll need:

* **Username:** `printer`
* **Password:** The password you entered during build.

Use your preferred SSH client to connect. The `printer` user has `sudo` privileges.

### Resize file system

Run the following command to expand the root partition:
```bash
sudo resize2fs /dev/mmcblk0p4
```
This allows you to install additional software using `apt`.

## Klipper Installation

### Installing KIAUH

KIAUH will be used to install Klipper. To install KIAUH, clone the repository:

```bash
cd ~ && git clone https://github.com/dw-0/kiauh.git
```

### Installing Klipper

1. Download the correct KIAUH config:
    ```bash
    curl -o ~/kiauh/kiauh.cfg https://raw.githubusercontent.com/powARman/k1-build/refs/heads/main/kiauh/creality-klipper.cfg
    ```
1. Start KIAUH:
    ```bash
    ./kiauh/kiauh.sh
    ```
1. Install Klipper, Moonraker, Mainsail, and Crowsnest. **Do not install the Mainsail printer config.**
1. Input shaping calibration

    Do not use KIAUH option to install input shaping dependencies, it will fail. Instead run following command to install dependencies:
    ```bash
    sudo apt install python3-numpy python3-matplotlib
    ```
    Next, in order to install numpy in the Klipper environment, run the command:
    ```bash
    ~/klippy-env/bin/pip install -v "numpy<1.26"
    ```
    This will take more than 20 minutes to complete.

1. Install host MCU support. Follow the instructions here: [https://www.Klipper3d.org/RPi_microcontroller.html](https://www.Klipper3d.org/RPi_microcontroller.html)
    1. Install the rc script:
        ```bash
        cd ~/klipper/
        sudo cp ./scripts/klipper-mcu.service /etc/systemd/system/
        sudo systemctl enable klipper-mcu.service
        ```
    1. Building the micro-controller code

        To compile the Klipper micro-controller code, start by configuring it for the "Linux process":
        ```bash
        cd ~/klipper/
        make menuconfig
        ```
        In the menu, set "Microcontroller Architecture" to "Linux process," then save and exit.

        To build and install the new micro-controller code, run:
        ```bash
        sudo service klipper stop
        make flash
        sudo service klipper start
        ```
1. Copy the default printer configs for your printer:
    ```bash
    cp -f ~/klipper/config/<YOUR PRINTER>/* ~/printer_data/config/
    ```
    Check [this directory](https://github.com/powARman/K1_Series_Klipper/tree/k1-debian/config) to see what options are available and choose the correct one for your printer. Replace `<YOUR PRINTER>` with the appropriate folder name.
1. Reboot:
    ```bash
    sudo reboot
    ```
1. Configure Crowsnest — use one of the many tutorials available online. If there is an error about ustreamer then install manually:
    ```bash
    sudo apt install ustreamer
    ```
1. Calibration and test print:

    To calibrate the printer, run:
    ```
    PRINT_CALIBRATION
    ```
    Then save the configuration:
    ```
    SAVE_CONFIG
    ```
    After this, you're ready to perform a test print.
