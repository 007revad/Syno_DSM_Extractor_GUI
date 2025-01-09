#-----------------------------------------------------------------------------#
#    Program:    Syno DSM Extractor GUI                                       #
#    File:       SDE-GUI.dsc                                                  #
#    Author:     007revad                                                     #
#    Contact:    https://github.com/007revad                                  #
#    Copyright:  2025, 007revad                                               #
#-----------------------------------------------------------------------------#
# dave@Dave-PC:/mnt/c/Windows/System32$ cd /
# dave@Dave-PC:/$ sudo chmod a+x /home/dave/sde/syno_archive_extractor.sh
# [sudo] password for dave:
# dave@Dave-PC:/$ sudo /home/dave/sde/syno_archive_extractor.sh
#-----------------------------------------------------------------------------#

  #define function,curdir_wsl
  #define command,Settings,CheckSettings

  # VDSConsole dll
#  %%LoadDLL = vdsconsole.dll
#  external vdsconsole.dll
#  #define command,consoleio
#  #define function,consoleio

  OPTION SCALE,96
  OPTION DECIMALSEP,"."
  OPTION TIMESEP,":"
  #OPTION DATESEP,"/"
  #OPTION DATEFORMAT,"dd/mm/yyyy"
  OPTION TIPTIME,4
  OPTION FIELDSEP,"|"
  OPTION REGKEY,007revad Software\Syno DSM Extractor GUI

  %%exedir = @curdir()
  if @not(@file(%%exedir\wsl.exe)) 
    warn You need to copy @windir(S)\wsl.exe to %%exedir ,
    exit
  end

  # Project Variables
  %%Title = Syno DSM Extractor GUI
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

  %%inifile = @path(%0)SDE-GUI.ini
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


  DIALOG CREATE,%%Title - v%%Version,-1,0,560,110,DRAGDROP
  #DIALOG ADD,MENU,Settings,Settings|Set Ubuntu User|Set Ubuntu Drive Letter
  DIALOG ADD,MENU,Settings,Settings|Install Scripts|Install Libraries
  DIALOG ADD,MENU,Help,About
  DIALOG ADD,STYLE,BRed,,,B,,RED
  DIALOG ADD,STYLE,BGGreen,,,BC,,00C400
  DIALOG ADD,STYLE,BCRed,,,BC,,RED
  DIALOG ADD,TEXT,TEXT1,20,18,45,18,In File
  DIALOG ADD,EDIT,EDIT1,18,70,390,18,,,READONLY
  DIALOG ADD,BUTTON,Select,15,468,70,24,Select File
  DIALOG ADD,BUTTON,Extract,60,240,74,24,Extract
  dialog disable, Extract
  dialog hide, TEXT5
  DIALOG HIDE
  if @not(@null(%1))
    %%file_in = %1
    gosub VerifyFile
  end
  DIALOG SHOW


:EvLoop
  CheckSettings
  wait event, 0.3
  goto @event() 


:TIMER
  %%ext_in = @ext(%%file_in)
  #if @file(%%file_out)
  #  dialog set, TEXT3, File Exists!
  #else
  #  dialog set, TEXT3, 
  #end
  if @equal(%%ext_in,pat) @equal(%%ext_in,spk)
    dialog enable, Extract
  else
    dialog disable, Extract
  end
  goto EvLoop 


:Close
  if @null(%%closechild)
    inifile close, %%inifile
    stop
  end
  %%closechild =
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
  dialog close
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

  DIALOG CREATE,Settings,-1,0,245,240,NOMIN
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
  DIALOG SHOWMODAL

  %%newuser = @dlgtext(NUser)
  %%newdrive = @dlgtext(NDrive)
  %%newmove = @dlgtext(CHECK1)

  %%closechild = 1
  dialog close
  exit


:SaveBUTTON
  if @not(@null(%%newuser))
    if @unequal(%%sdeuser,%%newuser)
      inifile write,main,user,%%newuser
    end
  end
  if @not(@null(%%newdrive))
    if @unequal(%%driveletter,@upper(%%newdrive))
      inifile write,main,drive,@upper(%%newdrive)
    end
  end
  inifile write,main,move,%%newmove
  goto EvLoop


:VerifyFile
  %%ext_in = @ext(%%file_in)
  %%name = @name(%%file_in)
  %%path = @path(%%file_in) 

  #%%file_out = %%path%%name.%%ext_out

  dialog set, EDIT1, %%file_in

  dialog set, TEXT4,
  dialog hide, TEXT5
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
  file copy,%%file_in,%%driveletter:\home\%%sdeuser\sde\in\%%name.%%ext_in,CONFIRM,SHOWERRORS
  if @ok()
    # Open WSL shell to run script to extract .pat file
    #shell open,@windir(S)\wsl.exe
    shell open,%%exedir\wsl.exe
    if @not(@ok())
      warn Failed to open wsl window! ,
      goto EvLoop
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

    # Allow time for script to extract .pat file
    #wait 10

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

