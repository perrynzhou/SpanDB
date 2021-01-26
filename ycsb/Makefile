
CC=g++

ROCKSDB_INCLUDE = ../build/include
ROCKSDB_LIB = ../build/lib64
ROCKSDB = -I${ROCKSDB_INCLUDE} -Wl,-rpath,${ROCKSDB_LIB} -L${ROCKSDB_LIB} -lrocksdb

DPDK = -Wl,-rpath,${DPDK_LIB}

CFLAGS=-std=c++11  -g -Wall -lpthread -I./ ${ROCKSDB} ${DPDK}

SUBDIRS=core
SUBSRCS=$(wildcard core/*.cc)
OBJECTS=$(SUBSRCS:.cc=.o)
EXEC=rocksdb test

all: $(SUBDIRS) $(EXEC)

$(SUBDIRS):
	$(MAKE) -C $@

rocksdb: $(wildcard src/rocksdb_client.cc src/rocksdb_test.cc) $(OBJECTS)
	$(CC) $(CFLAGS) $^ $(LDFLAGS) $(LIBS)  -o $@

test: $(wildcard src/rocksdb_client.cc src/test.cc) $(OBJECTS)
	$(CC) $(CFLAGS) $^ $(LDFLAGS) $(LIBS)  -o $@

clean:
	for dir in $(SUBDIRS); do \
		$(MAKE) -C $$dir $@; \
	done
	$(RM) $(EXEC)

.PHONY: $(SUBDIRS) $(EXEC)

