
# release 2.41/master at 28.02.2025
GLIBC_VERSION = 20250228-89be78704

GLIBC_ADD_LIB_PATH = \
	mkdir -p $(DESTDIR)$(sysconfdir) ; \
	$(if $(shell test -e $(DESTDIR)$(sysconfdir)/ld.so.conf && grep -e '$(strip $(1))' $(DESTDIR)$(sysconfdir)/ld.so.conf),, \
		echo '$(strip $(1))' >> $(DESTDIR)$(sysconfdir)/ld.so.conf ; \
		test ! -e $(build_DESTDIR)/$(build_esbindir)/ldconfig || $(build_DESTDIR)/$(build_esbindir)/ldconfig )
