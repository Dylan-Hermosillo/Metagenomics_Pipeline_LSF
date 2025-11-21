#!/bin/bash

#======================================================
# I'm a helper script. Make me executable and run me first to pull only the workflow and module files, and make them executable.
# Type the following into your terminal:
# chmod +x run_me_first.sh
# ./run_me_first.sh
#======================================================

# Store current directory
work_dir=$(pwd)

# Navigate to pipeline directory and move files
mv Workflow/run_scripts Workflow/test_data "$work_dir"/..
mv Modules "$work_dir"/..

# Return to work directory and clean up
cd "$work_dir"/..
rm -rf Metagenomics_Pipeline_LSF

# Make all .sh files executable
find run_scripts Modules -type f -name "*.sh" -exec chmod +x {} \;

echo "Setup complete. Files moved to: $work_dir"
echo "All .sh files made executable"
echo "edit WORKING_DIR and XFILE in the config.sh file to your working directory and file with SRA ID list"
echo "./launch_pipeline.sh after making config changes"
