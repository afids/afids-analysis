#!/bin/bash
# run locally on rete (graham was down) 20180823: ~/graham/projects/fid_study_bids/
# pre-req: fmriprep output

function usage {
 echo ""
 echo "Transform fcsv files"
 echo ""
 echo "Required args:"
 echo "  -i input_csv with subject names (e.g. sub-C020)"
 echo ""
}

if [ "$#" -lt 2 ]
then
 usage
 exit 1
fi

while getopts "i:" options; do
 case $options in
     i ) 
         in_csv=$OPTARG;;

    * ) usage
        exit 1;;
 esac
done

input_bids_dir=~/graham/project/fid_study_bids/PHASE2/input_data/OAS1_bids_MR1/derivatives/fmriprep_1.1.1/fmriprep/
input_fcsv_dir=~/GitHub/afids-analysis/data/PHASE2_output_afid_postQC/
output_dir=~/GitHub/afids-analysis/data/PHASE3_output_afid_lin/

mkdir -p $output_dir
{
  read # first line is a header
while read SUBJ; do
  echo "---------"
  echo $SUBJ
  echo "---------"

  input_warp_to_MNI152=${input_bids_dir}/${SUBJ}/anat/${SUBJ}_T1w_target-MNI152NLin2009cAsym_warp.h5
  input_warp_to_MNI152_inv=${input_bids_dir}/${SUBJ}/anat/${SUBJ}_T1w_space-MNI152NLin2009cAsym_target-T1w_warp.h5
  input_subj_id=`echo $SUBJ | cut -d "-" -f 2`
  input_fcsv=${input_fcsv_dir}/OAS1_${input_subj_id}_MR1_T1_MEAN.fcsv

  output_fcsv=${output_dir}/OAS1_${input_subj_id}_MR1_T1_MEAN_transformed.fcsv

  echo python3 ~/graham/GitHub/sandbox/antsApplyH5TransformsToSlicerFCSV.py -i $input_fcsv -o $output_fcsv -f $input_warp_to_MNI152 -b $input_warp_to_MNI152_inv
  python3 ~/graham/GitHub/sandbox/antsApplyH5TransformsToSlicerFCSV.py -i $input_fcsv -o $output_fcsv -f $input_warp_to_MNI152 -b $input_warp_to_MNI152_inv

done
} < "$in_csv"
