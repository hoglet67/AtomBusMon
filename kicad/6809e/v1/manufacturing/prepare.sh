#!/bin/bash

SRC=6809e_adapter
DST=6809e_adapter

mv $SRC-B_Cu.gbl      $DST.gbl
mv $SRC-B_Mask.gbs    $DST.gbs
mv $SRC-B_SilkS.gbo   $DST.gbo
mv $SRC.drl           $DST.xln
mv $SRC-Edge_Cuts.gm1 $DST.gko
mv $SRC-F_Cu.gtl      $DST.gtl
mv $SRC-F_Mask.gts    $DST.gts
mv $SRC-F_SilkS.gto   $DST.gto

rm -f manufacturing.zip
zip -qr manufacturing.zip $DST.*
