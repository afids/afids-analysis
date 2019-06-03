#!/bin/bash
# extract ROIs of interest from fmriprep output (pallidum,striatum,thalamus); and make linear and nonlinear transform versions
# run locally on rete (graham was down) 20180823: ~/graham/projects/fid_study_bids/
# pre-req: fmriprep output
# run from ~/GitHub/afids-analysis/
#   because CompositeTransformUtil does not allow for absolute paths

function usage {
 echo ""
 echo "Isolate ROIs of interest from fmriprep output"
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
     i ) echo "  Input csv $OPTARG"
         in_csv=$OPTARG;;

    * ) usage
	exit 1;;
 esac
done

echo "Input CSV file: $in_csv"

# TODO: remove hardcoded paths/variable names
input_bids_dir=~/graham/project/fid_study_bids/PHASE2/input_data/OAS1_bids_MR1/derivatives/fmriprep_1.1.1/fmriprep/
output_dir=~/graham/project/fid_study_bids/PHASE2/input_data/OAS1_bids_MR1/derivatives/fmriprep_1.1.1/fmriprep_PHASE3/

mkdir -p $output_dir

# input template
template_dir=~/GitHub/afidprotocol/etc/
input_template=${template_dir}/MNI152NLin2009cAsym_T1w.nii.gz

while read SUBJ; do
  echo "---------"
  echo $SUBJ
  echo "---------"
  input_label_aseg=${input_bids_dir}/${SUBJ}/anat/${SUBJ}_T1w_label-aseg_roi.nii.gz
  input_warp_to_MNI152_nlin=${input_bids_dir}/${SUBJ}/anat/${SUBJ}_T1w_target-MNI152NLin2009cAsym_warp.h5

  output_warp_to_MNI152_lin_local=./00_${SUBJ}_AffineTransform.mat
  output_warp_to_MNI152_nlin_local=./01_${SUBJ}_DisplacementFieldTransform.nii.gz
  output_warp_to_MNI152_lin=${output_dir}/${SUBJ}/anat/${SUBJ}_T1w_target-MNI152NLin2009cAsym_lin.mat
  output_warp_to_MNI152_nlin=${output_dir}/${SUBJ}/anat/${SUBJ}_T1w_target-MNI152NLin2009cAsym_nlin.nii.gz

  output_label_aseg=${output_dir}/${SUBJ}/anat/${SUBJ}_T1w_label-aseg_roi.nii.gz
  output_label_thalamusL=${output_dir}/${SUBJ}/anat/${SUBJ}_T1w_label-thalamus-L_roi.nii.gz
  output_label_thalamusR=${output_dir}/${SUBJ}/anat/${SUBJ}_T1w_label-thalamus-R_roi.nii.gz
  output_label_striatumL=${output_dir}/${SUBJ}/anat/${SUBJ}_T1w_label-striatum-L_roi.nii.gz
  output_label_striatumR=${output_dir}/${SUBJ}/anat/${SUBJ}_T1w_label-striatum-R_roi.nii.gz
  output_label_pallidumL=${output_dir}/${SUBJ}/anat/${SUBJ}_T1w_label-pallidum-L_roi.nii.gz
  output_label_pallidumR=${output_dir}/${SUBJ}/anat/${SUBJ}_T1w_label-pallidum-R_roi.nii.gz

  temp_output_label_naccL=${output_dir}/${SUBJ}/anat/${SUBJ}_T1w_label-nacc-L_roi_temp.nii.gz
  temp_output_label_naccR=${output_dir}/${SUBJ}/anat/${SUBJ}_T1w_label-nacc-R_roi_temp.nii.gz

  output_label_MNI152_lin_aseg=${output_dir}/${SUBJ}/anat/${SUBJ}_T1w_space-MNI152NLin2009cAsym_label-aseg_roi_lin.nii.gz
  output_label_MNI152_lin_thalamusL=${output_dir}/${SUBJ}/anat/${SUBJ}_T1w_space-MNI152NLin2009cAsym_label-thalamus-L_roi_lin.nii.gz
  output_label_MNI152_lin_thalamusR=${output_dir}/${SUBJ}/anat/${SUBJ}_T1w_space-MNI152NLin2009cAsym_label-thalamus-R_roi_lin.nii.gz
  output_label_MNI152_lin_striatumL=${output_dir}/${SUBJ}/anat/${SUBJ}_T1w_space-MNI152NLin2009cAsym_label-striatum-L_roi_lin.nii.gz
  output_label_MNI152_lin_striatumR=${output_dir}/${SUBJ}/anat/${SUBJ}_T1w_space-MNI152NLin2009cAsym_label-striatum-R_roi_lin.nii.gz
  output_label_MNI152_lin_pallidumL=${output_dir}/${SUBJ}/anat/${SUBJ}_T1w_space-MNI152NLin2009cAsym_label-pallidum-L_roi_lin.nii.gz
  output_label_MNI152_lin_pallidumR=${output_dir}/${SUBJ}/anat/${SUBJ}_T1w_space-MNI152NLin2009cAsym_label-pallidum-R_roi_lin.nii.gz

  output_label_MNI152_nlin_aseg=${output_dir}/${SUBJ}/anat/${SUBJ}_T1w_space-MNI152NLin2009cAsym_label-aseg_roi_nlin.nii.gz
  output_label_MNI152_nlin_thalamusL=${output_dir}/${SUBJ}/anat/${SUBJ}_T1w_space-MNI152NLin2009cAsym_label-thalamus-L_roi_nlin.nii.gz
  output_label_MNI152_nlin_thalamusR=${output_dir}/${SUBJ}/anat/${SUBJ}_T1w_space-MNI152NLin2009cAsym_label-thalamus-R_roi_nlin.nii.gz
  output_label_MNI152_nlin_striatumL=${output_dir}/${SUBJ}/anat/${SUBJ}_T1w_space-MNI152NLin2009cAsym_label-striatum-L_roi_nlin.nii.gz
  output_label_MNI152_nlin_striatumR=${output_dir}/${SUBJ}/anat/${SUBJ}_T1w_space-MNI152NLin2009cAsym_label-striatum-R_roi_nlin.nii.gz
  output_label_MNI152_nlin_pallidumL=${output_dir}/${SUBJ}/anat/${SUBJ}_T1w_space-MNI152NLin2009cAsym_label-pallidum-L_roi_nlin.nii.gz
  output_label_MNI152_nlin_pallidumR=${output_dir}/${SUBJ}/anat/${SUBJ}_T1w_space-MNI152NLin2009cAsym_label-pallidum-R_roi_nlin.nii.gz

  mkdir -p ${output_dir}/${SUBJ}/anat/

  # isolate ROIs of interest
   echo cp $input_label_aseg $output_label_aseg
   cp $input_label_aseg $output_label_aseg
   echo fslmaths $output_label_aseg -thr  9 -uthr 10 -bin $output_label_thalamusL
   fslmaths $output_label_aseg -thr  9 -uthr 10 -bin $output_label_thalamusL
   echo fslmaths $output_label_aseg -thr 48 -uthr 49 -bin $output_label_thalamusR
   fslmaths $output_label_aseg -thr 48 -uthr 49 -bin $output_label_thalamusR
 
   echo fslmaths $output_label_aseg -thr 11 -uthr 12 -bin $output_label_striatumL
   fslmaths $output_label_aseg -thr 11 -uthr 12 -bin $output_label_striatumL
   echo fslmaths $output_label_aseg -thr 26 -uthr 26 -bin $temp_output_label_naccL
   fslmaths $output_label_aseg -thr 26 -uthr 26 -bin $temp_output_label_naccL
   echo fslmaths $output_label_striatumL -add $temp_output_label_naccL -bin $output_label_striatumL
   fslmaths $output_label_striatumL -add $temp_output_label_naccL -bin $output_label_striatumL
 
   echo fslmaths $output_label_aseg -thr 50 -uthr 51 -bin $output_label_striatumR
   fslmaths $output_label_aseg -thr 50 -uthr 51 -bin $output_label_striatumR
   echo fslmaths $output_label_aseg -thr 58 -uthr 58 -bin $temp_output_label_naccR
   fslmaths $output_label_aseg -thr 58 -uthr 58 -bin $temp_output_label_naccR
   echo fslmaths $output_label_striatumR -add $temp_output_label_naccR -bin $output_label_striatumR
   fslmaths $output_label_striatumR -add $temp_output_label_naccR -bin $output_label_striatumR
 
   echo fslmaths $output_label_aseg -thr 13 -uthr 13 -bin $output_label_pallidumL
   fslmaths $output_label_aseg -thr 13 -uthr 13 -bin $output_label_pallidumL
   echo fslmaths $output_label_aseg -thr 52 -uthr 52 -bin $output_label_pallidumR
   fslmaths $output_label_aseg -thr 52 -uthr 52 -bin $output_label_pallidumR
 
   # propagate transforms for ROIs of interest
   echo antsApplyTransforms -d 3 --float 1 --verbose 1 -i $output_label_aseg -o $output_label_MNI152_nlin_aseg -r $input_template -t $input_warp_to_MNI152_nlin -n NearestNeighbor
   echo antsApplyTransforms -d 3 --float 1 --verbose 1 -i $output_label_thalamusL -o $output_label_MNI152_nlin_thalamusL -r $input_template -t $input_warp_to_MNI152_nlin -n NearestNeighbor
   echo antsApplyTransforms -d 3 --float 1 --verbose 1 -i $output_label_thalamusR -o $output_label_MNI152_nlin_thalamusR -r $input_template -t $input_warp_to_MNI152_nlin -n NearestNeighbor
   echo antsApplyTransforms -d 3 --float 1 --verbose 1 -i $output_label_striatumL -o $output_label_MNI152_nlin_striatumL -r $input_template -t $input_warp_to_MNI152_nlin -n NearestNeighbor
   echo antsApplyTransforms -d 3 --float 1 --verbose 1 -i $output_label_striatumR -o $output_label_MNI152_nlin_striatumR -r $input_template -t $input_warp_to_MNI152_nlin -n NearestNeighbor
   echo antsApplyTransforms -d 3 --float 1 --verbose 1 -i $output_label_pallidumL -o $output_label_MNI152_nlin_pallidumL -r $input_template -t $input_warp_to_MNI152_nlin -n NearestNeighbor
   echo antsApplyTransforms -d 3 --float 1 --verbose 1 -i $output_label_pallidumR -o $output_label_MNI152_nlin_pallidumR -r $input_template -t $input_warp_to_MNI152_nlin -n NearestNeighbor

   antsApplyTransforms -d 3 --float 1 --verbose 1 -i $output_label_aseg -o $output_label_MNI152_nlin_aseg -r $input_template -t $input_warp_to_MNI152_nlin -n NearestNeighbor
   antsApplyTransforms -d 3 --float 1 --verbose 1 -i $output_label_thalamusL -o $output_label_MNI152_nlin_thalamusL -r $input_template -t $input_warp_to_MNI152_nlin -n NearestNeighbor
   antsApplyTransforms -d 3 --float 1 --verbose 1 -i $output_label_thalamusR -o $output_label_MNI152_nlin_thalamusR -r $input_template -t $input_warp_to_MNI152_nlin -n NearestNeighbor
   antsApplyTransforms -d 3 --float 1 --verbose 1 -i $output_label_striatumL -o $output_label_MNI152_nlin_striatumL -r $input_template -t $input_warp_to_MNI152_nlin -n NearestNeighbor
   antsApplyTransforms -d 3 --float 1 --verbose 1 -i $output_label_striatumR -o $output_label_MNI152_nlin_striatumR -r $input_template -t $input_warp_to_MNI152_nlin -n NearestNeighbor
   antsApplyTransforms -d 3 --float 1 --verbose 1 -i $output_label_pallidumL -o $output_label_MNI152_nlin_pallidumL -r $input_template -t $input_warp_to_MNI152_nlin -n NearestNeighbor
   antsApplyTransforms -d 3 --float 1 --verbose 1 -i $output_label_pallidumR -o $output_label_MNI152_nlin_pallidumR -r $input_template -t $input_warp_to_MNI152_nlin -n NearestNeighbor

   # decompose/disassemble transforms into linear and nonlinear component parts
   CompositeTransformUtil --disassemble $input_warp_to_MNI152_nlin $SUBJ
   mv $output_warp_to_MNI152_lin_local $output_warp_to_MNI152_lin 
   mv $output_warp_to_MNI152_nlin_local $output_warp_to_MNI152_nlin 

   # propagate transforms for ROIs of interest
   echo antsApplyTransforms -d 3 --float 1 --verbose 1 -i $output_label_aseg -o $output_label_MNI152_lin_aseg -r $input_template -t $output_warp_to_MNI152_lin -n NearestNeighbor
   echo antsApplyTransforms -d 3 --float 1 --verbose 1 -i $output_label_thalamusL -o $output_label_MNI152_lin_thalamusL -r $input_template -t $output_warp_to_MNI152_lin -n NearestNeighbor
   echo antsApplyTransforms -d 3 --float 1 --verbose 1 -i $output_label_thalamusR -o $output_label_MNI152_lin_thalamusR -r $input_template -t $output_warp_to_MNI152_lin -n NearestNeighbor
   echo antsApplyTransforms -d 3 --float 1 --verbose 1 -i $output_label_striatumL -o $output_label_MNI152_lin_striatumL -r $input_template -t $output_warp_to_MNI152_lin -n NearestNeighbor
   echo antsApplyTransforms -d 3 --float 1 --verbose 1 -i $output_label_striatumR -o $output_label_MNI152_lin_striatumR -r $input_template -t $output_warp_to_MNI152_lin -n NearestNeighbor
   echo antsApplyTransforms -d 3 --float 1 --verbose 1 -i $output_label_pallidumL -o $output_label_MNI152_lin_pallidumL -r $input_template -t $output_warp_to_MNI152_lin -n NearestNeighbor
   echo antsApplyTransforms -d 3 --float 1 --verbose 1 -i $output_label_pallidumR -o $output_label_MNI152_lin_pallidumR -r $input_template -t $output_warp_to_MNI152_lin -n NearestNeighbor

   antsApplyTransforms -d 3 --float 1 --verbose 1 -i $output_label_aseg -o $output_label_MNI152_lin_aseg -r $input_template -t $output_warp_to_MNI152_lin -n NearestNeighbor
   antsApplyTransforms -d 3 --float 1 --verbose 1 -i $output_label_thalamusL -o $output_label_MNI152_lin_thalamusL -r $input_template -t $output_warp_to_MNI152_lin -n NearestNeighbor
   antsApplyTransforms -d 3 --float 1 --verbose 1 -i $output_label_thalamusR -o $output_label_MNI152_lin_thalamusR -r $input_template -t $output_warp_to_MNI152_lin -n NearestNeighbor
   antsApplyTransforms -d 3 --float 1 --verbose 1 -i $output_label_striatumL -o $output_label_MNI152_lin_striatumL -r $input_template -t $output_warp_to_MNI152_lin -n NearestNeighbor
   antsApplyTransforms -d 3 --float 1 --verbose 1 -i $output_label_striatumR -o $output_label_MNI152_lin_striatumR -r $input_template -t $output_warp_to_MNI152_lin -n NearestNeighbor
   antsApplyTransforms -d 3 --float 1 --verbose 1 -i $output_label_pallidumL -o $output_label_MNI152_lin_pallidumL -r $input_template -t $output_warp_to_MNI152_lin -n NearestNeighbor
   antsApplyTransforms -d 3 --float 1 --verbose 1 -i $output_label_pallidumR -o $output_label_MNI152_lin_pallidumR -r $input_template -t $output_warp_to_MNI152_lin -n NearestNeighbor

done < "$in_csv"

