# afids-analysis

Code and data for the preprint: A framework for evaluating correspondence between brain images using anatomical fiducials.

1. PHASE1: afids template validation
2. PHASE2: afids OAS1 subject validation
3. PHASE3: afids for evaluating subject-to-template registration
4. PHASE4: afids for evaluating template-to-template registration

Also afids validator available in alpha form at: http://fidvalidator.pythonanywhere.com

## PHASE1

* validation using Agile12v2016, Colin27, and MNI152NLin2009bAsym

## PHASE2

* validation using subset of OAS-1 dataset
* also processed through fMRIPrep v1.1.1:
```
bidsBatch fmriprep_1.1.1 /project/6007967/jclau/fid_study_bids/PHASE2/input_data/OAS1_bids/ /project/6007967/jclau/fid_study_bids/PHASE2/input_data/OAS1_bids/derivatives/fmriprep_1.1.1/ participant
```

## PHASE3

```
 ~/GitHub/afids-analysis/scripts/PHASE3_01_extract_labels.sh -i ~/graham/project/fid_study_bids/PHASE2/input_data/OAS1_bids_MR1/participants.tsv >& ~/GitHub/afids-analysis/logs/PHASE3_01_extract_labels.log
 ~/GitHub/afids-analysis/scripts/PHASE3_02_create_probabilistic_maps.sh -i ~/graham/project/fid_study_bids/PHASE2/input_data/OAS1_bids_MR1/participants.tsv >& ~/GitHub/afids-analysis/logs/PHASE3_02_create_probabilistic_maps.sh
 ~/GitHub/afids-analysis/scripts/PHASE3_03_calculate_voxel_overlap_lin.sh -i ~/graham/project/fid_study_bids/PHASE2/input_data/OAS1_bids_MR1/participants.tsv >& ~/GitHub/afids-analysis/logs/PHASE3_03_calculate_voxel_overlap_lin.log
 cp ~/GitHub/afids-analysis/logs/PHASE3_03_calculate_voxel_overlap_lin.log ~/GitHub/afids-analysis/data/PHASE3_output_maps/PHASE3_output_rois_lin.csv
 ~/GitHub/afids-analysis/scripts/PHASE3_03_calculate_voxel_overlap_nlin.sh -i ~/graham/project/fid_study_bids/PHASE2/input_data/OAS1_bids_MR1/participants.tsv >& ~/GitHub/afids-analysis/logs/PHASE3_03_calculate_voxel_overlap_nlin.log
 cp ~/GitHub/afids-analysis/logs/PHASE3_03_calculate_voxel_overlap_nlin.log ~/GitHub/afids-analysis/data/PHASE3_output_maps/PHASE3_output_rois_nlin.csv
 ~/GitHub/afids-analysis/scripts/PHASE3_04_transform_fcsv_nlin.sh -i ~/graham/project/fid_study_bids/PHASE2/input_data/OAS1_bids_MR1/participants.tsv >& ~/GitHub/afids-analysis/logs/PHASE3_04_transform_fcsv_nlin.sh
 ~/GitHub/afids-analysis/scripts/PHASE3_04_transform_fcsv_lin.sh -i ~/graham/project/fid_study_bids/PHASE2/input_data/OAS1_bids_MR1/participants.tsv >& ~/GitHub/afids-analysis/logs/PHASE3_04_transform_fcsv_lin.sh
```
* evaluated quality of registration of OAS-1 dataset (PHASE2) to default fMRIPrep template (MNI152NLin2009cAsym)
* MNI152NLin2009bAsym effectively the same as MNI152NLin2009cAsym (just resampled from 0.5 mm --> 1 mm)
* comparison of fiducial-based error (mm) against voxel overlap measures
* evaluation of ROI versus point-based measures of registration quality
* also compared sensitivity of ROI versus point-based measures for linear versus nonlinear alignment to the template

## PHASE4

* evaluated quality of registration between MNI152NLin2009bSym, MNI152NLin2009bASym, and BigBrainSym
* BigBrainSym is a mapping from BigBrain space to MNI152NLin2009bSym

## Other Notes

###

* Initializing Jupyter Notebook locally: `jupyter notebook`
* AFIDs validator: http://fidvalidator.pythonanywhere.com

### Conda mods

* conda install -c conda-forge r-lme4
* conda install -c conda-forge r-ggpubr
* conda install -c bioconda r-psych 

All notebooks exported to .R to ensure appropriate functionality. Also, notebooks are compiled in .pdf.
Warning: notebooks are to be run in sequential order.

### Manuscript Files

* Manuscript figures are output to `data/output_figures/`
* Manuscript tables are output to `data/output_tables/`

### Compiling to PDF

To create a pdf compiled from the ipynb file with just the output, the following command was run:
```
jupyter nbconvert phase1_validation.ipynb --to=html --TemplateExporter.exclude_input=True
```
Then the html was opened in a browser and converted to pdf.

Ideally the --to=pdf flag would work with R-based ipynb notebooks but the problem is documented here:
* https://stackoverflow.com/questions/49754862/jupyter-notebook-save-to-pdf-without-code
* https://github.com/jupyter/notebook/issues/3804

Can also create an executable script from the Python notebook with the following:
```
jupyter nbconvert phase1_validation.ipynb --to=script
```

### Location of Files

* also for now located on Graham: `~/projects/rrg-akhanf/jclau/fid_study_bids`
* clean version in `~/projects/rrg-akhanf/jclau/afids_study`

