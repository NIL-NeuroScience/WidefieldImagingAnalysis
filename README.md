# WidefieldImagingAnalysis
This code is used to acquire and process data from the wide field imaging system described in Doran et al. 2023
File Structure
This software is designed to process wide field imaging data organized in a certain structure.

Date
	Mouse
		onephoton
		basler
		accelerometer
		Triggers
		dataIn.mat
		processed
		mat
		Figures

All of the raw and processed data is stored in different directories located in root/Date/Mouse. Here are what each of those directories contain. 

onephoton: This directory contains the wide filed imaging data in .dat files saved by the Andor solis acquisition software.

basler: This directory contains videos of the mouse face. Videos are saved as individual .tif files for each frame. 

accelerometer: This directory contains analog input recorded by the daq system used to record the accelerometer. This analog input is saved as .mat files.

Triggers: This directory contains the digital input recorded by the main DAQ system controlling the imaging system. This includes triggers for the camera, each of the LEDs and the stimulus. This digital input is saved in .mat files. 

dataIn.mat: This structure is saved by the pre-processing code and contains metadata about each imaging run.

processed: This directory contains .h5 files saved by the pre-processing code for each imaging run. These .h5 files contain dF/F images for each fluorescence channel before and after hemodynamics correction and images of oxyhemoglobin and deoxyhemoglobin concentration changes. 

mat: This contains .mat files saved by various processing scripts including registration to the Allen atlas, behavioral parameters and images interpolated at different times relative to the stimulus. 

Figures: This directory is used to save figures produced during processing. 

Order of implementation
This list is the order in which the code contained in the folders of this package are typically run. If a script requires another script to be run before it can be run, this will be stated in the comments at the beginning of the script.

Acquisition
Pre_Processing
Mask
Allen_Registration
Resting_State_Plots
Detrending
Stimulus_Interprolation
Stimulus_Processing
Behavior
Accelerometer_Processing

The rest of this document describes the MATLAB scripts provided in this software package. The headings are the directories in this software package and below each heading the scripts included in that directory are described.

Acquisition
MAIN_Acquisition_Script.m is the MATLAB script that controls the wide field imaging system. It generates digital triggers for the camera and the LEDs. It records triggers as digital input from the DAQ. This code is written for use with an NI PCIe-6363 DAQ system and ThorLabs DC2200 LED drivers. It must be run with the 2022 version of MATLAB or newer because that is when the functions used to interface with the LED drivers using NI VISA were introduced. 

Accelerometer_Acquisition_Script.m is used to record analog input from a NI USB-6363. We run this on a separate computer from MAIN_Acquisition_Script.m to record the accelerometer signal. 

Airpuff_Test.m is used to only send triggers to the airpuff apparatus without running the imaging system. This is used to adjust the placement and power of the airpuff before imaging. This is also used during training to habituate the mouse to whisker stimulation. 

Pre_Processing
MAIN_Pre_Processing.m is the MATLAB script for pre-processing the data. This script reads .dat files created by the Andor solis acquisition software and creates an image matrix for each channel. For the fluorescence channels it divides each image by an average image to calculate the normalized change in fluorescnece (dF/F). It uses the two reflectance channels to calculate changes in the concentration of oxyhemoglobin and deoxyhemoglobin using a modified Beer-Lambert law. Correction of hemodynamic artifacts in the fluorescence channels due to the absorption of light by hemoglobin is implemented. The processed data is saved as .h5 files in a folder called processed. This script uses parallel processing. When running this script it is essential that the user lists any runs that did not run to completion or had other issues in commonSettings.badRuns. commonSettings.allRuns must be set to zero in order to bypass the runs listed in badRuns. 

Mask
Draw_Cranial_Window_Mask.m is used to draw a mask around the cranial window. Two masks are drawn by the user, one for each hemisphere. Then the two masks are combined and saved. 

Allen_Registration
MAIN_Allen_Registration.m is used to register wide field images to the regions of Allen Atlas. To complete initial registration, the user must click on marks that the surgeon leaves on bregma and lambda. An app allows the user to refine the registration. The code shows the user where each Allen region is located on the wide field images. After seeing the location of the regions, the user is given the option to redo the registration. 

Detrending
Detrend_Data.m is used to remove trends from fluorescence data. This code can use two types of correction: linear or exponential. Linear correction is implemented through the MATLAB function detrend. Exponential correction is implemented by fitting an exponential decay function to the data and regressing it out. Time courses should be viewed before running this data to determine which correction method is appropriate. The correction is applied to each pixel separately. This script uses parallel processing. 

Behavior
MAIN_Behavior_Analysis.m is used to calculate pupil diameter and whisking time courses from a video of the mouse face. The user must draw regions of interest around the eye, long whiskers and whisker pad. Whisking is calculated as the motion energy in the regions drawn by the user.

Resting_State_Plots
MAIN_Allen_Region_Plot.m extracts time courses of fluorescent indicators and hemoglobin species concentrations from an Allen atlas region defined by the user. This is implemented using the Allen registration saved by MAIN_Allen_Registration.m. This script creates several plots of the time courses calculated from the Allen region. 

Stimulus_Interprolation
MAIN_Interprolation_Uncorrected is used to interpolate data relative to the onset of a stimulus. Due to the near simultaneous imaging technique, each channel will have a slightly different timing relative to each stimulus presentation. This script interpolates the images (fluorescent and hemodynamic) that were created by the MAIN_Pre_Processing.m so that all data has images exactly at stimulus onset and at the same times relative to stimulus onset. The output of this script is a 4 dimensional matrix where the first two dimensions are the image dimensions, the third dimension is the time relative to stimulus onset and the fourth dimension is the stimulus presentation. A time vector with the same length as the third dimension of the data matrices is saved with the data to tell what time each image is relative to stimulus onset. This code uses parallel processing.

MAIN_Interprolation_Corrected does the same thing as MAIN_Interprolation_Uncorrected. The only difference is that MAIN_Interprolation_Corrected uses fluorescence data that has been processed by Detrend_Data.m. 

Stimulus_Processing
MAIN_Stimulus_Processing is used to visualize the data that was interpolated by the stimulus interpolation code. Baseline images are calculated for each stimulus presentation and subtracted from the data. This has the effect of defining the activity in the second before stimulus onset at “zero” and ensures that the stimulus response begins at zero. Stimulus averaged ratio images are created by averaging across stimulus presentations. Plots are saved of both individual ratio images and several ratio images over time after the stimulus presentation. Time courses are extracted from an Allen region defined by the user. Stimulus averaged time courses are plotted. Time courses of responses to individual stimuli are sorted by the magnitude of the response and plotted. This code is meant to be run in sections. 

Pupil_Processing
Pupil_LED_Effect.m is used to pupil data where the strobing LEDs of the imaging system are turned on and off several times. First, this code determine which behavior video frames occur when the LEDs are on. Then the code creates a matrix where each row is the pupil size time course around one time that the LEDs turn on. The vector tNew defines when each column of the pupil matrix occurs relative to the off-on transition that occurs at tNew = 0. The baseline is defined as the pupil size immediately before the LEDs turn on and the baseline is subtracted from each row. The time courses are averaged together to make a graph of average pupil size change when the LEDs turn on. Pupil ratio is defined as pupil size after LEDs are on divided by pupil size before LEDs are on. The distribution of pupil ratios is saved for further analysis.

Pupil_Ratio_Statistics.m is used to compare the distribution of pupil ratios between two conditions (here it is used for with the aluminum hemisphere vs without the aluminum hemisphere). A t-test is run to determine if the distribution of pupil ratios is significantly different between the two conditions. A bar graph with an error bar showing standard deviation and scattered points showing the distribution is plotted to compare the two conditions.













