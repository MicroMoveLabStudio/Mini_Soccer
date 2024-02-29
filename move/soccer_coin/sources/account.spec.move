spec soccer_coin::account {
    spec module {
        pragma verify = true;
        pragma aborts_if_is_strict;
    }

    spec init_account(account: &signer,
                      id: String,
                      name: String){
        let addr = signer::address_of(account);
        aborts_if exists<GameInfo>(addr);
        ensures exists<GameInfo>(addr);
    }

    spec decrease_score(account: &signer, value: u64){
        let addr = signer::address_of(account);
        aborts_if is_locked(addr);
        aborts_if borrow_global<GameInfo>(addr).score < value with ENotEnoughScore;
        ensures borrow_global<GameInfo>(addr).score == old(borrow_global<GameInfo>(addr).score) - value;
    }

    spec update_info(account: &signer, tag: u8, delta: u64, progress: u8){
        let addr = signer::address_of(account);
        aborts_if is_locked(addr);
        aborts_if tag == 2 && borrow_global<GameInfo>(addr).score < delta ;
    }
}
