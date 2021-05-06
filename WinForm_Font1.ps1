
# Windows Formの表示処理
function Show_WinForm() {

	Write-Host "Show_WinForm: start"

	# アセンブリの読み込み
	Add-Type -AssemblyName System.Windows.Forms
	Add-Type -AssemblyName System.Drawing

	# フォームの作成
	$form = New-Object System.Windows.Forms.Form
	$form.Text = "入力"
	$form.Size = New-Object System.Drawing.Size(260,180)
	$form.StartPosition = "CenterScreen"
	$form.BackColor = "green"
	$form.MaximizeBox = $false
	$form.MinimizeBox = $false
	$form.FormBorderStyle = "FixedSingle"
	$form.Opacity = 1

	# OKボタンの設定
	$OKButton = New-Object System.Windows.Forms.Button
	$OKButton.Location = New-Object System.Drawing.Point(40,100)
	$OKButton.Size = New-Object System.Drawing.Size(75,30)
	$OKButton.Text = "OK"
	$OKButton.DialogResult = "OK"
	$OKButton.Flatstyle = "Popup"
	$OKButton.Backcolor = "red"
	$OKButton.forecolor = "white"

	# キャンセルボタンの設定
	$CancelButton = New-Object System.Windows.Forms.Button
	$CancelButton.Location = New-Object System.Drawing.Point(130,100)
	$CancelButton.Size = New-Object System.Drawing.Size(75,30)
	$CancelButton.Text = "Cancel"
	$CancelButton.DialogResult = "Cancel"
	$CancelButton.Flatstyle = "Popup"
	$CancelButton.backcolor = "white"
	$CancelButton.forecolor = "black"

	# フォントの設定
	$Font = New-Object System.Drawing.Font("メイリオ",11)

	# ラベルの設定
	$label = New-Object System.Windows.Forms.Label
	$label.Location = New-Object System.Drawing.Point(10,30)
	$label.Size = New-Object System.Drawing.Size(250,20)
	$label.Text = "何か入力してください"
	$label.forecolor = "white"
	$label.font = $Font

	# 入力ボックスの設定
	$textBox = New-Object System.Windows.Forms.TextBox
	$textBox.Location = New-Object System.Drawing.Point(10,70)
	$textBox.Size = New-Object System.Drawing.Size(225,50)
	$textBox.Font = New-Object System.Drawing.Font("MS 明朝",11)

	# 最前面に表示：する
	$form.Topmost = $True

	# 入力ボックス部分を選択した状態にする
	$form.Add_Shown({$textBox.Select()})

	# キーとボタンの関係
	$form.AcceptButton = $OKButton
	$form.CancelButton = $CancelButton

	# ボタン等をフォームに追加
	$form.Controls.Add($OKButton)
	$form.Controls.Add($CancelButton)
	$form.Controls.Add($label)
	$form.Controls.Add($textBox)

	# フォームを表示させ、その結果を受け取る
	$result = $form.ShowDialog()

	# 結果による処理分岐
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