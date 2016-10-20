#!/bin/bash
#==============================================================================
#
# WARNING: YOU NEED APPROX. 500 GB OF FREE DISK
#
# RUNNING FLAGS
GET_GOOSE=0;
GET_GECO=0;
#==============================================================================
GET_VIRUS=0;
GET_BACTERIA=0;
GET_ARCHAEA=0;
GET_FUNGI=0;
#==============================================================================
SPLIT_READS_VIRUS=0;
SPLIT_READS_BACTERIA=0;
SPLIT_READS_ARCHAEA=0;
SPLIT_READS_FUNGI=0;
#==============================================================================
RUN_TOP_VIRUS=0;
RUN_TOP_BACTERIA=0;
RUN_TOP_ARCHAEA=0;
RUN_TOP_FUNGI=0;
#==============================================================================
RUN_CP=1;
#==============================================================================
RUN_PLOT=1;
RUN_PLOT_CP=1;
#==============================================================================
###############################################################################
#==============================================================================
# GET GOOSE
if [[ "$GET_GOOSE" -eq "1" ]]; then
  rm -fr goose/ goose-*
  git clone https://github.com/pratas/goose.git
  cd goose/src/
  make
  cp goose-* ../../
  cd ../../
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
  | ./goose-extractreadbypattern complete_genome > VDB.mfa
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
  | ./goose-extractreadbypattern complete_genome > BDB.mfa
fi
#==============================================================================
# GET ARCHAEA DB
if [[ "$GET_ARCHAEA" -eq "1" ]]; then
  perl DownloadArchaea.pl
  cat archaea.fa | tr ' ' '_' \
  | ./goose-extractreadbypattern complete_genome > ADB.mfa
fi
#==============================================================================
# GET ARCHAEA DB
if [[ "$GET_FUNGI" -eq "1" ]]; then
  perl DownloadFungi.pl
  cat fungi.fa | tr ' ' '_' \
  | ./goose-extractreadbypattern complete_genome > FDB.mfa
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
    bytes=`./GeCo -tm 4:1:0:0/0 -tm 6:1:1:0/0 -tm 13:20:1:0/0 -tm 16:20:1:2/10 -c 20 -g 0.9 data_virus/out$x.fa | grep "Total bytes" | awk '{ print $16; }'`;
    name=`cat data_virus/out$x.fa | grep ">"`;
    printf "%s\t%s\t%s\n" "$bytes" "$length" "$name" >> TOP-VIRUS;
    done
  sort -V TOP-VIRUS > SORTED-TOP-VIRUS;
fi
#==============================================================================
# RUN TOP BACTERIA
if [[ "$RUN_TOP_BACTERIA" -eq "1" ]]; then
  rm -f TOP-VIRUS_BACTERIA;
  size=`ls -la data_bacteria/out*.fa | wc -l`;
  for((x=1 ; x<=$size; ++x));
    do
    echo "Running bacteria $x out of $size ...";
    length=`ls -la data_bacteria/out$x.fa | awk '{ print $5}'`;
    bytes=`./GeCo -tm 4:1:0:0/0 -tm 6:1:1:0/0 -tm 13:20:1:0/0 -tm 16:20:1:2/10 -c 20 -g 0.9 data_bacteria/out$x.fa | grep "Total bytes" | awk '{ print $16; }'`;
    name=`cat data_bacteria/out$x.fa | grep ">"`;
    printf "%s\t%s\t%s\n" "$bytes" "$length" "$name" >> TOP-BACTERIA;
    done
  sort -V TOP-BACTERIA > SORTED-TOP-BACTERIA;
fi
#==============================================================================
# RUN TOP ARACHAEA
if [[ "$RUN_TOP_ARCHAEA" -eq "1" ]]; then
  rm -f TOP-VIRUS_ARCHAEA;
  size=`ls -la data_archaea/out*.fa | wc -l`;
  for((x=1 ; x<=$size; ++x));
    do
    echo "Running archaea $x out of $size ...";
    length=`ls -la data_archaea/out$x.fa | awk '{ print $5}'`;
    bytes=`./GeCo -tm 4:1:0:0/0 -tm 6:1:1:0/0 -tm 13:20:1:0/0 -tm 16:20:1:2/10 -c 20 -g 0.9 data_archaea/out$x.fa | grep "Total bytes" | awk '{ print $16; }'`;
    name=`cat data_archaea/out$x.fa | grep ">"`;
    printf "%s\t%s\t%s\n" "$bytes" "$length" "$name" >> TOP-ARCHAEA;
    done
  sort -V TOP-ARCHAEA > SORTED-TOP-ARCHAEA;
fi
#==============================================================================
# RUN TOP FUNGI
if [[ "$RUN_TOP_FUNGI" -eq "1" ]]; then
  rm -f TOP-VIRUS_FUNGI;
  size=`ls -la data_fungi/out*.fa | wc -l`;
  for((x=1 ; x<=$size; ++x));
    do
    echo "Running fungi $x out of $size ...";
    length=`ls -la data_fungi/out$x.fa | awk '{ print $5}'`;
    bytes=`./GeCo -tm 4:1:0:0/0 -tm 6:1:1:0/0 -tm 13:20:1:0/0 -tm 16:20:1:2/10 -c 20 -g 0.9 data_fungi/out$x.fa | grep "Total bytes" | awk '{ print $16; }'`;
    name=`cat data_fungi/out$x.fa | grep ">"`;
    printf "%s\t%s\t%s\n" "$bytes" "$length" "$name" >> TOP-FUNGI;
    done
  sort -V TOP-FUNGI > SORTED-TOP-FUNGI;
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
  cat SD-CP-VIRUS    | awk 'BEGIN{bits=0;size=0}{bits+=$1;size+=$2} END{print "Virus: "bits/size;}' > RT_VIRUS
  cat SD-CP-BACTERIA | awk 'BEGIN{bits=0;size=0}{bits+=$1;size+=$2} END{print "Bacteria: "bits/size;}' > RT_BACTERIA
  cat SD-CP-ARCHAEA  | awk 'BEGIN{bits=0;size=0}{bits+=$1;size+=$2} END{print "Arachaea: "bits/size;}' > RT_ARCHAEA
  cat SD-CP-FUNGI    | awk 'BEGIN{bits=0;size=0}{bits+=$1;size+=$2} END{print "Fungi: "bits/size;}' > RT_FUNGI
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
  set yrange [0.3:1.5] 
  set logscale x
  set grid
  set ylabel "Normalized Compression"
  set xlabel "Size"
  plot [100:100000000] "SORTED-TOP-VIRUS" u 2:1 w dots title "Virus", \
  "SORTED-TOP-BACTERIA" u 2:1 w dots title "Bacteria", \
  "SORTED-TOP-ARCHAEA" u 2:1 w dots title "Archaea", \
  "SORTED-TOP-FUNGI" u 2:1 w dots title "Fungi"
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
  plot [100:100000000] "SD-CP-VIRUS" u 2:1 w dots title "Virus", \
  "SD-CP-BACTERIA" u 2:1 w dots title "Bacteria", \
  "SD-CP-ARCHAEA" u 2:1 w dots title "Archaea", \
  "SD-CP-FUNGI" u 2:1 w dots title "Fungi"
EOF
fi
###############################################################################
echo "set terminal pdfcairo enhanced color
set output 'bytes.pdf'
set auto
set boxwidth 0.45
set xtics nomirror
set style fill solid 1.00
set ylabel 'Bytes'
set xlabel 'Types'
set yrange[0:1]
# Lighter grid lines
set grid ytics lc rgb '#C0C0C0'
unset key
set grid
set format y '%.0s %c'
set style line 2 lc rgb '#406090'
plot 'RT_VIRUS' using 2:xtic(1) with boxes ls 2", \
'RT_VIRUS' using 2:xtic(1) with boxes ls 2",
#==============================================================================
###############################################################################
#==============================================================================

