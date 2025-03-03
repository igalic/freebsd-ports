# $FreeBSD$

PORTNAME=	quantum-espresso
DISTVERSIONPREFIX=	qe-
DISTVERSION=	6.6
CATEGORIES=	science

MAINTAINER=	yuri@FreeBSD.org
COMMENT=	Package for research in electronic structure, simulation, optimization

LICENSE=	GPLv2
LICENSE_FILE=	${WRKSRC}/License

BROKEN_armv6=	fails to build: gfortran8: error: iotk_base_tmp.f90: No such file or directory
BROKEN_armv7=	fails to build: gfortran8: error: iotk_base_tmp.f90: No such file or directory

BUILD_DEPENDS=	fox-xml>0:textproc/fox-xml \
		bash:shells/bash
LIB_DEPENDS=	libmpich.so:net/mpich \
		libblas.so:math/blas \
		liblapack.so:math/lapack

USES=		fortran gmake python shebangfix
SHEBANG_FILES=	configure
GNU_CONFIGURE=	yes
USE_GITHUB=	yes
GH_ACCOUNT=	QEF
GH_PROJECT=	q-e

MAKE_ARGS=	TOPDIR=${WRKSRC}
BINARY_ALIAS=	make=gmake cpp=/usr/local/bin/cpp${GCC_DEFAULT}
FFLAGS+=	-x f95-cpp-input
LDFLAGS+=	${LOCALBASE}/lib/gcc${GCC_DEFAULT}/libgfortran.so -lm

MAKE_JOBS_UNSAFE=	yes # https://github.com/QEF/q-e/issues/9

.include <bsd.port.pre.mk>

.  if ${GCC_DEFAULT} >= 10
FFLAGS+=	-fallow-argument-mismatch # workaround for https://github.com/QEF/q-e/issues/34
.  endif

post-extract:
	@${RM} ${WRKSRC}/archive/lapack-3.6.1.tgz
	@cd ${WRKSRC} && ${MKDIR} FoX && ${LN} -s ${LOCALBASE}/include FoX/finclude

pre-build:
	@${REINPLACE_CMD} -i '' -e ' \
		s|$$(CPP) $$(CPPFLAGS)|$$(CPP) -P -traditional $$(CPPFLAGS)| ; \
		s|LD *=.*|LD=${CC}| ; \
		s|LAPACK_LIBS *=.*|LAPACK_LIBS=-L${LOCALBASE}/lib -llapack| ; \
		s|BLAS_LIBS *=.*|BLAS_LIBS=-L${LOCALBASE}/lib -lblas|' \
		${WRKSRC}/make.inc

post-install:
	@${STRIP_CMD} ${STAGEDIR}${PREFIX}/bin/*.x

run-examples: build
.for c in PP PW PWCOND PHonon
	@cd ${WRKSRC}/$c/examples && PREFIX=${STAGEDIR}${PREFIX} ./run_all_examples
.endfor

.include <bsd.port.post.mk>
