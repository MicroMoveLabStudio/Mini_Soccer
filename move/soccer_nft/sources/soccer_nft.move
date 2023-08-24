module soccer_nft::soccer_nft {
    use std::signer::{Self, address_of};
    use std::string::{Self, String};
    use std::vector;

    use aptos_std::table;
    use aptos_framework::account::{Self, SignerCapability};
    use aptos_framework::coin;
    use aptos_framework::event::EventHandle;
    use aptos_framework::resource_account;

    use aptos_token::token::{Self, TokenId, TokenDataId};

    use soccer_coin::account as ac;
    use soccer_coin::soccer_coin::SoccerCoin;

    struct NFTMinter has key {
        signer_cap: SignerCapability,
        collection: String,
    }

    struct NFTImageList has key, store {
        owner: address,
        img_price: table::Table<String, vector<u64>>,
        img_list: table::Table<String, String>
    }


    struct NFTList has store, drop {
        token_store: vector<TokenId>
    }

    struct NFTListEven has key {
        search_event: EventHandle<NFTList>
    }


    const EAddressNotRegisterd: u64 = 1;
    const EAddressProgressIsNotDone: u64 = 2;
    const ESoccerCoinNotEnough: u64 = 1;

    public fun insert_image(address: &signer) {
        let addr = signer::address_of(address);
        let img_price = table::new<String, vector<u64>>();
        let img_vec = table::new<String, String>();
        table::add(&mut img_price, string::utf8(b"5"), vector<u64>[500000000, 50]);
        table::add(
            &mut img_vec,
            string::utf8(b"5"),
            string::utf8(b"https://arweave.net/i5lrH7crD-3P5_jkJbAHspYKt1BG_gYJ-ujMmHmcMs8")
        );
        table::add(&mut img_price, string::utf8(b"4"), vector<u64>[400000000, 40]);
        table::add(
            &mut img_vec,
            string::utf8(b"4"),
            string::utf8(b"https://arweave.net/CBBl1r1xiJlkBYkTG7XqYYzJo7pxopdS0HByzrN9pWk")
        );
        table::add(&mut img_price, string::utf8(b"3"), vector<u64>[300000000, 30]);
        table::add(
            &mut img_vec,
            string::utf8(b"3"),
            string::utf8(b"https://arweave.net/DJphzR83so6X5aXHwndUSkkMbsQancUf4Vt6IiAfiZU")
        );
        table::add(&mut img_price, string::utf8(b"2"), vector<u64>[200000000, 20]);
        table::add(
            &mut img_vec,
            string::utf8(b"2"),
            string::utf8(b"https://arweave.net/nUG3WxaivP8hFVPFgATbgvXbH47Whj6G-Ru6oIVrla4")
        );
        table::add(&mut img_price, string::utf8(b"1"), vector<u64>[100000000, 10]);
        table::add(
            &mut img_vec,
            string::utf8(b"1"),
            string::utf8(b"https://arweave.net/Ua2Q6NmrT7tHa70H0wfhJdlY4PIuBe06__K0ZYh-tqs")
        );
        move_to(address, NFTImageList {
            owner: addr,
            img_price,
            img_list: img_vec
        });
    }

    fun init_module(resource_account: &signer) {
        let collection_name = string::utf8(b"Soccer Game NFT Collection");
        let description = string::utf8(b"NFT issued by Mini Soccer Game");
        let collection_uri = string::utf8(b"https://arweave.net/NPj6MoKStE_AsbbqKIm7iQpzcClHGP2Otkc_WBudHx4");

        let maximum_supply = 1024;
        let mutate_setting = vector<bool>[ false, false, false ];

        let resource_signer_cap = resource_account::retrieve_resource_account_cap(resource_account, @source_addr);
        let resource_signer = account::create_signer_with_capability(&resource_signer_cap);

        token::create_collection(
            &resource_signer,
            collection_name,
            description,
            collection_uri,
            maximum_supply,
            mutate_setting
        );
        insert_image(resource_account);
        move_to(resource_account, NFTMinter {
            signer_cap: resource_signer_cap,
            collection: collection_name,
        });
    }

    fun create_resource_signer_and_tokendata_id(signer_cap: &SignerCapability,
                                                collections: String,
                                                token_name: String,
                                                token_des: String,
                                                token_uri: String): (TokenDataId, signer) {
        let resource_signer = account::create_signer_with_capability(signer_cap);
        let resource_account_address = address_of(&resource_signer);
        let token_data_id = token::create_tokendata(
            &resource_signer,
            collections,
            token_name,
            token_des,
            1,
            token_uri,
            resource_account_address,
            1,
            0,
            token::create_token_mutability_config(
                &vector<bool>[ false, false, false, false, true ]
            ),
            vector::empty<String>(),
            vector::empty<vector<u8>>(),
            vector::empty<String>(),
        );
        (token_data_id, resource_signer)
    }

    public entry fun mint_nft(
        receiver: &signer,
        token_name: String,
        description: String,
        level: String
    ) acquires NFTMinter, NFTImageList {
        assert!(ac::is_address_registerd(signer::address_of(receiver)), EAddressNotRegisterd);

        let nft_minter = borrow_global_mut<NFTMinter>(@soccer_nft);
        let img_list = borrow_global_mut<NFTImageList>(@soccer_nft);
        let nft_price = *vector::borrow(table::borrow(&img_list.img_price, level), 0);
        let nft_progress = *vector::borrow(table::borrow(&img_list.img_price, level), 1);
        assert!(ac::get_progress(receiver) >= nft_progress, EAddressProgressIsNotDone);
        assert!(coin::balance<SoccerCoin>(signer::address_of(receiver)) >= nft_price, ESoccerCoinNotEnough);
        coin::transfer<SoccerCoin>(receiver, @scccer_nft, nft_price);

        let (token_data_id, resource_signer) = create_resource_signer_and_tokendata_id(&nft_minter.signer_cap,
            nft_minter.collection,
            token_name,
            description,
            *table::borrow(&img_list.img_list, level));

        let token_id = token::mint_token(&resource_signer, token_data_id, 1);
        token::direct_transfer(&resource_signer, receiver, token_id, 1);
    }
}