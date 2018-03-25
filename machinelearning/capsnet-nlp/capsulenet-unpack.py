#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Mar 25 11:39:52 2018
This is a simplification where I removed most functions to understand the model.
The code is pulled from this implementation
https://github.com/streamride/CapsNet-keras-imdb
@author: matthewpotts
"""

import os
import pydot
import pydot_ng
import numpy as np
import matplotlib.pyplot as plt
from PIL import Image

from keras import layers, models, callbacks
from keras import backend as K
from keras.utils.vis_utils import plot_model
from keras.preprocessing import sequence
from keras.utils import to_categorical

# keras datasets
from keras.datasets import reuters
from keras.datasets import imdb

# capsule layers from Xifeng Guo 
# https://github.com/XifengGuo/CapsNet-Keras
from capsulelayers import CapsuleLayer, PrimaryCap, Length, Mask

#from utils import plot_log


#Define hyperparameters
max_features = 5000
maxlen = 400
embed_dim = 50
num_routing = 1

#Define parameters
n_class = 46
save_dir = './result'
batch_size = 100
debug = 2
epochs = 1
lam_recon = 0.0005

#Load train and test data
(x_train, y_train), (x_test, y_test) = reuters.load_data(num_words=max_features)
x_train = sequence.pad_sequences(x_train, maxlen=maxlen)
x_test = sequence.pad_sequences(x_test, maxlen=maxlen)
# Reshape y from all labes to a row per class
y_train = to_categorical(y_train.astype('float32'))
y_test = to_categorical(y_test.astype('float32'))


#Build embedding and convolutional layers
x = layers.Input(shape=(maxlen,))
embed = layers.Embedding(max_features, embed_dim, input_length=maxlen)(x)

conv1 = layers.Conv1D(filters=256, kernel_size=9, strides=1, padding='valid', 
                      activation='relu', name='conv1')(embed)

# Layer 2: Conv2D layer with `squash` activation, then reshape to 
# [None, num_capsule, dim_vector]
primarycaps = PrimaryCap(conv1, dim_vector=8, n_channels=32, kernel_size=9, 
                         strides=2, padding='valid')

# Layer 3: Capsule layer. Routing algorithm works here.
digitcaps = CapsuleLayer(num_capsule=n_class, dim_vector=16, 
                         num_routing=num_routing, name='digitcaps')(primarycaps)

# Layer 4: This is an auxiliary layer to replace each capsule with its length. 
# Just to match the true label's shape.
# If using tensorflow, this will not be necessary. :)
out_caps = Length(name='out_caps')(digitcaps)

# Decoder network.
y = layers.Input(shape=(n_class,))
masked = Mask()([digitcaps, y])  # The true label is used to mask the output of capsule layer.
x_recon = layers.Dense(512, activation='relu')(masked)
x_recon = layers.Dense(1024, activation='relu')(x_recon)
x_recon = layers.Dense(maxlen, activation='sigmoid')(x_recon)
# x_recon = layers.Reshape(target_shape=[1], name='out_recon')(x_recon)

capsmodel = models.Model([x, y], [out_caps, x_recon])

#Saving weights and logging
log = callbacks.CSVLogger(save_dir + '/log.csv')
tb = callbacks.TensorBoard(log_dir=save_dir + '/tensorboard-logs', 
                           batch_size=batch_size, histogram_freq=debug)
checkpoint = callbacks.ModelCheckpoint(save_dir + '/weights-{epoch:02d}.h5', 
                                       save_best_only=True, 
                                       save_weights_only=True, 
                                       verbose=1)
lr_decay = callbacks.LearningRateScheduler(schedule=lambda epoch: 0.001 * np.exp(-epoch / 10.))

#margin_loss
def margin_loss(y_true, y_pred):
    L = y_true * K.square(K.maximum(0., 0.9 - y_pred)) + 0.5 * (1 - y_true) *  K.square(K.maximum(0., y_pred - 0.1))
    return K.mean(K.sum(L, 1))

capsmodel.summary()

#Save a png of the model shapes and flow
plot_model(capsmodel, to_file=save_dir + '/reuters-model.png', show_shapes=True)

# compile the model
capsmodel.compile(optimizer='adam',
              loss=[margin_loss, 'mse'],
              loss_weights=[1., lam_recon],
              metrics={'out_caps': 'accuracy'})

# train the model
capsmodel.fit([x_train, y_train], [y_train, x_train], batch_size=batch_size, 
              epochs=epochs, validation_data=[[x_test, y_test], [y_test, x_test]], 
              callbacks=[log, tb, checkpoint], verbose=1)


#capsmodel.save_weights(save_dir + '/trained_model.h5')
#print('Trained model saved to \'%s/trained_model.h5\'' % save_dir)

#from utils import plot_log
#plot_log(save_dir + '/log.csv', show=True)







