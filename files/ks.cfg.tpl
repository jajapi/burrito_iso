## version=Rocky8
## Rocky Linux 8 Kickstart 
# install mode: text, graphical
text
# network install
#url --url="http://download.rockylinux.org/pub/rocky/8/BaseOS/x86_64/os/"
# cdrom install
cdrom
#lang ko_KR.UTF-8
lang en_US --addsupport=ko_KR
keyboard us
firewall --disabled
selinux --disabled
timezone Asia/Seoul --isUtc --nontp
bootloader --timeout=5 --location=mbr --append="net.ifnames=0 biosdevname=0"
skipx
zerombr
# Partition scheme split into 2 mode - legacy BIOS vs. UEFI
clearpart --all --initlabel
ignoredisk --only-use=sda
%include /tmp/uefi
%include /tmp/legacy
%pre --logfile /tmp/kickstart.install.pre.log
if [ -d /sys/firmware/efi ]; then
  cat > /tmp/uefi <<END
part /boot --fstype xfs --size 1024
part /boot/efi --fstype efi --size 500
part / --fstype xfs --size 1 --grow
END
else
  cat > /tmp/legacy <<END
part / --fstype xfs --size 1 --grow
END
fi
if [ -d /sys/firmware/efi ]; then
  touch /tmp/legacy
else
  touch /tmp/uefi
fi
%end
firstboot --disabled
reboot --eject
rootpw --iscrypted %%ROOTPW_ENC%%
user --name=%%UNAME%% --iscrypted --password %%USERPW_ENC%%

%packages --instLangs=en_US.utf8
openssh-clients
sudo
nfs-utils
net-tools
tar
bzip2
rsync
python3
git
python3-cryptography
sshpass
lsof
wget
jq
%end

%post
# sudo
echo 'Defaults:clex !requiretty' > /etc/sudoers.d/clex
echo '%clex ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers.d/clex
chmod 440 /etc/sudoers.d/clex
# security settings
sed -i 's/^#UseDNS no/UseDNS no/;s/^PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
echo -e "TMOUT=300\nexport TMOUT" >> /etc/profile
%end

%addon com_redhat_kdump --enable --reserve-mb='auto'
%end

%anaconda
pwpolicy root --minlen=6 --minquality=1 --strict --nochanges --notempty
pwpolicy user --minlen=6 --minquality=1 --strict --nochanges --emptyok
pwpolicy luks --minlen=6 --minquality=1 --strict --nochanges --notempty
%end
