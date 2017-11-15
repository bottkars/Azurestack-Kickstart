foreach ($number in 1..10)
    {
    $disk = get-disk -Number $number
    $disk | Set-Disk -IsOffline:$false
    $disk | set-disk -IsReadOnly:$false
    $disk | Clear-Disk -RemoveData -RemoveOEM -Confirm:$false
    }