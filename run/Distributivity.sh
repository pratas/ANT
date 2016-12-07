#!/bin/bash
#==============================================================================
GET_XS=1;
GET_GECO=1;
GET_GOOSE=1;
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
# GET GOOSE
if [[ "$GET_GOOSE" -eq "1" ]]; then
  git clone https://github.com/pratas/goose.git
  cd goose/src/
  make
  cp goose-* ../../
  cd ../../
  rm -fr goose/
fi
#==============================================================================
###############################################################################
#==============================================================================
# RUN XS
if [[ "$RUN_XS" -eq "1" ]]; then
  ./XS -v -ls 100 -n 1400 -eh -eo -es -edb -f 0.25,0.25,0.25,0.25,0.0 -rn 0 -rm 0 -s 0 X1;
  ./goose-mutatedna -mr 0.10 < X1 > X2;
  ./XS -v -ls 100 -n 1000 -eh -eo -es -edb -f 0.25,0.25,0.25,0.25,0.0 -rn 0 -rm 0 -s 11 X3;
  ./goose-mutatedna -mr 0.01 < X3 > X4;
  cp X4 X5;
  ./XS -v -ls 100 -n 1200 -eh -eo -es -edb -f 0.25,0.25,0.25,0.25,0.0 -rn 0 -rm 0 -s 101 X6;
  cat X5 X6 > X7;
fi
#==============================================================================
# RUN GECO
if [[ "$RUN_GECO" -eq "1" ]]; then
  for((x=1 ; x<=7 ; ++x)); do  #7! = 720 combinations
    for((y=1 ; y<=7 ; ++y)); do  #8! = 40320 combinations
      for((z=1 ; z<=7 ; ++z)); do  
        echo "ID $x:$y:$z";
        XZ=`./GeCo -tm 18:20:0:0/10 -c 5 -g 0.9 X$x:X$z | grep "Total bytes" | awk '{ print $3}'`;
        YZ=`./GeCo -tm 18:20:0:0/10 -c 5 -g 0.9 X$y:X$z | grep "Total bytes" | awk '{ print $3}'`;
        XY=`./GeCo -tm 18:20:0:0/10 -c 5 -g 0.9 X$x:X$y | grep "Total bytes" | awk '{ print $3}'`;
        Z=`./GeCo  -tm 18:20:0:0/10 -c 5 -g 0.9 X$z | grep "Total bytes" | awk '{ print $3}'`;
        if [[ "$(($XZ+$YZ))" -lt "$(($XY+$Z))"  ]]; then
          echo "INVALID: it does not respect the distributivity property!";
          exit;
        fi
      done
    done
  done
fi
#==============================================================================
