# tutorial1_make.sh
# 2014-10-21 dmontaner@cipf.es
# Run Pandoc to create HTML tutorial

## PARAMETERS you may want to change
outfile="2014_10_21_alignment_tutorial1"   #name for the final HTML file (without extension)

## more parameters 
infile="tutorial1"
shfile="tutorial1"
cssfile="../000_commons/tutorial.css"
   refs="../000_commons/refs.md"

################################################################################

## Remoove odl files
rm $outfile
rm $styfile


## CSS to be inserted into the final HTML file
styfile="estilo.sty"
echo  "<style>"   > $styfile
cat   $cssfile   >> $styfile
echo ""          >> $styfile
echo "</style>"  >> $styfile

## RUN PANDOC
# pandoc -S --toc -f markdown -t html -c $cssfile -o $outfile.html $infile.md  ## css  outside the file
  pandoc -S --toc -f markdown -t html -H $styfile -o $outfile.html $infile.md  ## style inside the file

## CLEAN UP style
rm $styfile


## EXTRACT shell commands
sed 's/^\t/    /g' $infile.md  > $shfile.0.sh   # replace starting tabs by 4 spaces
grep  "^    " > $shfile.sh $shfile.0.sh         # fin the verbatim lines: those starting with 4 spaces
rm $shfile.0.sh
sed -i 's/^    //g'                 $shfile.sh  # remove spaces
chmod +x                            $shfile.sh  # executable
