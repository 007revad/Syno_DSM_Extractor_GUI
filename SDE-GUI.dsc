#-----------------------------------------------------------------------------#
#    Program:    Syno DSM Extractor GUI                                       #
#    File:       SDE-GUI.dsc                                                  #
#    Author:     007revad                                                     #
#    Contact:    https://github.com/007revad                                  #
#    Copyright:  2025, 007revad                                               #
#-----------------------------------------------------------------------------#

# To Do
# Add menu to install WSL (wsl --install in PowerShell admin mode) or install WSL during SDE-GUI installation
# Change to use consoleio.dll?
#
# Done
# Bug fix for UNC network paths
# Added installer
# Added Windows context menu (via installer)
# Added .pat and .spk file assiciation (via installer)
# Added Check for Updates menu option
# Changed to show how to install WSL if it's not installed
# Changed to auto detect wsl Ubuntu drive letter
# Changed so you don't need to copy wsl.exe to the same folder as SDE.exe
# Changed so only 1 instance can run at a time
# Changes to send %1 to open SDE-GUI window if already open


  #define function,curdir_wsl
  #define command,Settings,CheckSettings,open_wsl

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
    #warn %%Title is already running! ,
    window activate,#%%MainClass
    if @file(%%file_in)
      # If double clicked .pat/spk file send to already open SDE-GUI window
      %%wintop = @winpos(#%%MainClass,T)
      %%winleft = @winpos(#%%MainClass,L)
      %%texttop = @sum(%%wintop,64)
      %%textleft = @sum(%%winleft,73)
      %%editbox = @winatpoint(%%textleft,%%texttop)
      window settext,%%editbox,%%file_in
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
    warn Failed to open SDE-GUI.ini
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
    runh cmd /C where powershell, pipe
    %p = @pipe() 
    if @file(@trim(%p)) 
      %%powershell = powershell
      %%powershellpath = @trim(%p)
    else
      warn PowerShell not found! ,
    end
  #end

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

  # Set Ubuntu drive letter if not already set
  if @null(@iniread(main, drive))
    if @not(@null(%%powershell))
      runh %%powershell get-psdrive -psprovider filesystem | findstr "Ubuntu", pipe
      %%driveletter = @substr(@trim(@pipe()),1)
      inifile write,main,drive,@upper(%%driveletter)
    end
  end

  DIALOG CREATE,%%Title - v%%Version,-1,0,560,110,CLASS SDEmain,DRAGDROP,SAVEPOS
  DIALOG ADD,MENU,Settings,Settings|Install Scripts|Install Libraries
  DIALOG ADD,MENU,Help,Check for Updates|About
  DIALOG ADD,STYLE,BRed,,,B,,RED
  DIALOG ADD,STYLE,BGGreen,,,BC,,00C400
  DIALOG ADD,STYLE,BCRed,,,BC,,RED
  DIALOG ADD,TEXT,TEXT1,20,18,45,18,In File
  DIALOG ADD,EDIT,EDIT1,18,70,390,18,%%file_in,,READONLY
  DIALOG ADD,BUTTON,Select,15,468,70,24,Select File
  #DIALOG ADD,TEXT,TEXT3,50,470,70,18,,,BRed
  DIALOG ADD,BUTTON,Extract,60,240,74,24,Extract
  #DIALOG ADD,TEXT,TEXT4,120,20,518,18,,,FITTEXT,BGGreen
  #DIALOG ADD,TEXT,TEXT5,120,20,518,18,,,FITTEXT,BCRed
  dialog disable, Extract
  #dialog hide, TEXT5
  DIALOG SHOW
  dialog focus, Select

  goto TIMER


:EvLoop
  if @not(@winexists(#SDEset))
    CheckSettings
  end
  wait event, 0.2
  # %V is event, %W is dialog number that issued it (0,1,2,etc.)
  parse "%V;%W", @event(D) 
  if @both(@equal(%V,CLOSE),@winexists(#SDEset))
    if @null(%%sdeuser) @null(%%driveletter)
      # Exit app if Ubuntu user or drive letter blank and [x] button clicked
      # to prevent "You need to set Ubuntu user or drive letter" loop
      %%closechild =
    else
      %%closechild = 1
    end
  end
  dialog select, %W 
  goto %V 


:TIMER
  if @not(@winexists(#SDEset))
    %%file_in = @dlgtext(EDIT1)
    %%ext_in = @ext(%%file_in)
    %%sdeuser = @iniread(main, user)
    %%driveletter = @iniread(main, drive)
    if @equal(%%ext_in,pat) @equal(%%ext_in,spk)
      if @both(@not(@null(%%sdeuser)),@not(@null(%%driveletter)))
        dialog enable, Extract
        dialog focus, Extract
      else
        dialog disable, Extract
        dialog focus, Select
      end
    else
      dialog disable, Extract
      dialog focus, Select
    end
  end
  goto EvLoop 


:Close
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
  DIALOG CREATE,About Syno DSM Extractor GUI,-1,0,440,160,NOMIN
  DIALOG ADD,STYLE,STYLEHEADING,,14,B,,
  DIALOG ADD,BITMAP,BITMAP1,15,20,32,32,#sde-32.ico
  DIALOG ADD,TEXT,Heading,16,70,,,Syno DSM Extractor GUI,,STYLEHEADING
  DIALOG ADD,TEXT,Version,46,70,,,Version %%Version
  DIALOG ADD,TEXT,Copyright,66,70,,,%%Copyright 007revad
  DIALOG ADD,EXTTEXT,EXTTEXT1,86,70,,,<A HREF="https:\\www.github.com\007revad\Syno_DSM_Extractor_GUI">https:\\www.github.com\007revad\Syno_DSM_Extractor_GUI</A>
  DIALOG ADD,BUTTON,AboutOK,117,190,64,24,OK
  DIALOG SHOWMODAL
:AboutOKBUTTON
  %%closechild = 1
  while @event()
  wend
  goto EvLoop


:SETTINGSMENU
  Settings
  goto EvLoop


:CheckSettings
  #----------------------------------------------------------------------------
  # Check Settings command
  #----------------------------------------------------------------------------
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
  exit


:Settings
  #----------------------------------------------------------------------------
  # Settings command
  #----------------------------------------------------------------------------
  %%sdeuser = @iniread(main, user)
  %%driveletter = @iniread(main, drive)
  %%move = @iniread(main, move,1)

  DIALOG CREATE,Settings,-1,0,245,240,CLASS SDEset,NOMIN,ONTOP
  # User
  DIALOG ADD,TEXT,NewUser,16,20,,,Ubuntu User
  DIALOG ADD,EDIT,NUser,16,100,124,18,,Enter your Ubuntu user name
  DIALOG SET,NUser,%%sdeuser
  # Drive letter
  DIALOG ADD,TEXT,NewDrive,46,20,,,Ubuntu Drive Letter,
  DIALOG ADD,EDIT,NDrive,46,140,84,18,,Enter Ubuntu's drive letter
  DIALOG SET,NDrive,%%driveletter
  DIALOG ADD,BITMAP,BITMAP1,75,20,203,59,#drive-letter.bmp
  # Move
  DIALOG ADD,CHECK,CHECK1,151,20,210,18,Extract to same folder as pat/spk file,%%move
  DIALOG ADD,BUTTON,Save,192,90,64,24,Save
  #DIALOG SHOWMODAL
  DIALOG SHOW
  dialog focus, Save
  exit


:SaveBUTTON
  %%newuser = @dlgtext(NUser)
  %%newdrive = @dlgtext(NDrive)
  %%newmove = @dlgtext(CHECK1) 
  # User name
  if @not(@null(%%newuser))
    if @unequal(%%sdeuser,%%newuser)
      inifile write,main,user,%%newuser
    end
  end
  # Drive letter
  if @not(@null(%%newdrive))
    if @unequal(%%driveletter,@upper(%%newdrive))
      inifile write,main,drive,@upper(%%newdrive)
    end
  end
  # Move unpacked files
  inifile write,main,move,%%newmove
  dialog close
  while @event()
  wend
  goto EvLoop


:VerifyFile
  %%ext_in = @ext(%%file_in)
  %%name = @name(%%file_in)
  %%path = @path(%%file_in) 
  dialog set, EDIT1, %%file_in

  #dialog set, TEXT4,
  #dialog hide, TEXT5
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
  #%%file_in = @filedlg("pat file (*.pat)|*.pat",Open file) 
  #%%file_in = @filedlg("pat file (*.pat)|*.pat|spk file (*.spk)|*.spk",Select file) 
  %%file_in = @filedlg("Synology files|*.pat;*.spk",Select file)
  if @ok()
    gosub VerifyFile
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
    file copy,%f,%%driveletter:\home\%%sdeuser\sde\syno_archive_extractor.sh,CONFIRM,SHOWERRORS
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
    file copy,%g,%%driveletter:\home\%%sdeuser\sde\sae.py,CONFIRM,SHOWERRORS
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

  # Create file to hide shell header
  %x = @new(FILE,%%driveletter:\home\%%sdeuser\.hushlogin,CREATE)

  list close,%%installed
  goto EvLoop


# needs work on messages
:INSTALL LIBRARIESMENU
  #----------------------------------------------------------------------------
  # syno_extract_archive.sh moves libraries from \home\%%sdeuser\sde\lib
  # to \usr\lib
  #----------------------------------------------------------------------------
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

  # Copy libraries to WSL user's home\<user>\sde\lib
  if @greater(@count(%%toinstall),0)
    list seek,%%toinstall,0
    %x = @item(%%toinstall)
    %%ok =
    while @ok() 
      if @not(@file(%%exedir\lib\%x)) 
        warn File not found! %%exedir\lib\%x ,
      else
        file copy,%%exedir\lib\%x,%%driveletter:\home\%%sdeuser\sde\lib\%x,CONFIRM,SHOWERRORS
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
  # syno_archive_extractor.sh does the following: 
  #  1. Set chmod a+x on sae.py
  #  2. Creates out folder if it's missing
  #  3. Sets owner of extracted .pat or .spk folder

  # Copy .pat file to WSL
  %%name = @name(%%file_in)
  file copy,%%file_in,%%driveletter:\home\%%sdeuser\sde\in\%%name.%%ext_in,CONFIRM,SHOWERRORS
  if @ok()
    # Open WSL shell to run script to extract .pat file
    # This is a 32 bit app so we need to use sysnative instead of system32
    shell open,@windir()\sysnative\wsl.exe
    if @not(@ok())
      warn Failed to open wsl window! ,
      goto EvLoop
    end
    wait 1

    # Get window id "user@hostname: /mnt/<drive-letter>/<path>
    %%windowid = %%username@chr(64)%%hostname@chr(58) @chr(47)@curdir_wsl() 

    # Wait until WSL window has opened (timeout after 2 seconds)
    %C = 0
    repeat
      wait 0.2
      %C = @succ(%C)
    until @winexists(%%windowid) @greater(%C,10)

    # CD to /
    window send,%%windowid,cd @chr(47)@key(ENTER), wait
    if @not(@ok())
      warn Failed to cd to /! ,
      goto EvLoop
    end
    #wait 2

    # Get window id again as now titlebar only shows "user@hostname: /"
    %%windowid = %%username@chr(64)%%hostname@chr(58) @chr(47) 

    # Wait until WSL window title has changed (timeout after 2 seconds)
    %C = 0
    repeat
      wait 0.2
      %C = @succ(%C)
    until @winexists(%%windowid) @greater(%C,10)

    %%script = @chr(47)home@chr(47)%%sdeuser@chr(47)sde@chr(47)syno_archive_extractor.sh
    #%%logfile = @chr(47)home@chr(47)%%sdeuser@chr(47)sde@chr(47)sde.log

    # Make sure bash script is executable
    #window send,%%windowid,sudo chmod a+x @chr(47)home@chr(47)%%sdeuser@chr(47)sde@chr(47)syno_archive_extractor.sh@key(ENTER), wait
    window send,%%windowid,sudo chmod a+x %%script@key(ENTER), wait
    if @not(@ok())
      warn Failed to chmod a+x syno_archive_extractor.sh! ,
      goto EvLoop
    end

    # Allow time for use to enter sudo password
    wait 10

    # Run the script to extract .pat file
    #window send,%%windowid,sudo @chr(47)home@chr(47)%%sdeuser@chr(47)sde@chr(47)syno_archive_extractor.sh %%sdeuser@key(ENTER), wait
    #window send,%%windowid,sudo %%script %%sdeuser @chr(62) %%logfile@key(ENTER), wait
    window send,%%windowid,sudo %%script %%sdeuser@key(ENTER), wait
    if @not(@ok())
      warn Failed to run syno_archive_extractor.sh! ,
      goto EvLoop
    end

    # Wait until script has extracted .pat file (timeout after 10 seconds)
    %C = 0
    repeat
      wait 0.2
      %C = @succ(%C)
    until @file(%%driveletter:\home\%%sdeuser\sde\finished) @greater(%C,10)

    ## chmod extract .pat file's folder - syno_archive_extractor.sh does it
    #window send,%%windowid,sudo chmod a+x @chr(47)home@chr(47)%%sdeuser@chr(47)sde@chr(47)out@chr(47)%%name@key(ENTER), wait
    #if @not(@ok())
    #  goto EvLoop
    #end

    # Allow user to see script finished
    #wait 5

    # Exit WSL shell
    if @ask(Do you want to close the wsl window)
      window send,%%windowid,exit@key(ENTER), wait
      if @not(@ok())
        warn Failed to close wsl window! ,
        goto EvLoop
      end
    end


    #%%pipe = @pipe()
    #
    #if @null(%%pipe)
    #  dialog set, TEXT4, Finished
    #else
    #  dialog set, TEXT5, Finished with errors!
    #  dialog show, TEXT5
    #  info %%pipe ,
    #end

  end

  # Move extracted pat/sdk folder to pat/sdk folder
  if @equal(%%move,1)
    %n = @name(%%file_in)
    %p = @path(%%file_in)
    if @file(%%driveletter:\home\%%sdeuser\sde\out\%n,D)
      directory rename,%%driveletter:\home\%%sdeuser\sde\out\%n,%p,CONFIRM,SHOWERRORS 
      if @not(@ok())
        warn Failed to move extracted %n folder! ,
      end
    end
  end
  goto EvLoop


# not working
:install_wsl
  run %%powershell wsl --install
  exit


:curdir_wsl
  #----------------------------------------------------------------------------
  # Function to return the WSL current directory path so we know the last
  # part of the wsl window's titlebar sctring
  #----------------------------------------------------------------------------
  %a = @curdir() 
  %l = @lower(@substr(%a,1)) 
  %b = @strdel(%a,1,2) 
  %c = @strrep(%b,\,@chr(47),ALL)
  %d = mnt@chr(47)%l%c
  exit %d


:open_wsl
# currently not used
  #----------------------------------------------------------------------------
  # Command to open WSL shell
  #----------------------------------------------------------------------------
  # Open WSL shell to run script to extract .pat file
  #shell open,@windir(S)\wsl.exe
  #shell open,%%exedir\wsl.exe
  shell open,@windir()\sysnative\wsl.exe
  if @not(@ok())
    warn Failed to open wsl window! ,
    exit 1
  end
  wait 1

  # Get window id "user@hostname: /mnt/<drive-letter>/<path>
  #%%windowid = %%username@chr(64)%%hostname@chr(58) @chr(47)mnt@chr(47)d@chr(47)WORK@chr(47)VDS@chr(47)Syno DSM Extractor GUI
  %%windowid = %%username@chr(64)%%hostname@chr(58) @chr(47)@curdir_wsl() 

  # Wait until WSL window has opened (timeout after 2 seconds)
  %C = 0
  repeat
    wait 0.2
    %C = @succ(%C)
  until @winexists(%%windowid) @greater(%C,10)

  # CD to /
  window send,%%windowid,cd @chr(47)@key(ENTER), wait
  if @not(@ok())
    warn Failed to cd to /! ,
    exit 1
  end
  #wait 2

  # Get window id again as now titlebar only shows "user@hostname: /"
  %%windowid = %%username@chr(64)%%hostname@chr(58) @chr(47) 

  # Wait until WSL window title has changed (timeout after 2 seconds)
  %C = 0
  repeat
    wait 0.2
    %C = @succ(%C)
  until @winexists(%%windowid) @greater(%C,10)
  exit


:Check for UpdatesMENU
  %%currentversion = @verinfo(%0,V)
  if @not(@null(%%powershell))
    %%repo = 007revad/Syno_DSM_Extractor_GUI
    # Set to cursor to wait
    dialog cursor,wait
    runh cmd /C curl.exe --silent @chr(34)https://api.github.com/repos/%%repo/releases/latest@chr(34) | findstr tag_name, pipe
    %P = @pipe()
    # Set to cursor to normal
    dialog cursor

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
      info You have the latest version. ,
    end

    title %%Title
    option fieldsep,%S
  end
  goto EvLoop
