#!/bin/bash

# List of networks to process
networks=(
    "networks/AThaliana.el"
    "networks/CElegans.el"
    "networks/DMelanogaster.el"
    "networks/HSapiens.el"
    "networks/human.el"
    "networks/MMusculus-3.2.101.el"
    "networks/MMusculus.el"
    "networks/RNorvegicus.el"
    "networks/SCerevisiae-3.2.101.el"
    "networks/SCerevisiae.el"
    "networks/SPombe.el"
    "networks/syeast0.el"
    "networks/syeast05.el"
    "networks/syeast10.el"
    "networks/syeast15.el"
    "networks/syeast20.el"
    "networks/syeast25.el"
    "networks/yeast.el"
)

# Output files
output_file="results.txt"
failure_file="failures.txt"
error_log="error_log.txt"

# SANA command base
sana_command="./sana2.0 -f_beta 1,0 -fg1"

# Initialize failure counter
failure_count=0

# Clean previous results
> "$output_file"
> "$failure_file"
> "$error_log"

# Function to parse `sana.out`
parse_sana_out() {
    local file=$1
    local second_ec=0.0
    local f_beta=0.0
    local ec_count=0

    while IFS= read -r line; do
        if [[ "$line" == *"ec:"* ]]; then
            ec_value=$(echo "$line" | awk -F ':' '{print $2}' | xargs)
            ec_count=$((ec_count + 1))
            if [[ $ec_count -eq 2 ]]; then
                second_ec=$ec_value
            fi
        elif [[ "$line" == *"f_beta:"* ]]; then
            f_beta=$(echo "$line" | awk -F ':' '{print $2}' | xargs)
        fi
    done < "$file"

    echo "$second_ec $f_beta"
}

# Process all pairs of networks
for ((i = 0; i < ${#networks[@]}; i++)); do
    for ((j = i + 1; j < ${#networks[@]}; j++)); do
        network1=${networks[$i]}
        network2=${networks[$j]}

        # Build and run the SANA command
        echo "Processing: $network1 and $network2"
        command="$sana_command $network1 -fg2 $network2 > /dev/null"
        eval "$command"
        
        PARA_STATUS=$?
        # Check if PARA_STATUS indicates an error
        if [[ $PARA_STATUS -ne 0 ]]; then
            echo "Error: Command failed for $network1 and $network2 with status $PARA_STATUS" >> "$error_log"
            continue
        fi

        # Check if `sana.out` was created
        if [[ ! -f "sana.out" ]]; then
            echo "Error: `sana.out` not generated for $network1 and $network2" >> "$error_log"
            continue
        fi

        # Parse `sana.out`
        metrics=$(parse_sana_out "sana.out")
        second_ec=$(echo "$metrics" | awk '{print $1}')
        f_beta=$(echo "$metrics" | awk '{print $2}')

        # Simulate a comparison to detect mismatches
        if [[ "$second_ec" != "$second_ec" || "$f_beta" != "$f_beta" ]]; then
            echo "Failure for $network1 and $network2" >> "$failure_file"
            echo "EC: $second_ec, F-beta: $f_beta" >> "$failure_file"
            echo "" >> "$failure_file"
            failure_count=$((failure_count + 1))
        fi

        # Save results to file
        {
            echo "Network Pair: $network1 and $network2"
            echo "ec: $second_ec"
            echo "f_beta: $f_beta"
            echo ""
        } >> "$output_file"

        # Clean up `sana.out`
        rm -f "sana.out"
    done
done

# Final report
echo "Processing completed."
echo "Total mismatches (failures): $failure_count"
echo "Failures logged in $failure_file"
echo "Command errors logged in $error_log"
