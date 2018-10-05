EnableExplicit

Define.s Directory = GetCurrentDirectory(), wget = "/usr/bin/wget", ssh = "/usr/bin/ssh", scp = "/usr/bin/scp", xterm = "/usr/bin/xterm", chmod = "/bin/chmod", ipAddress, Device, Firmware
Define gDriveLink.s = "http://googledrive.com/host/0B2Rw19QgNYAWfl9MZHVtRnVFWVhzRU56SXF5ZlJXWUliaDNGcWF5ajFldDJ1dFU2WDk1YnM/"
Define.i Answer, NoSSH, Event, font, firmwareSize, deviceNumber
Dim filesSizes.i(3) : filesSizes(0) = 9708 : filesSizes(1) = 73728 : filesSizes(2) = 52064 : filesSizes(3) = 146568
Dim firmSizes.i(3) : firmSizes(0) = 967088093 : firmSizes(1) = 835654312 : firmSizes(2) = 852289339 : firmSizes(3) = 850330223

If OpenWindow(0, #PB_Ignore, #PB_Ignore, 250, 138, "iOS Downgrade Tool")

  StringGadget(1, 5, 5, 169, 22, "IP-Адрес")
  SetGadgetColor(1, #PB_Gadget_FrontColor, $696969)

  ComboBoxGadget(2, 5, 32, 240, 25)
  AddGadgetItem(2, 0, "Устройство")
  SetGadgetState(2, 0)
  AddGadgetItem(2, 1, "iPhone4,1")
  AddGadgetItem(2, 2, "iPad2,1")
  AddGadgetItem(2, 3, "iPad2,2")
  AddGadgetItem(2, 4, "iPad2,3")

  CheckBoxGadget(3, 176, 2, 70, 25, "No SSH")
  CheckBoxGadget(4, 5, 60, 180, 20, "Не скачивать прошивку")

  TextGadget(5, 229, 128, 50, 15, "v1.1")
  TextGadget(6, 0, 128, 50, 15, "by Kron")
  If LoadFont(0, "Ariral", 7)
    font = FontID(0)

    SetGadgetFont(5, font)
    SetGadgetFont(6, font)
  EndIf

  ButtonGadget(7, 5, 81, 240, 45, "Downgrade")
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
          ipAddress= GetGadgetText(1)
          Device = GetGadgetText(2)
          deviceNumber = GetGadgetState(2)
          Firmware = Directory + Device + "/custom_downgrade.ipsw"
          firmwareSize = FileSize(Firmware)

          If (Device And CountGadgetItems(2) = 4) And (NoSSH Or (ipAddress And ipAddress <> "IP-Адрес"))
            If Not FileSize(wget) = -1
              If Not FileSize(xterm) = -1
                If FileSize(ssh) <> -1 And FileSize(scp) <> -1
                  If Not FileSize(Device) = -2
                    CreateDirectory(Device)
                  EndIf
                  If Not FileSize("Tools") = -2
                    CreateDirectory("Tools")
                  EndIf
                  If FileSize("Tools/sshpass") <> filesSizes(0)
                    RunProgram(wget, "--no-check-certificate -q --show-progress -O sshpass " + gDriveLink + "sshpass", "Tools", #PB_Program_Wait | #PB_Program_Hide)
                    RunProgram(chmod, "+x sshpass", "Tools", #PB_Program_Wait | #PB_Program_Hide)
                  EndIf
                  If FileSize(Device + "/pwnediBSS") <> filesSizes(1)
                    RunProgram(wget, "--no-check-certificate -q --show-progress -O pwnediBSS " + gDriveLink + Device + "/pwnediBSS", Device, #PB_Program_Wait | #PB_Program_Hide)
                  EndIf
                  If FileSize("Tools/kloader") <> filesSizes(2)
                    RunProgram(wget, "--no-check-certificate -q --show-progress -O kloader " + gDriveLink + "kloader", "Tools", #PB_Program_Wait | #PB_Program_Hide)
                  EndIf
                  If FileSize("Tools/idevicerestore/idevicerestore") <> filesSizes(3)
                    RunProgram(wget, "--no-check-certificate -q --show-progress -O idevicerestore.zip " + gDriveLink + "idevicerestore_linux.zip", "Tools", #PB_Program_Wait | #PB_Program_Hide)
                    CreateDirectory("Tools/idevicerestore")
                    CreateDirectory("Tools/idevicerestore/libs")

                    UseZipPacker()

                    OpenPack(0, "Tools/idevicerestore.zip")

                    If ExaminePack(0)
                      While NextPackEntry(0)
                        UncompressPackFile(0, "Tools/idevicerestore/" + PackEntryName(0))
                      Wend
                    EndIf

                    ClosePack(0)

                    RunProgram(chmod, "+x idevicerestore/idevicerestore", "Tools", #PB_Program_Wait | #PB_Program_Hide)
                    DeleteFile("Tools/idevicerestore.zip")
                  EndIf

                  DisableGadget(7, 1)

                  If firmwareSize <> firmSizes(deviceNumber)
                    If GetGadgetState(4)
                      Firmware = OpenFileRequester("Выберите кастомную прошивку для " + Device, "", "IPSW|*.ipsw", 0)
                    Else
                      RunProgram(xterm, "-title FirmwareDownload -e " + #DQUOTE$ + "echo Скачивание прошивки... & " + wget + " --no-check-certificate -q --show-progress -O custom_downgrade.ipsw " + gDriveLink + Device + "/custom_downgrade.ipsw" + #DQUOTE$, Device, #PB_Program_Wait)
                    EndIf

                    firmwareSize = FileSize(Firmware)
                  EndIf

                  If firmwareSize = firmSizes(deviceNumber)
                    If Not NoSSH
                      RunProgram(xterm, "-title CopyFiles -e " + #DQUOTE$ + "Tools/sshpass -p 'alpine' " + scp + " -o StrictHostKeyChecking=no -o ConnectTimeout=10 Tools/kloader " + Device + "/pwnediBSS root@" + ipAddress + ":/var/mobile" + #DQUOTE$, Directory, #PB_Program_Wait | #PB_Program_Hide)
                      RunProgram(xterm, "-title DFUEnable -e " + #DQUOTE$ + "Tools/sshpass -p 'alpine' " + ssh + " -o StrictHostKeyChecking=no -o ConnectTimeout=10 root@" + ipAddress + " 'cd /var/mobile && chmod +x kloader && ./kloader pwnediBSS'" + #DQUOTE$, Directory, #PB_Program_Hide)

                      Delay(5000)
                      MessageRequester("Attention", "Подождите, пока устройство выключится!" + #CRLF$ + "После этого переподключите USB-кабель и нажмите ОК" + #CRLF$ + #CRLF$ + "Если устройство долго не выключается, значит у вас проблемы с WiFi")
                    EndIf

                    RunProgram(xterm, "-title Restore -e " + #DQUOTE$ + "LD_LIBRARY_PATH=Tools/idevicerestore/libs Tools/idevicerestore/idevicerestore -e " + Firmware + " & sleep 5" + #DQUOTE$, Directory, #PB_Program_Wait)

                    MessageRequester("Success", "Готово!")
                  Else
                    MessageRequester("Error", "Прошивка не кастомная или она повреждена!")
                  EndIf

                  DisableGadget(7, 0)
                Else
                  MessageRequester("Error", "В системе не установлен openssh")
                EndIf
              Else
                MessageRequester("Error", "В системе не установлен xterm")
              EndIf
            Else
              MessageRequester("Error", "В системе не установлен wget")
            EndIf
          Else
            MessageRequester("Error", "Введите IP-Адрес и/или выберите устройство")
          EndIf
      EndSelect
    EndIf
  Until Event = #PB_Event_CloseWindow
EndIf
