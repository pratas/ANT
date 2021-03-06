#!/bin/bash
#==============================================================================
#
# WARNING: YOU NEED APPROX. 500 GB OF FREE DISK
#
# RUNNING FLAGS
GET_GOOSE=1;
GET_GECO=1;
#==============================================================================
GET_VIRUS=1;
GET_BACTERIA=1;
GET_ARCHAEA=1;
GET_FUNGI=1;
GET_ANIMALS=1;
GET_PLANTS=1;
#==============================================================================
SPLIT_READS_VIRUS=1;
SPLIT_READS_BACTERIA=1;
SPLIT_READS_ARCHAEA=1;
SPLIT_READS_FUNGI=1;
SPLIT_READS_ANIMALS=1;
SPLIT_READS_PLANTS=1;
#==============================================================================
RUN_TOP_VIRUS=1;
RUN_TOP_BACTERIA=1;
RUN_TOP_ARCHAEA=1;
RUN_TOP_FUNGI=1;
RUN_TOP_ANIMALS=1;
RUN_TOP_PLANTS=1;
#==============================================================================
RUN_CP=1;
#==============================================================================
RUN_PLOT=1;
RUN_PLOT_CP=1;
RUN_PLOT_CUM=1;
#==============================================================================
###############################################################################
#==============================================================================
# GET GOOSE
if [[ "$GET_GOOSE" -eq "1" ]]; then
  rm -fr goose/ goose-*
  git clone https://github.com/pratas/goose.git
  cd goose/src/
  make
  cd ../../
  cp goose/src/goose-* .
  cp goose/scripts/Download*.pl .
fi
#==============================================================================
# GET GECO
if [[ "$GET_GECO" -eq "1" ]]; then
  rm -fr geco/
  git clone https://github.com/pratas/geco.git
  cd geco/src/
  cmake .
  make
  cp GeCo ../../
  cd ../../
fi
#==============================================================================
###############################################################################
#==============================================================================
# GET VIRUS DB
if [[ "$GET_VIRUS" -eq "1" ]]; then
  perl DownloadViruses.pl
  cat viruses.fa | tr ' ' '_' \
  | ./goose-extractreadbypattern omplete > VDB.mfa
fi
#==============================================================================
# GET BACTERIA DB
if [[ "$GET_BACTERIA" -eq "1" ]]; then
  perl DownloadBacteria.pl
  cat bacteria.fa \
  | grep -v -e "ERROR" -e "eFetchResult" -e "DOCTYPE" -e "xml version" -e "Unable to obtain" \
  | grep -v -x ">" > bacteria.fna
  mv bacteria.fna bacteria.fa
  cat bacteria.fa | tr ' ' '_' \
  | ./goose-extractreadbypattern omplete > BDB.mfa
fi
#==============================================================================
# GET ARCHAEA DB
if [[ "$GET_ARCHAEA" -eq "1" ]]; then
  perl DownloadArchaea.pl
  cat archaea.fa | tr ' ' '_' \
  | ./goose-extractreadbypattern omplete > ADB.mfa
fi
#==============================================================================
# GET FUNGI DB
if [[ "$GET_FUNGI" -eq "1" ]]; then
  perl DownloadFungi.pl
  cat fungi.fa | tr ' ' '_' \
  | ./goose-extractreadbypattern omplete > FDB.mfa
fi
#==============================================================================
# GET ANIMALS DB
if [[ "$GET_ANIMALS" -eq "1" ]]; then
  perl DownloadAnimals.pl
  cat animals.fa | tr ' ' '_' \
  | ./goose-extractreadbypattern omplete > MDB.mfa
fi
#==============================================================================
# GET PLANTS DB
if [[ "$GET_PLANTS" -eq "1" ]]; then
  perl DownloadPlants.pl
  cat plants.fa | tr ' ' '_' \
  | ./goose-extractreadbypattern omplete > PDB.mfa
fi
#==============================================================================
###############################################################################
#==============================================================================
# SPLIT READS VIRUS
if [[ "$SPLIT_READS_VIRUS" -eq "1" ]]; then
  mkdir -p data_virus/
  cp goose-splitreads data_virus/
  cp VDB.mfa data_virus/
  cd data_virus/
  ./goose-splitreads < VDB.mfa
  cd ..
fi
#==============================================================================
# SPLIT READS BACTERIA
if [[ "$SPLIT_READS_BACTERIA" -eq "1" ]]; then
  mkdir -p data_bacteria/
  cp goose-splitreads data_bacteria/
  cp BDB.mfa data_bacteria/
  cd data_bacteria/
  ./goose-splitreads < BDB.mfa
  cd ..
fi
#==============================================================================
# SPLIT READS ARCHAEA
if [[ "$SPLIT_READS_ARCHAEA" -eq "1" ]]; then
  mkdir -p data_archaea/
  cp goose-splitreads data_archaea/
  cp ADB.mfa data_archaea/
  cd data_archaea/
  ./goose-splitreads < ADB.mfa
  cd ..
fi
#==============================================================================
# SPLIT READS FUNGI
if [[ "$SPLIT_READS_FUNGI" -eq "1" ]]; then
  mkdir -p data_fungi/
  cp goose-splitreads data_fungi/
  cp FDB.mfa data_fungi/
  cd data_fungi/
  ./goose-splitreads < FDB.mfa
  cd ..
fi
#==============================================================================
# SPLIT READS ANIMALS
if [[ "$SPLIT_READS_ANIMALS" -eq "1" ]]; then
  mkdir -p data_animals/
  cp goose-splitreads data_animals/
  cp MDB.mfa data_animals/
  cd data_animals/
  ./goose-splitreads < MDB.mfa
  cd ..
fi
#==============================================================================
# SPLIT READS PLANTS
if [[ "$SPLIT_READS_PLANTS" -eq "1" ]]; then
  mkdir -p data_plants/
  cp goose-splitreads data_plants/
  cp PDB.mfa data_plants/
  cd data_plants/
  ./goose-splitreads < PDB.mfa
  cd ..
fi
#==============================================================================
###############################################################################
#==============================================================================
# RUN TOP VIRUS
if [[ "$RUN_TOP_VIRUS" -eq "1" ]]; then
  rm -f TOP-VIRUS;
  size=`ls -la data_virus/out*.fa | wc -l`;
  for((x=1 ; x<=$size; ++x));
    do
    echo "Running virus $x out of $size ...";
    length=`ls -la data_virus/out$x.fa | awk '{ print $5}'`;
    bytes=`./GeCo -tm 4:1:0:0/0 -tm 6:1:1:0/0 -tm 13:20:1:0/0 -tm 18:50:1:2/10 -c 40 -g 0.9 data_virus/out$x.fa | grep "Total bytes" | awk '{ print $16; }'`;
    name=`cat data_virus/out$x.fa | grep ">"`;
    decision=`echo "$bytes > 1.0" | bc -l`;
    if [[ "$decision" -eq "1" ]]; then
      printf "%s\t%s\t%s\n" "1.0" "$length" "$name" >> TOP-VIRUS;
    else
      printf "%s\t%s\t%s\n" "$bytes" "$length" "$name" >> TOP-VIRUS;
    fi
    done
  sort -V TOP-VIRUS > SORTED-TOP-VIRUS;
fi
#==============================================================================
# RUN TOP BACTERIA
if [[ "$RUN_TOP_BACTERIA" -eq "1" ]]; then
  rm -f TOP-BACTERIA;
  size=`ls -la data_bacteria/out*.fa | wc -l`;
  for((x=1 ; x<=$size; ++x));
    do
    echo "Running bacteria $x out of $size ...";
    length=`ls -la data_bacteria/out$x.fa | awk '{ print $5}'`;
    bytes=`./GeCo -tm 4:1:0:0/0 -tm 6:1:1:0/0 -tm 13:20:1:0/0 -tm 18:50:1:2/10 -c 40 -g 0.9 data_bacteria/out$x.fa | grep "Total bytes" | awk '{ print $16; }'`;
    name=`cat data_bacteria/out$x.fa | grep ">"`;
    decision=`echo "$bytes > 1.0" | bc -l`;
    if [[ "$decision" -eq "1" ]]; then
      printf "%s\t%s\t%s\n" "1.0" "$length" "$name" >> TOP-BACTERIA;
    else
      printf "%s\t%s\t%s\n" "$bytes" "$length" "$name" >> TOP-BACTERIA;
    fi
    done
  sort -V TOP-BACTERIA > SORTED-TOP-BACTERIA;
fi
#==============================================================================
# RUN TOP ARACHAEA
if [[ "$RUN_TOP_ARCHAEA" -eq "1" ]]; then
  rm -f TOP-ARCHAEA;
  size=`ls -la data_archaea/out*.fa | wc -l`;
  for((x=1 ; x<=$size; ++x));
    do
    echo "Running archaea $x out of $size ...";
    length=`ls -la data_archaea/out$x.fa | awk '{ print $5}'`;
    bytes=`./GeCo -tm 4:1:0:0/0 -tm 6:1:1:0/0 -tm 13:20:1:0/0 -tm 18:50:1:2/10 -c 40 -g 0.9 data_archaea/out$x.fa | grep "Total bytes" | awk '{ print $16; }'`;
    name=`cat data_archaea/out$x.fa | grep ">"`;
    decision=`echo "$bytes > 1.0" | bc -l`;
    if [[ "$decision" -eq "1" ]]; then
      printf "%s\t%s\t%s\n" "1.0" "$length" "$name" >> TOP-ARCHAEA;
    else
      printf "%s\t%s\t%s\n" "$bytes" "$length" "$name" >> TOP-ARCHAEA;
    fi
    done
  sort -V TOP-ARCHAEA > SORTED-TOP-ARCHAEA;
fi
#==============================================================================
# RUN TOP FUNGI
if [[ "$RUN_TOP_FUNGI" -eq "1" ]]; then
  rm -f TOP-FUNGI;
  size=`ls -la data_fungi/out*.fa | wc -l`;
  for((x=1 ; x<=$size; ++x));
    do
    echo "Running fungi $x out of $size ...";
    length=`ls -la data_fungi/out$x.fa | awk '{ print $5}'`;
    bytes=`./GeCo -tm 4:1:0:0/0 -tm 6:1:1:0/0 -tm 13:20:1:0/0 -tm 18:50:1:2/10 -c 40 -g 0.9 data_fungi/out$x.fa | grep "Total bytes" | awk '{ print $16; }'`;
    name=`cat data_fungi/out$x.fa | grep ">"`;
    decision=`echo "$bytes > 1.0" | bc -l`;
    if [[ "$decision" -eq "1" ]]; then
      printf "%s\t%s\t%s\n" "1.0" "$length" "$name" >> TOP-FUNGI;
    else
      printf "%s\t%s\t%s\n" "$bytes" "$length" "$name" >> TOP-FUNGI;
    fi
    done
  sort -V TOP-FUNGI > SORTED-TOP-FUNGI;
fi
#==============================================================================
# RUN TOP ANIMALS
if [[ "$RUN_TOP_ANIMALS" -eq "1" ]]; then
  rm -f TOP-ANIMALS;
  size=`ls -la data_animals/out*.fa | wc -l`;
  for((x=1 ; x<=$size; ++x));
    do
    echo "Running animals $x out of $size ...";
    length=`ls -la data_animals/out$x.fa | awk '{ print $5}'`;
    bytes=`./GeCo -tm 4:1:0:0/0 -tm 6:1:1:0/0 -tm 13:20:1:0/0 -tm 18:50:1:2/10 -c 80 -g 0.9 data_animals/out$x.fa | grep "Total bytes" | awk '{ print $16; }'`;
    name=`cat data_animals/out$x.fa | grep ">"`;
    decision=`echo "$bytes > 1.0" | bc -l`;
    if [[ "$decision" -eq "1" ]]; then
      printf "%s\t%s\t%s\n" "1.0" "$length" "$name" >> TOP-ANIMALS;
    else
      printf "%s\t%s\t%s\n" "$bytes" "$length" "$name" >> TOP-ANIMALS;
    fi
    done
  sort -V TOP-ANIMALS > SORTED-TOP-ANIMALS;
fi

#==============================================================================
# RUN TOP PLANTS
if [[ "$RUN_TOP_PLANTS" -eq "1" ]]; then
  rm -f TOP-PLANTS;
  size=`ls -la data_plants/out*.fa | wc -l`;
  for((x=1 ; x<=$size; ++x));
    do
    echo "Running plant $x out of $size ...";
    length=`ls -la data_plants/out$x.fa | awk '{ print $5}'`;
    bytes=`./GeCo -tm 4:1:0:0/0 -tm 6:1:1:0/0 -tm 13:20:1:0/0 -tm 18:50:1:2/10 -c 80 -g 0.9 data_plants/out$x.fa | grep "Total bytes" | awk '{ print $16; }'`;
    name=`cat data_plants/out$x.fa | grep ">"`;
    decision=`echo "$bytes > 1.0" | bc -l`;
    if [[ "$decision" -eq "1" ]]; then
      printf "%s\t%s\t%s\n" "1.0" "$length" "$name" >> TOP-PLANTS;
    else
      printf "%s\t%s\t%s\n" "$bytes" "$length" "$name" >> TOP-PLANTS;
    fi
    done
  sort -V TOP-PLANTS > SORTED-TOP-PLANTS;
fi
#==============================================================================
###############################################################################
#==============================================================================
# BUILD CP
if [[ "$RUN_CP" -eq "1" ]]; then
  cat SORTED-TOP-VIRUS    | awk '{print $1*$2"\t"$2"\t"$3}' > SD-CP-VIRUS
  cat SORTED-TOP-BACTERIA | awk '{print $1*$2"\t"$2"\t"$3}' > SD-CP-BACTERIA
  cat SORTED-TOP-ARCHAEA  | awk '{print $1*$2"\t"$2"\t"$3}' > SD-CP-ARCHAEA
  cat SORTED-TOP-FUNGI    | awk '{print $1*$2"\t"$2"\t"$3}' > SD-CP-FUNGI
  cat SORTED-TOP-ANIMALS  | awk '{print $1*$2"\t"$2"\t"$3}' > SD-CP-ANIMALS
  cat SORTED-TOP-PLANTS   | awk '{print $1*$2"\t"$2"\t"$3}' > SD-CP-PLANTS
  cat SD-CP-VIRUS    | awk 'BEGIN{bits=0;size=0}{bits+=$1;size+=$2} END{print "Viruses\t"bits/size;}' > TYPE
  cat SD-CP-BACTERIA | awk 'BEGIN{bits=0;size=0}{bits+=$1;size+=$2} END{print "Bacteria\t"bits/size;}' >> TYPE
  cat SD-CP-ARCHAEA  | awk 'BEGIN{bits=0;size=0}{bits+=$1;size+=$2} END{print "Archaea\t"bits/size;}' >> TYPE
  cat SD-CP-FUNGI    | awk 'BEGIN{bits=0;size=0}{bits+=$1;size+=$2} END{print "Fungi\t"bits/size;}' >> TYPE
  cat SD-CP-ANIMALS  | awk 'BEGIN{bits=0;size=0}{bits+=$1;size+=$2} END{print "Animals\t"bits/size;}' >> TYPE
  cat SD-CP-PLANTS   | awk 'BEGIN{bits=0;size=0}{bits+=$1;size+=$2} END{print "Plants\t"bits/size;}' >> TYPE
fi
#==============================================================================
###############################################################################
#==============================================================================
# PLOT 
if [[ "$RUN_PLOT" -eq "1" ]]; then
  gnuplot << EOF
  set terminal pdfcairo enhanced color
  set output "relative.pdf"
  set auto
  set key left bottom box
  set yrange [0.3:1.1] 
  set logscale x
  set grid
  set ylabel "Normalized Compression"
  set xlabel "Size"
  plot [100:300000000] "SORTED-TOP-VIRUS" u 2:1 w dots linecolor rgb '#3399FF' title "Virus", \
  "SORTED-TOP-BACTERIA" u 2:1 w dots linecolor rgb '#008000' title "Bacteria", \
  "SORTED-TOP-ARCHAEA" u 2:1 w dots linecolor rgb '#CC0000' title "Archaea", \
  "SORTED-TOP-FUNGI" u 2:1 w dots linecolor rgb '#6600CC' title "Fungi", \
  "SORTED-TOP-ANIMALS" u 2:1 w dots linecolor rgb '#FF00FF' title "Animals", \
  "SORTED-TOP-PLANTS" u 2:1 w dots linecolor rgb '#B8860B' title "Plants"
EOF
fi
#==============================================================================
# PLOT CP
if [[ "$RUN_PLOT_CP" -eq "1" ]]; then
  gnuplot << EOF
  set terminal pdfcairo enhanced color
  set output "compression.pdf"
  set auto
  set key left top box
  set yrange [100:100000000] 
  set logscale x
  set logscale y
  set grid
  set ylabel "Normalized Compression"
  set xlabel "Size"
  plot [100:300000000] "SD-CP-VIRUS" u 2:1 w dots title "Virus", \
  "SD-CP-BACTERIA" u 2:1 w dots title "Bacteria", \
  "SD-CP-ARCHAEA" u 2:1 w dots title "Archaea", \
  "SD-CP-FUNGI" u 2:1 w dots title "Fungi", \
  "SD-CP-ANIMALS" u 2:1 w dots title "Animals", \
  "SD-CP-PLANTS" u 2:1 w dots title "Plants"
EOF
fi
#==============================================================================
# PLOT BITS
if [[ "$RUN_PLOT_CUM" -eq "1" ]]; then
  gnuplot << EOF
  set terminal pdfcairo enhanced color
  set output 'cumulative.pdf'
  set auto
  set boxwidth 0.45
  set xtics nomirror
  set style fill solid 1.00
  set ylabel 'Normalized Cumulative Compression'
  set xlabel 'Types'
  set yrange[0.8:1.1]
  set grid ytics lc rgb '#C0C0C0'
  set style line 1 lc rgb "#3399FF"
  set style line 2 lc rgb "#008000"
  set style line 3 lc rgb "#CC0000"
  set style line 4 lc rgb "#6600CC"
  set style line 5 lc rgb "#FF00FF"
  set style line 6 lc rgb "#CC00CC"
  unset key
  set grid
  plot 'TYPE' using 2:xtic(1) with boxes ls 1, \
  'TYPE' using 2:xtic(1) with boxes ls 2, \
  'TYPE' using 2:xtic(1) with boxes ls 3, \
  'TYPE' using 2:xtic(1) with boxes ls 4, \
  'TYPE' using 2:xtic(1) with boxes ls 5, \
  'TYPE' using 2:xtic(1) with boxes ls 6
EOF
fi
#==============================================================================
###############################################################################
#==============================================================================

