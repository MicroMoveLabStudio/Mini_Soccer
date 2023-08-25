module soccer_coin::account {
    use std::signer;
    use std::string::String;

    use aptos_framework::account;
    use aptos_framework::aptos_coin::AptosCoin;
    use aptos_framework::coin::{Self, Coin};
    use aptos_framework::event::{Self, EventHandle};

    friend soccer_coin::soccer_coin;

    /// Holds the score for an account
    /// The score must be stored in chain
    struct GameInfo has key {
        id: String,
        name: String,
        score: u64,
        progress: u64,
        round: u8,
        is_locked: bool,
        search_events: EventHandle<InfoEvent>,
        update_events: EventHandle<UpdateEvent>,
        locked_events: EventHandle<LockEvent>
    }

    struct InfoEvent has store, drop {
        score: u64,
        progress: u64,
        round: u8,
        is_locked: bool
    }

    struct UpdateEvent has store, drop {
        tag: u8,
        delta: u64,
        progress: u8
    }

    struct LockEvent has store, drop {
        locked: bool
    }

    const ELocked: u64 = 1002;
    const ENotEnoughAPTCoinToUnlock: u64 = 1003;
    const ENotEnoughScore: u64 = 1004;
    const EAccountNotRegistered :u64 = 1005;

    public fun is_address_registerd(addr: address): bool {
        exists<GameInfo>(addr)
    }

    public fun is_locked(addr: address): bool acquires GameInfo {
        borrow_global<GameInfo>(addr).is_locked
    }

    /// initialize the struct `GameInfo` for an account
    public entry fun init_account(account: &signer,
                                  id: String,
                                  name: String) {
        let addr = signer::address_of(account);
        if (is_address_registerd(addr)) {
            return
        };
        let gameinfo = GameInfo {
            id,
            name,
            score: 0,
            progress: 0,
            round: 1,
            is_locked: false,
            search_events: account::new_event_handle<InfoEvent>(account),
            update_events: account::new_event_handle<UpdateEvent>(account),
            locked_events: account::new_event_handle<LockEvent>(account)
        };
        move_to(account, gameinfo);
    }

    public entry fun search_info(account: &signer) acquires GameInfo {
        assert!(!is_locked(signer::address_of(account)), ELocked);
        let gameinfo = borrow_global_mut<GameInfo>(signer::address_of(account));
        event::emit_event<InfoEvent>(
            &mut gameinfo.search_events,
            InfoEvent {
                score: gameinfo.score,
                progress: gameinfo.progress,
                round: gameinfo.round,
                is_locked: gameinfo.is_locked
            }
        )
    }

    /// get the score of an account by signer
    public fun get_score(account: &signer): u64 acquires GameInfo {
        assert!(!is_locked(signer::address_of(account)), ELocked);
        let gameinfo = borrow_global<GameInfo>(signer::address_of(account));
        gameinfo.score
    }

    public fun get_score_by_address(_account: &signer, addr: address): u64 acquires GameInfo {
        assert!(!is_locked(addr), ELocked);
        let gameinfo = borrow_global<GameInfo>(addr);
        gameinfo.score
    }

    /// get the progress of an account by signer
    public fun get_progress(account: &signer): u64 acquires GameInfo {
        assert!(!is_locked(signer::address_of(account)), ELocked);
        let gameinfo = borrow_global<GameInfo>(signer::address_of(account));
        gameinfo.progress
    }

    public fun get_progress_by_address(_account: &signer, addr: address): u64 acquires GameInfo {
        assert!(!is_locked(addr), ELocked);
        let gameinfo = borrow_global<GameInfo>(addr);
        gameinfo.progress
    }

    public fun decrease_score(account: &signer, value: u64) acquires GameInfo{
        assert!(!is_locked(signer::address_of(account)), ELocked);
        assert!(get_score(account) >= value, ENotEnoughScore);
        let score = borrow_global<GameInfo>(signer::address_of(account)).score;
        let gameinfo = borrow_global_mut<GameInfo>(signer::address_of(account));
        let s_ref = &mut gameinfo.score;
        *s_ref = score - value;
    }

    /// update the score
    public entry fun update_info(account: &signer, tag: u8, delta: u64, progress: u8) acquires GameInfo {
        assert!(!is_locked(signer::address_of(account)), ELocked);
        let s = borrow_global<GameInfo>(signer::address_of(account)).score;
        let gameinfo_mut = borrow_global_mut<GameInfo>(signer::address_of(account));
        let s_ref = &mut gameinfo_mut.score;
        if (tag == 1) {
            *s_ref = s + delta;
        }else {
            if (s <= delta) {
                *s_ref = 0u64;
            }else {
                *s_ref = s - delta;
            }
        };
        let pro_ref = &mut gameinfo_mut.progress;
        *pro_ref = (progress as u64);
        event::emit_event<UpdateEvent>(
            &mut gameinfo_mut.update_events,
            UpdateEvent {
                tag,
                delta,
                progress
            }
        )
    }

    public entry fun lock_account(account: &signer) acquires GameInfo {
        if (is_locked(signer::address_of(account))) {
            return
        };
        let gameinfo = borrow_global_mut<GameInfo>(signer::address_of(account));
        let is_locked_flag = &mut gameinfo.is_locked;
        *is_locked_flag = true;
        event::emit_event<LockEvent>(
            &mut gameinfo.locked_events,
            LockEvent {
                locked: true
            }
        )
    }

    public entry fun unlock_account(from: &signer, to: address, amount: u64) acquires GameInfo {
        assert!(coin::balance<Coin<AptosCoin>>(signer::address_of(from)) >= amount, ENotEnoughAPTCoinToUnlock);
        coin::transfer<Coin<AptosCoin>>(from, to, amount);
        let gameinfo = borrow_global_mut<GameInfo>(signer::address_of(from));
        let is_locked_flag = &mut gameinfo.is_locked;
        *is_locked_flag = false;
        event::emit_event<LockEvent>(
            &mut gameinfo.locked_events,
            LockEvent {
                locked: false
            }
        )
    }
}
