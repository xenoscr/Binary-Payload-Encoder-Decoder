param(
	[Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$True)][string]$inputFile,
	[Parameter(Position=1,Mandatory=$True,ValueFromPipeline=$True)][string]$outputFile,
	[Parameter(Position=2,Mandatory=$True,ValueFromPipeline=$True)][string]$xorKey
)

function HexToBin([string]$s) {
	$return = @()
	for ($i = 0; $i -lt $s.Length ; $i += 2)
	{
		$return += [Byte]::Parse($s.Substring($i, 2), [System.Globalization.NumberStyles]::HexNumber)
	}
	Write-Host "HexToBin Done"
	Write-Output $return
}

function encodeBase64([string]$clear) {
	$return = ""

	$Bytes = [System.Text.Encoding]::ASCII.GetBytes($clear)
	$return = [Convert]::ToBase64String($Bytes)
	Write-Host "Base64 Encoding Done"
	return $return
}

function decodeBase64([string]$stringB64)
{
        $return = ""
        $return = [System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String($stringB64))
	Write-Host "Base64 Decoding Done"
        return $return
}

function xorEncode($plaintext, $key)
{
	$cyphertext = ""
	$keyposition = 0
	$KeyArray = $key.ToCharArray()
	$plaintext.ToCharArray() | foreach-object -process {
		$cyphertext += [char]([byte][char]$_ -bxor $KeyArray[$keyposition])
		$keyposition += 1
		if ($keyposition -eq $key.Length) {$keyposition = 0}
	}
	Write-Host "XOR Done"
	return $cyphertext
}

function decompress([byte[]]$compressed) {
	$input = New-Object System.IO.MemoryStream( , $compressed)
	$output = New-Object System.IO.MemoryStream
	$gzipStream = New-Object System.IO.Compression.GzipStream $input, ([IO.Compression.CompressionMode]::Decompress)
	$gzipStream.CopyTo($output)
	$gzipStream.Close()
	[byte[]] $byteOutArray = $output.ToArray()
	return $byteOutArray
}

[byte[]]$decoded = decompress $(HexToBin $(xorEncode $(decodeBase64 $(Get-Content $inputFile)) $xorKey).replace("~","A"))

[io.file]::WriteAllBytes($outputFile,$decoded)
