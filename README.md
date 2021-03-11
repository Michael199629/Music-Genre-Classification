# Music-Genre-Classification
Rshiny | R | Sparklyr | Python | reticulate | Librosa | XGBoost
# Readme
The main application is a Rshiny dashboard which allow user to upload their `.wav` file and shows the spectrogram and the predicted results(belongs to which music genres with a probability). This dashboard also shows the EDA of the trainning set.

* I use python package librosa to extract the acoustic statistics.
* Using sparklyr to read the data file.
* XGBoost to build predictive model
* Reticulate to make sure I can use python in r environment.
