Add-PSSnapin VeeamPSsnapin

Connect-VBRServer -server <Veeam Srver Name>

$StorageOptimzation_info = @()
foreach($vbrjob in (Get-VBRJob | Sort Name)){
    
    switch($vbrjob.Options.BackupStorageOptions.CompressionLevel){
        0 {$CompressionLevel = "None"}
        4 {$CompressionLevel = "Dedupe-friendly"}
        5 {$CompressionLevel = "Optimal (recommended)"}
        6 {$CompressionLevel = "High"}
        9 {$CompressionLevel = "Extreme"}
    }

    switch($vbrjob.Options.BackupStorageOptions.StgBlockSize){
        KbBlockSize256 {$StgBlockSize = "256KB"; $StorageOptimization = "WAN target"}
        KbBlockSize512 {$StgBlockSize = "512KB"; $StorageOptimization = "LAN target"}
        KbBlockSize1024 {$StgBlockSize = "1024KB"; $StorageOptimization = "Local target"}
        KbBlockSize4096 {$StgBlockSize = "4096KB"; $StorageOptimization = "Local target 16TB +"}
    }

    $StorageOptimzation_info += [pscustomobject][ordered]@{
        VBRjob = $vbrjob.Name
        Blocksize = $StgBlockSize
        StorageOptimization = $StorageOptimization
        CompressionLevel = $CompressionLevel
        EnableDeduplication = $vbrjob.Options.BackupStorageOptions.EnableDeduplication
        ExcludeSwapFiles = $vbrjob.Options.ViSourceOptions.ExcludeSwapFile
        ExcludeDeletedFileBlocks = $vbrjob.Options.ViSourceOptions.DirtyBlocksNullingEnabled
        BackupFileEncryption = $vbrjob.Options.BackupStorageOptions.StorageEncryptionEnabled
    }

}
$StorageOptimzation_info | ft -AutoSize

Disconnect-VBRServer
