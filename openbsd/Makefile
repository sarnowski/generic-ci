V =			VERSION
DISTNAME =		generic-ci-openbsd-${V}
COMMENT =		generic-ci, a generic continuous integration tool

CATEGORIES =		devel

HOMEPAGE =		https://www.new-thoughts.org/generic-ci/
MAINTAINER =		Tobias Sarnowski <sarnowski@new-thoughts.org>

PERMIT_PACKAGE_CDROM =	No
PERMIT_PACKAGE_FTP =	No
PERMIT_DISTFILES_CDROM =No
PERMIT_DISTFILES_FTP =	No

RUN_DEPENDS =		devel/git,-main

# Things that we don't want to do for this port/package
# Generally, DON'T set anything to No if it's not needed.
# The time gained is not worth it.
#
NO_BUILD =		Yes
NO_REGRESS =		Yes

PKG_ARCH =		*

do-install:
	${INSTALL_SCRIPT} ${WRKSRC}/genci ${PREFIX}/bin/
	${INSTALL_DATA_DIR} ${PREFIX}/share/doc/genci
	${INSTALL_DATA_DIR} ${PREFIX}/share/doc/genci/css
	${INSTALL_DATA} ${WRKSRC}/doc/{LICENSE,index.html} ${PREFIX}/share/doc/genci
	${INSTALL_DATA} ${WRKSRC}/doc/css/* ${PREFIX}/share/doc/genci/css
	${INSTALL_DATA_DIR} ${PREFIX}/share/examples/genci
	${INSTALL_DATA_DIR} ${PREFIX}/share/examples/genci/hooks
	${INSTALL_DATA_DIR} ${PREFIX}/share/examples/genci/monitor
	${INSTALL_DATA} ${WRKSRC}/examples/example-config ${PREFIX}/share/examples/genci
	${INSTALL_SCRIPT} ${WRKSRC}/examples/hooks/* ${PREFIX}/share/examples/genci/hooks
	${INSTALL_DATA} ${WRKSRC}/examples/monitor/* ${PREFIX}/share/examples/genci/monitor

.include <bsd.port.mk>
