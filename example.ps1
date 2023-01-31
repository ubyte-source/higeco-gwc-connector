param (
    [Parameter(Mandatory=$true)][System.String]$ECHost,
    [Parameter(Mandatory=$true)][System.String]$ECPort,
    [Parameter(Mandatory=$true)][System.String]$ECProtocol,
    [Parameter(Mandatory=$true)][System.String]$ECUsername,
    [Parameter(Mandatory=$true)][System.String]$ECPassword,
    [Parameter(Mandatory=$true)][System.String]$ECReference
 )

$setting = @{
    "database" = @{
        "name" = "<name>"
        "server" = "<host>"
        "username" = "<username>"
        "password" = "<password>"
    }
    "middleware" = @{
        "host" = "192.168.11.40"
        "port" = "6443"
        "protocol" = "https"
    }
    "map" = @{
        "Q" = "q";
        "Saving percentage" = "percentage";
        "A L1" = "al1";
        "A L2" = "al2";
        "A L3" = "al3";
        "Total saving - carbon dioxide" = "total_saving_carbon_dioxide";
        "Total saving - energy" = "total_saving_energy";
        "Total saving - economic" = "total_saving_economic";
        "Total saving - power peack" = "total_saving_power_peack";
        "Level" = "level";
        "V L1-L2" = "vl12n";
        "V L2-L3" = "vl23n";
        "V L3-L1" = "vl31n";
        "Theshold" = "threshold";
        "Reactive energy" = "reactive_energy";
        "Active energy" = "active_energy";
        "p" = "p";
        "PF I" = "pfi";
        "PF C" = "pfc";
    }

}

if (-not ([System.Management.Automation.PSTypeName]"TrustAllCertsPolicy").Type) {
    Add-Type -TypeDefinition  @"
        using System.Net;
        using System.Security.Cryptography.X509Certificates;
        public class TrustAllCertsPolicy : ICertificatePolicy {
            public bool CheckValidationResult(ServicePoint srvPoint, X509Certificate certificate, WebRequest request, int certificateProblem) { return true; }
        }
"@
}


Function Execute-GetData {
    Param(
        [Parameter(Mandatory=$true)][System.String]$ip,
        [Parameter(Mandatory=$true)][System.String]$port,
        [Parameter(Mandatory=$true)][System.String]$protocol,
        [Parameter(Mandatory=$true)][System.String]$user,
        [Parameter(Mandatory=$true)][System.String]$password
    )
    Process
    {
        $request_credentials_auth = "${user}:${password}"
        $request_credentials_auth = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($request_credentials_auth))

        try
        {
            $request_uri = "$($setting.middleware.protocol)://$($setting.middleware.host):$($setting.middleware.port)/get?host=${ip}&port=${port}&protocol=${protocol}"
            $request = Invoke-RestMethod -Method Get -Headers @{Authorization = "Basic $request_credentials_auth"} -Uri $request_uri -ContentType "application/json"
            return $request.data
        }
        catch
        {
            Write-Host "Error when calling ${request_uri}"
        } 
    }
}

Function Execute-Procedure {
    Param(
        [Parameter(Mandatory=$true)][System.String]$ECReference,
        [Parameter(Mandatory=$true)][System.String]$json
    )
    Process
    {
        $connection = New-Object System.Data.SqlClient.SqlConnection
        $connection.ConnectionString = "Server=$($setting.database.server); Database=$($setting.database.name); User Id=$($setting.database.username); Password=$($setting.database.password); Trusted_Connection=False; MultipleActiveResultSets=true"

        $cmd = New-Object System.Data.SqlClient.SqlCommand
        $cmd.Connection = $connection
        $cmd.CommandTimeout = 0

        $parameter_json = New-Object System.Data.SqlClient.SqlParameter("@JSON", $json)
        $parameter_reference = New-Object System.Data.SqlClient.SqlParameter("@REFERENCE", $ECReference)

        $cmd.CommandText = "EXEC BL_I40_FixedAssets_Working_Populate @REFERENCE,@JSON"
        $cmd.Parameters.Add($parameter_json)
        $cmd.Parameters.Add($parameter_reference)

        try
        {
            $connection.Open()
            $cmd.ExecuteNonQuery() | Out-Null
        }
        catch [Exception]
        {
            Write-Warning $_.Exception.Message
        }
        finally
        {
            $connection.Dispose()
            $cmd.Dispose()
        }
    }
}

[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

$request = Execute-GetData ${ECHost} ${ECPort} ${ECProtocol} ${ECUsername} ${ECPassword}
if ( $request -ne $null ) {
    $object = @{}
    foreach( $item in $request ) {
        $object[$setting.map[$item.name]] = $item.value
    }
    $object = $object | ConvertTo-Json
    Execute-Procedure $ECReference $object
}