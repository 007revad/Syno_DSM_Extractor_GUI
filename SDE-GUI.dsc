#-----------------------------------------------------------------------------#
#    Program:    Syno DSM Extractor GUI                                       #
#    File:       SDE-GUI.dsc                                                  #
#    Author:     007revad                                                     #
#    Contact:    https://github.com/007revad                                  #
#    Copyright:  2025, 007revad                                               #
#-----------------------------------------------------------------------------#
# To Do
# Add menu to install WSL (wsl --install in PowerShell admin mode) or install WSL during SDE-GUI installation.
# Cleanup files in U:\home\dave\sde\in if error.
#
#
# Done
# Changed to auto close the WSL window if there were no errors and "Show WSL window" is not ticked.
# Removed "Do you want to close WSL window" prompt.
# Updated the installer's Getting Started page to show cmd or create sde folders.
# Bug fix for needing to click [X] twice to close app after About dialog was show and closed.
# Bug fix for app not closing when clicking [X] if Settings or About dialogs are open.
#
# Changed to show pat/spk source folder as target when "Extract to same folder" enaboled.
# Moved "Extract to same folder as pat/spk file" checkbox to main window.
# Added View Log menu (in Help menu).
# Added setting to check for newer version when opening Syno DSM Extractor GUI.
# Now creates in, out and lib folders if they are missing.
# Bug fix for sending file to already open window.
#
# Added "Extract To" option.
# Added setting for sudo password.
# Changed to automatically insert sudo password into WSL window.
# Bug fix for when "Failed to cd /" when Windows username and Ubuntu user name are different.
# Bug fix for sometimes being unable to access Ubuntu /home/<user>/sde folder.
# Changed to show "No files to extract" instead of "Finished" if there was nothing extracted.
#
# Added support for UNC network paths.
# Added installer.
# Added Windows context menu (via installer).
# Added .pat and .spk file assiciation (via installer).
# Added Check for Updates menu option.
# Changed to show how to install WSL if it's not installed.
# Changed to auto detect wsl Ubuntu drive letter.
# Changed so you don't need to copy wsl.exe to the same folder as SDE.exe.
# Changed so only 1 instance can run at a time.
# Changes to send %1 to open SDE-GUI window if already open.


# For testing in the IDE
if @sysinfo(inide) 
  if @file(F:\extracted\synology_v1000_1821+.pat)
#    %1 = F:\extracted\synology_v1000_1821+.pat
  end
end


  #define function,curdir_wsl
  #define command,Settings,CheckSettings,open_wsl,DialogState,CheckMain

  #resource add,icon,images\dsm_48.ico
  #resource add,icon,images\pkg_48.ico

  OPTION SCALE,96
  OPTION DECIMALSEP,"."
  OPTION TIMESEP,":"
  OPTION DATESEP,"/"
  OPTION DATEFORMAT,"dd/mm/yyyy"
  OPTION TIPTIME,4
  OPTION FIELDSEP,"|"
  OPTION REGKEY,007revad Software\Syno DSM Extractor GUI

  %%exedir = @curdir()

  # Project Variables
  %%Title = Syno DSM Extractor GUI
  %%ExeName = SDE-GUI.exe
  %%MainClass = SDEMain
  %%ClassMain = %%MainClass
  %%Company = 007revad
  if @greater(@datetime(yyyy),2025)
    %%Copyright = "Copyright © 2025-"@datetime(yyyy)
  else
    %%Copyright = "Copyright © 2025"
  end
  %%Beta =
  %%Version = @verinfo(%0,V) %%Beta
  %%WindowTitle = %%Title - %%Version

  # Popup Dialog Title
  title %%Title

  # Opened from context menu or pat/spk file double-clicked
  if @file(%1)
    if @equal(@ext(%1),pat) @equal(@ext(%1),spk)
      %%file_in = %1
    end
  end


  # Check if already running
  if @winexists(#%%MainClass)
    window activate,#%%MainClass
    if @file(%%file_in)
      # If double clicked .pat/spk file send to already open SDE-GUI window
      %%Parent = @winexists(#%%MainClass)
      if %%Parent
        %%Child = @window(%%Parent,CHILD) 

        # Find first #TVDSEdit (last #TVDSEdit in dialog)
        if @not(@equal(@winclass(%%Child),#TVDSEdit))
          repeat
            # This may result in a endless loop if you can't find the window...
            %%Child = @window(%%Child,NEXT)
          until @equal(@winclass(%%Child),#TVDSEdit)
        end

        # Find second #TVDSEdit (first #TVDSEdit in dialog)
        repeat
          # This may result in a endless loop if you can't find the window...
          %%Child = @window(%%Child,NEXT)
        until @equal(@winclass(%%Child),#TVDSEdit) 

        # Set %%file_in text in the Select File Editbox
        window settext,%%Child,%%file_in
      end
    end
    stop
  end


  # Inifile
  if @file(@windir(Local AppData)\%%Company\Syno DSM Extractor GUI,D)
    %%inifile = @windir(Local AppData)\%%Company\Syno DSM Extractor GUI\SDE-GUI.ini
  else
    %%inifile = @path(%0)SDE-GUI.ini
  end
  inifile open, %%inifile
  if @not(@ok())
    warn Failed to open SDE-GUI.ini ,
    goto Close
  end

  # Get PC hostname
  runh cmd /C HOSTNAME ,pipe
  %%hostname = @trim(@pipe()) 

  # Get user's name, in lower case
  runh cmd /C echo @chr(37)USERNAME@chr(37) ,pipe
  %%username = @trim(@lower(@pipe())) 

  # Get PowerShell exe name and path
  #runh cmd /C where pwsh, pipe
  #%p = @pipe() 
  #if @file(@trim(%p)) 
  #  %%powershell = pwsh
  #  %%powershellpath = @trim(%p)
  #else
  #  runh cmd /C where powershell, pipe
  #  %p = @pipe() 
  #  if @file(@trim(%p)) 
      %%powershell = powershell
  #    %%powershellpath = @trim(%p)
  #  else
  #    warn PowerShell not found! ,
  #  end
  #end


  # Check for newer version if updates = 1
  if @equal(@iniread(main, updates),1)
    %%startcheck = "yes"
    gosub Check for Updates
  end


  # Check wsl is installed
  # This is a 32 bit app so we need to use sysnative instead of system32
  if @not(@file(@windir()\sysnative\wsl.exe))
    #if @not(@null(%%powershell))
    #  %x = @ask(Windows System for Linux is not installed. @cr()Do you want to install it now?)
    #  if @equal(%x,1)
    #    goto install_wsl
    #  else
    #    exit
    #  end
    #else
      DIALOG CREATE,%%Title,-1,0,264,130,NOMIN
      DIALOG ADD,TEXT,TEXT1wsl,20,20,,,Windows System for Linux is not installed!
      DIALOG ADD,TEXT,TEXT2wsl,47,20,24,,See
      DIALOG ADD,EXTTEXT,URL,47,44,200,15,<A HREF="https://github.com/007revad/Syno_DSM_Extractor_GUI#installing-wsl-and-ubuntu">Installing WSL and Ubuntu</A>
      DIALOG ADD,BUTTON,BUTTON1,83,102,64,24,OK
      DIALOG SHOWMODAL
      while @event()
      wend
      exit
    #end
  end

  # Set ONTOP for testing in the IDE
  if @sysinfo(inide)
    window ontop,#%%MainClass
  end

  # Set Ubuntu drive letter if not already set
  if @null(@iniread(main, drive))
    if @not(@null(%%powershell))
      runh %%powershell get-psdrive -psprovider filesystem | findstr "Ubuntu", pipe
      %%driveletter = @substr(@trim(@pipe()),1)
      inifile open, %%inifile
      inifile write,main,drive,@upper(%%driveletter)
      inifile close
    end
  end

  # Get last used out_path
  %x = @iniread(main, saveto)
  %y = @iniread(main, move)
  if @both( @not(@null(%x)), @not(@equal(%y,1)) )
    %%out_path = %x
  end

  # Get "Extract to" checkbox state
  %%move = @iniread(main, move)

  # Main window
  # Dialog menu items with a tickbox mut NOT be named
  #  ShowWSLMENU:Show WSL window  does NOT work
  #  Show WSL window              works
  DIALOG CREATE,%%Title - v%%Version,-1,0,560,155,CLASS %%MainClass,DRAGDROP,SAVEPOS
  DIALOG ADD,MENU,Settings,Settings|-|Install Scripts|Install Libraries
  DIALOG ADD,MENU,Help,ViewLogMENU:View Log|Show WSL window|-|Check for Updates|About
  DIALOG ADD,TEXT,TEXT1,20,18,50,18,In File
  DIALOG ADD,EDIT,EDIT1,18,75,385,18,,,READONLY
  DIALOG ADD,BUTTON,Select,15,468,70,24,Select File
  DIALOG ADD,TEXT,TEXT2,60,18,50,18,Out Path
  DIALOG ADD,EDIT,EDIT2,58,75,385,18,%%out_path,,READONLY
  DIALOG ADD,BUTTON,Target,55,468,70,24,Extract To
  DIALOG ADD,CHECK,CHECKmain,97,75,210,18,Extract to same folder as pat/spk file,%%move,,CLICK
  DIALOG ADD,BUTTON,Extract,95,468,70,24,Extract
  dialog disable,Extract
  DIALOG ADD,STATUS,STATUS1,[80C]|[400C]|[80C]
  DIALOG SHOW
  dialog focus,Select

  # Reset cursor in case app crashed last time
  dialog cursor,default

  # Set ONTOP for testing in the IDE
  if @sysinfo(inide)
    window ontop,#%%MainClass
  end

  inifile close

  CheckMain


:EvLoop
  if @both(@not(@winexists(#SDEset)),@not(@winexists(#SDEabout)))
    CheckSettings
    if @unequal(%%closechild,1)
      DialogState
    end
  end
  wait event
  # %V is event, %W is dialog number that issued it (0,1,2,etc.)
  parse "%V;%W", @event(D) 

  # Close settings dialog
  if @both(@equal(%V,CLOSE),@winexists(#SDEset))
    if @null(%%sdeuser) @null(%%driveletter)
      # Exit app if Ubuntu user or drive letter blank and [x] button clicked
      # to prevent "You need to set Ubuntu user or drive letter" loop
      %%closechild =
    else
      %%closechild = 1
    end
  end

  # Close about dialog
  if @winexists(#SDEabout))
    if @equal(%V,CLOSE) @equal(%V,ABOUTOKBUTTON)
      %%closechild = 1
    end
  end

  # Close main dialog
  if @both(@not(@winexists(#SDEset)),@not(@winexists(#SDEabout)))
    %%closechild =
  end
  if @equal(%W,0)
    %%closechild =
  end

  dialog select, %W 
  goto %V 


:TIMER
  CheckMain
  gosub DialogState
  goto EvLoop 

:DialogState
  if @both(@not(@winexists(#SDEset)),@not(@winexists(#SDEabout)))
    inifile open, %%inifile
    # Extract Button
    %%file_in = @dlgtext(EDIT1)
    %%ext_in = @ext(%%file_in)
    %%sdeuser = @iniread(main, user)
    %s = @iniread(main, pass)
    if @not(@null(%s))
      %%sdepass = @encrypt(%s, 8027609167)
    end
    %%driveletter = @iniread(main, drive)
    if @equal(%%ext_in,pat) @equal(%%ext_in,spk)
      if @both(@not(@null(%%sdeuser)),@not(@null(%%driveletter)))
        dialog enable, Extract
      else
        dialog disable, Extract
      end
    else
      dialog disable, Extract
    end

    # View Log
    %%driveletter = @iniread(main, drive)
    if @file(%%driveletter:\sde\sde.log)
      dialog enable, ViewLogMENU
    else
      dialog disable, ViewLogMENU
    end
    inifile close
  end
  exit


:Close
:AboutOKBUTTON
  if @null(%%closechild)
    inifile close, %%inifile
    stop
  end
  %%closechild =
  dialog close
  while @event()
  wend
  goto EvLoop


:ABOUTMENU
:ABOUT Syno DSM Extractor GUIMENU
  DIALOG CREATE,About Syno DSM Extractor GUI,-1,0,440,160,CLASS SDEabout,NOMIN
  DIALOG ADD,STYLE,STYLEHEADING,,14,B,,
  DIALOG ADD,BITMAP,BITMAP1,15,20,32,32,#sde-32.ico
  DIALOG ADD,TEXT,Heading,16,70,,,Syno DSM Extractor GUI,,STYLEHEADING
  DIALOG ADD,TEXT,Version,46,70,,,Version %%Version
  DIALOG ADD,TEXT,Copyright,66,70,,,%%Copyright 007revad
  DIALOG ADD,EXTTEXT,EXTTEXT1,86,70,,,<A HREF="https://www.github.com/007revad/Syno_DSM_Extractor_GUI">https://www.github.com/007revad/Syno_DSM_Extractor_GUI</A>
  DIALOG ADD,BUTTON,AboutOK,117,190,64,24,OK
  DIALOG SHOW
  goto EvLoop


:VIEWLOGMENU
  shell open,%%driveletter:\sde\sde.log
  goto EvLoop


:SHOW WSL WINDOWMENU
  # Dialog menu items with a tickbox mut NOT be named
  #  ShowWSLMENU:Show WSL window  does NOT work
  #  Show WSL window              works
  if @equal(@regread(default,,Show WSL window),1)
    # Remove ticked checkbox from Show WSL window menu
    registry write,default,,Show WSL window,
  else
    # Add ticked checkbox to Show WSL window menu
    registry write,default,,Show WSL window,1
  end
  goto EvLoop


:CHECKMAINCLICK
  CheckMain
  goto EvLoop

:CheckMain
  inifile open, %%inifile
  # Move unpacked files
  %%move = @dlgtext(CHECKmain) 
  if @unequal(%%move,@iniread(main, move))
    inifile write,main,move,%%move
  end
  %f = @dlgtext(EDIT1)
  %p = @substr(@path(%f),1,-1)
  %s = @iniread(main, saveto)
  if @unequal(%p,%s)
    if @equal(%%move,1)
      dialog set, EDIT2, %p
    else
      dialog set, EDIT2, %s
    end
  end

  # Extract To ticked
  if @equal(@iniread(main, move),1)
    dialog disable, Target
    dialog disable, EDIT2
    dialog disable, TEXT2
  else
    dialog enable, Target
    dialog enable, EDIT2
    dialog enable, TEXT2
  end
  inifile close
  exit


:SETTINGSMENU
  Settings
  goto EvLoop


:CheckSettings
  #----------------------------------------------------------------------------
  # Check Settings command
  #----------------------------------------------------------------------------
  inifile open, %%inifile
  # Show settings dialog if user or drive letter not set
  %%sdeuser = @iniread(main, user)
  %%driveletter = @iniread(main, drive)
  %%move = @iniread(main, move)
  if @both(@null(%%sdeuser),@null(%%driveletter))
    info You need to set Ubuntu user and drive letter ,
    Settings
  elsif @null(%%sdeuser)
    info You need to set Ubuntu user ,
    Settings
  elsif @null(%%driveletter)
    info You need to set Ubuntu drive letter ,
    Settings
  end
  inifile close
  exit


:Settings
  #----------------------------------------------------------------------------
  # Settings command
  #----------------------------------------------------------------------------
  inifile open, %%inifile
  %%sdeuser = @iniread(main, user)
  %s = @iniread(main, pass)
  if @not(@null(%s))
    %%sdepass = @encrypt(%s, 8027609167)
  end
  %%driveletter = @iniread(main, drive)
  %%updates = @iniread(main, updates,1)
  inifile close

  DIALOG CREATE,Settings,-1,0,245,270,CLASS SDEset,NOMIN,ONTOP
  # User
  DIALOG ADD,TEXT,NewUser,16,20,,,Ubuntu User
  DIALOG ADD,EDIT,NUser,16,100,124,18,,Enter your Ubuntu user name
  DIALOG SET,NUser,%%sdeuser
  # Password
  DIALOG ADD,TEXT,NewPass,46,20,,,Ubuntu Password
  DIALOG ADD,EDIT,NPwd,46,140,84,18,,Enter your Ubuntu password,PASSWORD
  DIALOG SET,NPwd,%%sdepass
  # Drive letter
  DIALOG ADD,TEXT,NewDrive,76,20,,,Ubuntu Drive Letter
  DIALOG ADD,EDIT,NDrive,76,140,84,18,,Enter Ubuntu's drive letter
  DIALOG SET,NDrive,%%driveletter
  DIALOG ADD,BITMAP,BITMAP1,105,20,203,59,#drive-letter.bmp
  # Check for updates
  DIALOG ADD,CHECK,CHECK1,181,20,210,18,Check for updates when opening,%%updates
  DIALOG ADD,BUTTON,Save,222,90,64,24,Save
  DIALOG SHOW
  dialog focus, Save
  exit


:SaveBUTTON
  inifile open, %%inifile
  %%newuser = @dlgtext(NUser)
  %%newpass = @dlgtext(NPwd)
  %%newdrive = @dlgtext(NDrive)
  %%newupdates = @dlgtext(CHECK1)
  # User name
  if @not(@null(%%newuser))
    if @unequal(%%sdeuser,%%newuser)
      inifile write,main,user,%%newuser
    end
  end
  # User password
  if @not(@null(%%newpass))
    if @unequal(%%sdepass,%%newpass)
      inifile write,main,pass,@encrypt(%%newpass, 8027609167)
    end
  end
  # Drive letter
  if @not(@null(%%newdrive))
    if @unequal(%%driveletter,@upper(%%newdrive))
      inifile write,main,drive,@upper(%%newdrive)
    end
  end
  # Check for updates
  inifile write,main,updates,%%newupdates
  dialog close
  while @event()
  wend
  inifile close
  goto EvLoop


:VerifyFile
  %%ext_in = @ext(%%file_in)
  %%name = @name(%%file_in)
  %%path = @path(%%file_in) 
  dialog set,EDIT1,%%file_in
  # Clear status bar
  dialog set,status1,@tab()
  exit


:DRAGDROP
  %%droplist = @new(LIST)
  list dropfiles,%%droplist
  %%file_in = @item(%%droplist)
  if @ok()
    gosub VerifyFile
  end
  list close,%%droplist
  goto Timer


:SelectBUTTON
  %%file_in = @filedlg("Synology files|*.pat;*.spk",Select file)
  if @ok()
    gosub VerifyFile
  end
  goto Timer


:TargetBUTTON
  %p = @dirdlg(Select folder,%%out_path,shownewfolderbutton)
  if @ok()
    %%out_path = %p
    inifile open, %%inifile
    inifile write,main,saveto,%%out_path
    inifile close
    dialog set,EDIT2,%%out_path
  end
  goto Timer


# needs work on messages
:INSTALL SCRIPTSMENU
  #----------------------------------------------------------------------------
  # ExtractBUTTON does chmod a+x on syno_archive_extractor.sh
  # syno_archive_extractor.sh does chmod a+x on sae.py
  #----------------------------------------------------------------------------
  %%installed = @new(LIST)
  %f = %%exedir\scripts\syno_archive_extractor.sh
  if @file(%f)
    file copy,%f,%%driveletter:\sde\syno_archive_extractor.sh,CONFIRM,SHOWERRORS
    if @ok()
      list add,%%installed,syno_archive_extractor.sh
    else
      warn Failed to install syno_archive_extractor.sh ,
    end
  else
    warn %f missing! ,
  end
  %g = %%exedir\scripts\sae.py
  if @file(%g)
    file copy,%g,%%driveletter:\sde\sae.py,CONFIRM,SHOWERRORS
    if @ok()
      list add,%%installed,sae.py
    else
      warn Failed to install sae.py ,
    end
  else
    warn %g missing! ,
  end
  if @greater(@count(%%installed),0)
    title Installed or Updated
    info @text(%%installed)
    title %%Title
  end

  # Create file to hide WSL shell header (requires Ubuntu user)
  # Fails silently if %%sdeuser has no home folder
  %x = @new(FILE,%%driveletter:\home\%%sdeuser\.hushlogin,CREATE)

  list close,%%installed
  goto EvLoop


# needs work on messages
:INSTALL LIBRARIESMENU
  #----------------------------------------------------------------------------
  # syno_extract_archive.sh moves libraries from \sde\lib to \usr\lib
  #----------------------------------------------------------------------------
  # Create lib directory if missing
  if @not(@file(%%driveletter:\sde\lib,D))
    directory create,%%driveletter:\sde\lib
    if @not(@ok())
      warn Failed to create %%driveletter:\sde\lib ,
      goto EvLoop
    end
  end

  # Get list of libraries that need to be installed in WSL
  %%installables = @new(LIST)
  %%toinstall = @new(LIST)
  %%libscopied = @new(LIST)
  #list add,%%installables,libcodesign.so
  #list add,%%installables,libcore.so.7
  #list add,%%installables,libcredntials.so.7
  #list add,%%installables,libcrypto.so.1.1
  #list add,%%installables,libcrypto.so.7
  list add,%%installables,libicudata.so.64
  list add,%%installables,libicui18n.so.64
  list add,%%installables,libicuuc.so.64
  list add,%%installables,libmsgpackc.so.2
  list add,%%installables,libsodium.so
  list add,%%installables,libsynocodesign.so
  list add,%%installables,libsynocore.so.7
  #list add,%%installables,libsynocredentials.so.7
  list add,%%installables,libsynocrypto.so.7
  #list add,%%installables,libtss2-esys.so
  list add,%%installables,libtss2-esys.so.0
  list add,%%installables,libtss2-mu.so.0
  list add,%%installables,libtss2-rc.so.0
  list add,%%installables,libtss2-sys.so.1

  # Check which libraries are missing in WSL
  if @greater(@count(%%installables),0)
    list seek,%%installables,0
    %x = @item(%%installables)
    while @ok()
      if @not(@file(%%driveletter:\usr\lib\%x))
        list add,%%toinstall,%x
      end
      %x = @next(%%installables)
      %x = @item(%%installables)
    wend
  end

  # Copy libraries to WSL \sde\lib
  if @greater(@count(%%toinstall),0)
    list seek,%%toinstall,0
    %x = @item(%%toinstall)
    %%ok =
    while @ok() 
      if @not(@file(%%exedir\lib\%x)) 
        warn File not found! %%exedir\lib\%x ,
      else
        file copy,%%exedir\lib\%x,%%driveletter:\sde\lib\%x,CONFIRM,SHOWERRORS
        if @ok()
          list add,%%libscopied,%x
        end
      end
      %x = @next(%%toinstall)
      %x = @item(%%toinstall)
    wend
  end

  if @greater(@count(%%libscopied),0)
    info Installed: @cr()@text(%%libscopied) ,
  else
     info No libraries needed installing ,
  end

  list close,%%installables
  list close,%%toinstall
  list close,%%libscopied
  goto EvLoop


:ExtractBUTTON
  #----------------------------------------------------------------------------
  # syno_archive_extractor.sh does the following: 
  #  1. Set chmod a+x on sae.py
  #  2. Creates out folder if it's missing
  #  3. Sets owner of extracted .pat or .spk folder
  # sae.py must run as sudo so we must sudo in WSL
  #----------------------------------------------------------------------------
  # Clear status bar
  dialog set,status1,@tab()

  # Create in and out directories if missing
  if @not(@file(%%driveletter:\sde\in,D))
    directory create,%%driveletter:\sde\in
    if @not(@ok())
      warn Failed to create %%driveletter:\sde\in ,
      goto EvLoop
    end
  end
  if @not(@file(%%driveletter:\sde\out,D))
    directory create,%%driveletter:\sde\out
    if @not(@ok())
      warn Failed to create %%driveletter:\sde\out ,
      goto EvLoop
    end
  end

  # Copy .pat or .spk file to WSL
  %%name = @name(%%file_in)
  file copy,%%file_in,%%driveletter:\sde\in\%%name.%%ext_in,CONFIRM,SHOWERRORS
  if @ok()
    # Open WSL shell to run script to extract .pat or .spk file
    # This is a 32 bit app so we need to use sysnative instead of system32
#    if @equal(@regread(default,,Show WSL window),1)
      shell open,@windir()\sysnative\wsl.exe
#    else
#    end
    if @not(@ok())
      warn Failed to open wsl window! ,
      goto EvLoop
    end
    wait 1

    # When .pat or .spk file is local
    # Get window id "user@hostname: /mnt/<drive-letter>/<path>
    %%windowid = %%sdeuser@chr(64)%%hostname@chr(58) @chr(47)@curdir_wsl() 

    # Wait until WSL window has opened (timeout after 2 seconds)
    %C = 0
    repeat
      wait 0.2
      %C = @succ(%C)
    until @winexists(%%windowid) @greater(%C,10)


    # When .pat pr .spk file is UNC network path
    if @not(@winexists(%%windowid))
      # Get window id "user@hostname: ~
      %%windowid = %%sdeuser@chr(64)%%hostname@chr(58) @chr(126) 

      # Wait until WSL window has opened (timeout after 2 seconds)
      %C = 0
      repeat
        wait 0.2
        %C = @succ(%C)
      until @winexists(%%windowid) @greater(%C,10)
    end


    # Elevate to sudo
    window send,%%windowid,sudo -s@key(ENTER), wait
    if @not(@ok())
      # Bring main window to the front so warning is not hidden behind WSL window
      window activate,#%%MainClass
      warn Failed to sudo! ,
      goto EvLoop
    end

    # Enter password if password in settings
    if @not(@null(%%sdepass))
      window send,%%windowid,%%sdepass@key(ENTER), wait
      if @not(@ok())
       # Bring main window to the front so warning is not hidden behind WSL window
        window activate,#%%MainClass
        warn Failed to enter password! ,
        goto EvLoop
      end
    else
      # Allow time for use to enter sudo password
      wait 10
    end
    wait 1

    # Titlebar now shows root instead of user
    # Get window id "root@hostname: /mnt/<drive-letter>/<path>
    %%windowid = root@chr(64)%%hostname@chr(58) @chr(47)@curdir_wsl() 
    #%%windowid = root@chr(64)%%hostname@chr(58) @chr(47) 

    # Elevate to sudo and CD to /
    window send,%%windowid,cd @chr(47)@key(ENTER), wait
    if @not(@ok())
      # Bring main window to the front so warning is not hidden behind WSL window
      window activate,#%%MainClass
      warn Failed to cd to / ,
      goto EvLoop
    end
    #wait 2

    # Get window id again as now titlebar only shows "user@hostname: /"
    %%windowid = root@chr(64)%%hostname@chr(58) @chr(47) 

    # Wait until WSL window title has changed (timeout after 2 seconds)
    %C = 0
    repeat
      wait 0.2
      %C = @succ(%C)
    until @winexists(%%windowid) @greater(%C,10)

    %%script = @chr(47)sde@chr(47)syno_archive_extractor.sh
    %%logfile = @chr(47)sde@chr(47)sde.log

    # Make sure bash script is executable
    window send,%%windowid,chmod a+x %%script@key(ENTER), wait
    if @not(@ok())
      # Bring main window to the front so warning is not hidden behind WSL window
      window activate,#%%MainClass
      warn Failed to chmod a+x syno_archive_extractor.sh ,
      goto EvLoop
    end

    # Run the script to extract .pat file
    #window send,%%windowid,%%script %%sdeuser @chr(62) %%logfile@key(ENTER), wait
    window send,%%windowid,%%script %%sdeuser@key(ENTER), wait
    if @not(@ok())
      # Bring main window to the front so warning is not hidden behind WSL window
      window activate,#%%MainClass
      warn Failed to run syno_archive_extractor.sh ,
      goto EvLoop
    end

    # Wait until script has extracted .pat file (timeout after 10 seconds)
    %C = 0
    repeat
      wait 0.2
      %C = @succ(%C)
    until @file(%%driveletter:\sde\finished) @greater(%C,10)

    # Bring main window to the front so "Do you want close" is not hidden behind WSL window
    window activate,#SDEmain

    # Set status bar
    if @file(%%driveletter:\sde\okay)
      dialog set,STATUS1,@tab()Finished
    elsif @file(%%driveletter:\sde\nofiles)
      dialog set,STATUS1,@tab()No files to extract
    end

    # Exit WSL shell
    if @winexists(%%windowid)
      if @null(@regread(default,,Show WSL window))
        # Need to exit twice as first exit only exits sudo
        # Once to root@... and again to user@...
        #window send,%%windowid,exit@key(ENTER), wait
        window close,%%windowid
        if @not(@ok())
          warn Failed to close wsl window! ,
          goto EvLoop
        end
      end
    end
  end

  # Move extracted pat/sdk folder to pat/sdk folder
  if @equal(%%move,1) @not(@null(%%out_path))
    if @equal(%%move,1)
      %p = @path(%%file_in)
    else
      %p = %%out_path
    end
    %n = @name(%%file_in)
    if @file(%%driveletter:\sde\out\%n,D)
      directory rename,%%driveletter:\sde\out\%n,%p,CONFIRM,SHOWERRORS 
      if @not(@ok())
        warn Failed to move extracted %n folder! ,
      end
    end
  end
  goto EvLoop


:curdir_wsl
  #----------------------------------------------------------------------------
  # Function to return the WSL current directory path so we know the last
  # part of the wsl window's titlebar string
  #----------------------------------------------------------------------------
  %a = @curdir() 
  %l = @lower(@substr(%a,1)) 
  %b = @strdel(%a,1,2) 
  %c = @strrep(%b,\,@chr(47),ALL)
  %d = mnt@chr(47)%l%c
  exit %d


:Check for UpdatesMENU
  gosub Check for Updates
  %%dialogshowing = "yes"
  goto EvLoop

:Check for Updates
  %%currentversion = @verinfo(%0,V)
  if @not(@null(%%powershell))
    %%repo = 007revad/Syno_DSM_Extractor_GUI
    if %%dialogshowing
      # Set the cursor to wait
      dialog cursor,wait
    end
    runh cmd /C curl.exe --silent @chr(34)https://api.github.com/repos/%%repo/releases/latest@chr(34) | findstr tag_name, pipe
    %P = @pipe()
    if %%dialogshowing
      # Set the cursor to normal
      dialog cursor
    end
    %%dialogshowing =

    %S = @fsep()
    option fieldsep,@chr(34)
    parse "%A;%B;%V",%P

    # Strip v from start of version
    if @equal(v,@substr(%V,1))
      %%latestversion = @substr(%V,2,@len(%V))
    end

    # Variables in Visual DialogScript are strings so we need to compare each part of the version!!!
    option fieldsep,"."
    parse "%A;%B;%C;%%currentbuild", %%currentversion
    parse "%D;%E;%F;%%latestbuild", %%latestversion

    title Check for Updates
    if @greater(%%latestbuild,%%currentbuild)
      if @ask(%V is available. @cr()@cr()Do you want to download it? )
        shell open,https://github.com/007revad/Syno_DSM_Extractor_GUI/releases
      end
    else
      # Only show "You have the latest version" if menu item clicked
      if %%startcheck
        %%startcheck =
      else
        info You have the latest version. ,
      end
    end

    title %%Title
    option fieldsep,%S
  end
  exit

