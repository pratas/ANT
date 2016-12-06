#!/bin/bash
#==============================================================================
GET_XS=1;
GET_GECO=1;
RUN_XS=1;
RUN_GECO=1;
#==============================================================================
###############################################################################
#==============================================================================
# GET XS
if [[ "$GET_XS" -eq "1" ]]; then
  rm -fr XS
  git clone https://github.com/pratas/XS.git
  cd XS/
  make
  cp XS ../XSx
  cd ..
  rm -fr XS/
  mv XSx XS
fi
#==============================================================================
# GET GECO
if [[ "$GET_GECO" -eq "1" ]]; then
  git clone https://github.com/pratas/geco.git
  cd geco/src/
  cmake .
  make
  cp GeCo ../../
  cd ../../
  rm -fr geco/
fi
#==============================================================================
###############################################################################
#==============================================================================
# RUN XS
if [[ "$RUN_XS" -eq "1" ]]; then
  rm -f SYN*;
  for((x=1,y=1 ; x<1000 ; x*=10, ++y)); do
  ./XS -v -ls 10000 -n $x -eh -eo -es -edb -f 0.25,0.25,0.25,0.25,0.0 -rn 0 -rm 0 -s 0 SYN$y;
  done
fi
#==============================================================================
# RUN GECO
if [[ "$RUN_GECO" -eq "1" ]]; then
  for((x=1 ; x<10 ; ++x)); do
    ./GeCo -tm 4:1:0:0/0 -tm 6:1:1:0/0 -tm 13:20:1:0/0 -tm 16:20:1:2/10 -c 30 -g 0.9 SYN$x;
  done
fi
#==============================================================================
