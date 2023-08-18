script{

    use aptos_framework::managed_coin::mint;

    fun mint_coin<CoinType>(sender: &signer, receiver: address, amount: u64){
        mint<CoinType>(sender, receiver, amount);
    }

}