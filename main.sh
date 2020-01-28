#!/bin/sh
docker-compose down
echo "docker-clusteropenmpi_head_1">get_hosts.sh.txt
NNODES=3
for (( c=1; c<=${NNODES}; c++ ))
do

   echo "docker-cluster-openmpi_mpi_node_$c">>get_hosts.sh.txt
done

docker build -t openmpi .
docker network create docker-cluster-openmpi_net
docker-compose scale mpi_head=1 mpi_node=${NNODES}
docker cp docker-cluster-openmpi_mpi_head_1:/home/mpirun/machines get_hosts.sh.txt
docker exec -u mpirun docker-cluster-openmpi_mpi_head_1 mpirun -hostfile machines ./helloworld>slurm-${SLURM_JOBID}.out
