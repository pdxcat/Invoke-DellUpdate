Invoke-DellUpdate.ps1
======================
This script is used to check the bios version and update the bios of a computer. 
The script has two flags, one will return the bios information to the host console. 
The second flag will actually preform the bios update. The path must be defined for 
where the bios files must be stored. Also the bios update file must be striped to 
just the verion name for comparsion. 

Improvements
------------
Need to find a better way to make a comparsion for current bios and lastest bios. 
Right now it only depends on the you putting the file in the right place and the string 
comprasion in the right place. 