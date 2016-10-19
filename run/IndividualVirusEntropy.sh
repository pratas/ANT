#!/bin/bash
GET_GOOSE=1;
GET_GECO=1;
GET_VIRUS=1;
SPLIT_READS=1;
RUN_TOP=1;
RUN_PLOT=1;
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
# GET VIRUS DB
if [[ "$GET_VIRUS" -eq "1" ]]; then
  perl DownloadViruses.pl
  cat viruses.fa | tr ' ' '_' \
  | ./goose-extractreadbypattern complete_genome > VDB.mfa
fi
#==============================================================================
# SPLIT READS
if [[ "$SPLIT_READS" -eq "1" ]]; then
  mkdir -p data/
  cp goose-splitreads data/
  cp VDB.mfa data/
  cd data/
  ./goose-splitreads < VDB.mfa
  cd ..
fi
#==============================================================================
# RUN TOP
if [[ "$RUN_TOP" -eq "1" ]]; then
  rm -f TOP;
  size=`ls -la data/out*.fa | wc -l`;
  for((x=1 ; x<=$size; ++x));
    do
    echo "Running $x out of $size ...";
    length=`ls -la data/out$x.fa | awk '{ print $5}'`;
    bytes=`./GeCo -tm 4:1:0:0/0 -tm 6:1:1:0/0 -tm 13:20:1:0/0 -tm 16:20:1:2/10 -c 20 -g 0.9 data/out$x.fa | grep "Total bytes" | awk '{ print $16; }'`;
    name=`cat data/out$x.fa | grep ">"`;
    printf "%s\t%s\t%s\n" "$bytes" "$length" "$name" >> TOP
    done
  sort -V TOP > SORTED-TOP;
fi
#==============================================================================
# PLOT 
if [[ "$RUN_PLOT" -eq "1" ]]; then
  gnuplot << EOF
  set terminal pdfcairo enhanced color
  set output "virus.pdf"
  set auto
  unset key
  set yrange [0:1.5] 
  set grid
  set ylabel "Normalized Relative Compression"
  set xlabel "Size"
  plot [0:8330218] "SORTED-TOP" u 1:2 w dots
EOF
fi
#==============================================================================




