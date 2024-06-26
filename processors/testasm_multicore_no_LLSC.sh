for  ram_lat in 0 2 6 10
do
    sed -r "s|LAT = [0-9]+|LAT = $ram_lat|1" source/ram.sv | cat > temp_ram
    cat temp_ram > source/ram.sv
    rm temp_ram

    testasm -d multi test.coh dual.mergesort daxpy.asm dual.daxpy.asm
done