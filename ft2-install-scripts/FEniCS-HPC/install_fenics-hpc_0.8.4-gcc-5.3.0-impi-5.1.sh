module purge

module load cmake
module load gcc/5.3.0
module load impi/5.1
module load petsc/3.7.0
module load zlib/1.2.8


CURR_DIR=$PWD
FENICS_HPC_SRC_DIR=$CURR_DIR/fenics-hpc_hpfem

export PREFIX=/opt/cesga/fenics-hpc/0.8.4
PYV=`$(which python) -c "import sys;t='{v[0]}.{v[1]}'.format(v=list(sys.version_info[:2]));sys.stdout.write(t)";`
PYP=$PREFIX/lib/python$PYV/site-packages
export PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig:$PKG_CONFIG_PATH
export PATH=$PREFIX/bin:$PATH
export PYTHONPATH=$PYP:$PYTHONPATH

#wget http://www.csc.kth.se/~jjan/hpfem2016/fenics-hpc_hpfem.zip
#unzip fenics-hpc_hpfem.zip

# SymPy, Instant, FIAT, UFL, FFC, OrderedDict
for pkg in sympy-0.7.5 instant fiat ufl-1.0.0 ffc-1.0.0 ordereddict-1.1
do
  cd $FENICS_HPC_SRC_DIR/$pkg; python setup.py install --prefix=$PREFIX
done

# UFC
cd $FENICS_HPC_SRC_DIR/ufc2-hpc
rm CMakeCache.txt 
cmake -DCMAKE_INSTALL_PREFIX:PATH=$PREFIX
make install -j 8

#DOLFIN-HPC
cd $FENICS_HPC_SRC_DIR/dolfin-hpc
cp /usr/share/aclocal/pkg.m4 m4/
cp /usr/share/aclocal/libxml.m4 m4/
./regen.sh
CC=gcc CXX=g++ CFLAGS="" CXXFLAGS="" 
./configure --prefix=$PREFIX --with-pic --enable-function-cache --enable-optimize-p1 --disable-boost-tr1 \
                             --with-parmetis --with-petsc=/opt/cesga/petsc/3.7.0/gcc/5.3.0/impi/5.1/ \
                             --enable-openmp --enable-mpi --enable-mpi-io \
                             --disable-progress-bar --disable-xmltest --enable-ufl
make install -j 8
cp -av site-packages/dolfin_utils $PYP

cd $FENICS_HPC_SRC_DIR/unicorn-minimal
make -j 8

cd $CURR_DIR
