# Source: https://blogs.msdn.microsoft.com/jasonn/2008/06/13/downloading-files-from-the-internet-in-powershell-with-progress/

param(
    $vstsAgentGithubUrl = "https://api.github.com/repos/microsoft/vsts-agent/releases/latest"
)

function downloadFile($url, $targetFile)
{
    "Downloading $url" 
    $uri = New-Object "System.Uri" "$url" 
    $request = [System.Net.HttpWebRequest]::Create($uri) 
    $request.set_Timeout(15000) #15 second timeout 
    $response = $request.GetResponse() 
    $totalLength = [System.Math]::Floor($response.get_ContentLength()/1024) 
    $responseStream = $response.GetResponseStream() 
    $targetStream = New-Object -TypeName System.IO.FileStream -ArgumentList $targetFile, Create 
    $buffer = new-object byte[] 10KB 
    $count = $responseStream.Read($buffer,0,$buffer.length) 
    $downloadedBytes = $count 
    while ($count -gt 0) 
    {
        $targetStream.Write($buffer, 0, $count) 
        $count = $responseStream.Read($buffer,0,$buffer.length) 
        $downloadedBytes = $downloadedBytes + $count 
        Write-Progress -activity "Downloading file '$($url.split('/') | Select -Last 1)'" -status "Downloaded ($([System.Math]::Floor($downloadedBytes/1024))K of $($totalLength)K): " -PercentComplete ((([System.Math]::Floor($downloadedBytes/1024)) / $totalLength)  * 100)
    } 
    Write-Progress -activity "Finished downloading file '$($url.split('/') | Select -Last 1)'"
    $targetStream.Flush()
    $targetStream.Close() 
    $targetStream.Dispose() 
    $responseStream.Dispose() 
} 

# Call github api to get the latest release information
$response = iwr -Uri "$vstsAgentGithubUrl" -Method Get

# Convert the content to json
$json = $response.Content | ConvertFrom-Json

# Get the asset containing the agent zip file url
$asset = $json.assets | where { $_.name -like "*zip" }

# Extract the download url to the latest agent zip
$latestAgentUrl = $asset.browser_download_url
"Found url $latestAgentUrl"

# Download the zip and rename
downloadFile "$latestAgentUrl" "agent.zip"