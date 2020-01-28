#!/bin/sh
docker-compose down
echo "dockeropenmpi_mpi_head_1">get_hosts.sh.txt
NNODES=3
for (( c=1; c<=${NNODES}; c++ ))
do

   echo "dockeropenmpi_mpi_node_$c">>get_hosts.sh.txt
done

docker build -t openmpi .
docker network create dockeropenmpi_net
docker-compose scale mpi_head=1 mpi_node=${NNODES}
docker cp dockeropenmpi_mpi_head_1:/home/mpirun/machines get_hosts.sh.txt
docker exec -u mpirun dockeropenmpi_mpi_head_1 mpirun -hostfile machines ./helloworld>slurm-${SLURM_JOBID}.out
