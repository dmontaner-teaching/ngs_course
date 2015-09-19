# make_slides.sh
# 2014-10-21 dmontaner@cipf.es
# Run Pandoc to create the slides

## PARAMETERS you may want to change

infile="slides"   ## with yaml header
outfile="2014_11_11_gatk_slides"
beamer_template="../000_commons/slides_template.tex"
refs="../000_commons/refs.md"

################################################################################

rm -r aux
mkdir aux

rm $outfile.pdf
rm $outfile.html


## pandoc basic HTML 
## (for testing purposes; usually may be commented)
# pandoc -s -S -f markdown -t html -o $outfile.html $infile.md

########################################

##pandoc using template
pandoc -S -f markdown -t beamer --template=$beamer_template -o aux/slides.tex $infile.md $refs

##properly scale images
sed -i 's/\includegraphics{/\includegraphics[width=\\textwidth,height=0.8\\textheight,keepaspectratio]{/g' aux/slides.tex

##remove empty captions
sed -i 's/\\caption{}//g' aux/slides.tex

## remove \tightlist
sed -i 's/\\tightlist//g' aux/slides.tex

##pdf
pdflatex -output-directory=aux aux/slides.tex
pdflatex -output-directory=aux aux/slides.tex  ## needs to be compiled two times for the total number of frames to be properly estimated.
## it may need one more for the citations

##reallocate files
mv aux/slides.pdf $outfile.pdf
