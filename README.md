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

### Requirements

1. Computer with a x86_64 CPU.
2. Windows 11 or Windows 10 version 2004 and higher (Build 19041 and higher) running on either a physical device or virtual machine.
3. Windows System for Linux (WSL) installed with Ubuntu.
4. A copy of wsl.exe be in the same folder as SDE-GUI.exe

### Installing WSL and Ubuntu

1. Open PowerShell or Windows Command Prompt in administrator mode by right-clicking and selecting "Run as administrator"
2. Enter the wsl --install command:
    ```
    wsl --install
    ```
    This command will enable the features necessary to run WSL and install the Ubuntu distribution of Linux.
3. Then you may need to reboot.
4. Go to Windows Start Menu and click on Ubuntu.
    <p align="left"><img src="/images/open-ubuntu.png"></p>
6. When asked to create a username, type a username in lower case and press Enter.
7. When asked to create a password type a password and press Enter.

I use the same username and password that I use in Windows, just to make it easier.

### Download Syno DSM Extractor GUI

1. Download the latest version _Syno_DSM_Extractor_GUI_<version>_compiled.zip_ from https://github.com/007revad/Syno_DSM_Extractor_GUI/releases
2. Save the download zip file to a folder on your computer.
3. Unzip the zip file.
4. Copy wsl.exe from `C:\Windows\System32\wsl.exe` into the Syno_DSM_Extractor_GUI folder.

### Other settings

The first time you open Syno DSM Extractor GUI (SDE-GUI.exe):
1. It will ask you set your Ubuntu username and the drive letter Windows assigned to Ubuntu.
2. You need to install the included scripts by clicking "Settings > Install Scripts".
3. You need to install the included libraries by clicking "Settings > Install Libraries".

### Screenshots

<!--- <p align="center">Description of image 1 goes here</p> --->
<p align="center"><img src="/images/about.png"></p>

<br>

<p align="center">Ready to extract my mate Pat :o)</p>
<p align="center"><img src="/images/gui.png"></p>

<br>

<p align="center">Pat likes iTunes :o)</p>
<p align="center"><img src="/images/gui-spk.png"></p>

<br>

<p align="center">Install included scripts and libraries</p>
<p align="center"><img src="/images/install.png"></p>

<br>

<p align="center">Settings dialog</p>
<p align="center"><img src="/images/settings.png"></p>

<br>

<p align="center">Enter your Ubuntu password</p>
<p align="center"><img src="/images/sudo_pwd.png"></p>
