# <img src="images/icon.png" width="40"> Syno DSM Extractor GUI

<a href="https://github.com/007revad/Syno_DSM_Extractor_GUI/releases"><img src="https://img.shields.io/github/release/007revad/Syno_DSM_Extractor_GUI.svg"></a>
[![Github Releases](https://img.shields.io/github/downloads/007revad/Syno_DSM_Extractor_GUI/total.svg)](https://github.com/007revad/Syno_DSM_Extractor_GUI/releases)
<a href="https://hits.seeyoufarm.com"><img src="https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fgithub.com%2F007revad%2FSyno_DSM_Extractor_GUI&count_bg=%2379C83D&title_bg=%23555555&icon=&icon_color=%23E7E7E7&title=views&edge_flat=false"/></a>
[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://www.paypal.com/paypalme/007revad)
[![](https://img.shields.io/static/v1?label=Sponsor&message=%E2%9D%A4&logo=GitHub&color=%23fe8e86)](https://github.com/sponsors/007revad)
[![committers.top badge](https://user-badge.committers.top/australia/007revad.svg)](https://user-badge.committers.top/australia/007revad)

This program is provided only for the purpose of recovering or repairing Synology NAS or for personal research.

### Description

Windows GUI for extracting Synology DSM 7 pat files and spk package files.

You can drag and drop a .pat file or .spk file onto the window, or click the Select File button to browse for the .pat or .spk file. If you used the installer you can right-click on a .pat or .spk file and select extract, or double-click on the .pat or .spk file.

### Requirements

1. Computer with a x86_64 CPU.
2. Windows 11 or Windows 10 version 2004 and higher (Build 19041 and higher) running on either a physical device or virtual machine.
3. Windows System for Linux (WSL) installed with Ubuntu.

### Installing WSL and Ubuntu

1. Open PowerShell or Windows Command Prompt in administrator mode by right-clicking and selecting "Run as administrator"
2. Enter the following command:
    ```
    wsl --install -d Ubuntu
    ```
    This command will enable the features necessary to run WSL and install the Ubuntu distribution of Linux.
3. Then you may need to reboot.
4. Go to Windows Start Menu and click on Ubuntu.
    <p align="left"><img src="/images/open-ubuntu.png"></p>
5. When asked to create a username, type a username and press Enter.
6. When asked to create a password type a password and press Enter.
    - I use the same username and password that I use in Windows, just to make it easier.
7. Create the sde folders and set the permissions so any user can run Synology DSM Extractor.
    ```
    sudo mkdir -m 777 -p /sde/in /sde/out /sde/lib
    ```
8. Open Windows File Explorer then click on Linux, right-click on Ubuntu and select Map network drive...
    <p align="left"><img src="/images/map-step1.png"></p>
9. Select a drive letter and tick "Reconnect at sign-in" then click Finish.
    <p align="left"><img src="/images/map-step2.png"></p>

### Download Syno DSM Extractor GUI

With Installer

1. Download the latest version _Syno_DSM_Extractor_GUI_installer.zip_ from https://github.com/007revad/Syno_DSM_Extractor_GUI/releases
2. Save the download zip file to a folder on your computer.
3. Unzip the zip file.
4. Double-click on the downloaded setup exe file to install Syno DSM Extractor GUI.

Or without Installer

1. Download the latest version _Syno_DSM_Extractor_GUI_no_installer.zip_ from https://github.com/007revad/Syno_DSM_Extractor_GUI/releases
2. Save the download zip file to a folder on your computer.
3. Unzip the zip file.
4. Run the SDE-GUI.exe from that folder.

### Other settings

The first time you open Syno DSM Extractor GUI (SDE-GUI.exe):
1. It will ask you set your Ubuntu username and the drive letter Windows assigned to Ubuntu.
2. You then need to install the included scripts by clicking "Settings > Install Scripts".
3. Finally you need to install the included libraries by clicking "Settings > Install Libraries".

### Screenshots

<!--- <p align="center">Description of image goes here</p> --->
<p align="center"><img src="/images/about.png"></p>

<br>

<p align="center">Ready to extract DSM pat file</p>
<p align="center"><img src="/images/gui.png"></p>

<br>

<p align="center">Ready to extract DSM pat file to same folder</p>
<p align="center"><img src="/images/gui_same_folder.png"></p>

<br>

<p align="center">Ready to extract package spk file</p>
<p align="center"><img src="/images/gui-spk.png"></p>

<br>

<p align="center">Install included scripts and libraries</p>
<p align="center"><img src="/images/install.png"></p>

<br>

<p align="center">Help menu</p>
<p align="center"><img src="/images/help-menu.png"></p>

<br>

<p align="center">Settings dialog</p>
<p align="center"><img src="/images/settings.png"></p>

<br>

<p align="center">Extracted files</p>
<p align="center"><img src="/images/extracted.png"></p>

### When installed via the setup.exe

<br>

<!--- <p align="center">Description of image goes here</p> --->
<p align="center"><img src="/images/setup-finished.png"></p>

<br>

<p align="center">Windows Start Menu</p>
<p align="center"><img src="/images/windows-start-menu.png"></p>

<br>

<p align="center">File Association</p>
<p align="center"><img src="/images/file-association.png"></p>

<br>

<p align="center">Context Menu</p>
<p align="center"><img src="/images/context-menu.png"></p>

