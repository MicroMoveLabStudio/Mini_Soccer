module soccer_coin::soccer_coin {
    use aptos_framework::managed_coin;
    use aptos_framework::coin;

    use soccer_coin::account;

    struct SoccerCoin {}

    const ENotEnoughScoreToMint:u64 = 1001;

    /// Initialize the Module
    fun init_module(sender: &signer) {
        managed_coin::initialize<SoccerCoin>(
            sender,
            b"Soccer Coin",
            b"Soccer",
            6,
            false,
        );
    }

    /// register the coin for an account
    public entry fun register<CoinType>(account: &signer){
        coin::register<CoinType>(account);
    }

    /// Mint the Coin to a receiver
    public entry fun mint<CoinType>(account: &signer, receiver: address, amount: u64){
        assert!(account::get_score_by_address(account, receiver) >= amount, ENotEnoughScoreToMint);
        managed_coin::mint<CoinType>(account, receiver, amount);
    }
}