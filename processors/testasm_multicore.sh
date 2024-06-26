for  ram_lat in 0 2 6 10
do
    echo "LAT=$ram_lat"
    sed -r "s|LAT = [0-9]+|LAT = $ram_lat|1" source/ram.sv | cat > temp_ram
    cat temp_ram > source/ram.sv
    rm temp_ram

    testasm -d multi test.coh example.asm daxpy.asm dual.daxpy.asm dual.LLr dual.LLSCt dual.m palgorithm crit
done