# aztec-integration-testing

1) Run sandbox
1) aztec-cli compile iun our repo
1) yarn run:oracle in our repo
1) Copy-Paste the /mock-poc/local-oracle  (our repo) to aztec-packages/noir-projects/noir-contracts
1) Add it to the workspaces in nargo
1) compile noir-contracts
1) from inside aztec-packages/noir-projects/noir-contracts run ../../noir/noir-repo/target/release/nargo test --oracle-resolver 'http://localhost:5555/' --silence-warnings --package local_oracle

needs node 18