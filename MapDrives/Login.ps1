$command = @'
cmd.exe /C net use *  /delete /y
'@

Invoke-Expression -Command:$command

$groups = Get-ADPrincipalGroupMembership $env:USERNAME | Where-Object {$_.Name -like 'group*'}
switch ($groups.name)
   { ##Start switch
    'groupAccounting_W' 
    {
    If (-not(Get-PSDrive W -ErrorAction SilentlyContinue))
        {
         New-PSDrive -Name W -PSProvider FileSystem -Root \\Server\SharedData\Accounting -Persist
        }   
    }
  
      'groupCustomerService_R' 
    {
    If (-not(Get-PSDrive R -ErrorAction SilentlyContinue))
        {
         New-PSDrive -Name R -PSProvider FileSystem -Root \\Server\SharedData\CustomerService -Persist
        }   
    }

      'groupGroups_V' 
    {
    If (-not(Get-PSDrive V -ErrorAction SilentlyContinue))
        {
         New-PSDrive -Name V -PSProvider FileSystem -Root \\Server\SharedData\Groups -Persist
        }   
    }

      'groupManufacturing_N' 
    {
    If (-not(Get-PSDrive N -ErrorAction SilentlyContinue))
        {
         New-PSDrive -Name N -PSProvider FileSystem -Root \\Server\SharedData\Manufacturing -Persist
        }   
    }

      'groupHuman_Resources_H' 
    {
    If (-not(Get-PSDrive H -ErrorAction SilentlyContinue))
        {
         New-PSDrive -Name H -PSProvider FileSystem -Root \\Server\SharedData\Human_Resources -Persist
        }   
    }

      'groupPublic_QC_P' 
    {
    If (-not(Get-PSDrive P -ErrorAction SilentlyContinue))
        {
         New-PSDrive -Name P -PSProvider FileSystem -Root \\Server\SharedData\Public_QC -Persist
        }   
    }


      'groupShared_S' 
    {
    If (-not(Get-PSDrive S -ErrorAction SilentlyContinue))
        {
         New-PSDrive -Name S -PSProvider FileSystem -Root \\Server\SharedData\JAS\Shared -Persist
        }   
    }


      'groupTechnicalService_T' 
    {
    If (-not(Get-PSDrive T -ErrorAction SilentlyContinue))
        {
         New-PSDrive -Name T -PSProvider FileSystem -Root \\Server\SharedData\TechnicalService -Persist
        }   
    }







    }  ##end switch



