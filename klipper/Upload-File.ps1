[CmdletBinding()]
param (
    # Specifies a path to one or more locations. Wildcards are permitted.
    [Parameter(Mandatory=$true,
               ValueFromPipeline=$true,
               ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNullOrEmpty()]
    [SupportsWildcards()]
    [string[]]
    $Path,

    [Parameter()]
    [switch]
    $Start,

    [Parameter(ValueFromPipeline=$true,
               ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $Url = "trident.local"
)
# POST /server/files/upload`
# Content-Type: multipart/form-data
# 
# ------FormBoundaryemap3PkuvKX0B3HH
# Content-Disposition: form-data; name="file"; filename="myfile.gcode"
# Content-Type: application/octet-stream
# 
# <binary data>
# ------FormBoundaryemap3PkuvKX0B3HH--
Process {

foreach ($item in Get-ChildItem $Path) {
    $FileStream = [System.IO.FileStream]::new($item.FullName, [System.IO.FileMode]::Open)
    $FileHeader = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new('form-data')
    $FileHeader.Name = "file"
    $FileHeader.FileName = $item.Name
    $FileContent = [System.Net.Http.StreamContent]::new($FileStream)
    $FileContent.Headers.ContentDisposition = $FileHeader
    $FileContent.Headers.ContentType = [System.Net.Http.Headers.MediaTypeHeaderValue]::Parse("application/octet-stream")
    
    $body = [System.Net.Http.MultipartFormDataContent]::new()
    $body.Add($FileContent)
    
    Invoke-WebRequest `
        -Method Post `
        -Uri "$url/server/files/upload" `
        -Body $body `
        -SkipHttpErrorCheck
    
    if ($Start) {
        Invoke-RestMethod `
            -Method Post `
            -Uri "http://${url}:7125/printer/print/start?filename=$($item.Name)" `
            -SkipHttpErrorCheck
        $Start = $false
    }
}

}