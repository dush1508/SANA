#!/bin/bash

# Specify the single network pair to process
network1="networks/CElegans.el"
network2="networks/AThaliana.el"

# Output files
output_file="results.txt"
error_log="error_log.txt"

# Clean previous results
> "$output_file"
> "$error_log"

# SANA command base
sana_command_base="./sana2.0 -f_beta 1,z -fg1"

# Range for 'a' values (10^1 to 10^100)
declare -a a_values=()
for ((i = 1; i <= 100; i++)); do
    a_values+=($(bc <<< "10^$i"))
done

# Function to parse SANA output
parse_sana_out() {
    local file=$1
    local ics1=0.0
    local ics2=0.0
    local f_beta=0.0
    local ics_count=0

    while IFS= read -r line; do
        if [[ "$line" == "ics:"* && $ics_count -lt 2 ]]; then
            if [[ $ics_count -eq 0 ]]; then
                ics1=$(echo "$line" | awk -F ':' '{print $2}' | xargs)
            else
                ics2=$(echo "$line" | awk -F ':' '{print $2}' | xargs)
            fi
            ics_count=$((ics_count + 1))
        elif [[ "$line" == *"f_beta:"* ]]; then
            f_beta=$(echo "$line" | awk -F ':' '{print $2}' | xargs)
        fi
    done < "$file"

    echo "$ics1 $ics2 $f_beta"
}

# Process the network pair
echo "Processing: $network1 and $network2"

# Iterate over all 'a' values
for a in "${a_values[@]}"; do
    echo "Running for a = $a"
    suma_ics1=0
    suma_ics2=0
    suma_fbeta=0

    for ((run = 1; run <= 10; run++)); do
        echo "Run $run for a = $a"

        sana_command="${sana_command_base/z/$a} $network1 -fg2 $network2"
        eval "$sana_command > /dev/null"

        PARA_STATUS=$?
        if [[ $PARA_STATUS -ne 0 || ! -f "sana.out" ]]; then
            echo "Error: Failed for $network1 and $network2, z = $a, run = $run" >> "$error_log"
            continue
        fi

        # Parse `sana.out`
        metrics=$(parse_sana_out "sana.out")
        ics1=$(echo "$metrics" | awk '{print $1}')
        ics2=$(echo "$metrics" | awk '{print $2}')
        f_beta=$(echo "$metrics" | awk '{print $3}')

        # Accumulate results
        suma_ics1=$(bc -l <<< "$suma_ics1 + $ics1")
        suma_ics2=$(bc -l <<< "$suma_ics2 + $ics2")
        suma_fbeta=$(bc -l <<< "$suma_fbeta + $f_beta")

        rm -f "sana.out"
    done

    # Compute averages
    avg_ics1=$(bc -l <<< "$suma_ics1 / 10")
    avg_ics2=$(bc -l <<< "$suma_ics2 / 10")
    avg_fbeta=$(bc -l <<< "$suma_fbeta / 10")

    # Save to file
    {
        echo "Network Pair: $network1 and $network2"
        echo "a: $a"
        echo "Average ics1: $avg_ics1"
        echo "Average ics2: $avg_ics2"
        echo "Average f_beta: $avg_fbeta"
        echo ""
    } >> "$output_file"
done

echo "Processing completed. Results saved to $output_file."
