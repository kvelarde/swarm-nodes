# swarm-nodes

# Build
docker build -t swarm-nodes:0.1 .

docker build -f Dockerfile.apply -t swarm-nodes-apply:0.1 .
docker build -f Dockerfile.build -t swarm-nodes-build:0.1 .
docker build -f Dockerfile.destroy -t swarm-nodes-destroy:0.1 .
# Run
docker run -v /keys:/keys -ti --rm  swarm-nodes-build:0.1
docker run -v /keys:/keys -ti --rm  swarm-nodes-apply:0.1
docker run -v /keys:/keys -ti --rm  swarm-nodes-destroy:0.1
