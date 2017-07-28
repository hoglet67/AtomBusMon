#!/bin/bash
DATE=$(date +"%Y%m%d_%H%M")

VERSION=$(grep "define VERSION" firmware/AtomBusMon.c | cut -d\" -f2 | tr -d "." )

NAME=ice_${DATE}_${VERSION}

DIR=releases/$NAME/

echo "Building release in: "${DIR}

mkdir -p ${DIR}

pushd target

make clean
make

cp --parents */*/*.bit ../${DIR}
cp --parents */*/*.mcs ../${DIR}

popd

pushd releases
zip -qr ${NAME}.zip ${NAME}
popd

echo "Built release in: "${DIR}
unzip -l releases/${NAME}.zip

 
