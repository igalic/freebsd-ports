# Created by: Joe Marcus Clarke <marcus@FreeBSD.org>
# $FreeBSD$

PORTNAME=	gnome-user-docs
PORTVERSION=	3.38.1
CATEGORIES=	misc gnome
MASTER_SITES=	GNOME
DIST_SUBDIR=	gnome

MAINTAINER=	gnome@FreeBSD.org
COMMENT=	GNOME 3 users guide

LICENSE=	CC-BY-3.0
LICENSE_FILE=	${WRKSRC}/COPYING

BUILD_DEPENDS=	itstool:textproc/itstool

PORTSCOUT=	limitw:1,even

GNU_CONFIGURE=	yes
NO_ARCH=	yes
USES=		gettext-tools gmake gnome pathfix tar:xz
USE_GNOME=	libxml2:build

.include <bsd.port.mk>
