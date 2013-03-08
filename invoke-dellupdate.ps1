## invoke-dellupdate.ps1
## Sandeep Parmar
## This script is used to check the bios version and update the bios of a computer. 
## Flags 
##       /b will return computer information and the bios informations requires computer name. 
##       /u will update the computers bios. You must be loggedon in to the computer and run as an Admin.
##          This doesn't need a computer name.
##       /d this flag is the default flag and does nothing.  
## Example
##      Bios information .\invoke-dellupdate.ps1 /b <computer name>
##      Update the bios  .\invoke-dellupdate.ps1 /u

param(
    [string]$option = "/d",
    [string]$CompName = $env:COMPUTERNAME
)

## The location of the bios directory. 
$BiosLocation = "\\normandy\c$\temp\bios"

## Retrieves the necessary bios information and returns it as a object.
Function get-BiosInfo{
    
    ## Retrieves the Model Number 
    $Model = ((Get-WmiObject -ComputerName $CompName -Class Win32_ComputerSystem).Model).Trim()
    ## Retrieves the computers bios version
    $ComputerBios = (Get-WmiObject -ComputerName $CompName Win32_Bios).SMBIOSBIOSVersion
    ## Retrieves the current bios version. 
    $CurrentBios = (gci $BiosLocation\$Model).basename
    
    ## Creates a new objects used to pass model, computerbios and currentbios
    $Bios = new-object PSObject
    $Bios | Add-Member -type NoteProperty -Name Model -Value $Model
    $Bios | Add-Member -type NoteProperty -Name ComputerBios -Value $ComputerBios
    $Bios | Add-Member -type NoteProperty -Name CurrentBios -Value $CurrentBios
    
    return $Bios 
     
}


## Used to display bios information. 
## Outputs: Computer Name, Model Number, Bios version the computer is on, the current update. 
Function display-BiosInfo{
   $CBios = get-BiosInfo

    Write-host -foregroundcolor Green "Computer Name:  $CompName"
    Write-host -foregroundcolor Green " Model Number: " $CBios.Model
    Write-host -foregroundcolor Green "Computer Bios: " $CBios.ComputerBios
    Write-host -foregroundcolor Green " Current Bios: " $CBios.CurrentBios
}

## Used to update the computer 
Function update-bios{
    $CBios = get-BiosInfo
    $FileLocation = "$BiosLocation\" + $CBios.Model +  "\" + $CBios.CurrentBios + ".EXE"
    $OSVer=(Get-WmiObject -Class Win32_OperatingSystem -ComputerName $CompName -ea 0).OSArchitecture
   
    if($OSVer -eq "64-bit" -and $CBios.Model -eq "Precision WorkStation 380" ){ 

        Write-host -ForegroundColor Red "Sorry can't update Bios"
        Write-host -ForegroundColor Red "Because bios won't install"
        Write-host -ForegroundColor Red "OS is 64-bit"

    }else{
            if($CBios.ComputerBios -ne $CBios.CurentBios){ 
                write-host -ForegroundColor green "Updating Bios..."
                Copy-Item $FileLocation "\\$compName\c$\temp\update2.exe"
                Invoke-Command -computername $CompName {cmd /c "c:\temp\update2.exe" "-nopause"}   
            }
        }
}

## Used to handle the different flags. 
switch -Wildcard ($option){
    "/b" {
            display-BiosInfo
         }
    "/u" {
            update-bios
         }
    default {
                write-host -foregroundcolor Red "You need pass a flag"
                write-host -foregroundcolor Red "/b for Bios Information"
                write-host -foregroundcolor Red "/u for Updating the computer information"
             }
}