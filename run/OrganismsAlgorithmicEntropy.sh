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
#==============================================================================
SPLIT_READS_VIRUS=1;
SPLIT_READS_BACTERIA=1;
SPLIT_READS_ARCHAEA=1;
SPLIT_READS_FUNGI=1;
#==============================================================================
RUN_TOP_VIRUS=1;
RUN_TOP_BACTERIA=1;
RUN_TOP_ARCHAEA=1;
RUN_TOP_FUNGI=1;
#==============================================================================
RUN_PLOT=1;
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
    echo "Running virus $x out of $size ...";
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
    echo "Running virus $x out of $size ...";
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
    echo "Running virus $x out of $size ...";
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
# PLOT 
if [[ "$RUN_PLOT" -eq "1" ]]; then
  gnuplot << EOF
  set terminal pdfcairo enhanced color
  set output "virus.pdf"
  set auto
  unset key
  set yrange [0.3:1.5] 
  set logscale x
  set grid
  set ylabel "Normalized Compression"
  set xlabel "Size"
  plot [100:10000000] "SORTED-TOP-VIRUS" u 2:1 w dots
EOF
fi
#==============================================================================
###############################################################################
#==============================================================================

