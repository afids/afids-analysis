
# initialize libraries
library(plyr)
library(digest)
library(reshape2)
library(ggplot2)
library("plot3D")

# useful functions

# calculate the distance between two sets of coordinates
dist3D <- function(coord1, coord2) { # vector X,Y,Z
        xdist <- coord1[1] - coord2[1] # could also write as coord1$X, etc.
        ydist <- coord1[2] - coord2[2]
        zdist <- coord1[3] - coord2[3]
        return(as.numeric(sqrt(xdist^2+ydist^2+zdist^2)))
}

# calculate the pairwise distance between an array of 3D coordinates
pairwise_dist3D <- function(temp_coords) { # labeled X,Y,Z
        N <- length(temp_coords$X)
        dist_vec <- rep(0,N) # create vector
        # TODO: some error checking
        sum_dist <- 0 # initialize to zero
        count <- 0
        for (i in 1:(N-1)) {
                for (j in (i+1):N) {
                        if (i != j) {
                                count <- count + 1
                                first_coord <- temp_coords[i,]
                                second_coord <- temp_coords[j,]
                                curr_dist <- dist3D(first_coord, second_coord)
                                sum_dist <- sum_dist + curr_dist
                                dist_vec[count] <- curr_dist
                        }
                }
        }
        return(c(as.numeric(mean(dist_vec)),as.numeric(sd(dist_vec))))
}

# initialize variables and load in raw fcsv data into df_raters
setwd('~/GitHub/afids-analysis/data/PHASE1_input_afid/')

df_afids <- read.table('~/GitHub/afids-analysis/etc/afids.csv', sep=",", header=TRUE)

df_raters <- data.frame(fid=integer(),X=double(),Y=double(),Z=double(),rater=factor(),
                        template=factor(),mri_type=factor(),session=integer(),date=integer(),
                        name=character(),description=character(),stringsAsFactors = FALSE)
csv_files <- list.files(".", "*.fcsv")

for (i in 1:length(csv_files)) {
    curr_split <- unlist(strsplit(csv_files[i],"_"))
    if (length(curr_split)>1) { # extract name and session data
        rater_template <- curr_split[1]
        rater_mri_type <- curr_split[2]
        rater_name <- curr_split[3]
        rater_session <- as.numeric(curr_split[4])
        rater_date <- as.numeric(unlist(strsplit(curr_split[5],"[.]"))[1])
    }
    curr_rater <- read.table(csv_files[i], header=FALSE, sep=",")
    df_rater <- data.frame(fid = 1:length(curr_rater$V1))

    df_rater <- cbind(df_rater,X=curr_rater[2],Y=curr_rater[3],Z=curr_rater[4],rater=rater_name,
                    template=rater_template,mri_type=rater_mri_type,
                    session=rater_session,date=rater_date,name=curr_rater[12],
                    description=curr_rater[13])
  
    df_rater <- rename(df_rater, c("V2"="X","V3"="Y","V4"="Z","V12"="name","V13"="description"))
    df_raters <- rbind(df_raters,df_rater)
}

levels(df_raters$rater) <- 1:8

# TODO: save df_raters as a file

# start by calculating mean coordinates
df_template_mean <- data.frame(fid=integer(),X=double(),Y=double(),Z=double(),
                        template=factor(), name=factor(),description=character(),stringsAsFactors = FALSE)
df_template_sd <- data.frame(fid=integer(),X=double(),Y=double(),Z=double(),
                        template=factor(), name=factor(),description=character(),stringsAsFactors = FALSE)

# iterate over each template and compute the mean and standard deviation
for (curr_template in levels(df_raters$template)) {
    for (i in 1:32) { # for each AFID32 point, calculate the mean
        df_subset <- subset(df_raters, fid == i & template == curr_template)
        curr_fid_name <- df_afids$name[i]
        curr_fid_desc <- df_afids$description[i]
        df_curr_fid <- data.frame(fid = i, X = mean(df_subset$X), Y = mean(df_subset$Y), Z = mean(df_subset$Z),
                        template=curr_template, name=curr_fid_name, description=curr_fid_desc)
        df_template_mean <- rbind(df_template_mean, df_curr_fid)
        df_curr_fid_sd <- data.frame(fid = i, X = sd(df_subset$X), Y = sd(df_subset$Y), Z = sd(df_subset$Z),
                        template=curr_template, name=curr_fid_name, description=curr_fid_desc)
        df_template_sd <- rbind(df_template_sd, df_curr_fid_sd)
    }
}

##########################################################################################
# Agile12v2016
##########################################################################################
df_Agile12v1_mean <- subset(df_template_mean, template == 'Agile12v2016')
df_Agile12v1_fcsv <- data.frame(id=paste('vtkMRMLMarkupsFiducialNode',df_Agile12v1_mean$fid,sep="_"),x=df_Agile12v1_mean$X,y=df_Agile12v1_mean$Y,z=df_Agile12v1_mean$Z,
                               ow=0,ox=0,oy=0,oz=1,
                               vis=1,sel=1,lock=0,label=df_Agile12v1_mean$fid,desc=df_Agile12v1_mean$description,
                               associatedNodeID='vtkMRMLScalarVolumeNode1',stringsAsFactors = FALSE)

# write out table (need to use file connection approach because of multiple header lines required by Slicer)
fio <- file('~/GitHub/afids-analysis/data/PHASE1_output_afid/Agile12v2016_MEAN.fcsv', open="wt") # TODO: link to output directory
  writeLines(paste('# Markups fiducial file version = 4.6'),fio)
  writeLines(paste('# CoordinateSystem = 0'),fio)
  writeLines(paste('# columns = id,x,y,z,ow,ox,oy,oz,vis,sel,lock,label,desc,associatedNodeID'),fio)
  write.table(df_Agile12v1_fcsv,fio,sep=',',quote=FALSE,col.names=FALSE,row.names=FALSE)
close(fio)

##########################################################################################
# Colin27
##########################################################################################
df_Colin27_mean <- subset(df_template_mean, template == 'Colin27')
df_Colin27_fcsv <- data.frame(id=paste('vtkMRMLMarkupsFiducialNode',df_Colin27_mean$fid,sep="_"),x=df_Colin27_mean$X,y=df_Colin27_mean$Y,z=df_Colin27_mean$Z,
                               ow=0,ox=0,oy=0,oz=1,
                               vis=1,sel=1,lock=0,label=df_Colin27_mean$fid,desc=df_Colin27_mean$description,
                               associatedNodeID='vtkMRMLScalarVolumeNode1',stringsAsFactors = FALSE)

# write out table (need to use file connection approach because of multiple header lines required by Slicer)
fio <- file('~/GitHub/afids-analysis/data/PHASE1_output_afid/Colin27_MEAN.fcsv', open="wt") # TODO: link to output directory
  writeLines(paste('# Markups fiducial file version = 4.6'),fio)
  writeLines(paste('# CoordinateSystem = 0'),fio)
  writeLines(paste('# columns = id,x,y,z,ow,ox,oy,oz,vis,sel,lock,label,desc,associatedNodeID'),fio)
  write.table(df_Colin27_fcsv,fio,sep=',',quote=FALSE,col.names=FALSE,row.names=FALSE)
close(fio)

##########################################################################################
# MNI152NLin2009bAsym
##########################################################################################
df_MNI2009b_mean <- subset(df_template_mean, template == 'MNI152NLin2009bAsym')
df_MNI2009b_fcsv <- data.frame(id=paste('vtkMRMLMarkupsFiducialNode',df_MNI2009b_mean$fid,sep="_"),x=df_MNI2009b_mean$X,y=df_MNI2009b_mean$Y,z=df_MNI2009b_mean$Z,
                               ow=0,ox=0,oy=0,oz=1,
                               vis=1,sel=1,lock=0,label=df_MNI2009b_mean$fid,desc=df_MNI2009b_mean$description,
                               associatedNodeID='vtkMRMLScalarVolumeNode1',stringsAsFactors = FALSE)

# write out table (need to use file connection approach because of multiple header lines required by Slicer)
fio <- file('~/GitHub/afids-analysis/data/PHASE1_output_afid/MNI152NLin2009bAsym_MEAN.fcsv', open="wt") # TODO: link to output directory
  writeLines(paste('# Markups fiducial file version = 4.6'),fio)
  writeLines(paste('# CoordinateSystem = 0'),fio)
  writeLines(paste('# columns = id,x,y,z,ow,ox,oy,oz,vis,sel,lock,label,desc,associatedNodeID'),fio)
  write.table(df_MNI2009b_fcsv,fio,sep=',',quote=FALSE,col.names=FALSE,row.names=FALSE)
close(fio)

df_raters$mean_AFLE <- NA # mean AFID localization error
df_raters$outlier <- NA
df_raters$xdist <- NA
df_raters$ydist <- NA
df_raters$zdist <- NA

for (i in 1:dim(df_raters)[1]) {
    curr_rater <- df_raters[i,]
        
    mean_raters <- df_MNI2009b_mean[curr_rater$fid,] # just so it's set to something for now
    
    #determine current template in order to assign the appropriate mean rater
    if (curr_rater$template == 'MNI152NLin2009bAsym') {
        mean_raters <- df_MNI2009b_mean[curr_rater$fid,]
    } else if (curr_rater$template == 'Agile12v2016') {
        mean_raters <- df_Agile12v1_mean[curr_rater$fid,]
    } else if (curr_rater$template == 'Colin27') {
        mean_raters <- df_Colin27_mean[curr_rater$fid,]
    } else {
        # unidentified template, e.g. MNI2009b
    }
    df_raters[i,]$xdist <- curr_rater$X - mean_raters$X
    df_raters[i,]$ydist <- curr_rater$Y - mean_raters$Y
    df_raters[i,]$zdist <- curr_rater$Z - mean_raters$Z
    curr_coords <- curr_rater[,2:4]
    mean_coords <- mean_raters[,2:4]
    df_raters[i,]$mean_AFLE <- dist3D(curr_coords, mean_coords)
    df_raters[i,]$outlier <- (df_raters[i,]$mean_AFLE > 10) # outliers > 10mm
}

# summary of findings

# Total: 1.27 +/- 1.98 mm; Outliers: 24/3072 (0.78%)
all_templates <- subset(df_raters, session > 0) # ignore session 0 which was from the group tutorial
num_outliers <- sum(subset(all_templates, outlier == TRUE)$outlier)
num_total <- length(all_templates$outlier)
sprintf( "Total: %.2f +/- %.2f mm; Outliers: %d/%d (%.2f%%)",
        mean(all_templates$mean_AFLE), sd(all_templates$mean_AFLE),
        num_outliers, num_total, (num_outliers/num_total)*100 )

# Agile12v1.0: 1.10 +/- 1.59 mm; Outliers: 3/1024 (0.29%)
curr_template <- subset(df_raters, session > 0 & template == 'Agile12v2016') # UHF == Agile12v1.0
num_outliers <- sum(subset(curr_template, outlier == TRUE)$outlier)
num_total <- length(curr_template$outlier)
sprintf( "Agile12v2016: %.2f +/- %.2f mm; Outliers: %d/%d (%.2f%%)",
        mean(curr_template$mean_AFLE), sd(curr_template$mean_AFLE),
        num_outliers, num_total, (num_outliers/num_total)*100 )

# Colin27: 1.71 +/- 2.78 mm; Outliers: 20/1024 (1.95%)
curr_template <- subset(df_raters, session > 0 & template == 'Colin27')
num_outliers <- sum(subset(curr_template, outlier == TRUE)$outlier)
num_total <- length(curr_template$outlier)
sprintf( "Colin27: %.2f +/- %.2f mm; Outliers: %d/%d (%.2f%%)",
        mean(curr_template$mean_AFLE), sd(curr_template$mean_AFLE),
        num_outliers, num_total, (num_outliers/num_total)*100 )

# MNI2009b: 0.99 +/- 1.11 mm; Outliers: 1/1024 (0.10%)
curr_template <- subset(df_raters, session > 0 & template == 'MNI152NLin2009bAsym')
num_outliers <- sum(subset(curr_template, outlier == TRUE)$outlier)
num_total <- length(curr_template$outlier)
sprintf( "MNI152NLin2009bAsym: %.2f +/- %.2f mm; Outliers: %d/%d (%.2f%%)",
        mean(curr_template$mean_AFLE), sd(curr_template$mean_AFLE),
        num_outliers, num_total, (num_outliers/num_total)*100 )

# summarize results for each fid and template

summary_all_df <- ddply(df_raters, .(fid), summarize, mean_total=mean(mean_AFLE), sd_total=sd(mean_AFLE), sum_outliers_total=sum(outlier))

summary_temp_df <- ddply(df_raters, .(fid,template), summarize, mean=mean(mean_AFLE), sd=sd(mean_AFLE), sum_outliers=sum(outlier))

# Agile12v2016
summary_all_df$mean_UHF <- subset(summary_temp_df, template == "Agile12v2016")$mean
summary_all_df$sd_UHF <- subset(summary_temp_df, template == "Agile12v2016")$sd
summary_all_df$sum_outliers_UHF <- subset(summary_temp_df, template == "Agile12v2016")$sum_outliers
# Colin27
summary_all_df$mean_Colin27 <- subset(summary_temp_df, template == "Colin27")$mean
summary_all_df$sd_Colin27 <- subset(summary_temp_df, template == "Colin27")$sd
summary_all_df$sum_outliers_Colin27 <- subset(summary_temp_df, template == "Colin27")$sum_outliers
# MNI152NLin2009bAsym
summary_all_df$mean_MNI2009b <- subset(summary_temp_df, template == "MNI152NLin2009bAsym")$mean
summary_all_df$sd_MNI2009b <- subset(summary_temp_df, template == "MNI152NLin2009bAsym")$sd
summary_all_df$sum_outliers_MNI2009b <- subset(summary_temp_df, template == "MNI152NLin2009bAsym")$sum_outliers

summary_all_df

# TODO: reformat and round off numbers for manuscript
write.table(summary_all_df, file = "~/GitHub/afids-analysis/tables/PHASE1_template_validation_afid_AFLE.csv", row.names = FALSE, quote = FALSE, sep = ",")

# now QC all the output
df_raters_QC <- subset(df_raters, outlier == FALSE)

# start by calculating mean coordinates
df_template_mean <- data.frame(fid=integer(),X=double(),Y=double(),Z=double(),
                        template=factor(), name=factor(),description=character(),stringsAsFactors = FALSE)
df_template_sd <- data.frame(fid=integer(),X=double(),Y=double(),Z=double(),
                        template=factor(), name=factor(),description=character(),stringsAsFactors = FALSE)

# iterate over each template and compute the mean and standard deviation
for (curr_template in levels(df_raters_QC$template)) {
    for (i in 1:32) { # for each AFID32 point, calculate the mean
        df_subset <- subset(df_raters_QC, fid == i & template == curr_template)
        curr_fid_name <- df_afids$name[i]
        curr_fid_desc <- df_afids$description[i]
        df_curr_fid <- data.frame(fid = i, X = mean(df_subset$X), Y = mean(df_subset$Y), Z = mean(df_subset$Z),
                        template=curr_template, name=curr_fid_name, description=curr_fid_desc)
        df_template_mean <- rbind(df_template_mean, df_curr_fid)
        df_curr_fid_sd <- data.frame(fid = i, X = sd(df_subset$X), Y = sd(df_subset$Y), Z = sd(df_subset$Z),
                        template=curr_template, name=curr_fid_name, description=curr_fid_desc)
        df_template_sd <- rbind(df_template_sd, df_curr_fid_sd)
    }
}

##########################################################################################
# Agile12v2016
##########################################################################################
df_Agile12v1_mean <- subset(df_template_mean, template == 'Agile12v2016')
df_Agile12v1_fcsv <- data.frame(id=paste('vtkMRMLMarkupsFiducialNode',df_Agile12v1_mean$fid,sep="_"),x=df_Agile12v1_mean$X,y=df_Agile12v1_mean$Y,z=df_Agile12v1_mean$Z,
                               ow=0,ox=0,oy=0,oz=1,
                               vis=1,sel=1,lock=0,label=df_Agile12v1_mean$fid,desc=df_Agile12v1_mean$description,
                               associatedNodeID='vtkMRMLScalarVolumeNode1',stringsAsFactors = FALSE)

# write out table (need to use file connection approach because of multiple header lines required by Slicer)
fio <- file('~/GitHub/afids-analysis/data/PHASE1_output_afid_postQC/Agile12v2016_MEAN_postQC.fcsv', open="wt")
  writeLines(paste('# Markups fiducial file version = 4.6'),fio)
  writeLines(paste('# CoordinateSystem = 0'),fio)
  writeLines(paste('# columns = id,x,y,z,ow,ox,oy,oz,vis,sel,lock,label,desc,associatedNodeID'),fio)
  write.table(df_Agile12v1_fcsv,fio,sep=',',quote=FALSE,col.names=FALSE,row.names=FALSE)
close(fio)

##########################################################################################
# Colin27
##########################################################################################
df_Colin27_mean <- subset(df_template_mean, template == 'Colin27')
df_Colin27_fcsv <- data.frame(id=paste('vtkMRMLMarkupsFiducialNode',df_Colin27_mean$fid,sep="_"),x=df_Colin27_mean$X,y=df_Colin27_mean$Y,z=df_Colin27_mean$Z,
                               ow=0,ox=0,oy=0,oz=1,
                               vis=1,sel=1,lock=0,label=df_Colin27_mean$fid,desc=df_Colin27_mean$description,
                               associatedNodeID='vtkMRMLScalarVolumeNode1',stringsAsFactors = FALSE)

# write out table (need to use file connection approach because of multiple header lines required by Slicer)
fio <- file('~/GitHub/afids-analysis/data/PHASE1_output_afid_postQC/Colin27_MEAN_postQC.fcsv', open="wt") # TODO: link to output directory
  writeLines(paste('# Markups fiducial file version = 4.6'),fio)
  writeLines(paste('# CoordinateSystem = 0'),fio)
  writeLines(paste('# columns = id,x,y,z,ow,ox,oy,oz,vis,sel,lock,label,desc,associatedNodeID'),fio)
  write.table(df_Colin27_fcsv,fio,sep=',',quote=FALSE,col.names=FALSE,row.names=FALSE)
close(fio)

##########################################################################################
# MNI2009b
##########################################################################################
df_MNI2009b_mean <- subset(df_template_mean, template == 'MNI152NLin2009bAsym')
df_MNI2009b_fcsv <- data.frame(id=paste('vtkMRMLMarkupsFiducialNode',df_MNI2009b_mean$fid,sep="_"),x=df_MNI2009b_mean$X,y=df_MNI2009b_mean$Y,z=df_MNI2009b_mean$Z,
                               ow=0,ox=0,oy=0,oz=1,
                               vis=1,sel=1,lock=0,label=df_MNI2009b_mean$fid,desc=df_MNI2009b_mean$description,
                               associatedNodeID='vtkMRMLScalarVolumeNode1',stringsAsFactors = FALSE)

# write out table (need to use file connection approach because of multiple header lines required by Slicer)
fio <- file('~/GitHub/afids-analysis/data/PHASE1_output_afid_postQC/MNI152NLin2009bAsym_MEAN_postQC.fcsv', open="wt") # TODO: link to output directory
  writeLines(paste('# Markups fiducial file version = 4.6'),fio)
  writeLines(paste('# CoordinateSystem = 0'),fio)
  writeLines(paste('# columns = id,x,y,z,ow,ox,oy,oz,vis,sel,lock,label,desc,associatedNodeID'),fio)
  write.table(df_MNI2009b_fcsv,fio,sep=',',quote=FALSE,col.names=FALSE,row.names=FALSE)
close(fio)

df_raters_QC$mean_AFLE <- NA # mean AFID localization error
df_raters_QC$outlier <- NA
df_raters_QC$xdist <- NA
df_raters_QC$ydist <- NA
df_raters_QC$zdist <- NA

for (i in 1:dim(df_raters_QC)[1]) {
    curr_rater <- df_raters_QC[i,]
        
    mean_raters <- df_MNI2009b_mean[curr_rater$fid,] # just so it's set to something for now
    
    #determine current template in order to assign the appropriate mean rater
    if (curr_rater$template == 'MNI152NLin2009bAsym') {
        mean_raters <- df_MNI2009b_mean[curr_rater$fid,]
    } else if (curr_rater$template == 'Agile12v2016') {
        mean_raters <- df_Agile12v1_mean[curr_rater$fid,]
    } else if (curr_rater$template == 'Colin27') {
        mean_raters <- df_Colin27_mean[curr_rater$fid,]
    } else {
        # unidentified template, e.g. MNI2009b
    }
    df_raters_QC[i,]$xdist <- curr_rater$X - mean_raters$X
    df_raters_QC[i,]$ydist <- curr_rater$Y - mean_raters$Y
    df_raters_QC[i,]$zdist <- curr_rater$Z - mean_raters$Z
    curr_coords <- curr_rater[,2:4]
    mean_coords <- mean_raters[,2:4]
    df_raters_QC[i,]$mean_AFLE <- dist3D(curr_coords, mean_coords)
    df_raters_QC[i,]$outlier <- (df_raters_QC[i,]$mean_AFLE > 10) # outliers > 10mm
}

# summary of findings

all_templates <- subset(df_raters_QC, session > 0) # ignore session 0 which was from the group tutorial
num_outliers <- sum(subset(all_templates, outlier == TRUE)$outlier)
num_total <- length(all_templates$outlier)
sprintf( "Total: %.2f +/- %.2f mm; Outliers: %d/%d (%.2f%%)",
        mean(all_templates$mean_AFLE), sd(all_templates$mean_AFLE),
        num_outliers, num_total, (num_outliers/num_total)*100 )

curr_template <- subset(df_raters_QC, session > 0 & template == 'Agile12v2016')
num_outliers <- sum(subset(curr_template, outlier == TRUE)$outlier)
num_total <- length(curr_template$outlier)
sprintf( "Agile12v2016: %.2f +/- %.2f mm; Outliers: %d/%d (%.2f%%)",
        mean(curr_template$mean_AFLE), sd(curr_template$mean_AFLE),
        num_outliers, num_total, (num_outliers/num_total)*100 )

curr_template <- subset(df_raters_QC, session > 0 & template == 'Colin27')
num_outliers <- sum(subset(curr_template, outlier == TRUE)$outlier)
num_total <- length(curr_template$outlier)
sprintf( "Colin27: %.2f +/- %.2f mm; Outliers: %d/%d (%.2f%%)",
        mean(curr_template$mean_AFLE), sd(curr_template$mean_AFLE),
        num_outliers, num_total, (num_outliers/num_total)*100 )

curr_template <- subset(df_raters_QC, session > 0 & template == 'MNI152NLin2009bAsym')
num_outliers <- sum(subset(curr_template, outlier == TRUE)$outlier)
num_total <- length(curr_template$outlier)
sprintf( "MNI152NLin2009bAsym: %.2f +/- %.2f mm; Outliers: %d/%d (%.2f%%)",
        mean(curr_template$mean_AFLE), sd(curr_template$mean_AFLE),
        num_outliers, num_total, (num_outliers/num_total)*100 )

# summarize results for each fid and template

summary_all_df <- ddply(df_raters_QC, .(fid), summarize, mean_total=mean(mean_AFLE), sd_total=sd(mean_AFLE), sum_outliers_total=sum(outlier))

summary_temp_df <- ddply(df_raters_QC, .(fid,template), summarize, mean=mean(mean_AFLE), sd=sd(mean_AFLE), sum_outliers=sum(outlier))
# Colin27
summary_all_df$mean_Colin27 <- subset(summary_temp_df, template == "Colin27")$mean
summary_all_df$sd_Colin27 <- subset(summary_temp_df, template == "Colin27")$sd
summary_all_df$sum_outliers_Colin27 <- subset(summary_temp_df, template == "Colin27")$sum_outliers
# MNI2009b
summary_all_df$mean_MNI2009b <- subset(summary_temp_df, template == "MNI152NLin2009bAsym")$mean
summary_all_df$sd_MNI2009b <- subset(summary_temp_df, template == "MNI152NLin2009bAsym")$sd
summary_all_df$sum_outliers_MNI2009b <- subset(summary_temp_df, template == "MNI152NLin2009bAsym")$sum_outliers
# UHF
summary_all_df$mean_UHF <- subset(summary_temp_df, template == "Agile12v2016")$mean
summary_all_df$sd_UHF <- subset(summary_temp_df, template == "Agile12v2016")$sd
summary_all_df$sum_outliers_UHF <- subset(summary_temp_df, template == "Agile12v2016")$sum_outliers

summary_all_df

# TODO: export table

df_rater_info <- read.table('~/GitHub/afids-analysis/etc/raters.csv', sep=",", header=TRUE)
df_rater_info

sprintf( "Imaging Experience: %.1f +/- %.1f months (Range: %.1f-%.1f)",
        mean(df_rater_info$imaging_exp), sd(df_rater_info$imaging_exp),
        range(df_rater_info$imaging_exp)[1], range(df_rater_info$imaging_exp)[2])
sprintf( "Neuroanatomy Experience: %.1f +/- %.1f months (Range: %.1f-%.1f)",
        mean(df_rater_info$neuro_exp), sd(df_rater_info$neuro_exp),
        range(df_rater_info$neuro_exp)[1], range(df_rater_info$neuro_exp)[2])
sprintf( "3D Slicer Experience: %.1f +/- %.1f months (Range: %.1f-%.1f)",
        mean(df_rater_info$slicer_exp), sd(df_rater_info$slicer_exp),
        range(df_rater_info$slicer_exp)[1], range(df_rater_info$slicer_exp)[2])

# subset for learning calculations (linear regression)
df_learning <- subset(df_raters_QC, session > 0)
l <- lm(mean_AFLE ~ session, data = df_learning)
s <- summary(l) # for session, the estimate was negative: -0.024 and non-significant: 0.1141
round(cbind(l$coeff,s$coefficients[,4]),4) # first column is the effect, second column is the pval

# no difference with mixed-effects modeling approach
#library(lme4)
#learning.lmer <- lmer(mean_AFLE ~ session + (1|rater), data = df_learning)
#summary(learning.lmer)
# no significant difference

# Did specific raters demonstrate any learning?
# create dataframe for linear model for each rater and p-values
models = dlply(df_learning, .(rater), lm, formula = mean_AFLE ~ session)
# also extract p-values for intercept and session
qual <- laply(models, function(mod) summary(mod)$coefficients[,4])
              
coefs = ldply(models, coef)
summary_learning_raters <- cbind(coefs,qual)
summary_learning_raters <- summary_learning_raters[,c(1,2,4,3,5)]
names(summary_learning_raters)[c(3,5)] <- c('pval_(Intercept)','pval_session')
              
# FDR correction
summary_learning_raters$pval_session_adjusted <- p.adjust(summary_learning_raters$pval_session, "fdr")
summary_learning_raters$pval_session_significant <- (summary_learning_raters$pval_session_adjusted < 0.05)
              
# Display the table
# TODO: also export the table
summary_learning_raters

# Did raters improve placing specific AFIDs?
# create dataframe for linear model for each rater and p-values
models = dlply(df_learning, .(fid), lm, formula = mean_AFLE ~ session)
# also extract p-values for intercept and session
qual <- laply(models, function(mod) summary(mod)$coefficients[,4])

coefs = ldply(models, coef)
summary_learning_afids <- cbind(coefs,qual)
summary_learning_afids <- summary_learning_afids[,c(1,2,4,3,5)]
names(summary_learning_afids)[c(3,5)] <- c('pval_(Intercept)','pval_session')
              
# FDR correction
summary_learning_afids$pval_session_adjusted <- p.adjust(summary_learning_afids$pval_session, "fdr")
summary_learning_afids$pval_session_significant <- (summary_learning_afids$pval_session_adjusted < 0.05)
              
# Display the table
# TODO: also export the table
summary_learning_afids

# intra-rater AFLE
#   defined here as mean pairwise distance between AFIDs placed by the same rater
df_intrarater <- data.frame(fid=integer(),
                 rater=factor(),
                 template=factor(),
                 intrarater_mean=double(),
                 intrarater_sd=double(),
                 stringsAsFactors=FALSE)

for (curr_template in levels(df_raters_QC$template)) {
        for (curr_rater in levels(df_raters_QC$rater)) {
                for (curr_fid in 1:32) {
                        curr_coords <- subset(df_raters_QC, rater == curr_rater & fid == curr_fid & template == curr_template & session > 0 & outlier == FALSE)
                        if (length(curr_coords$fid) > 0) {
                                curr_output <- pairwise_dist3D(curr_coords[,2:4])
                                curr_df <- data.frame(fid = curr_fid, rater = curr_rater, template = curr_template, intrarater_mean = curr_output[1], intrarater_sd = curr_output[2])
                                df_intrarater <- rbind(df_intrarater, curr_df)
                        }
                }
        }
}

# exploration of intra-rater AFLE data

# summary of findings
df_intrarater_summary <- ddply(df_intrarater, .(template), summarize, mean=mean(intrarater_mean), sd=sd(intrarater_mean))
df_intrarater_Colin27 <- ddply(subset(df_intrarater, template == "Colin27"), .(fid), summarize, mean_Colin27=mean(intrarater_mean), sd_Colin27=sd(intrarater_mean))
df_intrarater_ICBM2009b <- ddply(subset(df_intrarater, template == "MNI152NLin2009bAsym"), .(fid), summarize, mean_ICBM2009b=mean(intrarater_mean), sd_ICBM2009b=sd(intrarater_mean))
df_intrarater_Agile12v1 <- ddply(subset(df_intrarater, template == "Agile12v2016"), .(fid), summarize, mean_Agile12v1=mean(intrarater_mean), sd_Agile12v1=sd(intrarater_mean))
df_intrarater_total <- ddply(df_intrarater, .(fid), summarize, mean_total=mean(intrarater_mean), sd_total=sd(intrarater_mean))

df_intrarater_summary_all <- merge(df_intrarater_Agile12v1, df_intrarater_Colin27)
df_intrarater_summary_all <- merge(df_intrarater_summary_all, df_intrarater_ICBM2009b)
df_intrarater_summary_all <- merge(df_intrarater_summary_all, df_intrarater_total)

df_intrarater_summary
round(df_intrarater_summary_all,2)

sprintf( "Intra-Rater AFLE: %.1f +/- %.1f mm",
        mean(df_intrarater$intrarater_mean), sd(df_intrarater$intrarater_mean))

# inter-rater AFLE
#   defined here as the mean pairwise distance between mean intra-rater AFID coordinates
df_meanrater <- ddply(subset(df_raters_QC, session > 0), .(template,rater,fid), summarize, X=mean(X), Y=mean(Y), Z=mean(Z))

df_interrater <- data.frame(fid=integer(),
                            template=factor(),
                            interrater_mean=double(),
                            interrater_sd=double(),
                            stringsAsFactors=FALSE)

for (curr_template in levels(df_raters_QC$template)) {
        for (curr_fid in 1:32) {
                curr_coords <- subset(df_meanrater, fid == curr_fid & template == curr_template)
                if (length(curr_coords$fid) > 0) {
                        curr_output <- pairwise_dist3D(curr_coords[,4:6]) # careful here as index can shift.
                        curr_df <- data.frame(fid = curr_fid, template = curr_template, interrater_mean = curr_output[1], interrater_sd = curr_output[2])
                        df_interrater <- rbind(df_interrater, curr_df)
                        
                }
        }
}

# exploration of inter-rater AFLE data
# summary of findings
df_interrater_summary <- ddply(df_interrater, .(template), summarize, mean=mean(interrater_mean), sd=sd(interrater_mean))

df_interrater_Colin27 <- subset(df_interrater, template == "Colin27")
names(df_interrater_Colin27)[3:4] <- c("mean_Colin27","sd_Colin27")
df_interrater_Colin27 <- df_interrater_Colin27[,c(1,3,4)]

df_interrater_ICBM2009b <- subset(df_interrater, template == "MNI152NLin2009bAsym")
names(df_interrater_ICBM2009b)[3:4] <- c("mean_MNI152NLin2009bAsym","sd_MNI152NLin2009bAsym")
df_interrater_ICBM2009b <- df_interrater_ICBM2009b[,c(1,3,4)]

df_interrater_Agile12v1 <- subset(df_interrater, template == "Agile12v2016")
names(df_interrater_Agile12v1)[3:4] <- c("mean_Agile12v2016","sd_Agile12v2016")
df_interrater_Agile12v1 <- df_interrater_Agile12v1[,c(1,3,4)]

df_interrater_total <- ddply(df_interrater, .(fid), summarize, mean_total=mean(interrater_mean), sd_total=sd(interrater_mean))

df_interrater_summary_all <- merge(df_interrater_Agile12v1, df_interrater_Colin27)
df_interrater_summary_all <- merge(df_interrater_summary_all, df_interrater_ICBM2009b)
df_interrater_summary_all <- merge(df_interrater_summary_all, df_interrater_total)

df_interrater_summary
round(df_interrater_summary_all,2)

sprintf( "Inter-Rater AFLE: %.1f +/- %.1f mm",
        mean(df_interrater$interrater_mean), sd(df_interrater$interrater_mean))

# ANOVA for templates
res.aov <- aov(mean_AFLE ~ template, data = df_raters_QC)
summary(res.aov)[[1]][[1,"F value"]]
summary(res.aov)[[1]][[1,"Pr(>F)"]]

# analysis of variance across templates and fids
summary_anova_templates <- ddply(df_raters_QC, "fid", summarise,
      Fval = summary(aov(mean_AFLE ~ template))[[1]][[1,"F value"]],
      pval = summary(aov(mean_AFLE ~ template))[[1]][[1,"Pr(>F)"]]
      )
summary_anova_templates$adjusted <- p.adjust(summary_anova_templates$pval, "fdr")
summary_anova_templates$significant <- (summary_anova_templates$adjusted < 0.05)

# display
# TODO: also export the table
summary_anova_templates

# PCA + K-means clustering
# set the variables up
fid_pca <- ddply(df_raters_QC, "fid", summarise,
                           eval1 = summary(prcomp(cbind(xdist,ydist,zdist), center=TRUE, scale. = TRUE))$importance[2,1],
                           eval2 = summary(prcomp(cbind(xdist,ydist,zdist), center=TRUE, scale. = TRUE))$importance[2,2],
                           eval3 = summary(prcomp(cbind(xdist,ydist,zdist), center=TRUE, scale. = TRUE))$importance[2,3],
                           evec1x = summary(prcomp(cbind(xdist,ydist,zdist), center=TRUE, scale. = TRUE))$rotation[1,1],
                           evec1y = summary(prcomp(cbind(xdist,ydist,zdist), center=TRUE, scale. = TRUE))$rotation[2,1],
                           evec1z = summary(prcomp(cbind(xdist,ydist,zdist), center=TRUE, scale. = TRUE))$rotation[3,1],
                           evec2x = summary(prcomp(cbind(xdist,ydist,zdist), center=TRUE, scale. = TRUE))$rotation[1,2],
                           evec2y = summary(prcomp(cbind(xdist,ydist,zdist), center=TRUE, scale. = TRUE))$rotation[2,2],
                           evec2z = summary(prcomp(cbind(xdist,ydist,zdist), center=TRUE, scale. = TRUE))$rotation[3,2],
                           evec3x = summary(prcomp(cbind(xdist,ydist,zdist), center=TRUE, scale. = TRUE))$rotation[1,3],
                           evec3y = summary(prcomp(cbind(xdist,ydist,zdist), center=TRUE, scale. = TRUE))$rotation[2,3],
                           evec3z = summary(prcomp(cbind(xdist,ydist,zdist), center=TRUE, scale. = TRUE))$rotation[3,3]            
)

# create clusters
fid_pca$kmeans2 <- kmeans( fid_pca[,2:4], 2 )$cluster
fid_pca$kmeans3 <- kmeans( fid_pca[,2:4], 3 )$cluster
fid_pca$kmeans4 <- kmeans( fid_pca[,2:4], 4 )$cluster
fid_pca$kmeans5 <- kmeans( fid_pca[,2:4], 5 )$cluster
fid_pca$kmeans6 <- kmeans( fid_pca[,2:4], 6 )$cluster

# map cluster corresponding to kmeans clustering
df_raters_QC$kmeans2 <- fid_pca$kmeans2[df_raters_QC$fid]
df_raters_QC$kmeans3 <- fid_pca$kmeans3[df_raters_QC$fid]
df_raters_QC$kmeans4 <- fid_pca$kmeans4[df_raters_QC$fid]
df_raters_QC$kmeans5 <- fid_pca$kmeans5[df_raters_QC$fid]
df_raters_QC$kmeans6 <- fid_pca$kmeans6[df_raters_QC$fid]

# a template for the scatterplots
# show displacement positions for each fid
par( mfrow=c(4,8), mar = c(0.2,0.2,0.2,0.2), # margins between plots
     oma = c(2,2,2,2), # outer margines
     mgp = c(1,1,0),
     xpd = NA ) #oma = outer margins
for(i in 1:32) {
        scatter3D(x = 0, y = 0, z = 0, bty = "b2", colkey = FALSE, alpha = 0,
                  main = sprintf("%d", i), xlim = c(-2.5,2.5), ylim = c(-2.5,2.5), zlim = c(-2.5,2.5),
                  pch = 20, phi = 30, theta = 40, pch = 19, cex = 1, col = df_raters_QC$kmeans3[i]+1 )
}

# figure
# show displacement positions for each fid
# K-means clustering with k = 3; tried 2-6 but 3 appeared most optimal
par( mfrow=c(4,8), mar = c(0.2,0.2,0.2,0.2), # margins between plots
                   oma = c(2,2,2,2), # outer margines
                   mgp = c(1,1,0),
                   xpd = NA ) #oma = outer margins
for(i in 1:32) {
        df_fid <- subset(df_raters, fid == i)
        scatter3D( df_fid$xdist, df_fid$ydist, df_fid$zdist, bty = "b2", colkey = FALSE, alpha = 1,
                   main = sprintf("%d", i), xlim = c(-2.5,2.5), ylim = c(-2.5,2.5), zlim = c(-2.5,2.5),
                   pch = 20, phi = 30, theta = 40, col = df_raters_QC$kmeans3[i]+1)
}

#figure with cluster colouring

# melt / modify existing dataframe for looking at clusters
fid_pca_simple <- fid_pca[,c("fid","eval1","eval2","eval3","kmeans3")]
melted <- melt(fid_pca_simple,id.vars=c("fid","kmeans3"))
levels(melted$variable) <- 1:3 # rename/refactor variables to numeric
colnames(melted)[3] <- 'PC'

ggplot(melted, aes(x = PC, y = value, group = fid, colour = as.factor(kmeans3))) +
        geom_line() +
        geom_point() +
        scale_colour_manual("Cluster", breaks = c(1,2,3), values = c("red", "green", "blue")) +
        scale_x_discrete("Principal Component") +
        scale_y_continuous("Variance Explained") +
        theme_bw() + theme(legend.position="bottom")


# TODO: K-means for individual templates

sessionInfo()
