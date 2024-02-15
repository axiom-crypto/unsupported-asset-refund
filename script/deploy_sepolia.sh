# Call script from root directory of repo: ./script/deploy_sepolia.sh

source .env
forge script script/UnsupportedAssetRefund.s.sol:UnsupportedAssetRefundScript --private-key $PRIVATE_KEY_SEPOLIA --broadcast --rpc-url $PROVIDER_URI_SEPOLIA -vvvv --verify --etherscan-api-key $ETHERSCAN_API_KEY -vvvv
cp out/UnsupportedAssetRefund.sol/UnsupportedAssetRefund.json ./app/src/lib/abi/UnsupportedAssetRefund.json
