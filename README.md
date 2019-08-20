# SchoppikLisberger2006
Code from Schoppik and Lisberger Journal of Neuroscience 2006

generatepaths.m -- will create a structure with the paths to the data for each monkey, for each experiment.

pull.m -- the main analysis code to parse trials from different types of experiments. 
Well-commented, this will take you from the individual trials for one experiment to a structure that is easy to analyze. 
Calls getlastdir.m (for directory parsing), digitaldiff.m (for differentiation) and readcxdata (mex code which will need to be compiled for your platform, for reading individual trials)

preptype*.m -- * refers to a type of experiment; takes the output of pull and runs summary-type analyses, in preparation for figure generation.

figure*.m -- code to generate each of the figures in the manuscript.
