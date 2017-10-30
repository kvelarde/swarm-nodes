# swarm-nodes

# Build
docker build -t swarm-nodes:0.1 .

# Run
docker run -v /keys:/keys -dti --rm  swarm-nodes:0.1
