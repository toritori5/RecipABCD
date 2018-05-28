#!/bin/bash
#to run the script you'll need reciprocal hits for four samples calculated with the scripts in "http://archive.sysbio.harvard.edu/CSB/resources/computational/scriptome/UNIX/Protocols/Sequences.html". You will be asked to provide them when the script starts. Also, you'll need a file with a list of headers from samples A and B, with names "listA" and "listB" in the same folder you are running the script. Headers will have to be without ">" in the beggining.
#After the script finishes, you will find a folder named "results" with respective reciprocal hits and a csv table with final numbers. 

mkdir tmp
mkdir results
read -e -p "Enter reciprocal between samples A and B: " AB
read -e -p "Enter reciprocal between samples A and C: " AC
read -e -p "Enter reciprocal between samples A and D: " AD

#Considering A, you join all the reciprocal hits for the same A sequence in one table
sort $AB | cut -f1,2 > tmp/A_B
sort $AC | cut -f1,2 > tmp/A_C
sort $AD | cut -f1,2 > tmp/A_D

###
for i in {1..3}
do
for f in tmp/A_B tmp/A_C tmp/A_D
do
awk 'NR==FNR {a[$1]=$2;next} {
   split($1, b, "\t");
   if (b[1] in a)
       print a[b[1]] "\t" b[2], $2;
   else
       print "nada";
 }' $f listA > $f.nuevo
done
done

paste -d@ listA tmp/*.nuevo > tmp/archivo
sed 's/\t //g' tmp/archivo > tmp/archivo1
grep -v 'nada' tmp/archivo1 > tmp/4columnasx
sort -u tmp/4columnasx > tmp/4columnasxx
sed 's/@/\t/g' tmp/4columnasxx > 4columnas
###
#Knowing that every line is reciprocal with A, start checking the others. B and C now
sort -k 2 4columnas | cut -f1,2 > tmp/A_B_4columnas_sortedby_B
sort -k 2 4columnas | cut -f2,3 | sed 's/\t/@/g' > tmp/B_C_4columnas

read -e -p "Enter reciprocal between samples B and C: " BC

sort -k 1 $BC | cut -f1,2 | sed 's/\t/@/g' > tmp/B_C_reciprocos
sort -k 1 $BC | cut -f2 > tmp/2dacol_BC
paste tmp/B_C_reciprocos tmp/2dacol_BC > tmp/paraelscript_B_C

awk 'NR==FNR {a[$1]=$2;next} {
   split($1, b, "\t");
   if (b[1] in a)
       print a[b[1]] "\t" b[2], $2;
   else
       print "nada";
 }' tmp/paraelscript_B_C tmp/B_C_4columnas > tmp/1verdaderos_reciprocos_ABC

paste tmp/A_B_4columnas_sortedby_B tmp/1verdaderos_reciprocos_ABC > tmp/A@B@C
grep -v 'nada' tmp/A@B@C | sed 's/@/\t/g' > results/A_B_C
a123=$(wc -l results/A_B_C | cut -f1 -d ' ')

#Checking reciprocity between B and D

sort -k 2 4columnas | cut -f2,4 | sed 's/\t/@/g' > tmp/B_D_4columnas

read -e -p "Enter reciprocal between samples B and D: " BD

sort -k 1 $BD | cut -f1,2 | sed 's/\t/@/g' > tmp/B_D_reciprocos
sort -k 1 $BD | cut -f2 > tmp/2dacol_BD
paste tmp/B_D_reciprocos tmp/2dacol_BD > tmp/paraelscript_B_D

awk 'NR==FNR {a[$1]=$2;next} {
   split($1, b, "\t");
   if (b[1] in a)
       print a[b[1]] "\t" b[2], $2;
   else
       print "nada";
 }' tmp/paraelscript_B_D tmp/B_D_4columnas > tmp/1verdaderos_reciprocos_ABD

paste tmp/A_B_4columnas_sortedby_B tmp/1verdaderos_reciprocos_ABD > tmp/A@B@D
grep -v 'nada' tmp/A@B@D | sed 's/@/\t/g' > results/A_B_D
a124=$(wc -l results/A_B_D | cut -f1 -d ' ')

#Checking reciprocity between C and D

sort -k 3 4columnas | cut -f1,3 > tmp/A_B_4columnas_sortedby_B
sort -k 3 4columnas | cut -f3,4 | sed 's/\t/@/g' > tmp/C_D_4columnas

read -e -p "Enter reciprocal between samples C and D: " CD

sort -k 1 $CD | cut -f1,2 | sed 's/\t/@/g' > tmp/C_D_reciprocos
sort -k 1 $CD | cut -f2 > tmp/2dacol_CD
paste tmp/C_D_reciprocos tmp/2dacol_CD > tmp/paraelscript_C_D

awk 'NR==FNR {a[$1]=$2;next} {
   split($1, b, "\t");
   if (b[1] in a)
       print a[b[1]] "\t" b[2], $2;
   else
       print "nada";
 }' tmp/paraelscript_C_D tmp/C_D_4columnas > tmp/1verdaderos_reciprocos_ACD

paste tmp/A_B_4columnas_sortedby_B tmp/1verdaderos_reciprocos_ACD > tmp/A@C@D
grep -v 'nada' tmp/A@C@D | sed 's/@/\t/g' > results/A_C_D
a134=$(wc -l results/A_C_D | cut -f1 -d ' ')

#To calculate reciprocal hits between B, C and D we use a new table considering hits with B and then calculating how many of the hits with B are also hits between C and D.
sort $BC | cut -f1,2 > tmp/B_C_recip
sort $BD | cut -f1,2 > tmp/B_D_recip


for i in {1..2}
do
for f in tmp/B_C_recip tmp/B_D_recip
do
awk 'NR==FNR {a[$1]=$2;next} {
   split($1, b, "\t");
   if (b[1] in a)
       print a[b[1]] "\t" b[2], $2;
   else
       print "nada";
 }' $f listahhal > $f.nuevo
done
done

paste listahhal tmp/B_C_recip.nuevo tmp/B_D_recip.nuevo | grep -v 'nada' > tmp/B@C@D
sed 's/\t+/\t/g' tmp/B@C@D > results/B_C_D

a234=$(wc -l results/B_C_D | cut -f1 -d ' ')
#
#Now we can calculate reciprocal hits between the 4 samples. 
#From the first file created considering A we can sort them according to C and check how many of those A@B@C are the same with A_B_C that is already calculated. Then we can extract any of them with D and compare with the original reciprocal hit and get the final number.


sort -k 3 4columnas | cut -f1,2,3 | sed 's/\t/@/g' > tmp/ABC_4col
sort -k 3 4columnas | cut -f4 > tmp/D_4col
paste tmp/ABC_4col tmp/D_4col > tmp/compare_3
sed 's/\t/@/g' results/A_B_C |  sed 's/RA@/RA/g' > tmp/3reciprocos_ABC

awk 'NR==FNR {
a[$1]=$2;next} {
   split($1, b, "\t");
   if (b[1] in a)
       print a[b[1]] "\t" b[2], $2;
   else
       print "nada";
 }' tmp/compare_3 tmp/3reciprocos_ABC> tmp/result3

paste tmp/3reciprocos_ABC tmp/result3 | grep -v 'nada' | sed 's/PA@/PA/g' |sed 's/@/\t/g' | sed 's/PAOF/PA\tOF/g' > tmp/reciprocos_de_a_4_conD
sort -k2 tmp/reciprocos_de_a_4_conD | cut -f2,4 | sed 's/\t/@/g' > tmp/B_D_recipconD
sort -k2 tmp/reciprocos_de_a_4_conD | cut -f4 > tmp/column4
paste tmp/B_D_recipconD tmp/column4 > tmp/lastscriptin
sort -k2 tmp/reciprocos_de_a_4_conD | cut -f1,2,3 > tmp/3recipde4conD

awk 'NR==FNR {
a[$1]=$2;next} {
   split($1, b, "\t");
   if (b[1] in a)
       print a[b[1]] "\t" b[2], $2;
   else
       print "nada";
 }'  tmp/B_D_reciprocos tmp/lastscriptin > tmp/result4

paste tmp/3recipde4conD tmp/result4 | grep -v 'nada' | sed 's/@/\t/g'> tmp/reciprocos_de_a_4_noC


sort -k1 $CD | cut -f1,2 | sed 's/\t/@/g' > tmp/C@D
sort -k3 tmp/reciprocos_de_a_4_noC | cut -f3,5 | sed 's/ \t /@/g' > tmp/C@D2
sort -k3 tmp/reciprocos_de_a_4_noC | cut -f5  > tmp/columnD
paste tmp/C@D2 tmp/columnD > tmp/forthelastscript

awk 'NR==FNR {
a[$1]=$2;next} {
   split($1, b, "\t");
   if (b[1] in a)
       print a[b[1]] "\t" b[2], $2;
   else
       print "nada";
 }' tmp/C@D tmp/forthelastscript > tmp/result5

sort -k3 tmp/reciprocos_de_a_4_noC | cut -f1,2,3 > tmp/3recipde4conD2
paste tmp/3recipde4conD2 tmp/result5 | grep -v 'nada' | sed 's/@/\t/g'> tmp/1reciprocos_de_a_4
cut -f1,2,3,5 tmp/1reciprocos_de_a_4 > results/reciprocs_for_ABCD
a1234=$(wc -l results/reciprocs_for_ABCD | cut -f1 -d ' ')

#To get the final number of recirpocal hits. 
a12=$(wc -l $AB | cut -f1 -d ' ')
a13=$(wc -l $AC | cut -f1 -d ' ')
a14=$(wc -l $AD | cut -f1 -d ' ')
a23=$(wc -l $BC | cut -f1 -d ' ')
a24=$(wc -l $BD | cut -f1 -d ' ')
a34=$(wc -l $CD | cut -f1 -d ' ')

#Creating a table with results
echo -e "Samples\nAB\nAC\nAD\nBC\nBD\nCD\nABC\nABD\nACD\nBCD\nABCD" > tmp/1stcolumn
echo -e "Reciprocal_Hits\n$a12\n$a13\n$a14\n$a23\n$a24\n$a34\n$a123\n$a124\n$a134\n$a234\n$a1234" > tmp/2ndcolumn
paste tmp/1stcolumn tmp/2ndcolumn > results/final_results.csv

rm -r tmp
rm 4columnas
#Output to terminal
echo "There are $a12 reciprocal hits between A and B"
echo "There are $a13 reciprocal hits between A and C"
echo "There are $a14 reciprocal hits between A and D"
echo "There are $a23 reciprocal hits between B and C"
echo "There are $a24 reciprocal hits between B and D"
echo "There are $a34 reciprocal hits between C and D"
echo "There are $a123 reciprocal hits between A, B and C"
echo "There are $a124 reciprocal hits between A, B and D"
echo "There are $a134 reciprocal hits between A, C and D"
echo "There are $a234 reciprocal hits between B, C and D"
echo "There are $a1234 reciprocal hits between A, B, C and D"

echo "



done"
#CeBio
