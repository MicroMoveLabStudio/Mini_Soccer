module soccer_coin::soccer_coin {
    use aptos_framework::managed_coin;
    use aptos_framework::coin;

    use soccer_coin::account as ac;
    use aptos_framework::aptos_coin::AptosCoin;
    use std::signer;

    struct SoccerCoin {}

    /// Error for Not Enough Socre to Mint Soccer Coin
    const ENotEnoughScoreToMint:u64 = 1001;
    /// Error for Not Enough APT to Buy Soccer Coin
    const ENotEnoughAPTToBuySoccerCoin:u64 = 1002;

    const EAccountNotRegistered :u64 = 1003;

    /// Initialize the SoccerCoin, decimal 6.
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
        managed_coin::mint<SoccerCoin>(account, receiver, amount);
    }


    public entry fun buy_coin_with_apt(account: &signer, amount: u64){
        assert!(ac::is_address_registerd(signer::address_of(account)), EAccountNotRegistered);
        assert!(coin::balance<AptosCoin>(signer::address_of(account)) >= amount, ENotEnoughAPTToBuySoccerCoin);
        coin::transfer<AptosCoin>(account, @soccer_coin, amount);
    }

    public entry fun buy_coin_with_score(account: &signer, amount: u64){
        assert!(ac::is_address_registerd(signer::address_of(account)), EAccountNotRegistered);
        assert!(ac::get_score(account) >= amount, ENotEnoughScoreToMint);
        ac::decrease_score(account, amount);
    }
}