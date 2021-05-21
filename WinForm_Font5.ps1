
function Get-RandomTextAlign{
#	Write-Host "Get-RandomTextAlign: START"

	# ContentAlignment �񋓌^�̒l���擾���Ĕz��ɋl�߂�
	$arr = [System.Drawing.ContentAlignment]|get-member -static -MemberType Property | Select-Object Name	
	$count_arr = $arr.Count
	# �z��̗v�f�ԍ��������_���Ɏ擾����
	$num_select = Get-Random -Maximum ($count_arr - 1)
	$selected = $arr[$num_select]

#	Write-Host "selected: $selected"
#	Write-Host "Get-RandomTextAlign: END"

	return $selected.Name
}

# Windows Form��n���ĉ摜�t�@�C���ɕϊ��E�ۑ����鏈��
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
	# ���x����Bitmap�ɕϊ�����
	$form.DrawToBitmap($DstBmp, $Rect)

	# �ۑ�����t�@�C��������͂���
	$savename = Read-Host "please enter filename to save as PNG" 
	
	try{
		#�ۑ�����
		$DstBmp.Save((Get-Location).Path + '\WinForm_png\' + "$savename", [System.Drawing.Imaging.ImageFormat]::Png)	
	}catch{
		Write-Host "Save failed."
		throw ArgumentNullException
	}
	"savename: $savename" | Add-Content $logfilename -Encoding UTF8

#	Write-Host "Convert-LabelToImage: END"
}

# �����_���Ƀ��x���̃T�C�Y��Ԃ�����
function Get-RandomLabelSize{
	$sizefilename = "./sizefile.txt"
	# �t�@�C��������e��Ǎ��ݔz��ɋl�߂�
	$arr_size = Get-Content -LiteralPath $sizefilename -Encoding UTF8
	$count_arr = $arr_size.Count
	# �z��̗v�f�ԍ��������_���Ɏ擾����
	$num_select = Get-Random -Maximum ($count_arr - 1)
	$selectsize = $arr_size[$num_select]
	Write-Host "[Get-RandomLabelSize]selectsize: $selectsize num_all: $count_arr ,num_select: $num_select"

	return $selectsize
}

function Get-SelectLabelSize{
	$sizefilename = "./sizefile.txt"
	$arr_size = Get-Content -LiteralPath $sizefilename -Encoding UTF8

	# �t�H���g�̎w��
	$Font = New-Object System.Drawing.Font("���C���I",12)
	# �t�H�[���S�̂̐ݒ�
	$form = New-Object System.Windows.Forms.Form
	$form.Text = "�I��"
	$form.Size = New-Object System.Drawing.Size(600,450)
	$form.StartPosition = "CenterScreen"
	$form.font = $Font

	# ���x����\��
	$label = New-Object System.Windows.Forms.Label
	$label.Location = New-Object System.Drawing.Point(10,10)
	$label.Size = New-Object System.Drawing.Size(500,40)
	$label.Text = "�T�C�Y��I�����Ă�������"
	$form.Controls.Add($label)

	# OK�{�^���̐ݒ�
	$OKButton = New-Object System.Windows.Forms.Button
	$OKButton.Location = New-Object System.Drawing.Point(40,100)
	$OKButton.Size = New-Object System.Drawing.Size(75,30)
	$OKButton.Text = "OK"
	$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
	$form.AcceptButton = $OKButton
	$form.Controls.Add($OKButton)

	# �L�����Z���{�^���̐ݒ�
	$CancelButton = New-Object System.Windows.Forms.Button
	$CancelButton.Location = New-Object System.Drawing.Point(130,100)
	$CancelButton.Size = New-Object System.Drawing.Size(75,30)
	$CancelButton.Text = "Cancel"
	$CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
	$form.CancelButton = $CancelButton
	$form.Controls.Add($CancelButton)

	# �R���{�{�b�N�X���쐬
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

	# �R���{�{�b�N�X�ɍ��ڂ�ǉ�
	ForEach ($select in $arr_size){
		[void] $Combo.Items.Add("$select")
	}

	# �t�H�[���ɃR���{�{�b�N�X��ǉ�
	$form.Controls.Add($Combo)

	# �t�H�[�����őO�ʂɕ\��
	$form.Topmost = $True

	# �t�H�[����\���{�I�����ʂ�ϐ��Ɋi�[
	$result = $form.ShowDialog()

	# �I����AOK�{�^���������ꂽ�ꍇ�A�I�����ڂ�\��
	if ($result -eq "OK")
	{
		$ret = $combo.Text
		Write-Host "[Get-SelectLabelSize]selectsize: $ret"
	}else{
		exit
	}

	return $ret
}


# �����_���ɓo�^����Ă��镶�����Ԃ�����
function Get-RandomRegisteredStr{
	# �t�@�C��������e��Ǎ��ݔz��ɋl�߂�
	$arr_file = Get-Content -LiteralPath $storefilename -Encoding UTF8
	$count_arr = $arr_file.Count
	# �z��̗v�f�ԍ��������_���Ɏ擾����
	$num_select = Get-Random -Maximum ($count_arr - 1)
	$selectstr = $arr_file[$num_select]
	Write-Host "[Get-RandomRegisteredStr]selectstr: $selectstr num_all: $count_arr ,num_select: $num_select"

	return $selectstr
}
function Get-SelectRegisteredStr{
	$arr_str_all = Get-Content -LiteralPath $storefilename -Encoding UTF8

	# �t�H���g�̎w��
	$Font = New-Object System.Drawing.Font("���C���I",12)
	# �t�H�[���S�̂̐ݒ�
	$form = New-Object System.Windows.Forms.Form
	$form.Text = "�I��"
	$form.Size = New-Object System.Drawing.Size(600,450)
	$form.StartPosition = "CenterScreen"
	$form.font = $Font

	# ���x����\��
	$label = New-Object System.Windows.Forms.Label
	$label.Location = New-Object System.Drawing.Point(10,10)
	$label.Size = New-Object System.Drawing.Size(500,40)
	$label.Text = "�������I�����Ă�������"
	$form.Controls.Add($label)

	# OK�{�^���̐ݒ�
	$OKButton = New-Object System.Windows.Forms.Button
	$OKButton.Location = New-Object System.Drawing.Point(40,100)
	$OKButton.Size = New-Object System.Drawing.Size(75,30)
	$OKButton.Text = "OK"
	$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
	$form.AcceptButton = $OKButton
	$form.Controls.Add($OKButton)

	# �L�����Z���{�^���̐ݒ�
	$CancelButton = New-Object System.Windows.Forms.Button
	$CancelButton.Location = New-Object System.Drawing.Point(130,100)
	$CancelButton.Size = New-Object System.Drawing.Size(75,30)
	$CancelButton.Text = "Cancel"
	$CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
	$form.CancelButton = $CancelButton
	$form.Controls.Add($CancelButton)

	# �R���{�{�b�N�X���쐬
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

	# �R���{�{�b�N�X�ɍ��ڂ�ǉ�
	ForEach ($select in $arr_str_all){
		[void] $Combo.Items.Add("$select")
	}

	# �t�H�[���ɃR���{�{�b�N�X��ǉ�
	$form.Controls.Add($Combo)

	# �t�H�[�����őO�ʂɕ\��
	$form.Topmost = $True

	# �t�H�[����\���{�I�����ʂ�ϐ��Ɋi�[
	$result = $form.ShowDialog()

	# �I����AOK�{�^���������ꂽ�ꍇ�A�I�����ڂ�\��
	if ($result -eq "OK")
	{
		$ret = $combo.Text
		Write-Host "[Get-RandomRegisteredStr]selectstr: $ret"
	}else{
		exit
	}

	return $ret
}

# �����_����system.drawing.color�̈�F��Ԃ�����
function Get-RandomColor{

	$arr_color = @()

	# �F�����̔z��𐶐�
	$arr_all = [system.drawing.color]|get-member -static -MemberType Property | Select-Object Name

	foreach($color in $arr_all){
		if($color.Name -eq "Empty"){
				continue
		}
#		Write-Host $font.Name
		$arr_color += $color
	}
	$count = $arr_color.Count

	# �F�����̔z��̗v�f�ԍ��������_���ɐ���
	$select = Get-Random -Maximum ($count - 1)
	$retcolor = $arr_color[$select]

	Write-Host $retcolor.Name
	return $retcolor.Name
}

# �t�H���g��I�����鏈��
function Get-SelectFont{
	$arr_font = [System.Drawing.FontFamily]::Families

	# �t�H���g�̎w��
	$Font = New-Object System.Drawing.Font("���C���I",12)
	# �t�H�[���S�̂̐ݒ�
	$form = New-Object System.Windows.Forms.Form
	$form.Text = "�I��"
	$form.Size = New-Object System.Drawing.Size(600,450)
	$form.StartPosition = "CenterScreen"
	$form.font = $Font

	# ���x����\��
	$label = New-Object System.Windows.Forms.Label
	$label.Location = New-Object System.Drawing.Point(10,10)
	$label.Size = New-Object System.Drawing.Size(400,40)
	$label.Text = "�t�H���g��I�����Ă�������"
	$form.Controls.Add($label)

	# OK�{�^���̐ݒ�
	$OKButton = New-Object System.Windows.Forms.Button
	$OKButton.Location = New-Object System.Drawing.Point(40,100)
	$OKButton.Size = New-Object System.Drawing.Size(75,30)
	$OKButton.Text = "OK"
	$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
	$form.AcceptButton = $OKButton
	$form.Controls.Add($OKButton)

	# �L�����Z���{�^���̐ݒ�
	$CancelButton = New-Object System.Windows.Forms.Button
	$CancelButton.Location = New-Object System.Drawing.Point(130,100)
	$CancelButton.Size = New-Object System.Drawing.Size(75,30)
	$CancelButton.Text = "Cancel"
	$CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
	$form.CancelButton = $CancelButton
	$form.Controls.Add($CancelButton)

	# �R���{�{�b�N�X���쐬
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

	# �R���{�{�b�N�X�ɍ��ڂ�ǉ�
	ForEach ($select in $arr_font){
		$fontname = $select.Name
		[void] $Combo.Items.Add("$fontname")
	}

	# �t�H�[���ɃR���{�{�b�N�X��ǉ�
	$form.Controls.Add($Combo)

	# �t�H�[�����őO�ʂɕ\��
	$form.Topmost = $True

	# �t�H�[����\���{�I�����ʂ�ϐ��Ɋi�[
	$result = $form.ShowDialog()

	# �I����AOK�{�^���������ꂽ�ꍇ�A�I�����ڂ�\��
	if ($result -eq "OK")
	{
		$ret = $combo.Text
	}else{
		exit
	}

	return $ret
}

# �C���X�g�[������Ă���t�H���g�̒����烉���_���Ƀt�H���g��I�����A�t�H���g����Ԃ�����
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

# ���͂��ꂽ���e��\������
function Show_Message($text){
#	Write-Host "Show_Message: start"
	$partition = "==========================="
	$partition | Add-Content $logfilename -Encoding UTF8

	"text: $text" | Add-Content $logfilename -Encoding UTF8

	# �t�H�[���̍쐬
	$form = New-Object System.Windows.Forms.Form
	$form.Text = "���͓��e�̕\��"
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

	# OK�{�^���̐ݒ�
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

	# �L�����Z���{�^���̐ݒ�
	$CancelButton = New-Object System.Windows.Forms.Button
	$CancelButton.Location = New-Object System.Drawing.Point(130,100)
	$CancelButton.Size = New-Object System.Drawing.Size(75,30)
	$CancelButton.Text = "Cancel"
	$CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
	$form.CancelButton = $CancelButton
	$form.Controls.Add($CancelButton)
	
	# ���[�h�̑I��(�����_��or�I��)
	$mode = Read-Host "Font random mode: r or R , select mode: s or S"
	if(($mode -eq 'r') -or ($mode -eq 'R')){
		# �t�H���g�̐ݒ�(�����_���ɐݒ肷��)
		$font_selected = Get-RandomFont
	}elseif(($mode -eq 's') -or ($mode -eq 'S')) {
		# �I�����Ńt�H���g�̐ݒ���s��
		$font_selected = Get-SelectFont
	}
	Write-Host "font_selected: $font_selected"
	$Font = New-Object System.Drawing.Font("$font_selected", 100)
	"font_selected: $font_selected" | Add-Content $logfilename -Encoding UTF8

	# ���x���̐ݒ�
	$label = New-Object System.Windows.Forms.Label
	$label.Location = New-Object System.Drawing.Point(10,30)
	# ���x���̃T�C�Y�B�ۑ�����摜�̃T�C�Y�ƂȂ�B
	$mode = Read-Host "Label size random mode: r or R , select mode: s or S"
	$size_selected = @()
	if(($mode -eq 'r') -or ($mode -eq 'R')){
		# ���x���̃T�C�Y�������_���ɐݒ肷��
		$size_selected = Get-RandomLabelSize
	}elseif(($mode -eq 's') -or ($mode -eq 'S')) {
		# �I�����Ń��x���̃T�C�Y�ݒ���s��
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
	
	# ���x����̃e�L�X�g�̔z�u�������_���Ɏ擾�E�ݒ肷��
	$label.TextAlign = Get-RandomTextAlign
	$TextAlign = $label.TextAlign
	"TextAlign: $TextAlign" | Add-Content $logfilename -Encoding UTF8

	$str_labelforeColor = Get-RandomColor
#	Write-Host "[Show_Message]str_labelForeColor: $str_labelforeColor"
	$label.forecolor = $str_labelforeColor
	"strColor: $str_labelforeColor" | Add-Content $logfilename -Encoding UTF8

	$label.font = $Font

	# �őO�ʂɕ\���F����
	$form.Topmost = $True

	# �L�[�ƃ{�^���̊֌W
	$form.AcceptButton = $OKButton
	$form.CancelButton = $CancelButton

	# �{�^�������t�H�[���ɒǉ�
	$form.Controls.Add($OKButton)
	$form.Controls.Add($CancelButton)
	$form.Controls.Add($label)

	# �t�H�[����\�������A���̌��ʂ��󂯎��
	$result = $form.ShowDialog()

	# ���ʂɂ�鏈������
	if($result -eq "OK"){
		# ���x�����摜�ɕϊ����ĕۑ����鏈��
		Convert-LabelToImage($label)
	}else {
		Write-Host "cancel"
		"cancel" | Add-Content $logfilename -Encoding UTF8
	}
}

# Windows Form�̕\������
function Show_WinForm($mode) {

#	Write-Host "Show_WinForm: start"

	# �t�H�[���̍쐬
	$form = New-Object System.Windows.Forms.Form
	$form.Text = "����"
	$form.Size = New-Object System.Drawing.Size(260,180)
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

	# OK�{�^���̐ݒ�
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

	# �L�����Z���{�^���̐ݒ�
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

	# �t�H���g�̐ݒ�
	$Font = New-Object System.Drawing.Font("���C���I",11)

	# ���x���̐ݒ�
	$label = New-Object System.Windows.Forms.Label
	$label.Location = New-Object System.Drawing.Point(10,30)
	$label.Size = New-Object System.Drawing.Size(250,20)
	$label.Text = "�������͂��Ă�������"

	while ($true) {
		$str_labelBackColor = Get-RandomColor
		if ($str_BackColor -ne "Transparent") {
			break
		}		
	}
#	Write-Host "[Show_WinForm]str_labelBackColor: $str_labelBackColor"
	$label.forecolor = $str_labelBackColor

	$label.font = $Font

	# ���̓{�b�N�X�̐ݒ�
	$textBox = New-Object System.Windows.Forms.TextBox
	$textBox.Location = New-Object System.Drawing.Point(10,70)
	$textBox.Size = New-Object System.Drawing.Size(225,50)
	$textBox.Font = New-Object System.Drawing.Font("MS ����",11)

	# �őO�ʂɕ\���F����
	$form.Topmost = $True

	# ���̓{�b�N�X������I��������Ԃɂ���
	$form.Add_Shown({$textBox.Select()})

	# �L�[�ƃ{�^���̊֌W
	$form.AcceptButton = $OKButton
	$form.CancelButton = $CancelButton

	# �{�^�������t�H�[���ɒǉ�
	$form.Controls.Add($OKButton)
	$form.Controls.Add($CancelButton)
	$form.Controls.Add($label)
	$form.Controls.Add($textBox)

	# �t�H�[����\�������A���̌��ʂ��󂯎��
	$result = $form.ShowDialog()

	# ���[�h�ƌ��ʂɂ�鏈������
	if(($mode -eq "register") -and ($result -eq "OK") -and ($textBox.Text.Length -gt 0)){
		$registerStr = $textBox.Text
		Write-Host "$registerStr��o�^���܂�"
		# UTF-8�Ńt�@�C����������
		$registerStr | Add-Content $storefilename -Encoding UTF8
	}elseif (($result -eq "OK") -and ($textBox.Text.Length -gt 0)){
		$registerStr = $textBox.Text
		Write-Host "$registerStr"
		Show_Message($registerStr)
	}elseif($textBox.Text.Length -gt 0){
		# ���b�Z�[�W�{�b�N�X�̕\��
		[System.Windows.Forms.MessageBox]::Show("Input is Anything")
	}

#	Write-Host "Show_WinForm: end"

}

# main

# �A�Z���u���̓ǂݍ���
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ������f�[�^��o�^�E�ێ����Ă������߂̃t�@�C��
$storefilename = "./datastore.txt"
# ���O�t�@�C��
$logfilename = "./logfile.log"

while ($true) {
    $select = Read-Host "please enter and start. if you want to quit, please 'q' and enter. if you want to check registered str, enter 'r'. if want to register words, enter 's'."
    if(($select -eq 'r') -or ($select -eq 'R')){
		# �t�@�C������ǂ݂����ꂽ������
		$r_storestr = $null

		$mode = Read-Host "Str random mode: r or R , select mode: s or S"
		if(($mode -eq 'r') -or ($mode -eq 'R')){
			# �t�@�C�����當����������_���ɓǂݏo��
			$r_storestr = Get-RandomRegisteredStr $storefilename
		}elseif(($mode -eq 's') -or ($mode -eq 'S')) {
			# �I�����ŕ�����̐ݒ���s��
			$r_storestr = Get-SelectRegisteredStr
		}
	
		# ���b�Z�[�W�_�C�A���O��\������
		Show_Message($r_storestr)		
    }elseif(($select -eq 's') -or ($select -eq 'S')){
		$mode = "register"
		Show_WinForm $mode
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