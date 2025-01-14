# $FreeBSD$
#
# Provide support for Berkeley DB
# Feature:	bdb
# Usage:	USES=	bdb[:version]
#
#			  If no version is given (by the maintainer via the port or
#			  by the user via defined variable), try to find the
#			  currently installed version.  Fall back to default if
#			  necessary (db5 if compatible).
#			  This adds a "debug-bdb" make target which will dump the
#			  related data.
# INVALID_BDB_VER
#			- This variable can be defined when the port does not
#			  support one or more versions of Berkeley DB.
# <BDB_UNIQUENAME>_WITH_BDB_VER
#			- User defined port specific variable to set Berkeley DB
#			  version.
# WITH_BDB_HIGHEST
#			- Use the highest installed version of Berkeley DB.
# WITH_BDB6_PERMITTED
# 			- If defined, BerkeleyDB 6 is added to the
# 			  default version set, making it eligible even
# 			  if not already installed. This is due to its
# 			  stricter Affero GNU Public License.
#
# These variables will then be filled in by this .mk file:
#
# BDB_LIB_NAME
#			- This variable is automatically set to the name of the
#			  Berkeley DB library (default: db41).
# BDB_LIB_CXX_NAME
#			- This variable is automatically set to the name of the
#			  Berkeley DB C++ library (default: db41_cxx).
# BDB_INCLUDE_DIR
#			- This variable is automatically set to the location of
#			  the Berkeley DB include directory (default:
#			  ${LOCALBASE}/include/db41).
# BDB_LIB_DIR
#			- This variable is automatically set to the location of
#			  the Berkeley DB library directory.
# BDB_VER
#			- Detected Berkeley DB version.
#
# MAINTAINER:	ports@FreeBSD.org

.if !defined(_INCLUDE_USES_BDB_MK)
_INCLUDE_USES_BDB_MK=	yes

.if !empty(bdb_ARGS)
_bdb_ARGS:=	${bdb_ARGS}
.endif
_bdb_ARGS?=	yes

# TODO: avoid malformed conditional with invalid _bdb_ARGS/BDB_DEFAULT
# check if + works properly from test builds 01h12m23s

BDB_UNIQUENAME?=	${PKGNAMEPREFIX}${PORTNAME}

_BDB_DEFAULT_save:=${BDB_DEFAULT}

_DB_PORTS=		5 6 18
_DB_DEFAULTS=	5	# does not include 6 due to different licensing
#	but user can re-add it through WITH_BDB6_PERMITTED
#
#   Since 2020-12-02, this name is not fitting too much but
#   retained for now for compatibility. The name of this variable
#   is subject to change especially once db6 were removed.
. if defined(WITH_BDB6_PERMITTED)
_DB_DEFAULTS+=	6 18
. endif

# Dependency lines for different db versions
db5_DEPENDS=	libdb-5.3.so:databases/db5
db6_DEPENDS=	libdb-6.2.so:databases/db6
db18_DEPENDS=	libdb-18.1.so:databases/db18
# Detect db versions by finding some files
db5_FIND=	${LOCALBASE}/include/db5/db.h
db6_FIND=	${LOCALBASE}/include/db6/db.h
db18_FIND=	${LOCALBASE}/include/db18/db.h

# Override the global BDB_DEFAULT with the
# port specific <BDB_UNIQUENAME>_WITH_BDB_VER
.if defined(${BDB_UNIQUENAME:tu:S,-,_,}_WITH_BDB_VER)
BDB_DEFAULT=	${${BDB_UNIQUENAME:tu:S,-,_,}_WITH_BDB_VER}
.endif

# Override _bdb_ARGS with global BDB_DEFAULT if the maintainer did not
# ask for a more specific version.
. if ${_bdb_ARGS} == yes
.  if ${BDB_DEFAULT} != 1
_bdb_ARGS=	${BDB_DEFAULT}
.  else
_bdb_ARGS:=	5+
.  endif
. endif

# Compatiblity hack:
# upgrade older plussed versions to 5+
_BDB_OLDPLUSVERS=4+ 40+ 41+ 42+ 43+ 44+ 45+ 46+ 47+ 48+
.for i in ${_bdb_ARGS}
. if ${_BDB_OLDPLUSVERS:M${i}}
_bdb_ARGS:=	5+
. endif
.endfor

# 1. detect installed versions
_INST_BDB_VER=
.for bdb in ${_DB_PORTS}
. if exists(${db${bdb}_FIND})
_INST_BDB_VER+=${bdb}
. endif
.endfor

# 2. parse supported versions:
# 2a. build list from _bdb_ARGS
_SUPP_BDB_VER=
__bdb_ARGS:=${_bdb_ARGS:C,\+$,,}
.if !empty(_bdb_ARGS:M*+)
. for bdb in ${_DB_PORTS}
.  if ${__bdb_ARGS} <= ${bdb}
_SUPP_BDB_VER+=${bdb:C/\.//}
.  endif
. endfor
.else
_SUPP_BDB_VER=${_bdb_ARGS}
.endif
# 2b. expand INVALID_BDB_VER if given with "+":
.if !empty(INVALID_BDB_VER:M*+)
_INV_BDB:=${INVALID_BDB_VER:C,\+$,,}
_INV_BDB_VER:=
. for bdb in ${_DB_PORTS}
.  if ${_INV_BDB} <= ${bdb}
_INV_BDB_VER+=${bdb:C/\.//}
.  endif
. endfor
.else
_INV_BDB_VER:=${INVALID_BDB_VER}
.endif
# 2c. strip versions from INVALID_BDB_VER out of _SUPP_BDB_VER
.for unsupp in ${_INV_BDB_VER}
_SUPP_BDB_VER:=${_SUPP_BDB_VER:N${unsupp}}
.endfor

# 3a. calculate intersection in _INST_BDB_VER to see if there
# is a usable installed version
.for i in ${_INST_BDB_VER}
. if empty(_SUPP_BDB_VER:M${i})
_INST_BDB_VER:=	${_INST_BDB_VER:N${i}}
. endif
.endfor
_ELIGIBLE_BDB_VER:=${_INST_BDB_VER}

# 3b. if there is no usable version installed, check defaults
.if empty(_INST_BDB_VER)
_DFLT_BDB_VER:=${_DB_DEFAULTS}
# make sure we use a reasonable version for package builds
_WITH_BDB_HIGHEST=yes
. for i in ${_DFLT_BDB_VER}
.  if empty(_SUPP_BDB_VER:M${i})
_DFLT_BDB_VER:=	${_DFLT_BDB_VER:N${i}}
.  endif
. endfor
_ELIGIBLE_BDB_VER:=${_DFLT_BDB_VER}
.endif

# 4. elect a version
_BDB_VER=
.for i in ${_ELIGIBLE_BDB_VER}
. if !empty(WITH_BDB_HIGHEST) || !empty(_WITH_BDB_HIGHEST) || empty(${_BDB_VER})
_BDB_VER:=${i}
. endif
.endfor

# 5. catch errors or set variables
.if empty(_BDB_VER)
IGNORE=		cannot install: no eligible BerkeleyDB version. Requested: ${_bdb_ARGS}, incompatible: ${_INV_BDB_VER}. Try: make debug-bdb
.else
. if defined(BDB_BUILD_DEPENDS)
BUILD_DEPENDS+=	${db${_BDB_VER}_FIND}:${db${_BDB_VER}_DEPENDS:C/^libdb.*://}
. else
LIB_DEPENDS+=	${db${_BDB_VER}_DEPENDS}
. endif
. if ${_BDB_VER} == 5
BDB_LIB_NAME=		db-5.3
BDB_LIB_CXX_NAME=	db_cxx-5.3
BDB_LIB_DIR=		${LOCALBASE}/lib/db5
. elif ${_BDB_VER} == 6
BDB_LIB_NAME=		db-6.2
BDB_LIB_CXX_NAME=	db_cxx-6.2
BDB_LIB_DIR=		${LOCALBASE}/lib/db6
. elif ${_BDB_VER} == 18
BDB_LIB_NAME=		db-18.1
BDB_LIB_CXX_NAME=	db_cxx-18.1
BDB_LIB_DIR=		${LOCALBASE}/lib/db18
. endif
BDB_LIB_NAME?=		db${_BDB_VER}
BDB_LIB_CXX_NAME?=	db${_BDB_VER}_cxx
BDB_INCLUDE_DIR?=	${LOCALBASE}/include/db${_BDB_VER}
BDB_LIB_DIR?=		${LOCALBASE}/lib
.endif
BDB_VER=	${_BDB_VER}

debug-bdb:
	@${ECHO_CMD} "--INPUTS----------------------------------------------------"
	@${ECHO_CMD} "${BDB_UNIQUENAME:tu:S,-,_,}_WITH_BDB_VER: ${${BDB_UNIQUENAME:tu:S,-,_,}_WITH_BDB_VER}"
	@${ECHO_CMD} "BDB_DEFAULT: ${_BDB_DEFAULT_save}"
	@${ECHO_CMD} "BDB_BUILD_DEPENDS: ${BDB_BUILD_DEPENDS}"
	@${ECHO_CMD} "bdb_ARGS (original): ${bdb_ARGS}"
	@${ECHO_CMD} "WITH_BDB_HIGHEST (original): ${WITH_BDB_HIGHEST}"
	@${ECHO_CMD} "--PROCESSING------------------------------------------------"
	@${ECHO_CMD} "supported versions: ${_SUPP_BDB_VER}"
	@${ECHO_CMD} "invalid versions: ${_INV_BDB_VER}"
	@${ECHO_CMD} "installed versions: ${_INST_BDB_VER}"
	@${ECHO_CMD} "eligible versions: ${_ELIGIBLE_BDB_VER}"
	@${ECHO_CMD} "bdb_ARGS (effective): ${_bdb_ARGS}"
	@${ECHO_CMD} "WITH_BDB_HIGHEST (override): ${_WITH_BDB_HIGHEST}"
	@${ECHO_CMD} "--OUTPUTS---------------------------------------------------"
	@${ECHO_CMD} "IGNORE=${IGNORE}"
	@${ECHO_CMD} "BDB_VER=${BDB_VER}"
	@${ECHO_CMD} "BDB_INCLUDE_DIR=${BDB_INCLUDE_DIR}"
	@${ECHO_CMD} "BDB_LIB_NAME=${BDB_LIB_NAME}"
	@${ECHO_CMD} "BDB_LIB_CXX_NAME=${BDB_LIB_CXX_NAME}"
	@${ECHO_CMD} "BDB_LIB_DIR=${BDB_LIB_DIR}"
	@${ECHO_CMD} "BUILD_DEPENDS=${BUILD_DEPENDS:M*\:databases/db*}"
	@${ECHO_CMD} "LIB_DEPENDS=${LIB_DEPENDS:M*\:databases/db*}"
	@${ECHO_CMD} "------------------------------------------------------------"

# Obsolete variables - ports can define these to want users about
# variables that may be in /etc/make.conf but that are no longer
# effective:
.if defined(OBSOLETE_BDB_VAR)
. for var in ${OBSOLETE_BDB_VAR}
.  if defined(${var})
BAD_VAR+=	${var},
.  endif
. endfor
. if defined(BAD_VAR)
_IGNORE_MSG=	Obsolete variable(s) ${BAD_VAR} use DEFAULT_VERSIONS or ${BDB_UNIQUENAME:tu:S,-,_,}_WITH_BDB_VER to select Berkeley DB version
.  if defined(IGNORE)
IGNORE+= ${_IGNORE_MSG}
.  else
IGNORE=	${_IGNORE_MSG}
.  endif
. endif
.endif


.endif
