#!/usr/bin/env python
# coding: utf-8

# In[32]:


import numpy as np
import librosa
import pandas as pd


# In[33]:


def makeFeatrues(path):
    y, sr = librosa.load(path)
    # Eliminate silence start and end
    audio_file,_ = librosa.effects.trim(y)
    #zero_crossings_rates
    zero_crossings = librosa.zero_crossings(audio_file, pad=False)
    zero_crossings_mean = zero_crossings.mean()
    zero_crossings_var = zero_crossings.var()
    #Harmonics and perceptrual
    y_harm,y_perc = librosa.effects.hpss(audio_file)
    harm_mean = y_harm.mean()
    harm_var = y_harm.var()
    perc_mean = y_perc.mean()
    perc_var = y_perc.var()
    #spectral_bandwidth
    spectral_bandwidth = librosa.feature.spectral_bandwidth(audio_file,sr)
    spectral_bandwidth_mean = spectral_bandwidth.mean()
    spectral_bandwidth_var = spectral_bandwidth.var()
    #rms
    rms = librosa.feature.rms(audio_file)
    rms_mean = rms.mean()
    rms_var = rms.var()
    #tempo
    tempo,_=librosa.beat.beat_track(audio_file,sr=sr)
    #Spectral_centroids
    spectral_centroids = librosa.feature.spectral_centroid(audio_file,sr=sr)[0]
    spectral_centroids_mean = spectral_centroids.mean()
    spectral_centroids_var = spectral_centroids.var()
    #Spectral_rolloff
    spectral_rolloff = librosa.feature.spectral_rolloff(audio_file,sr=sr)[0]
    spectral_rolloff_mean = spectral_rolloff.mean()
    spectral_rolloff_var = spectral_rolloff.var()
    #MFCCs
    mfccs = librosa.feature.mfcc(audio_file,sr=sr)
    mfccs_mean = mfccs.mean(axis = 1)
    mfccs_var = mfccs.var(axis = 1)
    #chroma
    chroma = librosa.feature.chroma_stft(audio_file, sr=sr)
    chroma_stft_mean = chroma.mean()
    chroma_stft_var = chroma.var()
    #Make a np array
    temp = np.array([chroma_stft_mean,chroma_stft_var,                     rms_mean,rms_var,spectral_centroids_mean,                     spectral_centroids_var,spectral_bandwidth_mean,                     spectral_bandwidth_var,                     spectral_rolloff_mean,spectral_rolloff_var,                     zero_crossings_mean,zero_crossings_var,                     harm_mean,harm_var,perc_mean,perc_var,                     tempo])
    mfcc_table = np.empty([1,1])
    for i in range(len(mfccs_mean)):
        mfcc_table = np.append(mfcc_table,mfccs_mean[i])
        mfcc_table = np.append(mfcc_table,mfccs_var[i])
    mfcc_table = mfcc_table[1:]    
    temp = np.append(temp,mfcc_table).flatten().reshape(1,-1)
    newData = pd.DataFrame(temp, columns = ["chroma_stft_mean","chroma_stft_var","rms_mean",                                            "rms_var","spectral_centroid_mean","spectral_centroid_var",                                            "spectral_bandwidth_mean","spectral_bandwidth_var",                                            "rolloff_mean","rolloff_var","zero_crossing_rate_mean",                                            "zero_crossing_rate_var","harmony_mean",                                            "harmony_var","perceptr_mean","perceptr_var","tempo",                                            "mfcc1_mean","mfcc1_var","mfcc2_mean","mfcc2_var","mfcc3_mean","mfcc3_var",                                            "mfcc4_mean","mfcc4_var","mfcc5_mean","mfcc5_var","mfcc6_mean",                                            "mfcc6_var","mfcc7_mean","mfcc7_var","mfcc8_mean","mfcc8_var",                                            "mfcc9_mean","mfcc9_var","mfcc10_mean","mfcc10_var","mfcc11_mean",                                            "mfcc11_var","mfcc12_mean","mfcc12_var","mfcc13_mean","mfcc13_var",                                            "mfcc14_mean","mfcc14_var","mfcc15_mean","mfcc15_var","mfcc16_mean",                                            "mfcc16_var","mfcc17_mean","mfcc17_var","mfcc18_mean","mfcc18_var",                                            "mfcc19_mean","mfcc19_var","mfcc20_mean","mfcc20_var"])
    return newData
        


# path = "C:/Users/Michael/Documents/ALY 6110/final project/Music_genre/Data/genres_original/blues/blues.00000.wav"
# 
# y, sr = librosa.load(path)
# 
# print('y:', y, '\n')
# print('y shape:', np.shape(y), '\n')
# print('Sample Rate (KHz):', sr, '\n')

# audio_file,_ = librosa.effects.trim(y)
# print('Audio File:', audio_file, '\n')
# print('Audio File shape:', np.shape(audio_file))

# ipd.Audio(audio_file,rate = sr)

# n_fft = 2048 # FFT window size
# hop_length = 512 # number audio of frames between STFT columns (looks like a good default)
# 
# # Short-time Fourier transform (STFT)
# D = np.abs(librosa.stft(audio_file, n_fft = n_fft, hop_length = hop_length))
# 
# print('Shape of D object:', np.shape(D))

# DB = librosa.amplitude_to_db(D, ref = np.max)
# plt.figure(figsize=(16,6))
# librosa.display.specshow(DB,sr=sr,x_axis='time',y_axis='hz')
# plt.colorbar()
# plt.title('Spectrogram',fontsize=23)
# 

# S = librosa.feature.melspectrogram(audio_file, sr=sr)
# S_DB = librosa.amplitude_to_db(S, ref=np.max)
# 
# plt.figure(figsize=(16,6))
# librosa.display.specshow(data=S_DB,sr=sr,x_axis='time',y_axis='log',cmap='cool')
# plt.colorbar()
# plt.title('Mel Spectrogram',fontsize=23)

# print(S.shape)

# zero_crossings = librosa.zero_crossings(audio_file, pad=False)
# print(sum(zero_crossings))

# mfccs = librosa.feature.mfcc(audio_file,sr=sr)
# mfccs_mean = mfccs.mean(axis = 1)
# mfccs_var = mfccs.var(axis = 1)

# mfccs_mean

# mfccs_var

# mfcc_table = np.empty([1,1])
# for i in range(len(mfccs_mean)):
#     mfcc_table = np.append(mfcc_table,mfccs_mean[i])
#     mfcc_table = np.append(mfcc_table,mfccs_var[i])
# mfcc_table = mfcc_table[1:]    
# print(mfcc_table)

# df = makeFeatues(path)

# df
