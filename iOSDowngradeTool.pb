EnableExplicit

Define.s Directory = GetCurrentDirectory(), wget = "Tools\wget.exe", ipAddress, Device, Firmware
Define.s sysDir = GetEnvironmentVariable("WinDir") + "\system32\", cmd = sysDir + "cmd.exe", ping = sysDir + "ping.exe"
Define gDriveLink.s = "http://googledrive.com/host/0B2Rw19QgNYAWfl9MZHVtRnVFWVhzRU56SXF5ZlJXWUliaDNGcWF5ajFldDJ1dFU2WDk1YnM/"
Define.i Event, font, Answer, NoSSH, firmwareSize, deviceNumber
Dim filesSizes.i(4) : filesSizes(0) = 73728 : filesSizes(1) = 52064 : filesSizes(2) = 335872 : filesSizes(3) = 352256 : filesSizes(4) = 447568
Dim firmSizes.i(3) : firmSizes(0) = 967088093 : firmSizes(1) = 835654312 : firmSizes(2) = 852289339 : firmSizes(3) = 850330223

If OpenWindow(0, #PB_Ignore, #PB_Ignore, 250, 135, "iOS Downgrade Tool")

  StringGadget(1, 5, 5, 178, 22, "IP-Адрес")
  SetGadgetColor(1, #PB_Gadget_FrontColor, $696969)

  ComboBoxGadget(2, 5, 32, 240, 22)
  AddGadgetItem(2, 0, "Устройство")
  SetGadgetState(2, 0)
  AddGadgetItem(2, 1, "iPhone4,1")
  AddGadgetItem(2, 2, "iPad2,1")
  AddGadgetItem(2, 3, "iPad2,2")
  AddGadgetItem(2, 4, "iPad2,3")

  CheckBoxGadget(3, 188, 2, 60, 25, "No SSH")
  CheckBoxGadget(4, 6, 57, 160, 20, "Не скачивать прошивку")

  TextGadget(5, 223, 125, 50, 15, "v1.2.2")
  TextGadget(6, 0, 125, 50, 15, "by Kron")
  If LoadFont(0, "Ariral", 7)
    font = FontID(0)

    SetGadgetFont(5, font)
    SetGadgetFont(6, font)
  EndIf

  ButtonGadget(7, 5, 78, 240, 45, "Downgrade")
  If LoadFont(1, "Ariral", 16, #PB_Font_Bold)
    SetGadgetFont(7, FontID(1))
  EndIf

  SetCurrentDirectory(Directory)

  Repeat
    Event = WaitWindowEvent()

    If Event = #PB_Event_Gadget
      Select EventGadget()
        Case 1
          If EventType() = #PB_EventType_Focus And GetGadgetText(1) = "IP-Адрес"
            SetGadgetText(1, "")
            SetGadgetColor(1, #PB_Gadget_FrontColor, $0000000)
          EndIf
        Case 2
          If CountGadgetItems(2) = 5 : RemoveGadgetItem(2, 0) : EndIf
        Case 3
          NoSSH = GetGadgetState(3) : DisableGadget(1, NoSSH)
        Case 7
          ipAddress = GetGadgetText(1)
          Device = GetGadgetText(2)
          deviceNumber = GetGadgetState(2)
          Firmware = Directory + Device + "\custom_downgrade.ipsw"
          firmwareSize = FileSize(Firmware)

          If (Device And CountGadgetItems(2) = 4) And (NoSSH Or (ipAddress And ipAddress <> "IP-Адрес"))
            If Not FileSize(wget) = -1
              If Not FileSize(Device) = -2
                CreateDirectory(Device)
              EndIf
              If FileSize(Device + "\pwnediBSS") <> filesSizes(0)
                RunProgram(wget, "--no-check-certificate -O pwnediBSS " + gDriveLink + Device + "/pwnediBSS", Device, #PB_Program_Wait | #PB_Program_Hide)
              EndIf
              If FileSize("Tools\kloader") <> filesSizes(1)
                RunProgram(wget, "--no-check-certificate -O kloader " + gDriveLink + "kloader", "Tools", #PB_Program_Wait | #PB_Program_Hide)
              EndIf
              If FileSize("Tools\plink.exe") <> filesSizes(2)
                RunProgram(wget, "--no-check-certificate -O plink.exe " + gDriveLink + "plink.exe", "Tools", #PB_Program_Wait | #PB_Program_Hide)
              EndIf
              If FileSize("Tools\pscp.exe") <> filesSizes(3)
                RunProgram(wget, "--no-check-certificate -O pscp.exe " + gDriveLink + "pscp.exe", "Tools", #PB_Program_Wait | #PB_Program_Hide)
              EndIf
              If FileSize("Tools\idevicerestore\idevicerestore.exe") <> filesSizes(4)
                RunProgram(wget, "--no-check-certificate -O idevicerestore.zip " + gDriveLink + "idevicerestore.zip", "Tools", #PB_Program_Wait | #PB_Program_Hide)
                CreateDirectory("Tools\idevicerestore")

                UseZipPacker()

                OpenPack(0, "Tools\idevicerestore.zip")

                If ExaminePack(0)
                  While NextPackEntry(0)
                    UncompressPackFile(0, "Tools\idevicerestore\" + PackEntryName(0))
                  Wend
                EndIf

                ClosePack(0)
                DeleteFile("Tools\idevicerestore.zip")
              EndIf

              DisableGadget(7, 1)

              If firmwareSize <> firmSizes(deviceNumber)
                If GetGadgetState(4)
                  Firmware = OpenFileRequester("Выберите кастомную прошивку для " + Device, "", "IPSW|*.ipsw", 0)
                Else
                  RunProgram(cmd, "/c title FirmwareDownload & echo Скачивание прошивки... & " + wget + " --no-check-certificate -q --show-progress -O " + Device + "\custom_downgrade.ipsw " + gDriveLink + Device + "/custom_downgrade.ipsw", Directory, #PB_Program_Wait)
                EndIf

                firmwareSize = FileSize(Firmware)
              EndIf

              If firmwareSize = firmSizes(deviceNumber)
                If Not NoSSH
                  If CreateFile(0, "Tools\ssh_key.bat")
                    WriteStringN(0, "@ECHO OFF & title SSH & echo y | plink.exe -pw alpine root@" + ipAddress + " exit & exit")
                    CloseFile(0)
                  EndIf
                  RunProgram(cmd, "/c start ssh_key.bat", "Tools", #PB_Program_Wait | #PB_Program_Hide)

                  RunProgram("Tools\pscp.exe", "-pw alpine kloader root@" + ipAddress + ":/var/mobile", "Tools", #PB_Program_Wait | #PB_Program_Hide)
                  RunProgram("Tools\pscp.exe", "-pw alpine " + Device + "\pwnediBSS root@" + ipAddress + ":/var/mobile", Directory, #PB_Program_Wait | #PB_Program_Hide)
                  RunProgram("Tools\plink.exe", "-pw alpine root@" + ipAddress + " " + #DQUOTE$ + "chmod +x /var/mobile/kloader && /var/mobile/kloader /var/mobile/pwnediBSS" + #DQUOTE$, Directory, #PB_Program_Wait | #PB_Program_Hide)
                  MessageRequester("Attention", "Подождите, пока устройство выключится!" + #CRLF$ + "После этого переподключите USB-кабель и нажмите ОК" + #CRLF$ + #CRLF$ + "Если устройство долго не выключается, значит у вас проблемы с WiFi")
                EndIf

                If FileSize(Device + "\drv_st") = -1
                  If CreateFile(1, Device + "\drv_st") : CloseFile(1) : EndIf

                  Delay(5000)
                EndIf

                RunProgram(cmd, "/c title Restore & Tools\idevicerestore\idevicerestore.exe -e " + #DQUOTE$ + Firmware + #DQUOTE$ + " & " + ping + " 1.1.1.1 -n 1 -w 5000 > nul", Directory, #PB_Program_Wait)

                MessageRequester("Success", "Готово!")
              Else
                MessageRequester("Error", "Прошивка не кастомная или она повреждена!")
              EndIf

              DisableGadget(7, 0)
            Else
              MessageRequester("Error", "Отсутствует утилита wget")
            EndIf
          Else
            MessageRequester("Error", "Введите IP-Адрес и/или выберите устройство")
          EndIf
      EndSelect
    EndIf
  Until Event = #PB_Event_CloseWindow
EndIf
