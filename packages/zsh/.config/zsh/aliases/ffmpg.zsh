# 横幅を指定してリサイズ
function ffres() {
  read inputname"?type input file name:  ";
  read outputname"?type output file type: ";
  read size"?type file size:        ";
  ffmpeg -i ${inputname} -vf "scale=${size}:-1" -q 2 output.${outputtype}
}

# 動画を綺麗なgifに変換
function ffgif() {
  read inputname"?type input file name:  ";
  ffmpeg -i ${inputname} -filter_complex "[0:v] fps=10,scale=640:-1,split [a][b];[a] palettegen [p];[b][p] paletteuse" output.gif
}
