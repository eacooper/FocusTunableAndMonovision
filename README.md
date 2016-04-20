# FocusTunableAndMonovision
Raw data and plotting code for user studies in:

R. Konrad, E.A. Cooper, and G. Wetzstein. Novel Optical Configurations for Virtual Reality: Evaluating User Preference and Performance with Focus-tunable and Monovision Near-eye Displays. Proceedings of the ACM Conference on Human Factors in Computing Systems (CHI), 2016

User Preference Study

Data are contained in preference_data.mat in the structure called "data"

Rows are trials, Columns are:

(1) Display mode (0 -> normal, 1 -> adaptive DOF, 2 -> adaptive focus, 3 -> adaptive focus + DOF, 4 -> monovision)
(2) Ranking (1 best, 5 worse)
(3) User ID

User Performance Studies

Data are contained in performance_data.mat in two structures, "data_clarity" and "data_depth"
Each structure has 5 fields for the 5 different display modes

Rows are trials, Columns are:

(1) Correct? (1 = yes) 
(2) response time (s)
(3) Viewing distance (D) 
(4) Target relative distance
(5) Trial number
(6) User ID

Note that in the Depth Judgment task, data from 4 trials were lost, so these matrices have 836 rathern than 840 entries
