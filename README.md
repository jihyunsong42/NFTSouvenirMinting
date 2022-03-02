# NFT Souvenir Minting App

![souvenirNFTMintingApp](https://user-images.githubusercontent.com/43053791/156301380-3727e6dd-324c-4059-bf33-bf3ee0c0d252.PNG)

I made a simple app in which people can receive a souvenir NFT(Non Fungible Token) when they visit places like museum, art gallary etc.
This app is purposed to be installed near the museum for everyone to be accessible to receive their NFTs.

#1 Client side is programmed by Flutter.<br>
#2 The main page shows scrollable lists of NFT image which client wants to receive.<br>
#3 When client tap the image, the QR scanner pops up to read customer's blockchain(Ethereum) wallet address.<br>
I used Klaytn blockchain(EVM Compatible) to implement this.<br>
#4 Customer scans their wallet QR Code.<br>
#5 The Client App sends minting request(POST) to Back-End server(node.js & express.js)<br>
#6 The server (Klip App2App SDK was used to implement this.)<br>

![klip app2app workflow](https://user-images.githubusercontent.com/43053791/156303647-0e6e5c3e-6b58-4503-ae26-73dc5f23ea52.png)
Fig.1) Klip App2App SDK workflow<br><br>
※ "Purchase" Function was added to sell NFTs but it is excluded in this prototype.
