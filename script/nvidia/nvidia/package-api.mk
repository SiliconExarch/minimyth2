GARNAME = nvidia
GARVERSION = $(NVIDIA_VERSION)
CATEGORIES = nvidia
MASTER_SITES  = http://us.download.nvidia.com/XFree86/Linux-$(NVIDIA_SUPER_VERSION)/$(NVIDIA_VERSION)/
MASTER_SITES += ftp://download.nvidia.com/XFree86/Linux-$(NVIDIA_SUPER_VERSION)/$(NVIDIA_VERSION)/
DISTFILES = $(DISTFILE).run
LICENSE = nvidia
nvidia_LICENSE_TEXT=$(WORKSRC)/LICENSE

DESCRIPTION = 
define BLURB
endef

DEPENDS   = lang/c kernel/kernel xorg/xorg
BUILDDEPS = utils/module-init-tools

DISTFILE = NVIDIA-Linux-$(NVIDIA_SUPER_VERSION)-$(NVIDIA_VERSION)

WORKSRC = $(WORKDIR)/$(DISTFILE)

NVIDIA_SUPER_VERSION = $(strip $(if $(filter i386,$(GARCH_FAMILY)),x86,x86_64))

#NVIDIA_SUPER_VERSION = $(strip \
#	$(if $(filter i386,  $(GARCH_FAMILY)),x86   ) \
#	$(if $(filter x86_64,$(GARCH_FAMILY)),x86_64))

NVIDIA_VERSION_LIST  = $(strip \
	$(if $(NVIDIA_MAJOR_VERSION), \
		$(if $(NVIDIA_MINOR_VERSION), \
			$(if $(NVIDIA_TEENY_VERSION), \
				$(NVIDIA_MAJOR_VERSION).$(NVIDIA_MINOR_VERSION).$(NVIDIA_TEENY_VERSION) \
			) \
			$(NVIDIA_MAJOR_VERSION).$(NVIDIA_MINOR_VERSION) \
		) \
		$(NVIDIA_MAJOR_VERSION) \
	))

NVIDIA_VERSION = $(strip $(if $(filter 1.0,$(NVIDIA_MAJOR_VERSION).$(NVIDIA_MINOR_VERSION)), \
		1.0-$(NVIDIA_TEENY_VERSION), \
		$(word 1,$(NVIDIA_VERSION_LIST), \
	)))

NVIDIA_FILE_LIST_BIN     = $(strip \
		$(if $(wildcard $(WORKSRC)/usr/bin/nvidia-bug-report.sh), \
			nvidia-bug-report.sh:/usr/bin:$(bindir)) \
		$(if $(wildcard $(WORKSRC)/usr/bin/nvidia-settings), \
			nvidia-settings:/usr/bin:$(bindir)) \
		$(if $(wildcard $(WORKSRC)/usr/bin/nvidia-xconfig), \
			nvidia-xconfig:/usr/bin:$(bindir)) \
		$(if $(wildcard $(WORKSRC)/nvidia-bug-report.sh), \
			nvidia-bug-report.sh:/:$(bindir)) \
		$(if $(wildcard $(WORKSRC)/nvidia-settings), \
			nvidia-settings:/:$(bindir)) \
		$(if $(wildcard $(WORKSRC)/nvidia-smi), \
			nvidia-smi:/:$(bindir)) \
		$(if $(wildcard $(WORKSRC)/nvidia-xconfig), \
			nvidia-xconfig:/:$(bindir)) \
	)

NVIDIA_FILE_LIST_LIB_DRV = $(strip \
		$(if $(wildcard $(WORKSRC)/usr/X11R6/lib/modules/drivers/nvidia_drv.so), \
			nvidia_drv.so:/usr/X11R6/lib/modules/drivers:$(libdir)/nvidia/xorg/modules/drivers) \
		$(if $(wildcard $(WORKSRC)/nvidia_drv.so), \
			nvidia_drv.so:/:$(libdir)/nvidia/xorg/modules/drivers) \
	)

NVIDIA_FILE_LIST_LIB_SO  = $(strip \
	$(if $(wildcard $(WORKSRC)/libGL.so.*), \
	    libGL.so:/:$(libdir)/nvidia) \
	$(if $(wildcard $(WORKSRC)/libEGL.so.*), \
	    libEGL.so:/:$(libdir)/nvidia) \
	$(if $(wildcard $(WORKSRC)/libGLESv1_CM.so.*), \
	    libGLESv1_CM.so:/:$(libdir)/nvidia) \
	$(if $(wildcard $(WORKSRC)/libGLESv2.so.*), \
	    libGLESv2.so:/:$(libdir)/nvidia) \
	$(if $(wildcard $(WORKSRC)/libnvidia-glcore.so.*), \
	    libnvidia-glcore.so:/:$(libdir)/nvidia) \
	$(if $(wildcard $(WORKSRC)/libnvidia-eglcore.so.*), \
	    libnvidia-eglcore.so:/:$(libdir)/nvidia) \
	$(if $(wildcard $(WORKSRC)/libnvidia-cfg.so.*), \
	    libnvidia-cfg.so:/:$(libdir)/nvidia) \
	$(if $(wildcard $(WORKSRC)/libnvidia-tls.so.*), \
	    libnvidia-tls.so:/:$(libdir)/nvidia) \
	$(if $(wildcard $(WORKSRC)/libvdpau_nvidia.so.*), \
	    libvdpau_nvidia.so:/:$(libdir)/vdpau) \
	$(if $(wildcard $(WORKSRC)/libnvidia-ml.so.*), \
	    libnvidia-ml.so:/:$(libdir)/nvidia) \
	$(if $(wildcard $(WORKSRC)/libnvidia-glsi.so.*), \
	    libnvidia-glsi.so:/:$(libdir)/nvidia) \
	$(if $(wildcard $(WORKSRC)/libGLX.so.*), \
	    libGLX.so:/:$(libdir)/nvidia/xorg/modules/extensions) \
	)

NVIDIA_MAKE_ARGS = \
	module \
	$(LINUX_MAKE_ARGS) \
	HOST_CC=$(build_CC) \
	SYSSRC=$(shell readlink -f $(DESTDIR)$(LINUX_SOURCEDIR)) \
	SYSOUT=$(shell readlink -f $(DESTDIR)$(LINUX_BUILDDIR)) \
	MODULE_ROOT=$(DESTDIR)$(LINUX_MODULESDIR)/misc/nvidia

NVIDIA_MAKE_ENV = \
	$(LINUX_MAKE_ENV)

extract-%.run:
	@mkdir -p $(WORKDIR)
	@cp $(DOWNLOADDIR)/$*.run $(WORKDIR)
	@cd $(WORKDIR) ; sh $*.run --extract-only
	@cd $(WORKDIR) ; rm -rf $*.run
	@$(MAKECOOKIE)

build-nvidia:
	@$(if $(wildcard $(WORKSRC)/usr/src/nv), \
		echo " ==> Running make in $(WORKSRC)/usr/src/nv" ; \
		cd $(WORKSRC)/usr/src/nv ; $(BUILD_ENV) $(MAKE) $(PARALLELMFLAGS) $(foreach TTT,$(BUILD_OVERRIDE_DIRS),$(TTT)="$($(TTT))") $(BUILD_ARGS) \
	)
	@$(if $(wildcard $(WORKSRC)/kernel), \
		echo " ==> Running make in $(WORKSRC)/kernel" ; \
		cd $(WORKSRC)/kernel ; $(BUILD_ENV) $(MAKE) $(PARALLELMFLAGS) $(foreach TTT,$(BUILD_OVERRIDE_DIRS),$(TTT)="$($(TTT))") $(BUILD_ARGS) \
	)
	@$(MAKECOOKIE)

install-nvidia: install-nvidia-kernel install-nvidia-x11
	@$(MAKECOOKIE)

install-nvidia-kernel:
	@mkdir -p $(DESTDIR)$(LINUX_MODULESDIR)/misc/nvidia
	@$(if $(wildcard $(WORKSRC)/usr/src/nv/nvidia.ko), \
		cp $(WORKSRC)/usr/src/nv/nvidia.ko $(DESTDIR)$(LINUX_MODULESDIR)/misc/nvidia/nvidia.ko)
	@$(if $(wildcard $(WORKSRC)/kernel/nvidia-drm.ko), \
		cp $(WORKSRC)/kernel/nvidia-drm.ko $(DESTDIR)$(LINUX_MODULESDIR)/misc/nvidia/nvidia-drm.ko)
	@$(if $(wildcard $(WORKSRC)/kernel/nvidia-modeset.ko), \
		cp $(WORKSRC)/kernel/nvidia-modeset.ko $(DESTDIR)$(LINUX_MODULESDIR)/misc/nvidia/nvidia-modeset.ko)
	@$(if $(wildcard $(WORKSRC)/kernel/nvidia-uvm.ko), \
		cp $(WORKSRC)/kernel/nvidia-uvm.ko $(DESTDIR)$(LINUX_MODULESDIR)/misc/nvidia/nvidia-uvm.ko)
	@$(if $(wildcard $(WORKSRC)/kernel/nvidia.ko), \
		cp $(WORKSRC)/kernel/nvidia.ko $(DESTDIR)$(LINUX_MODULESDIR)/misc/nvidia/nvidia.ko)
	@depmod -b "$(DESTDIR)$(rootdir)" "$(LINUX_FULL_VERSION)"
	@$(MAKECOOKIE)

install-nvidia-x11:
	@# Since 430 family libGL has generic version instead of NVIDIA_VERSION. Symlink it to
	@# libGL.so.$(NVIDIA_VERSION)
	@if [ -e $(WORKSRC)/libGL.so.1.7.0 ]; then \
	    ln -rsf $(WORKSRC)/libGL.so.1.7.0 $(WORKSRC)/libGL.so.$(NVIDIA_VERSION); \
	 fi
	@if [ -e $(WORKSRC)/libGL.so.1.8.0 ]; then \
	    ln -rsf $(WORKSRC)/libGL.so.1.7.0 $(WORKSRC)/libGL.so.$(NVIDIA_VERSION); \
	 fi
	# Symlinking non GLVND libs (libXXX_nvidia.so) to standard names (libXXX.so)
	@rm -f $(WORKSRC)/libEGL.so*
	@ln -rsf $(WORKSRC)/libEGL_nvidia.so.$(NVIDIA_VERSION) $(WORKSRC)/libEGL.so.$(NVIDIA_VERSION)
	@rm -f $(WORKSRC)/ibGLESv1_CM.so*
	@ln -rsf $(WORKSRC)/libGLESv1_CM_nvidia.so.$(NVIDIA_VERSION) $(WORKSRC)/libGLESv1_CM.so.$(NVIDIA_VERSION)
	@rm -f $(WORKSRC)/libGLESv2.so*
	@ln -rsf $(WORKSRC)/libGLESv2_nvidia.so.$(NVIDIA_VERSION) $(WORKSRC)/libGLESv2.so.$(NVIDIA_VERSION)
	@rm -f $(WORKSRC)/libGLX.so*
	@ln -rsf $(WORKSRC)/libglxserver_nvidia.so.$(NVIDIA_VERSION) $(WORKSRC)/libGLX.so.$(NVIDIA_VERSION)
	@rm -f $(DESTDIR)$(bindir)/nvidia-bug-report.sh
	@rm -f $(DESTDIR)$(bindir)/nvidia-settings
	@rm -f $(DESTDIR)$(bindir)/nvidia-smi
	@rm -f $(DESTDIR)$(bindir)/nvidia-xconfig
	@$(foreach entry,$(NVIDIA_FILE_LIST_BIN), \
		install -D \
		    $(WORKSRC)$(word 2,$(subst :, ,$(entry)))/$(word 1,$(subst :, ,$(entry))) \
		    $(DESTDIR)$(word 3,$(subst :, ,$(entry)))/$(word 1,$(subst :, ,$(entry))) ; \
	)
	@rm -rf $(DESTDIR)$(libdir)/nvidia/*
	@rm -rf $(DESTDIR)$(libdir)/vdpau/libvdpau_nvidia.*
	@$(foreach entry,$(NVIDIA_FILE_LIST_LIB_DRV), \
		install -D \
		    $(WORKSRC)$(word 2,$(subst :, ,$(entry)))/$(word 1,$(subst :, ,$(entry))) \
		    $(DESTDIR)$(word 3,$(subst :, ,$(entry)))/$(word 1,$(subst :, ,$(entry))) ; \
	)
	@$(foreach entry,$(NVIDIA_FILE_LIST_LIB_SO), \
		install -D \
		    $(WORKSRC)$(word 2,$(subst :, ,$(entry)))/$(word 1,$(subst :, ,$(entry))).$(word 1,$(NVIDIA_VERSION_LIST)) \
		    $(DESTDIR)$(word 3,$(subst :, ,$(entry)))/$(word 1,$(subst :, ,$(entry))).$(word 1,$(NVIDIA_VERSION_LIST)) ; \
	)
	@$(foreach entry,$(NVIDIA_FILE_LIST_LIB_SO), $(if $(word 2,$(NVIDIA_VERSION_LIST)), \
		ln -sf \
		    $(word 1,$(subst :, ,$(entry))).$(word 1,$(NVIDIA_VERSION_LIST)) \
		    $(DESTDIR)$(word 3,$(subst :, ,$(entry)))/$(word 1,$(subst :, ,$(entry))).$(word 2,$(NVIDIA_VERSION_LIST)) ; \
	))
	@$(foreach entry,$(NVIDIA_FILE_LIST_LIB_SO), $(if $(word 3,$(NVIDIA_VERSION_LIST)), \
		ln -sf \
		    $(word 1,$(subst :, ,$(entry))).$(word 2,$(NVIDIA_VERSION_LIST)) \
		    $(DESTDIR)$(word 3,$(subst :, ,$(entry)))/$(word 1,$(subst :, ,$(entry))).$(word 3,$(NVIDIA_VERSION_LIST)) ; \
	))
	@$(foreach entry,$(NVIDIA_FILE_LIST_LIB_SO), \
		ln -sf \
		    $(word 1,$(subst :, ,$(entry))).$(word $(words $(NVIDIA_VERSION_LIST)),$(NVIDIA_VERSION_LIST)) \
		    $(DESTDIR)$(word 3,$(subst :, ,$(entry)))/$(word 1,$(subst :, ,$(entry))) ; \
	)
	@$(foreach entry,$(NVIDIA_FILE_LIST_LIB_SO), $(if $(filter-out 1,$(NVIDIA_MAJOR_VERSION)), \
		ln -sf \
		    $(word 1,$(subst :, ,$(entry))).$(word $(words $(NVIDIA_VERSION_LIST)),$(NVIDIA_VERSION_LIST)) \
		    $(DESTDIR)$(word 3,$(subst :, ,$(entry)))/$(word 1,$(subst :, ,$(entry))).1 ; \
	))
	@$(foreach entry,$(NVIDIA_FILE_LIST_LIB_SO), $(if $(word 4,$(subst :, ,$(entry))), \
		ln -sf \
		    $(word 1,$(subst :, ,$(entry))) \
		    $(DESTDIR)$(word 3,$(subst :, ,$(entry)))/$(word 4,$(subst :, ,$(entry))) ; \
	))
	@cp $(WORKSRC)/html/supportedchips.html $(WORKSRC)/../../../files/
	@$(MAKECOOKIE)

clean-all: clean-all-kernel clean-all-x11
	@$(foreach dir, $(wildcard ../nvidia ../nvidia-*), $(MAKE) clean -C $(dir) ; )
	@rm -rf $(DESTDIR)$(versiondir)/$(GARNAME)
	@rm -rf $(DESTDIR)$(licensedir)/$(GARNAME)

clean-all-kernel:
	@rm -rf $(DESTDIR)$(LINUX_MODULESDIR)/misc/nvidia

clean-all-x11:
	@rm -f $(DESTDIR)$(bindir)/nvidia-bug-report.sh
	@rm -f $(DESTDIR)$(bindir)/nvidia-settings
	@rm -f $(DESTDIR)$(bindir)/nvidia-smi
	@rm -f $(DESTDIR)$(bindir)/nvidia-xconfig
	@rm -rf $(DESTDIR)$(libdir)/nvidia/*
	@rm -rf $(DESTDIR)$(libdir)/vdpau/libvdpau_nvidia.*
