for  ram_lat in 0 2 6 10
do
    sed -r "s|LAT = [0-9]+|LAT = $ram_lat|1" source/ram.sv | cat > temp_ram
    cat temp_ram > source/ram.sv
    rm temp_ram

    testasm -s -d multi test.coh example.asm dual palgorithm
done