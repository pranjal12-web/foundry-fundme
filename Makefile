# makefile is used for creating shortcuts for long forge commands in the terminal.
-include .env

build:; forge build  #so now instead of writing forge build we can write make build

compile:; forge compile

deploy:  #so now instead of writing the following long command in the terminal we can just write make deploy
	forge script script/DeployFundMe.s.sol --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvv

# SEPOLIA_RPC_URL -- to get this, create an app on alchemy and then paste the sepolia url
# PRIVATE_KEY -- we get this private key from our metamask wallet
# ETHERSCAN_API_KEY -- we get this api key after creating app on etherscan website



.PHONY: all test clean deploy fund help install snapshot format anvil   
#In a Makefile, the .PHONY directive is used to declare certain targets as "phony" or "virtual," meaning they don't represent actual files or dependencies. Instead, they are used as labels for tasks that need to be executed.So basically all,test,clean ,deploy,....... are all targets which are declared as phony

DEFAULT_ANVIL_KEY := 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

help:
	@echo "Usage:"
	@echo "  make deploy [ARGS=...]\n    example: make deploy ARGS=\"--network sepolia\""
	@echo ""
	@echo "  make fund [ARGS=...]\n    example: make deploy ARGS=\"--network sepolia\""

all: clean remove install update build
#Typically used as the default target.When you run make without specifying a target, the all target is executed.When all target is executed -- clean,remove,install ,update and build targets are executed

# Clean the repo
clean  :; forge clean

# Remove modules
remove :; rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "modules"

install :; forge install cyfrin/foundry-devops@0.0.11 --no-commit && forge install smartcontractkit/chainlink-brownie-contracts@0.6.1 --no-commit && forge install foundry-rs/forge-std@v1.5.3 --no-commit

# Update Dependencies
update:; forge update

build:; forge build

test :; forge test 

snapshot :; forge snapshot

format :; forge fmt

anvil :; anvil -m 'test test test test test test test test test test test junk' --steps-tracing --block-time 1

NETWORK_ARGS := --rpc-url http://localhost:8545 --private-key $(DEFAULT_ANVIL_KEY) --broadcast #this is default NETWORK_ARGS

ifeq ($(findstring --network sepolia,$(ARGS)),--network sepolia)
# if --network sepolia is found in $(ARGS), the following block will be executed.
	NETWORK_ARGS := --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv
endif

deploy:
	@forge script script/DeployFundMe.s.sol:DeployFundMe $(NETWORK_ARGS)

fund:
	@forge script script/Interactions.s.sol:FundFundMe $(NETWORK_ARGS)

withdraw:
	@forge script script/Interactions.s.sol:WithdrawFundMe $(NETWORK_ARGS)

#make deploy -- will deploy the script DeployFundMe.s.sol on local anvil chain
# whereas make deploy ARGS="--network sepolia" will deploy the script DeployFundMe.s.sol on sepolia network. 

