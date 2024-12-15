from web3 import Web3
from web3.middleware import geth_poa_middleware
import json

# Set up the Web3 instance
infura_url = 'https://mainnet.infura.io/v3/YOUR_INFURA_PROJECT_ID'
w3 = Web3(Web3.HTTPProvider(infura_url))

# Add the middleware for PoA networks like Polygon if required
w3.middleware_stack.inject(geth_poa_middleware, layer=0)

# Your Ethereum wallet private key
private_key = 'YOUR_PRIVATE_KEY'

# Sender address (your wallet address)
sender_address = 'YOUR_WALLET_ADDRESS'

# OpenSea Seaport contract address
seaport_address = '0x00000000006c3852cbef3e08e8bf3e5e96a5b3b14'

# ABI for Seaport contract (simplified, should be complete in production)
seaport_abi = json.loads('''[YOUR_SEAPORT_ABI]''')

# Function to list NFT for sale
def list_nft_for_sale(token_address, token_id, price_in_wei):
    # Initialize the Seaport contract
    seaport_contract = w3.eth.contract(address=seaport_address, abi=seaport_abi)
    
    # Prepare the transaction data
    nonce = w3.eth.get_transaction_count(sender_address)
    
    # You would need to create the correct parameters for a Seaport listing, this is just a simplified example
    listing_data = {
        "offer": [{
            "itemType": 2,  # NFT (ERC721)
            "token": token_address,
            "identifierOrCriteria": token_id,
            "startAmount": price_in_wei,
            "endAmount": price_in_wei,
            "recipient": sender_address
        }],
        "consideration": [{
            "itemType": 0,  # Ether
            "token": '0x0000000000000000000000000000000000000000',
            "identifierOrCriteria": 0,
            "startAmount": price_in_wei,
            "endAmount": price_in_wei,
            "recipient": sender_address
        }],
    }

    # Create the transaction
    tx = seaport_contract.functions.createSellOrder(
        listing_data['offer'], 
        listing_data['consideration']
    ).buildTransaction({
        'chainId': 1,  # Mainnet
        'gas': 300000,  # Estimate gas required
        'gasPrice': w3.toWei('30', 'gwei'),  # Gas price in gwei
        'nonce': nonce
    })

    # Sign the transaction
    signed_tx = w3.eth.account.sign_transaction(tx, private_key)

    # Send the transaction
    tx_hash = w3.eth.sendRawTransaction(signed_tx.rawTransaction)

    return tx_hash.hex()

# Example usage
token_address = '0xYourNFTContractAddress'
token_id = 1234  # Your NFT's token ID
price_in_wei = w3.toWei(0.1, 'ether')  # Listing price in wei (for 0.1 ETH)

tx_hash = list_nft_for_sale(token_address, token_id, price_in_wei)
print(f"Transaction hash: {tx_hash}")
