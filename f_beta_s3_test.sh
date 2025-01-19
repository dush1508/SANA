# List to store successful (Second Ec, F Measure) pairs
declare -a results_list=()
#!/bin/bash

# List of networks to process
networks=(
    "networks/AThaliana.el"
    "networks/CElegans.el"
    "networks/DMelanogaster.el"
    "networks/HSapiens.el"
    "networks/human.el"
    
)

# Output files
output_file="results.txt"
error_log="error_log.txt"

# SANA command base
sana_command="./sana2.0 -f_beta 1,1 -fg1"

# Clean previous results
> "$output_file"
> "$error_log"

parse_sana_out() {
    local file=$1
    local s3=0.69
    local f_beta=0.0
    local s3_found=false

    while IFS= read -r line; do
        if [[ "$line" == "s3:"* && $s3_found == false ]]; then
            s3=$(echo "$line" | awk -F ':' '{print $2}' | xargs)
            s3_found=true
        elif [[ "$line" == *"f_beta:"* ]]; then
            f_beta=$(echo "$line" | awk -F ':' '{print $2}' | xargs)
        fi
    done < "$file"

    echo "$s3 $f_beta"
}

# Function to check monotonicity
check_monotonicity() {
    local pairs=$1  # Pass array by name
    local increasing=true
    local decreasing=true

    for ((k = 0; k < ${#pairs[@]} - 2; k+=2)); do
        ec1=${pairs[k]}
        fb1=${pairs[k+1]}
        ec2=${pairs[k+2]}
        fb2=${pairs[k+3]}

        # Compare to check monotonicity
        if (( $(echo "$ec1 <= $ec2" | bc -l) )); then
            if (( $(echo "$fb1 > $fb2" | bc -l) )); then
                increasing=false
            fi
        else
            increasing=false
        fi

        if (( $(echo "$ec1 >= $ec2" | bc -l) )); then
            if (( $(echo "$fb1 < $fb2" | bc -l) )); then
                decreasing=false
            fi
        else
            decreasing=false
        fi
    done

    if [[ $increasing == true || $decreasing == true ]]; then
        echo "Monotonic relationship detected."
    else
        echo "No monotonic relationship detected."
    fi
}


# Process all pairs of networks
for ((i = 0; i < ${#networks[@]}; i++)); do
    for ((j = i + 1; j < ${#networks[@]}; j++)); do
        network1=${networks[$i]}
        network2=${networks[$j]}

        echo "Processing: $network1 and $network2"
        command="$sana_command $network1 -fg2 $network2 > /dev/null"
        eval "$command"
        
        PARA_STATUS=$?
        if [[ $PARA_STATUS -ne 0 || ! -f "sana.out" ]]; then
            echo "Error: Failed for $network1 and $network2" >> "$error_log"
            continue
        fi

        # Parse `sana.out`
        metrics=$(parse_sana_out "sana.out")
        s3=$(echo "$metrics" | awk '{print $1}')
        f_beta=$(echo "$metrics" | awk '{print $2}')

        # Save results if valid
        if [[ -n "$s3" && -n "$f_beta" ]]; then
            results_list+=("$s3" "$f_beta")
            {
                echo "Network Pair: $network1 and $network2"
                echo "s3: $s3"
                echo "f_beta: $f_beta"
                echo ""
            } >> "$output_file"
        else
            echo "Invalid results for $network1 and $network2" >> "$failure_file"
        fi

        rm -f "sana.out"
    done
done

# Check monotonicity after processing
if [[ ${#results_list[@]} -gt 2 ]]; then
    echo "Analyzing monotonicity..."
    check_monotonicity results_list
else
    echo "Insufficient data for monotonicity analysis."
fi

# Final report
echo "Processing completed."
