# $FreeBSD$

PORTNAME=	open3d-python
DISTVERSIONPREFIX=	v
DISTVERSION=	0.2
PORTREVISION=	4
CATEGORIES=	graphics
PKGNAMEPREFIX=	${PYTHON_PKGNAMEPREFIX}

MAINTAINER=	yuri@FreeBSD.org
COMMENT=	Modern library for 3D data processing (Python binding)

LICENSE=	MIT
LICENSE_FILE=	${WRKSRC}/../LICENSE

LIB_DEPENDS=	libOpen3D.so:graphics/open3d

USES=		cmake compiler:c++11-lang eigen:3 fortran localbase:ldflags \
		pkgconfig python
USE_GITHUB=	yes
GH_ACCOUNT=	IntelVCL
GH_PROJECT=	Open3D
USE_PYTHON=	flavors

CMAKE_ARGS=	-DPYTHON_EXECUTABLE:FILEPATH=${PYTHON_CMD} -DPYTHON_SITE_PACKAGES:STRING=lib/${PYTHON_VERSION}/site-packages
CMAKE_ON=	BUILD_SHARED_LIBS BUILD_PYTHON_MODULE
CMAKE_OFF=	BUILD_TESTS BUILD_PYTHON_TESTS BUILD_PYTHON_TUTORIALS BUILD_TINYFILEDIALOGS

WRKSRC_SUBDIR=	src
LDFLAGS+=	-pthread # https://github.com/IntelVCL/Open3D/issues/510

PLIST_FILES=	${PYTHON_SITELIBDIR}/open3d.so

.include <bsd.port.pre.mk>

.if !exists(/usr/include/c++/v1/experimental/optional) && ${CHOSEN_COMPILER_TYPE} == clang
BROKEN=		Base C++ compiler is missing the header <experimental/optional>, see bug\#249538
.endif

.include <bsd.port.post.mk>
