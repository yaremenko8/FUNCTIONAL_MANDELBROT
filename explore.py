#!/usr/bin/python3
import matplotlib.pyplot as plt
import matplotlib.image as mpimg
from matplotlib.backend_bases import NavigationToolbar2
from math import log10, floor
import numpy as np
import os

dim = 300
mag = 3

def itr(a):
    i = floor(50 * ((log10(dim / a))**1.25))
    print(i)
    return i



class MRenderer:
    def __init__(self, f):
        img=mpimg.imread('data/home.bmp')
        plt.imshow(img)
        hcoords = tuple(map(np.float128, (-2, 1.5, 3)))
        self.chain = [(hcoords, img)]
        self.curindex = 0
        plt.imshow(img)   
        self.cid = f.canvas.mpl_connect('button_press_event', self)

    def __call__(self, event):
        x = event.xdata
        y = event.ydata
        i = self.curindex
        r = self.chain[i][0][2] / dim
        mx = self.chain[i][0][0] + r * x
        my = self.chain[i][0][1] - r * y
        a  = self.chain[i][0][2] / mag
        tlx = mx - (a / 2)
        tly = my + (a / 2)
        coords = (tlx, tly, a)
        self.chain = self.chain[:i + 1]
        self.chain.append((coords, self.render(*coords, itr(a))))
        self.curindex += 1
        print(x, y)
        plt.show()
    
    def loadbm(self, bmname):
        f = open("data/bmarks.dat")
        s = f.readlines()
        f.close()
        s = map(lambda x: x.split("|"), s)
        for i in s:
            if i[0] == bmname:
                tlx, tly, a = map(np.float128, i[1].split())
                coords = (tlx, tly, a)
                self.curindex += 1
                self.chain = self.chain[:self.curindex]
                self.chain.append((coords, self.render(*coords, itr(a))))
                return 
    
    def render(self, tlx, tly, a, i):
        os.system("./mru " + str(dim) + " " + str(dim) + " " + repr(tlx) + " " + repr(tly) + " " + repr(a) + " " +str(i) + " +RTS -N12")
        img = mpimg.imread('mb.bmp')  
        plt.imshow(img)
        return img

def mback(self, *args, **kwargs):
    if renderer.curindex != 0:
        renderer.curindex -= 1
        plt.imshow(renderer.chain[renderer.curindex][1])
        plt.show()

def mforward(self, *args, **kwargs):
    if renderer.curindex != (len(renderer.chain) - 1):
        renderer.curindex += 1
        plt.imshow(renderer.chain[renderer.curindex][1])
        plt.show()

def mhome(self, *args, **kwargs):
    renderer.curindex = 0
    plt.imshow(renderer.chain[renderer.curindex][1])
    plt.show()
        
NavigationToolbar2.back    = mback
NavigationToolbar2.forward = mforward
NavigationToolbar2.home    = mhome

fig = plt.figure()
ax = fig.add_subplot(111)
ax.set_title('Click to zoom in.')
renderer = MRenderer(fig)


plt.show()

