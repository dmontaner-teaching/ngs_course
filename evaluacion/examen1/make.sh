#!/bin/bash
## make.sh
## david.montaner@gmail.com
## The script creates the PDF files using pandoc

## Usually I write the test exam in markdown using - (minus) to start the list elements of the answers.
## I use + (plus) for the correct answer.
## In the PDF + or - come both as a bullet so students cannot distinguish.
## To create the _solved_ PDF I just replace the + symbol by `+  CORRECT` or a similar indication.

pandoc -S -f markdown -t latex -V geometry:margin=2.3cm -o estudios_in_silico_examen1.pdf estudios_in_silico_examen1.md 

pandoc -S -f markdown -t latex -V geometry:margin=2.3cm -o estudios_in_silico_examen1_resuelto.pdf estudios_in_silico_examen1_resuelto.md 
