import numpy as np
from mpl_toolkits.mplot3d import Axes3D
from matplotlib import cm
import matplotlib.pyplot as plt
import sys

voxel = np.linspace(1, 10, 10)
dose = np.array([np.random.randint(68, 84) for x in voxel])

dose_inv = 68 + 50 - dose

f1 = 20
f2 = 20

plt.figure(1)
p1 = plt.bar(voxel, dose, align='center', label = 'Prescribed Dose')
plt.ylim(0, 120)
plt.xlabel('Voxel', fontsize = f2)
plt.ylabel('Dose [Gy]', fontsize = f2)
plt.title('Prescribed Dose', fontsize = f1)
plt.legend()
plt.savefig('../Latex/Figures/presc.png')


plt.figure(2)
p2 = plt.bar(voxel, dose_inv, align='center', color = 'orange', label = 'Inverse Dose')
plt.ylim(0, 120)
plt.xlabel('Voxel', fontsize = f2)
plt.ylabel('Dose [Gy]', fontsize = f2)
plt.title('Inverse Dose', fontsize = f1)
plt.legend()
plt.savefig('../Latex/Figures/inv.png')


plt.figure(3)
p3 = plt.bar(voxel, dose_inv, align='center', color = 'orange', label = 'Inverse Dose')
p4 = plt.bar(voxel, dose, align = 'center', bottom = dose_inv, label = 'Planned Dose', color = 'Green')
plt.ylim(0, 120)
plt.xlabel('Voxel', fontsize = f2)
plt.ylabel('Dose [Gy]', fontsize = f2)
plt.title('Planned and Inverse Dose', fontsize = f1)
plt.legend()
plt.savefig('../Latex/Figures/presc_inv.png')


plt.figure(4)
p5 = plt.bar(voxel, dose, align = 'center', label = 'Planned Dose', color = 'Green')
p6 = plt.bar(voxel, dose_inv, align = 'center', label = 'Inverse Dose', 
							color = 'White', bottom = dose, ls = 'dashed')

plt.ylim(0, 120)
plt.xlabel('Voxel', fontsize = f2)
plt.ylabel('Dose [Gy]', fontsize = f2)
plt.title('Planned Dose without inverse', fontsize = f1)
plt.legend()
plt.savefig('../Latex/Figures/presc_noinv.png')


plt.show()