<#
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
#>

<#
.SYNOPSIS
Decline updates for editions of Windows 11 your organization does not support.
.DESCRIPTION
Decline updates for editions of Windows 11 your organization does not support.
.NOTES
You must un-comment the $SupportedEditions variable and add the editions your organization supports.
The KnownEditions variable holds a list of known editions to _try_ and prevent the script from going rogue if MS decides to change the naming scheme.  If ... or when ... they do this will need to be updated.
Written By: Andrew Baker
Version 1.0: 11/30/2022
#>

#Un-comment and add elements to this array for editions you support.  Be sure to add a comma at the end in order to avoid confusion between editions.
$SupportedEditions = @("Feature update to Windows 11 Pro,","Feature update to Windows 11 \(business editions\),", "Feature update to Windows 11 \(consumer editions\),","Feature update to Windows 11 Enterprise,")

#If Microsoft decides to change their naming scheme you will need to udpate this variable to support the new scheme.  Note that commas are used to prevent mismatches.
$KnownEditions=@("Feature update to Windows 11 Pro,","Feature update to Windows 11 Pro N,","Feature update to Windows 11 Enterprise,","Feature update to Windows 11 Enterprise N,", "Feature update to Windows 11 Education,","Feature update to Windows 11 Education N,","Feature update to Windows 11 Team,","Feature update to Windows 11 \(business editions\),", "Feature update to Windows 11 \(consumer editions\),")
Function Invoke-SelectUpdatesPlugin{
    
    $DeclineUpdates = @{}
    If (!$SupportedEditions){Return $DeclineUpdates}    


    $Windows11Updates = $ActiveUpdates | Where{$_.ProductTitles.Contains('Windows 11') -or $_.ProductTitles.Contains('Windows 11*') -or $_.ProductTitles.Contains('Windows Insider Pre-Release')}
    
    #Loop through the updates and decline any that match the version.
    ForEach ($Update in $Windows11Updates){

        #Verify that the title matches one of the known edition.  If not then skip the update.
        $EditionFound=$False
        ForEach ($Edition in $KnownEditions){
            If ($Update.Title -match $Edition){$EditionFound=$True}
        }
        If(!$EditionFound){Continue} #Skip to the next update.

        #Verify that the title does not match any of the editions the user supports.
        $EditionFound=$False
        ForEach ($Edition in $SupportedEditions){
            If ($Update.Title -match $Edition){$EditionFound=$True}
        }
        
        #If one of the supported editions was found then skip to the next update.
        If($EditionFound -or (Test-Exclusions $Update)){
            Continue #Skip to the next update.
        } Else {
            $DeclineUpdates.Set_Item($Update.Id.UpdateId,"Windows 11 Edition")
        }        
    }
    Return $DeclineUpdates
}
