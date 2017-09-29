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
	return $return
}

function BinToHex([string]$fileName) {
	$return = ""
	
	$binFile = [io.file]::ReadAllBytes($fileName)
	if ($binFile.Length -eq 1) {$binFile = @($input)}
	$return = -join ($binFile |  foreach { "{0:X2}" -f $_ })
	Write-Host "BinToHex Done"
	return $return
}

function base64Encode([string]$clear) {
	$return = ""

	$Bytes = [System.Text.Encoding]::ASCII.GetBytes($clear)
	$return = [Convert]::ToBase64String($Bytes)
	Write-Host "Base64 Encoding Done"
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

[string]$encoded = base64Encode $(xorEncode $(BinToHex $inputFile).replace("A","~") $xorKey)

$encoded | Out-File $outputFile -Encoding ASCII
