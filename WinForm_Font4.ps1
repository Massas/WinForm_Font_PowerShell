
function Get-RandomTextAlign{
#	Write-Host "Get-RandomTextAlign: START"

	# ContentAlignment 列挙型の値を取得して配列に詰める
	$arr = [System.Drawing.ContentAlignment]|get-member -static -MemberType Property | Select-Object Name	
	$count_arr = $arr.Count
	# 配列の要素番号をランダムに取得する
	$num_select = Get-Random -Maximum ($count_arr - 1)
	$selected = $arr[$num_select]

#	Write-Host "selected: $selected"
#	Write-Host "Get-RandomTextAlign: END"

	return $selected.Name
}

# Windows Formを渡して画像ファイルに変換・保存する処理
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
	# ラベルをBitmapに変換する
	$form.DrawToBitmap($DstBmp, $Rect)

	# 保存するファイル名を入力する
	$savename = Read-Host "please enter filename to save as PNG" 
	
	try{
		#保存する
		$DstBmp.Save((Get-Location).Path + '\WinForm_png\' + "$savename", [System.Drawing.Imaging.ImageFormat]::Png)	
	}catch{
		Write-Host "Save failed."
		throw ArgumentNullException
	}
	"savename: $savename" | Add-Content $logfilename -Encoding UTF8

#	Write-Host "Convert-LabelToImage: END"
}

# ランダムに登録されている文字列を返す処理
function Get-RandomRegisteredStr{
	# ファイルから内容を読込み配列に詰める
	$arr_file = Get-Content -LiteralPath $storefilename -Encoding UTF8
	$count_arr = $arr_file.Count
	# 配列の要素番号をランダムに取得する
	$num_select = Get-Random -Maximum ($count_arr - 1)
	$selectstr = $arr_file[$num_select]
	Write-Host "[Get-RandomRegisteredStr]selectstr: $selectstr num_all: $count_arr ,num_select: $num_select"

	return $selectstr
}

# ランダムにsystem.drawing.colorの一色を返す処理
function Get-RandomColor{
	# 色名情報の配列を生成
	$arr = [system.drawing.color]|get-member -static -MemberType Property | Select-Object Name
	$count = $arr.Count

	# 色名情報の配列の要素番号をランダムに生成
	$select = Get-Random -Maximum ($count - 1)
	$retcolor = $arr[$select]

	if(($retcolor.Name -eq "Empty") -or ($retcolor.Name -eq "Transparent")){
		Get-RandomColor
	}

	return $retcolor.Name
}

# フォントを選択する処理
function Get-SelectFont{
	$arr_font = [System.Drawing.FontFamily]::Families

	# フォントの指定
	$Font = New-Object System.Drawing.Font("メイリオ",12)
	# フォーム全体の設定
	$form = New-Object System.Windows.Forms.Form
	$form.Text = "選択"
	$form.Size = New-Object System.Drawing.Size(500,300)
	$form.StartPosition = "CenterScreen"
	$form.font = $Font

	# ラベルを表示
	$label = New-Object System.Windows.Forms.Label
	$label.Location = New-Object System.Drawing.Point(10,10)
	$label.Size = New-Object System.Drawing.Size(400,40)
	$label.Text = "フォントを選択してください"
	$form.Controls.Add($label)

	# OKボタンの設定
	$OKButton = New-Object System.Windows.Forms.Button
	$OKButton.Location = New-Object System.Drawing.Point(40,100)
	$OKButton.Size = New-Object System.Drawing.Size(75,30)
	$OKButton.Text = "OK"
	$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
	$form.AcceptButton = $OKButton
	$form.Controls.Add($OKButton)

	# キャンセルボタンの設定
	$CancelButton = New-Object System.Windows.Forms.Button
	$CancelButton.Location = New-Object System.Drawing.Point(130,100)
	$CancelButton.Size = New-Object System.Drawing.Size(75,30)
	$CancelButton.Text = "Cancel"
	$CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
	$form.CancelButton = $CancelButton
	$form.Controls.Add($CancelButton)

	# コンボボックスを作成
	$Combo = New-Object System.Windows.Forms.Combobox
	$Combo.Location = New-Object System.Drawing.Point(50,50)
	$Combo.size = New-Object System.Drawing.Size(250,40)
	$Combo.DropDownStyle = "DropDown"
	$Combo.FlatStyle = "standard"
	$Combo.font = $Font

	$str_BackColor = Get-RandomColor
#	Write-Host "Combo.BackColor: $str_BackColor"
	$Combo.BackColor = $str_BackColor

	$str_ForeColor = Get-RandomColor
#	Write-Host "Combo.ForeColor: $str_ForeColor"
	$Combo.ForeColor = $str_ForeColor

	# コンボボックスに項目を追加
	ForEach ($select in $arr_font){
		$fontname = $select.Name
		[void] $Combo.Items.Add("$fontname")
	}

	# フォームにコンボボックスを追加
	$form.Controls.Add($Combo)

	# フォームを最前面に表示
	$form.Topmost = $True

	# フォームを表示＋選択結果を変数に格納
	$result = $form.ShowDialog()

	# 選択後、OKボタンが押された場合、選択項目を表示
	if ($result -eq "OK")
	{
		$ret = $combo.Text
	}else{
		exit
	}

	return $ret
}

# インストールされているフォントの中からランダムにフォントを選択し、フォント名を返す処理
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

# 入力された内容を表示する
function Show_Message($text){
#	Write-Host "Show_Message: start"
	$partition = "==========================="
	$partition | Add-Content $logfilename -Encoding UTF8

	"text: $text" | Add-Content $logfilename -Encoding UTF8

	# フォームの作成
	$form = New-Object System.Windows.Forms.Form
	$form.Text = "入力内容の表示"
	$form.Size = New-Object System.Drawing.Size(500,300)
	$form.StartPosition = "CenterScreen"

	$str_BackColor = Get-RandomColor
#	Write-Host "[Show_Message]str_BackColor: $str_BackColor"
	$form.BackColor = $str_BackColor
	"backColor: $str_BackColor" | Add-Content $logfilename -Encoding UTF8
	
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

	$str_OKBackColor = Get-RandomColor
#	Write-Host "str_OKBackColor: $str_OKBackColor"
	$OKButton.Backcolor = $str_OKBackColor

	$str_OKForeColor = Get-RandomColor
#	Write-Host "str_OKForeColor: $str_OKForeColor"
	$OKButton.forecolor = $str_OKForeColor

	# キャンセルボタンの設定
	$CancelButton = New-Object System.Windows.Forms.Button
	$CancelButton.Location = New-Object System.Drawing.Point(130,100)
	$CancelButton.Size = New-Object System.Drawing.Size(75,30)
	$CancelButton.Text = "Cancel"
	$CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
	$form.CancelButton = $CancelButton
	$form.Controls.Add($CancelButton)
	
	# モードの選択(ランダムor選択)
	$mode = Read-Host "random mode: r or R , select mode: s or S"
	if(($mode -eq 'r') -or ($mode -eq 'R')){
		# フォントの設定(ランダムに設定する)
		$font_selected = Get-RandomFont
	}elseif(($mode -eq 's') -or ($mode -eq 'S')) {
		# 選択式でフォントの設定を行う
		$font_selected = Get-SelectFont
	}else {
		
	}
	Write-Host "font_selected: $font_selected"
	$Font = New-Object System.Drawing.Font("$font_selected", 100)
	"font_selected: $font_selected" | Add-Content $logfilename -Encoding UTF8

	# ラベルの設定
	$label = New-Object System.Windows.Forms.Label
	$label.Location = New-Object System.Drawing.Point(10,30)
	$label.Size = New-Object System.Drawing.Size(800,400)
	$label.Text = $text
	
	# ラベル上のテキストの配置をランダムに取得・設定する
	$label.TextAlign = Get-RandomTextAlign
	$TextAlign = $label.TextAlign
	"TextAlign: $TextAlign" | Add-Content $logfilename -Encoding UTF8

	$str_labelforeColor = Get-RandomColor
#	Write-Host "[Show_Message]str_labelForeColor: $str_labelforeColor"
	$label.forecolor = $str_labelforeColor
	"strColor: $str_labelforeColor" | Add-Content $logfilename -Encoding UTF8

	$label.font = $Font

	# 最前面に表示：する
	$form.Topmost = $True

	# キーとボタンの関係
	$form.AcceptButton = $OKButton

	# ボタン等をフォームに追加
	$form.Controls.Add($OKButton)
	$form.Controls.Add($label)

	# フォームを表示させ、その結果を受け取る
	$result = $form.ShowDialog()

	# ラベルを画像に変換して保存する処理
	Convert-LabelToImage($label)

	# 結果による処理分岐
	if ($result -eq "OK")
	{
#		$x = $label.Text
#		Write-Host "$x"
#		Write-Host "Show_Message: end"
		return
	}
}

# Windows Formの表示処理
function Show_WinForm($mode) {

#	Write-Host "Show_WinForm: start"

	# フォームの作成
	$form = New-Object System.Windows.Forms.Form
	$form.Text = "入力"
	$form.Size = New-Object System.Drawing.Size(260,180)
	$form.StartPosition = "CenterScreen"
	
	$str_formBackColor = Get-RandomColor
#	Write-Host "[Show_WinForm]str_formBackColor: $str_formBackColor"
	$form.BackColor = $str_formBackColor

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

	$str_OKBackColor = Get-RandomColor
#	Write-Host "[Show_WinForm]str_OKBackColor: $str_OKBackColor"
	$OKButton.Backcolor = $str_OKBackColor
	
	$str_OKforeColor = Get-RandomColor
#	Write-Host "[Show_WinForm]str_OKforeColor: $str_OKforeColor"
	$OKButton.forecolor = $str_OKforeColor

	# キャンセルボタンの設定
	$CancelButton = New-Object System.Windows.Forms.Button
	$CancelButton.Location = New-Object System.Drawing.Point(130,100)
	$CancelButton.Size = New-Object System.Drawing.Size(75,30)
	$CancelButton.Text = "Cancel"
	$CancelButton.DialogResult = "Cancel"
	$CancelButton.Flatstyle = "Popup"

	$str_cancelBackColor = Get-RandomColor
#	Write-Host "[Show_WinForm]str_cancelBackColor: $str_cancelBackColor"
	$CancelButton.backcolor = $str_cancelBackColor

	$str_cancelForeColor = Get-RandomColor
#	Write-Host "[Show_WinForm]str_cancelForeColor: $str_cancelForeColor"
	$CancelButton.forecolor = $str_cancelForeColor

	# フォントの設定
	$Font = New-Object System.Drawing.Font("メイリオ",11)

	# ラベルの設定
	$label = New-Object System.Windows.Forms.Label
	$label.Location = New-Object System.Drawing.Point(10,30)
	$label.Size = New-Object System.Drawing.Size(250,20)
	$label.Text = "何か入力してください"

	$str_labelBackColor = Get-RandomColor
#	Write-Host "[Show_WinForm]str_labelBackColor: $str_labelBackColor"
	$label.forecolor = $str_labelBackColor

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

	# モードと結果による処理分岐
	if(($mode -eq "register") -and ($result -eq "OK") -and ($textBox.Text.Length -gt 0)){
		$registerStr = $textBox.Text
		Write-Host "$registerStrを登録します"
		# UTF-8でファイル書き込み
		$registerStr | Add-Content $storefilename -Encoding UTF8
	}elseif (($result -eq "OK") -and ($textBox.Text.Length -gt 0)){
		$registerStr = $textBox.Text
		Write-Host "$registerStr"
		Show_Message($registerStr)
	}elseif($textBox.Text.Length -gt 0){
		# メッセージボックスの表示
		[System.Windows.Forms.MessageBox]::Show("Input is Anything")
	}

#	Write-Host "Show_WinForm: end"

}

# main

# アセンブリの読み込み
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# 文字列データを登録・保持しておくためのファイル
$storefilename = "./datastore.txt"
# ログファイル
$logfilename = "./logfile.log"

while ($true) {
    $select = Read-Host "please enter and start. if you want to quit, please 'q' and enter. if you want to check registered str, enter 'r'. if want to register words, enter 's'."
    if(($select -eq 'r') -or ($select -eq 'R')){
		# ファイルから読みだされた文字列
		$r_storestr = $null
		# ファイルから文字列をランダムに読み出す
		$r_storestr = Get-RandomRegisteredStr $storefilename
		# メッセージダイアログを表示する
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