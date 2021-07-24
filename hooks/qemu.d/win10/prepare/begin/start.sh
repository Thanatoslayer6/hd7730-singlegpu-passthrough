#enable debugging
set -x

# load the variables we defined from /etc/libvirt/hooks/kvm.conf
#needed for passing pci devices, like usbs and such...
source "/etc/libvirt/hooks/kvm.conf"

# Now we kill our display manager, (lxdm, gdm, sddm, etc)
# If we use a tiling wm like bspwm, you should use `killall bspwm`
systemctl stop lxdm.service
#killall bspwm

# Unbind VTconsoles
echo 0 > /sys/class/vtconsole/vtcon0/bind
echo 0 > /sys/class/vtconsole/vtcon1/bind

# Avoid a Race condition
sleep 5

# Unload all Radeon drivers

modprobe -r amdgpu
modprobe -r gpu_sched
modprobe -r ttm
modprobe -r drm_kms_helper
modprobe -r i2c_algo_bit
modprobe -r drm
modprobe -r snd_hda_intel

# Unbind the GPU, now we will use the variables inside /etc/libvirt/hooks/kvm.conf
virsh nodedev-detach $VIRSH_GPU_VIDEO
virsh nodedev-detach $VIRSH_GPU_AUDIO

# Load VFIO kernel module
modprobe vfio
modprobe vfio_pci
modprobe vfio_iommu_type1

