
# Get Image
function Get-RandomOrSelectImage{
	Write-Host "[Get-RandomOrSelectImage]:START"

	$mode = Read-Host "Image random mode: r or R, select mode: s or S, in case of no need is others"
	if(($mode -eq 'r') -or ($mode -eq 'R')){
		$pattern = Read-Host "Image pattern:please Enter. repeating pattern(default): y spot: n"
		switch -Wildcard ($pattern) {
			"[yY]"{ 
				Write-Host "pattern1"
				$image = Get-RandomSourceImg

			}
			"[nN]"{
				Write-Host "pattern2"
				# Set images randomly.
				$image = Get-RandomSourceImg		
			}
			Default {
				Write-Host "default1"
				$image = Get-RandomSourceImg
			}
		}
	}elseif(($mode -eq 's') -or ($mode -eq 'S')){
		$pattern = Read-Host "Image pattern:please Enter. repeating pattern(default): y spot: n"
		switch -Wildcard ($pattern) {
			"[yY]"{ 
				Write-Host "pattern3"
				$image = Get-SelectSourceImg		
			}
			"[nN]"{
				Write-Host "pattern4"
				# Set select images
				$image = Get-SelectSourceImg		
			}
			Default {
				Write-Host "default2"
				$image = Get-SelectSourceImg
			}
		}
	}else{
		Write-Host "[Get-RandomOrSelectImage]:NO NEED"
		return
	}
	Write-Host "[Get-RandomOrSelectImage]:END"
	return $image
}

function Get-RectValues($image,$rectmode){
	Write-Host "[Get-RectValues]:START"
	[Array]$arr = $image
#	$type = $arr.GetType()
#	Write-Host "type:$type"
	$Image = $arr[0]
	$mode = $arr[1]
#	Write-Host "$Image, $mode"

	switch($mode) {
		"x"{ 
			Write-Host "mode1"
			$ret_xcoodinate = Get-Random -Maximum 360 -Minimum 0
			Write-Host "ret_xcoodinate: $ret_xcoodinate"
			return $ret_xcoodinate
		}
		"y"{
			Write-Host "mode2"
			$ret_ycoodinate = Get-Random -Maximum 360 -Minimum 0
			Write-Host "ret_ycoodinate: $ret_ycoodinate"
			return $ret_ycoodinate
		}
		"width"{ 
			Write-Host "mode3:width"
			Write-Host $image.Width
			$ret_width = Get-Random -Maximum ($Image.Width) -Minimum 1
			Write-Host "ret_width: $ret_width"
			return $ret_width
		}
		"height"{
			Write-Host "mode4:height"
			Write-Host $image.Height
			$ret_height = Get-Random -Maximum ($Image.Height) -Minimum 1
			Write-Host "ret_height: $ret_height"
			return $ret_height
		}
		Default {
			Write-Host "default"
		}
	}

	Write-Host "[Get-RectValues]:END"
}

# create new background image processes's main routine
function New-BakcgroundImg{
	Write-Host "[New-BakcgroundImg]:START"
	$image = $null
	$image = Get-RandomOrSelectImage
	if ($null -eq $image) {
		Write-Host "[New-BakcgroundImg]:image is nothing"
		return
	}	
#	Write-Host $image.GetType()

	# Get Rectangle's values
	$mode = "x"
	$xcoodinate = Get-RectValues($image,$mode)
	$mode = "y"
	$ycoodinate = Get-RectValues($image,$mode)
	$mode = "width"
	$width = Get-RectValues($image,$mode)
	$mode = "height"
	$height = Get-RectValues($image,$mode)

	# Crop the image
#	$Rect = New-Object System.Drawing.Rectangle(17, 89, 600, 234)
	$Rect = New-Object System.Drawing.Rectangle($xcoodinate, $ycoodinate, $width, $height)

	try {
		$Dstimage = $image.Clone($Rect, 925707)
	}
	catch {
		Write-Host "[New-BakcgroundImg]:recursive call"
		New-BakcgroundImg
		return
	}
	$savename = Read-Host "please enter filename to save as PNG"
	$Dstimage.Save($backgroundImgDir + "$savename", [System.Drawing.Imaging.ImageFormat]::Png)		

	Write-Host "[New-BakcgroundImg]:END"
	return
}

# Return a random datastore file.
function Get-RandomStoreFile{
	# Get the file name and put it into an array
	[System.Array]$arr = Get-ChildItem -Path ./store_file -Include @("*.txt") -Name

	$count_arr = $arr.Count
	if($count_arr -ge 2){
		$num_select = Get-Random -Maximum ($count_arr - 1) -Minimum 0
	}elseif ($count_arr -eq 1) {
		$num_select = 0
	}else {
		Write-Host "There is no data store file!"
		return
	}
	$selected = $arr[$num_select]

	$fullpath = $store_fileDir + $selected
	Write-Host "[Get-RandomStoreFile]selected: $selected fullpath: $fullpath"

	return $selected
}

# Select and return a datastore file.
function Get-SelectStoreFile{
	# Get the file name and put it into an array
	$arr = Get-ChildItem -Path ./store_file -Include @("*.txt") -Name

	$Font = New-Object System.Drawing.Font("Meiryo UI",12)
	$form = New-Object System.Windows.Forms.Form
	$form.Text = "Select"
	$form.Size = New-Object System.Drawing.Size(600,450)
	$form.StartPosition = "CenterScreen"
	$form.font = $Font

	$label = New-Object System.Windows.Forms.Label
	$label.Location = New-Object System.Drawing.Point(10,10)
	$label.Size = New-Object System.Drawing.Size(500,40)
	$label.Text = "Select the data store file"
	$form.Controls.Add($label)

	$OKButton = New-Object System.Windows.Forms.Button
	$OKButton.Location = New-Object System.Drawing.Point(40,100)
	$OKButton.Size = New-Object System.Drawing.Size(75,30)
	$OKButton.Text = "OK"
	$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
	$form.AcceptButton = $OKButton
	$form.Controls.Add($OKButton)

	$CancelButton = New-Object System.Windows.Forms.Button
	$CancelButton.Location = New-Object System.Drawing.Point(130,100)
	$CancelButton.Size = New-Object System.Drawing.Size(75,30)
	$CancelButton.Text = "Cancel"
	$CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
	$form.CancelButton = $CancelButton
	$form.Controls.Add($CancelButton)

	$Combo = New-Object System.Windows.Forms.Combobox
	$Combo.Location = New-Object System.Drawing.Point(50,50)
	$Combo.size = New-Object System.Drawing.Size(500,60)
	$Combo.DropDownStyle = "DropDown"
	$Combo.FlatStyle = "standard"
	$Combo.font = $Font

	while ($true) {
		$str_BackColor = Get-RandomColor
		if ($str_BackColor -ne "Transparent") {
			break
		}		
	}
#	Write-Host "Combo.BackColor: $str_BackColor"
	$Combo.BackColor = $str_BackColor

	while ($true) {
		$str_ForeColor = Get-RandomColor
		if ($str_BackColor -ne "Transparent") {
			break
		}		
	}
#	Write-Host "Combo.ForeColor: $str_ForeColor"
	$Combo.ForeColor = $str_ForeColor

	# Add an array item to the combo box
	ForEach ($select in $arr){
		[void] $Combo.Items.Add("$select")
	}

	$form.Controls.Add($Combo)
	$form.Topmost = $True
	$result = $form.ShowDialog()

	if ($result -eq "OK")
	{
		$ret = $combo.Text
	}else{
		exit
	}

	$fullpath = $store_fileDir + $ret
	Write-Host "[Get-SelectStoreFile]selected: $ret fullpath: $fullpath"

	return $ret
}

# Return a random image.
function Get-RandomBackgroundImg{
	Write-Host "[Get-RandomBackgroundImg] START"
	# Add an array item to the combo box
	$arr = Get-ChildItem -Path $backgroundImgDir -Include @("*.jpg","*.jpeg","*.png","*.gif") -Name

	$count_arr = $arr.Count
	$num_select = Get-Random -Maximum ($count_arr - 1)
	$selected = $arr[$num_select]

	$fullpath = $backgroundImgDir + $selected
	Write-Host "selected: $selected, fullpath: $fullpath"

	$img = [System.Drawing.Image]::FromFile($fullpath)

	Write-Host "[Get-RandomBackgroundImg] END"
	return $img
}

# Select and return an image.
function Get-SelectBackgroundImg{
	# Get the file name and put it into an array
	$arr = Get-ChildItem -Path $backgroundImgDir -Include @("*.jpg","*.jpeg","*.png","*.gif") -Name

	$Font = New-Object System.Drawing.Font("Meiryo UI",12)
	$form = New-Object System.Windows.Forms.Form
	$form.Text = "Select"
	$form.Size = New-Object System.Drawing.Size(600,450)
	$form.StartPosition = "CenterScreen"
	$form.font = $Font

	$label = New-Object System.Windows.Forms.Label
	$label.Location = New-Object System.Drawing.Point(10,10)
	$label.Size = New-Object System.Drawing.Size(500,40)
	$label.Text = "Please select an image"
	$form.Controls.Add($label)

	$OKButton = New-Object System.Windows.Forms.Button
	$OKButton.Location = New-Object System.Drawing.Point(40,100)
	$OKButton.Size = New-Object System.Drawing.Size(75,30)
	$OKButton.Text = "OK"
	$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
	$form.AcceptButton = $OKButton
	$form.Controls.Add($OKButton)

	$CancelButton = New-Object System.Windows.Forms.Button
	$CancelButton.Location = New-Object System.Drawing.Point(130,100)
	$CancelButton.Size = New-Object System.Drawing.Size(75,30)
	$CancelButton.Text = "Cancel"
	$CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
	$form.CancelButton = $CancelButton
	$form.Controls.Add($CancelButton)

	$Combo = New-Object System.Windows.Forms.Combobox
	$Combo.Location = New-Object System.Drawing.Point(50,50)
	$Combo.size = New-Object System.Drawing.Size(500,60)
	$Combo.DropDownStyle = "DropDown"
	$Combo.FlatStyle = "standard"
	$Combo.font = $Font

	while ($true) {
		$str_BackColor = Get-RandomColor
		if ($str_BackColor -ne "Transparent") {
			break
		}		
	}
#	Write-Host "Combo.BackColor: $str_BackColor"
	$Combo.BackColor = $str_BackColor

	while ($true) {
		$str_ForeColor = Get-RandomColor
		if ($str_BackColor -ne "Transparent") {
			break
		}		
	}
#	Write-Host "Combo.ForeColor: $str_ForeColor"
	$Combo.ForeColor = $str_ForeColor

	# Add an array item to the combo box
	ForEach ($select in $arr){
		[void] $Combo.Items.Add("$select")
	}

	$form.Controls.Add($Combo)
	$form.Topmost = $True
	$result = $form.ShowDialog()

	if ($result -eq "OK")
	{
		$ret = $combo.Text
		Write-Host "[Get-SelectBackgroundImg]img: $ret"
	}else{
		exit
	}

	$fullpath = $backgroundImgDir + $ret
	Write-Host "selected: $ret, fullpath: $fullpath"

	$img = [System.Drawing.Image]::FromFile($fullpath)

	return $img
}

# Return a random image.
function Get-RandomSourceImg{
	# Add an array item to the combo box
	$arr = Get-ChildItem -Path ./source_img -Include @("*.jpg","*.jpeg","*.png","*.gif") -Name

	$count_arr = $arr.Count
	$num_select = Get-Random -Maximum ($count_arr - 1)
	$selected = $arr[$num_select]

	$fullpath = $sourceImgDir + $selected
	Write-Host "selected: $selected, fullpath: $fullpath"

	$img = [System.Drawing.Image]::FromFile($fullpath)

	return $img
}

# Select and return an image.
function Get-SelectSourceImg{
	# Get the file name and put it into an array
	$arr = Get-ChildItem -Path ./source_img -Include @("*.jpg","*.jpeg","*.png","*.gif") -Name

	$Font = New-Object System.Drawing.Font("Meiryo UI",12)
	$form = New-Object System.Windows.Forms.Form
	$form.Text = "Select"
	$form.Size = New-Object System.Drawing.Size(600,450)
	$form.StartPosition = "CenterScreen"
	$form.font = $Font

	$label = New-Object System.Windows.Forms.Label
	$label.Location = New-Object System.Drawing.Point(10,10)
	$label.Size = New-Object System.Drawing.Size(500,40)
	$label.Text = "Please select an image"
	$form.Controls.Add($label)

	$OKButton = New-Object System.Windows.Forms.Button
	$OKButton.Location = New-Object System.Drawing.Point(40,100)
	$OKButton.Size = New-Object System.Drawing.Size(75,30)
	$OKButton.Text = "OK"
	$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
	$form.AcceptButton = $OKButton
	$form.Controls.Add($OKButton)

	$CancelButton = New-Object System.Windows.Forms.Button
	$CancelButton.Location = New-Object System.Drawing.Point(130,100)
	$CancelButton.Size = New-Object System.Drawing.Size(75,30)
	$CancelButton.Text = "Cancel"
	$CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
	$form.CancelButton = $CancelButton
	$form.Controls.Add($CancelButton)

	$Combo = New-Object System.Windows.Forms.Combobox
	$Combo.Location = New-Object System.Drawing.Point(50,50)
	$Combo.size = New-Object System.Drawing.Size(500,60)
	$Combo.DropDownStyle = "DropDown"
	$Combo.FlatStyle = "standard"
	$Combo.font = $Font

	while ($true) {
		$str_BackColor = Get-RandomColor
		if ($str_BackColor -ne "Transparent") {
			break
		}		
	}
#	Write-Host "Combo.BackColor: $str_BackColor"
	$Combo.BackColor = $str_BackColor

	while ($true) {
		$str_ForeColor = Get-RandomColor
		if ($str_BackColor -ne "Transparent") {
			break
		}		
	}
#	Write-Host "Combo.ForeColor: $str_ForeColor"
	$Combo.ForeColor = $str_ForeColor

	# Add an array item to the combo box
	ForEach ($select in $arr){
		[void] $Combo.Items.Add("$select")
	}

	$form.Controls.Add($Combo)
	$form.Topmost = $True
	$result = $form.ShowDialog()

	if ($result -eq "OK")
	{
		$ret = $combo.Text
		Write-Host "[Get-SelectSourceImg]selectsize: $ret"
	}else{
		exit
	}

	$fullpath = $sourceImgDir + $ret
	Write-Host "selected: $ret, fullpath: $fullpath"

	$img = [System.Drawing.Image]::FromFile($fullpath)

	return $img
}

# Pass a Windows Form to convert and save it as an image file.
function Convert-LabelToImage($form){
	#	Write-Host "Convert-LabelToImage: START"
	
	#	$formType = $form.GetType()
	#	Write-Host "formType: $formType"
		$size = $label.Size
		$height = $size.Height
		$width = $size.Width
	#	$sizeType = $size.GetType()
	#	Write-Host "size Type: $sizeType, value: $size, width: $width, height: $height"
	
		$DstBmp = New-Object System.Drawing.Bitmap($width, $height)
		$Rect = New-Object System.Drawing.Rectangle(0, 0, $width, $height)
		# Convert a label to a Bitmap
		$form.DrawToBitmap($DstBmp, $Rect)
	
		$savename = Read-Host "please enter filename to save as PNG" 
		
		try{
			# Save the file
			$DstBmp.Save((Get-Location).Path + '\WinForm_png\' + "$savename", [System.Drawing.Imaging.ImageFormat]::Png)	
		}catch{
			Write-Host "Save failed."
			throw ArgumentNullException
		}
		"savename: $savename" | Add-Content $logfilename -Encoding UTF8
	
	#	Write-Host "Convert-LabelToImage: END"
	}
	
# Return a random label size
function Get-RandomLabelSize{
	$sizefilename = "./sizefile.txt"
	# Get the size definition from the file and put it into an array
	$arr_size = Get-Content -LiteralPath $sizefilename -Encoding UTF8
	$count_arr = $arr_size.Count
	$num_select = Get-Random -Maximum ($count_arr - 1) -Minimum 0
	$selectsize = $arr_size[$num_select]
	Write-Host "[Get-RandomLabelSize]selectsize: $selectsize num_all: $count_arr ,num_select: $num_select"

	return $selectsize
}

# Select and return the label size
function Get-SelectLabelSize{
	$sizefilename = "./sizefile.txt"
	$arr_size = Get-Content -LiteralPath $sizefilename -Encoding UTF8

	$Font = New-Object System.Drawing.Font("Meiryo UI",12)
	$form = New-Object System.Windows.Forms.Form
	$form.Text = "Select"
	$form.Size = New-Object System.Drawing.Size(600,450)
	$form.StartPosition = "CenterScreen"
	$form.font = $Font

	$label = New-Object System.Windows.Forms.Label
	$label.Location = New-Object System.Drawing.Point(10,10)
	$label.Size = New-Object System.Drawing.Size(500,40)
	$label.Text = "Select the size"
	$form.Controls.Add($label)

	$OKButton = New-Object System.Windows.Forms.Button
	$OKButton.Location = New-Object System.Drawing.Point(40,100)
	$OKButton.Size = New-Object System.Drawing.Size(75,30)
	$OKButton.Text = "OK"
	$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
	$form.AcceptButton = $OKButton
	$form.Controls.Add($OKButton)

	$CancelButton = New-Object System.Windows.Forms.Button
	$CancelButton.Location = New-Object System.Drawing.Point(130,100)
	$CancelButton.Size = New-Object System.Drawing.Size(75,30)
	$CancelButton.Text = "Cancel"
	$CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
	$form.CancelButton = $CancelButton
	$form.Controls.Add($CancelButton)

	$Combo = New-Object System.Windows.Forms.Combobox
	$Combo.Location = New-Object System.Drawing.Point(50,50)
	$Combo.size = New-Object System.Drawing.Size(500,60)
	$Combo.DropDownStyle = "DropDown"
	$Combo.FlatStyle = "standard"
	$Combo.font = $Font

	while ($true) {
		$str_BackColor = Get-RandomColor
		if ($str_BackColor -ne "Transparent") {
			break
		}		
	}
#	Write-Host "Combo.BackColor: $str_BackColor"
	$Combo.BackColor = $str_BackColor

	while ($true) {
		$str_ForeColor = Get-RandomColor
		if ($str_BackColor -ne "Transparent") {
			break
		}		
	}
#	Write-Host "Combo.ForeColor: $str_ForeColor"
	$Combo.ForeColor = $str_ForeColor

	# Add an array item to the combo box
	ForEach ($select in $arr_size){
		[void] $Combo.Items.Add("$select")
	}

	$form.Controls.Add($Combo)
	$form.Topmost = $True
	$result = $form.ShowDialog()

	if ($result -eq "OK")
	{
		$ret = $combo.Text
		Write-Host "[Get-SelectLabelSize]selectsize: $ret"
	}else{
		exit
	}

	return $ret
}

# Return the text placement randomly
function Get-RandomTextAlign{
#	Write-Host "Get-RandomTextAlign: START"

	# Get the definition of an enumerated type and put it into an array.
	$arr = [System.Drawing.ContentAlignment]|get-member -static -MemberType Property | Select-Object Name	
	$count_arr = $arr.Count
	$num_select = Get-Random -Maximum ($count_arr - 1)
	$selected = $arr[$num_select]
	$ret = $selected.Name

#	Write-Host "[Get-RandomTextAlign]TextAlign: $ret"
#	"TextAlign: $ret" | Add-Content $logfilename -Encoding UTF8
	return $ret
}

# Select and return the size of the label
function Get-SelectTextAlign{
	# Get the definition of an enumerated type and pack it into an array.
	$arr = [System.Drawing.ContentAlignment]|get-member -static -MemberType Property | Select-Object Name	

	$Font = New-Object System.Drawing.Font("Meiryo UI",12)
	$form = New-Object System.Windows.Forms.Form
	$form.Text = "Select"
	$form.Size = New-Object System.Drawing.Size(600,450)
	$form.StartPosition = "CenterScreen"
	$form.font = $Font

	$label = New-Object System.Windows.Forms.Label
	$label.Location = New-Object System.Drawing.Point(10,10)
	$label.Size = New-Object System.Drawing.Size(500,40)
	$label.Text = "Select the text placement"
	$form.Controls.Add($label)

	$OKButton = New-Object System.Windows.Forms.Button
	$OKButton.Location = New-Object System.Drawing.Point(40,100)
	$OKButton.Size = New-Object System.Drawing.Size(75,30)
	$OKButton.Text = "OK"
	$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
	$form.AcceptButton = $OKButton
	$form.Controls.Add($OKButton)

	$CancelButton = New-Object System.Windows.Forms.Button
	$CancelButton.Location = New-Object System.Drawing.Point(130,100)
	$CancelButton.Size = New-Object System.Drawing.Size(75,30)
	$CancelButton.Text = "Cancel"
	$CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
	$form.CancelButton = $CancelButton
	$form.Controls.Add($CancelButton)

	$Combo = New-Object System.Windows.Forms.Combobox
	$Combo.Location = New-Object System.Drawing.Point(50,50)
	$Combo.size = New-Object System.Drawing.Size(500,60)
	$Combo.DropDownStyle = "DropDown"
	$Combo.FlatStyle = "standard"
	$Combo.font = $Font

	while ($true) {
		$str_BackColor = Get-RandomColor
		if ($str_BackColor -ne "Transparent") {
			break
		}		
	}
#	Write-Host "Combo.BackColor: $str_BackColor"
	$Combo.BackColor = $str_BackColor

	while ($true) {
		$str_ForeColor = Get-RandomColor
		if ($str_BackColor -ne "Transparent") {
			break
		}		
	}
#	Write-Host "Combo.ForeColor: $str_ForeColor"
	$Combo.ForeColor = $str_ForeColor

	# Add an array item to the combo box
	ForEach ($select in $arr){
		[void] $Combo.Items.Add($select.Name)
	}

	$form.Controls.Add($Combo)
	$form.Topmost = $True
	$result = $form.ShowDialog()

	if ($result -eq "OK")
	{
		$ret = $combo.Text
#		Write-Host [Get-SelectTextAlign]TextAlign: $ret
#		"TextAlign: $ret" | Add-Content $logfilename -Encoding UTF8
	}else{
		exit
	}

	return $ret
}

# Return a string registered in a datastore file at random
function Get-RandomRegisteredStr($storefilename){
	# Read the registered contents from the file and put it into an array
	$arr_file = Get-Content -LiteralPath $storefilename -Encoding UTF8
	$count_arr = $arr_file.Count
	$num_select = Get-Random -Maximum ($count_arr - 1)
	$selectstr = $arr_file[$num_select]
	Write-Host "[Get-RandomRegisteredStr]selectstr: $selectstr num_all: $count_arr ,num_select: $num_select"

	return $selectstr
}

# Select and return a registered string
function Get-SelectRegisteredStr($storefilename){
	$arr_str_all = Get-Content -LiteralPath $storefilename -Encoding UTF8

	$Font = New-Object System.Drawing.Font("Meiryo UI",12)
	$form = New-Object System.Windows.Forms.Form
	$form.Text = "Select"
	$form.Size = New-Object System.Drawing.Size(600,450)
	$form.StartPosition = "CenterScreen"
	$form.font = $Font

	$label = New-Object System.Windows.Forms.Label
	$label.Location = New-Object System.Drawing.Point(10,10)
	$label.Size = New-Object System.Drawing.Size(500,40)
	$label.Text = "Please select a string."
	$form.Controls.Add($label)

	$OKButton = New-Object System.Windows.Forms.Button
	$OKButton.Location = New-Object System.Drawing.Point(40,100)
	$OKButton.Size = New-Object System.Drawing.Size(75,30)
	$OKButton.Text = "OK"
	$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
	$form.AcceptButton = $OKButton
	$form.Controls.Add($OKButton)

	$CancelButton = New-Object System.Windows.Forms.Button
	$CancelButton.Location = New-Object System.Drawing.Point(130,100)
	$CancelButton.Size = New-Object System.Drawing.Size(75,30)
	$CancelButton.Text = "Cancel"
	$CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
	$form.CancelButton = $CancelButton
	$form.Controls.Add($CancelButton)

	$Combo = New-Object System.Windows.Forms.Combobox
	$Combo.Location = New-Object System.Drawing.Point(50,50)
	$Combo.size = New-Object System.Drawing.Size(500,60)
	$Combo.DropDownStyle = "DropDown"
	$Combo.FlatStyle = "standard"
	$Combo.font = $Font

	while ($true) {
		$str_BackColor = Get-RandomColor
		if ($str_BackColor -ne "Transparent") {
			break
		}		
	}
#	Write-Host "Combo.BackColor: $str_BackColor"
	$Combo.BackColor = $str_BackColor

	while ($true) {
		$str_ForeColor = Get-RandomColor
		if ($str_BackColor -ne "Transparent") {
			break
		}		
	}
#	Write-Host "Combo.ForeColor: $str_ForeColor"
	$Combo.ForeColor = $str_ForeColor

	# Add an array item to the combo box
	ForEach ($select in $arr_str_all){
		[void] $Combo.Items.Add("$select")
	}

	$form.Controls.Add($Combo)
	$form.Topmost = $True
	$result = $form.ShowDialog()

	if ($result -eq "OK")
	{
		$ret = $combo.Text
		Write-Host "[Get-RandomRegisteredStr]selectstr: $ret"
	}else{
		exit
	}

	return $ret
}

# Return one color of system.drawing.color at random
function Get-RandomColor{

	$arr_color = @()

	# Obtain color name information and put it into an array.
	$arr_all = [system.drawing.color]|get-member -static -MemberType Property | Select-Object Name

	foreach($color in $arr_all){
		if($color.Name -eq "Empty"){
				continue
		}
#		Write-Host $font.Name
		$arr_color += $color
	}
	$count = $arr_color.Count
	$select = Get-Random -Maximum ($count - 1)
	$retcolor = $arr_color[$select]

	Write-Host $retcolor.Name
	return $retcolor.Name
}

# Return a random font name.
function Get-RandomFont{
	$exclude_file = "./excludeFont.txt"
	$excludes = Get-Content -LiteralPath $exclude_file -Encoding UTF8
	Write-Host $excludes.Count
#	Write-Host arr_exclude: $arr_exclude count: $arr_exclude.Count
	
	$arr_font_all = [System.Drawing.FontFamily]::Families

	$arr_font = @()
	foreach($font in $arr_font_all){
		if($excludes -contains $font.Name){
			continue
		}
#		Write-Host $font.Name
		$arr_font += $font
	}
#	$arr_font = $arr_font_all | Select-Object -ExcludeProperty $arr_exclude 

	$count_all = $arr_font_all.Count
	$count = $arr_font.Count
	Write-Host "[Get-RandomFont]count_all: $count_all, count: $count"
#	Write-Host "arr_font: $arr_font"

	$num_select = Get-Random -Maximum ($count - 1)
	Write-Host "num_select: $num_select"
	$ret_font = $arr_font[$num_select]
	$ret_str = $ret_font.Name
	Write-Host "ret_str: $ret_str"

	if($ret_font.Length -eq 0){
		Get-RandomFont
	}

	return $ret_str
}

# Select and return a font.
function Get-SelectFont{
	$arr_font = [System.Drawing.FontFamily]::Families

	$Font = New-Object System.Drawing.Font("Meiryo UI",12)
	$form = New-Object System.Windows.Forms.Form
	$form.Text = "Select"
	$form.Size = New-Object System.Drawing.Size(600,450)
	$form.StartPosition = "CenterScreen"
	$form.font = $Font

	$label = New-Object System.Windows.Forms.Label
	$label.Location = New-Object System.Drawing.Point(10,10)
	$label.Size = New-Object System.Drawing.Size(400,40)
	$label.Text = "Please select a font."
	$form.Controls.Add($label)

	$OKButton = New-Object System.Windows.Forms.Button
	$OKButton.Location = New-Object System.Drawing.Point(40,100)
	$OKButton.Size = New-Object System.Drawing.Size(75,30)
	$OKButton.Text = "OK"
	$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
	$form.AcceptButton = $OKButton
	$form.Controls.Add($OKButton)

	$CancelButton = New-Object System.Windows.Forms.Button
	$CancelButton.Location = New-Object System.Drawing.Point(130,100)
	$CancelButton.Size = New-Object System.Drawing.Size(75,30)
	$CancelButton.Text = "Cancel"
	$CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
	$form.CancelButton = $CancelButton
	$form.Controls.Add($CancelButton)

	$Combo = New-Object System.Windows.Forms.Combobox
	$Combo.Location = New-Object System.Drawing.Point(50,50)
	$Combo.size = New-Object System.Drawing.Size(400,50)
	$Combo.DropDownStyle = "DropDown"
	$Combo.FlatStyle = "standard"
	$Combo.font = $Font

	while ($true) {
		$str_BackColor = Get-RandomColor
		if ($str_BackColor -ne "Transparent") {
			break
		}		
	}
#	Write-Host "Combo.BackColor: $str_BackColor"
	$Combo.BackColor = $str_BackColor

	$str_ForeColor = Get-RandomColor
#	Write-Host "Combo.ForeColor: $str_ForeColor"
	$Combo.ForeColor = $str_ForeColor

	# Get the content to be excluded
	$exclude_file = "./excludeFont.txt"
	$excludes = Get-Content -LiteralPath $exclude_file -Encoding UTF8

	# Exclude content in exclude file
	$arr = @()
	foreach($font in $arr_font){
		if($excludes -contains $font.Name){
			continue
		}
#		Write-Host $font.Name
		$arr += $font
	}

	# Add an array item to the combo box
	ForEach ($select in $arr){
		$fontname = $select.Name
		[void] $Combo.Items.Add("$fontname")
	}

	$form.Controls.Add($Combo)
	$form.Topmost = $True
	$result = $form.ShowDialog()

	if ($result -eq "OK")
	{
		$ret = $combo.Text
	}else{
		exit
	}

	return $ret
}

function Show_Message($text){
#	Write-Host "Show_Message: start"
	$partition = "==========================="
	$partition | Add-Content $logfilename -Encoding UTF8

	"text: $text" | Add-Content $logfilename -Encoding UTF8

	$form = New-Object System.Windows.Forms.Form
	$form.Text = "ShowMessage"
	$form.Size = New-Object System.Drawing.Size(900,500)
	$form.StartPosition = "CenterScreen"

	while ($true) {
		$str_BackColor = Get-RandomColor
		if ($str_BackColor -ne "Transparent") {
			break
		}		
	}
#	Write-Host "[Show_Message]str_BackColor: $str_BackColor"
	$form.BackColor = $str_BackColor
	"backColor: $str_BackColor" | Add-Content $logfilename -Encoding UTF8
	
	$form.MaximizeBox = $false
	$form.MinimizeBox = $false
	$form.FormBorderStyle = "FixedSingle"
	$form.Opacity = 1

	$OKButton = New-Object System.Windows.Forms.Button
	$OKButton.Location = New-Object System.Drawing.Point(40,100)
	$OKButton.Size = New-Object System.Drawing.Size(75,30)
	$OKButton.Text = "OK"
	$OKButton.DialogResult = "OK"
	$OKButton.Flatstyle = "Popup"

	while ($true) {
		$str_OKBackColor = Get-RandomColor
		if ($str_BackColor -ne "Transparent") {
			break
		}		
	}
	#	Write-Host "str_OKBackColor: $str_OKBackColor"
	$OKButton.Backcolor = $str_OKBackColor

	$str_OKForeColor = Get-RandomColor
#	Write-Host "str_OKForeColor: $str_OKForeColor"
	$OKButton.forecolor = $str_OKForeColor

	$CancelButton = New-Object System.Windows.Forms.Button
	$CancelButton.Location = New-Object System.Drawing.Point(130,100)
	$CancelButton.Size = New-Object System.Drawing.Size(75,30)
	$CancelButton.Text = "Cancel"
	$CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
	$form.CancelButton = $CancelButton
	$form.Controls.Add($CancelButton)
	
	# Font settings
	$mode = Read-Host "Font random mode: r or R , select mode: s or S"
	if(($mode -eq 'r') -or ($mode -eq 'R')){
		# Set font randomly
		$font_selected = Get-RandomFont
	}elseif(($mode -eq 's') -or ($mode -eq 'S')) {
		# Select and set a font
		$font_selected = Get-SelectFont
	}
	Write-Host "font_selected: $font_selected"
	$Font = New-Object System.Drawing.Font("$font_selected", 100)
	"font_selected: $font_selected" | Add-Content $logfilename -Encoding UTF8

	$label = New-Object System.Windows.Forms.Label
	$label.Location = New-Object System.Drawing.Point(10,30)
	# Label size setting
	$mode = Read-Host "Label size random mode: r or R , select mode: s or S"
	$size_selected = @()
	if(($mode -eq 'r') -or ($mode -eq 'R')){
		# Set the label size randomly.
		$size_selected = Get-RandomLabelSize
	}elseif(($mode -eq 's') -or ($mode -eq 'S')) {
		# Select and set the size of the label.
		$size_selected = Get-SelectLabelSize
	}
	$arr_size_int = $size_selected -split(",")
	$width = [int]$arr_size_int[0]
	$height = [int]$arr_size_int[1]
	Write-Host size_selected: $size_selected Type: $size_selected.GetType() 
	Write-Host "width: $width, height: $height"
	$label.Size = New-Object System.Drawing.Size($width,$height)
#	$label.Size = New-Object System.Drawing.Size(800,600)
	$label.Text = $text

	$str_labelforeColor = Get-RandomColor
#	Write-Host "[Show_Message]str_labelForeColor: $str_labelforeColor"
	$label.forecolor = $str_labelforeColor
	"strColor: $str_labelforeColor" | Add-Content $logfilename -Encoding UTF8

	$label.font = $Font

	# Text placement settings
	$mode = Read-Host "TextAlign random mode: r or R , select mode: s or S"
	if(($mode -eq 'r') -or ($mode -eq 'R')){
		# Randomly set the text placement.
		$label.TextAlign = Get-RandomTextAlign
	}elseif(($mode -eq 's') -or ($mode -eq 'S')) {
		# Select and set text placement.
		$textalign = Get-SelectTextAlign
		$label.TextAlign = $textalign
	}
	$TextAlign = $label.TextAlign
	"TextAlign: $TextAlign" | Add-Content $logfilename -Encoding UTF8

	# Image Settings
	$mode = $null
	$pattern = $null
	$mode = Read-Host "Image random mode: r or R, select mode: s or S, in case of no need is others"
	if(($mode -eq 'r') -or ($mode -eq 'R')){
		$pattern = Read-Host "Image pattern:please Enter. repeating pattern(default): y spot: n"
		switch -Wildcard ($pattern) {
			"[yY]"{ 
				Write-Host "pattern1"
				#$label.BackgroundImage = Get-RandomSourceImg
				$label.BackgroundImage = Get-RandomBackgroundImg
			}
			"[nN]"{
				Write-Host "pattern2"
				# Set images randomly.
				$label.Image = Get-RandomSourceImg		
			}
			Default {
				Write-Host "default1"
				$label.BackgroundImage = Get-RandomSourceImg
			}
		}
	}elseif(($mode -eq 's') -or ($mode -eq 'S')){
		$pattern = Read-Host "Image pattern:please Enter. repeating pattern(default): y spot: n"
		switch -Wildcard ($pattern) {
			"[yY]"{ 
				Write-Host "pattern3"
#				$label.BackgroundImage = Get-SelectSourceImg
				$label.BackgroundImage = Get-SelectBackgroundImg
			}
			"[nN]"{
				Write-Host "pattern4"
				# Set select images
				$label.Image = Get-SelectSourceImg		
			}
			Default {
				Write-Host "default2"
				$label.BackgroundImage = Get-SelectSourceImg
			}
		}
	}else {
		# Image: nothing
		Write-Host "pattern5"
	}

	# Image's place settings


	$form.Topmost = $True
	$form.AcceptButton = $OKButton
	$form.CancelButton = $CancelButton

	$form.Controls.Add($OKButton)
	$form.Controls.Add($CancelButton)
	$form.Controls.Add($label)

	$result = $form.ShowDialog()

	if($result -eq "OK"){
		# Converting a label to an image and saving it
		Convert-LabelToImage($label)
	}else {
		Write-Host "cancel"
		"cancel" | Add-Content $logfilename -Encoding UTF8
	}
}

function Show_WinForm($mode) {
#	Write-Host "Show_WinForm: start"

	$form = New-Object System.Windows.Forms.Form
	$form.Text = "Show Winform"
	$form.Size = New-Object System.Drawing.Size(500,300)
	$form.StartPosition = "CenterScreen"
	
	while ($true) {
		$str_formBackColor = Get-RandomColor
		if ($str_BackColor -ne "Transparent") {
			break
		}		
	}
	#	Write-Host "[Show_WinForm]str_formBackColor: $str_formBackColor"
	$form.BackColor = $str_formBackColor

	$form.MaximizeBox = $false
	$form.MinimizeBox = $false
	$form.FormBorderStyle = "FixedSingle"
	$form.Opacity = 1

	$OKButton = New-Object System.Windows.Forms.Button
	$OKButton.Location = New-Object System.Drawing.Point(40,100)
	$OKButton.Size = New-Object System.Drawing.Size(75,30)
	$OKButton.Text = "OK"
	$OKButton.DialogResult = "OK"
	$OKButton.Flatstyle = "Popup"

	while ($true) {
		$str_OKBackColor = Get-RandomColor
		if ($str_BackColor -ne "Transparent") {
			break
		}		
	}
#	Write-Host "[Show_WinForm]str_OKBackColor: $str_OKBackColor"
	$OKButton.Backcolor = $str_OKBackColor
	
	$str_OKforeColor = Get-RandomColor
#	Write-Host "[Show_WinForm]str_OKforeColor: $str_OKforeColor"
	$OKButton.forecolor = $str_OKforeColor

	$CancelButton = New-Object System.Windows.Forms.Button
	$CancelButton.Location = New-Object System.Drawing.Point(130,100)
	$CancelButton.Size = New-Object System.Drawing.Size(75,30)
	$CancelButton.Text = "Cancel"
	$CancelButton.DialogResult = "Cancel"
	$CancelButton.Flatstyle = "Popup"

	while ($true) {
		$str_cancelBackColor = Get-RandomColor
		if ($str_BackColor -ne "Transparent") {
			break
		}		
	}
	#	Write-Host "[Show_WinForm]str_cancelBackColor: $str_cancelBackColor"
	$CancelButton.backcolor = $str_cancelBackColor

	$str_cancelForeColor = Get-RandomColor
#	Write-Host "[Show_WinForm]str_cancelForeColor: $str_cancelForeColor"
	$CancelButton.forecolor = $str_cancelForeColor

	$Font = New-Object System.Drawing.Font("Meiryo UI",11)

	$label = New-Object System.Windows.Forms.Label
	$label.Location = New-Object System.Drawing.Point(10,30)
	$label.Size = New-Object System.Drawing.Size(400,30)
	$label.Text = "Enter the words you want to use in the image"

	while ($true) {
		$str_labelBackColor = Get-RandomColor
		if ($str_BackColor -ne "Transparent") {
			break
		}		
	}
#	Write-Host "[Show_WinForm]str_labelBackColor: $str_labelBackColor"
	$label.forecolor = $str_labelBackColor

	$label.font = $Font

	$textBox = New-Object System.Windows.Forms.TextBox
	$textBox.Location = New-Object System.Drawing.Point(10,70)
	$textBox.Size = New-Object System.Drawing.Size(400,50)
	$textBox.Font = New-Object System.Drawing.Font("Meiryo UI",11)

	$form.Topmost = $True
	$form.Add_Shown({$textBox.Select()})

	$form.AcceptButton = $OKButton
	$form.CancelButton = $CancelButton

	$form.Controls.Add($OKButton)
	$form.Controls.Add($CancelButton)
	$form.Controls.Add($label)
	$form.Controls.Add($textBox)

	$result = $form.ShowDialog()

	if((($mode -eq "register") -or ($mode -eq "S")) -and ($result -eq "OK") -and ($textBox.Text.Length -gt 0)){
		$registerStr = $textBox.Text
		$registerStr | Add-Content $filename_store -Encoding UTF8

		# Check usage rights for font's legal compliance.
		Check_UsageRights($Font)

	}elseif (($result -eq "OK") -and ($textBox.Text.Length -gt 0)){
		$registerStr = $textBox.Text
		Write-Host "$registerStr"
		Show_Message($registerStr)
	}elseif($textBox.Text.Length -gt 0){
		[System.Windows.Forms.MessageBox]::Show("Input is Anything")
	}
}

function Get-Storefile{
	# Select the data store file
	$mode = Read-Host "storefile random mode: r or R , select mode: s or S"
	if(($mode -eq 'r') -or ($mode -eq 'R')){
		# Set a random data store file
		$storefilename = Get-RandomStoreFile
		Write-Host "storefilename: $storefilename"
	}elseif(($mode -eq 's') -or ($mode -eq 'S')) {
		# Selecting and setting a data store file
		$storefilename = Get-SelectStoreFile
		Write-Host "storefilename: $storefilename"
	}
	$filename_store = $store_fileDir + $storefilename

	return $filename_store	
}

function Check_UsageRights($Font){
	# Get a comma-separated confirmation array

	# Get the value of the corresponding element.

	# If there is no corresponding font, 
	# the rights cannot be ascertained and recommend updating this information.
}

function Get-FontList{
	Write-Host "[Get-FontList] START"
	$date = Get-Date -Format yyyyMMdd
	$fontlistname = "./fontlist_" + $date + ".txt"

	$arr_font_all = [System.Drawing.FontFamily]::Families

#	$arr_font_all | Select-Object Name | Add-Content $fontlistname -Encoding UTF8
	foreach($font in $arr_font_all){
		$font.Name | Add-Content $fontlistname -Encoding UTF8
	}
	Write-Host "[Get-FontList] END"
}

# main

# Loading an assembly
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# log file name
$logfilename = "./logfile.log"
# Folder to store image files and store files to be set as labels
$sourceImgDir = (Get-Location).Path + '\source_img\'
$store_fileDir = (Get-Location).Path + '\store_file\'
$backgroundImgDir = (Get-Location).Path + '\background_img\'


while ($true) {
	Write-Host "[[MAIN FUNCTION]]"
	Write-Host "please enter to start. if you want to quit, please 'q'. if you want to check registered str, enter 'r'."
	Write-Host "if you want to get font list, enter 'g'."
    $select = Read-Host "if want to register words, enter 's'. if you want to create background image, enter 'b'."
    if(($select -eq 'r') -or ($select -eq 'R')){
		$r_storestr = $null

		# Get random or select store file name
		$filename_store = Get-Storefile

		$mode = Read-Host "Str random mode: r or R , select mode: s or S"
		if(($mode -eq 'r') -or ($mode -eq 'R')){
			# Set a random string
			Write-Host "filename: $filename_store"
			$r_storestr = Get-RandomRegisteredStr($filename_store)
		}elseif(($mode -eq 's') -or ($mode -eq 'S')) {
			# Selecting and setting a string
			Write-Host "filename: $filename_store"
			$r_storestr = Get-SelectRegisteredStr($filename_store)
		}	
		Show_Message($r_storestr)
    }elseif(($select -eq 's') -or ($select -eq 'S')){
		$mode = "register"
		Show_WinForm $mode
	}elseif(($select -eq 'b') -or ($select -eq 'B')){
		# create new background image
		New-BakcgroundImg
	}elseif(($select -eq 'g') -or ($select -eq 'G')){
        # Get font list
        Get-FontList
	}elseif(($select -ne 'q') -or ($select -ne 'Q')){
        # Windows Form shows
        Show_WinForm
	}else {
        $date = Get-Date
        Write-Host "terminate this program ($date)"
        Start-Sleep 1
        return
    }   
}