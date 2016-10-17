#!/bin/bash
GET_GOOSE=0;
GET_GECO=0;
GET_VIRUS=0;
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
  | ./goose-extractreadbypattern complete_genome > VDB.fa
fi
#==============================================================================
# SPLIT READS
mkdir -p data/
cp goose-splitreads data/
cp VDB.fa data/
cd data/
./goose-splitreads < VDB.fa
cd ..
#==============================================================================
rm -f TOP;
./GeCo -tm 4:1:0:0/0 -tm 6:1:1:0/0 -tm 13:20:1:0/0 -tm 16:20:1:2/10 -c 20 -g 0.9 data/out$x.fa |
cat data/out$x.fa | grep ">" >> TOP;

