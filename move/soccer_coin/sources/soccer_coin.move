module soccer_coin::soccer_coin {
    use aptos_framework::managed_coin;
    use aptos_framework::coin;

    use soccer_coin::account;
    use aptos_framework::aptos_coin::AptosCoin;
    use std::signer;

    struct SoccerCoin {}

    const ENotEnoughScoreToMint:u64 = 1001;
    const ENotEnoughAPTToBuySoccerCoin:u64 = 1002;

    /// Initialize the Module
    fun init_module(sender: &signer) {
        managed_coin::initialize<SoccerCoin>(
            sender,
            b"Soccer Coin",
            b"MSC",
            6,
            false,
        );

    }

    /// register the coin for an account
    public entry fun register(account: &signer){
        coin::register<SoccerCoin>(account);
    }

    /// Mint the Coin to a receiver
    public entry fun mint(account: &signer, receiver: address, amount: u64){
        assert!(account::get_score_by_address(account, receiver) >= amount, ENotEnoughScoreToMint);
        managed_coin::mint<SoccerCoin>(account, receiver, amount);
    }

    public entry fun buy_coin_with_apt(account: &signer, amount: u64){
        assert!(coin::balance<AptosCoin>(signer::address_of(account)) >= amount, ENotEnoughAPTToBuySoccerCoin);
        coin::transfer<AptosCoin>(account, @soccer_coin, amount);
    }

    public entry fun buy_coin_with_score(account: &signer, amount: u64){
        assert!(account::get_score(account) >= amount, ENotEnoughAPTToBuySoccerCoin);
        account::decrease_score(account, amount);
    }
}