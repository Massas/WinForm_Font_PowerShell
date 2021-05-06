
# Windows Form�̕\������
function Show_WinForm() {

	Write-Host "Show_WinForm: start"

	# �A�Z���u���̓ǂݍ���
	Add-Type -AssemblyName System.Windows.Forms
	Add-Type -AssemblyName System.Drawing

	# �t�H�[���̍쐬
	$form = New-Object System.Windows.Forms.Form
	$form.Text = "����"
	$form.Size = New-Object System.Drawing.Size(260,180)
	$form.StartPosition = "CenterScreen"
	$form.BackColor = "green"
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
	$OKButton.Backcolor = "red"
	$OKButton.forecolor = "white"

	# �L�����Z���{�^���̐ݒ�
	$CancelButton = New-Object System.Windows.Forms.Button
	$CancelButton.Location = New-Object System.Drawing.Point(130,100)
	$CancelButton.Size = New-Object System.Drawing.Size(75,30)
	$CancelButton.Text = "Cancel"
	$CancelButton.DialogResult = "Cancel"
	$CancelButton.Flatstyle = "Popup"
	$CancelButton.backcolor = "white"
	$CancelButton.forecolor = "black"

	# �t�H���g�̐ݒ�
	$Font = New-Object System.Drawing.Font("���C���I",11)

	# ���x���̐ݒ�
	$label = New-Object System.Windows.Forms.Label
	$label.Location = New-Object System.Drawing.Point(10,30)
	$label.Size = New-Object System.Drawing.Size(250,20)
	$label.Text = "�������͂��Ă�������"
	$label.forecolor = "white"
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

	# ���ʂɂ�鏈������
	if ($result -eq "OK"){
		$x = $textBox.Text
		$x
	}	

	Write-Host "Show_WinForm: end"

}

# main
while ($true) {
    $select = Read-Host "please enter and start. if you want to quit, please 'q' and enter"
    if(($select -ne 'q') -or ($select -ne 'Q')){
        # Windows Form shows
        Show_WinForm
    }else {
        $date = Get-Date
        Write-Host "terminate this program ($date)"
        Start-Sleep 1
        return
    }   
}