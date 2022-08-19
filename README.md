# WindowsUnattendedInstall

The goal of this project is to place this script in a specific folder of the windows installation media and let it install everything you need at the first startup after windows install based on an YAML file. 

## A little story

After discovering that it was possible to copy files in the Windows installation, I had an idea to launch some tasks at the first launch of Windows to ease the installation process (Thanks the 'sources\\\$OEM\$' folder and OOBE commands).

### \$OEM\$ folder

We can copy files to Windows installation media and have them copy to either the Windows Folder or System Drive During Installation. To do so, we need to store the files we want on the installation media, specifically:

> sources\\\$OEM\\\$$ 
> sources\\\$OEM\\\$1

The first folder content will copied into the `C:\\Windows` folder, 
The second into the `C:\\` root drive.

### oobe.cmd

This is where the operation begins, there is a file that you can store in a specific location, which will be executed when the machine is started after the installation of Windows.

> \\sources\\$OEM$\\$$\\setup\\scripts\\oobe.cmd

In my project, this file will call my script via RunOnceEx registry commands. 
And the scripts begins.


## Features

So far, the script does : 

- Connect to Wi-Fi with password stored in config.ini
- Install WSL 
- Install Winget
- Install winget selected apps 
- install Chocolatey 
- install Chocolatey selected apps 
- Set some windows settings 
  - set Taskbar search section to a bar, button or hide (Windows 10 Only)
  - set Windows news and interest to show icon, only text or hide (Windows 10 Only)
  - set Windows news and interest show on mouse hover (Windows 10 Only)
  - Set a wallpaper
- Delete itself at the end of the script

## Usage 

The usage is pretty simple, copy the content of the 'files' folder into the root of a Windows 10/11 installation media, and edit the YAML file located in 'sources\\$OEM$\\$1\Setup\config.yaml' with the desired settings/apps.



## An idea, want to help? 

Don't hesitate to reach me or post an issue/PR to help this projet growth. That's why open source community stands for after all. 

## Useful links

- [Create a custom partition configuration with autounattended.xml file](https://docs.microsoft.com/en-us/windows-hardware/customize/desktop/unattend/microsoft-windows-setup-diskconfiguration-disk-createpartitions-createpartition-size)


# Credits

This project depends on work done by others and they should at least get a mention. Please note that this list is not complete yet.

### [powershell-yaml](https://github.com/cloudbase/powershell-yaml)

powershell-yaml was used to parse the YAML file.

### [NuGet](https://github.com/NuGet)


### [PSWindowsUpdate](https://www.powershellgallery.com/packages/PSWindowsUpdate/)

PSWindowsUpdate is used to manage updates of the computer. [GitHub](https://github.com/mgajda83/PSWindowsUpdate)

### [WinGet](https://github.com/microsoft/winget-cli)

WinGet is the main package manager, where most of apps will be installed with. More info [here](https://docs.microsoft.com/en-us/windows/package-manager/winget/)

### [Chocolatey](https://chocolatey.org/)

Chocolatey is the second package manager, used for apps not found in WinGet repo.


# Sources 

- [The \$OEM\$ Folder](https://dellwindowsreinstallationguide.com/the-oem-folder/)
