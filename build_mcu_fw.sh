#!/bin/sh

. $(pwd)/build_env.sh

rm -r $MCU_FW_BUILD
mkdir -p $MCU_FW_BUILD

cd K1_Series_Klipper

for filepath in src/configs/K1*; do

    # Check if any files actually match the pattern
    [ -e "$filepath" ] || continue

    filename=$(basename "$filepath")
    echo "------------------------------------------"
    echo "Processing: $filename"
    echo "------------------------------------------"

    make $filename

    echo "Running make clean..."
    make clean

    echo "Running make..."
    make -j4

    if [ -d "out" ] && ls out/*000.bin >/dev/null 2>&1; then
        echo "Copying binaries..."
        cp out/*000.bin $MCU_FW_BUILD
    else
        echo "Warning: 'out' directory not found or no .bin files exist."
    fi
done

echo "Running make clean..."
make clean
