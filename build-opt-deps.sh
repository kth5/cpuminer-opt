#!/bin/bash
openssl=openssl-1.0.2j
opensslurl=https://www.openssl.org/source/${openssl}.tar.gz

CFLAGS="-O3 -march=native -mtune=native -maes -mavx -mavx2 -pipe"
CXXFLAGS="-O3 -march=native -mtune=native -maes -mavx -mavx2 -std=gnu++11 -flto -fpermissive -pipe"
CPPFLAGS="-D_FORTIFY_SOURCE=2"
LDFLAGS="-Wl,-O1,--sort-common,--as-needed,-z,relro"

CARCH=$(uname -m)

if [ "${CARCH}" == 'x86_64' ]; then
	openssltarget='linux-x86_64'
	optflags='enable-ec_nistp_64_gcc_128'
elif [ "${CARCH}" == 'i686' ]; then
	openssltarget='linux-elf'
	optflags=''
fi

OPW=$(pwd)

mkdir -p opt-deps/built
cd opt-deps
wget -c ${opensslurl}
tar xzfv ${openssl}.tar.gz
cd ${openssl}
./Configure --prefix=/ --libdir=lib \
		shared no-ssl3-method ${optflags} \
		"${openssltarget}" \
		"-Wa,--noexecstack ${CPPFLAGS} ${CFLAGS} ${LDFLAGS}"
make depend
make INSTALL_PREFIX=${OPW}/opt-deps/built MANSUFFIX=ssl install

cd ${OPW}
