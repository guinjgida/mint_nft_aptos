module cat::cat{
    use std::signer;
    use std::string::{Self, String};
    use std::vector;
    use aptos_framework::account;
    use aptos_framework::aptos_coin::AptosCoin;
    use aptos_framework::coin;
    use aptos_framework::object;
    use aptos_framework::object::Object;
    use aptos_framework::randomness;
    use aptos_token_objects::aptos_token;
    use aptos_token_objects::aptos_token::AptosToken;
    use aptos_token_objects::token;

    const ENOT_A_Cat: u64 = 1;
    const ENOT_CREATOR: u64 = 2;
    const EINVALID_TYPE: u64 = 3;
    const ENOT_START:u64 = 4;

    struct OnChainConfig has key{
        signer_cap:account::SignerCapability,
        collection:String,
        index:u64,
        status:bool,
        price:u64,
        payee:address,
        description:String,
        name:String,
        image_urls:vector<String>,

    }

    // #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    struct Cat has key {
        mutator_ref: token::MutatorRef
    }


    fun init_module(account:&signer){
        let collection = string::utf8(b"Cat Quest!");
        let (resource_signer,signer_cap) = account::create_resource_account(account,b"cat");
        aptos_token::create_collection(
            &resource_signer,
            string::utf8(b"black cat or white cat"),
            100,
            collection,
            string::utf8(b"collection uri"),
            false,
            false,
            true,
            false,
            false,
            false,
            false,
            true,
            true,
            10,
            100000,
        );

        let on_chain_config = OnChainConfig{
            signer_cap,
            collection,
            index:0,
            status:false,
            price:0,
            payee:signer::address_of(account),
            description:string::utf8(b"random cat"),
            name:string::utf8(b"cat"),
            image_urls: vector<String>[
                string::utf8(b"https://k.sinaimg.cn/n/sinakd20200810ac/200/w600h400/20200810/f3fd-ixreehn5060223.jpg/w700d1q75cms.jpg"),
                string::utf8(b"https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRxGeXfPXAL88nYATTZz7YkdwVM0xrC09bBkQ&usqp=CAU")]
        };
        move_to(account,on_chain_config);
    }

    public entry fun init_mint(account:&signer,){
        let collection = string::utf8(b"Cat Quest!");
        let (resource_signer,signer_cap) = account::create_resource_account(account,b"cat");
        aptos_token::create_collection(
            &resource_signer,
            string::utf8(b"black cat or white cat"),
            100,
            collection,
            string::utf8(b"collection uri"),
            false,
            false,
            true,
            false,
            false,
            false,
            false,
            true,
            true,
            10,
            100000,
        );

        let on_chain_config = OnChainConfig{
            signer_cap,
            collection,
            index:0,
            status:false,
            price:0,
            payee:signer::address_of(account),
            description:string::utf8(b"random cat"),
            name:string::utf8(b"cat"),
            image_urls: vector<String>[
                string::utf8(b"https://k.sinaimg.cn/n/sinakd20200810ac/200/w600h400/20200810/f3fd-ixreehn5060223.jpg/w700d1q75cms.jpg"),
                string::utf8(b"https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRxGeXfPXAL88nYATTZz7YkdwVM0xrC09bBkQ&usqp=CAU")]
        };
        move_to(account,on_chain_config);
    }

    public fun buy_cat(sender:&signer,nft_address:address) acquires OnChainConfig{
        let config = borrow_global_mut<OnChainConfig>(nft_address);
        assert!(config.status,ENOT_START);

        let coins = coin::withdraw<AptosCoin>(sender,config.price);
        coin::deposit(config.payee,coins);
        create(sender,config);
        config.index = config.index + 1;
    }

    entry fun buy_cat_entry(
        account: &signer,
        nft_address: address
    ) acquires OnChainConfig {
        buy_cat(account, nft_address);
    }

    inline fun get_cat(creator: &address, collection: &String, name: &String): (Object<Cat>, &Cat) {
        let token_address = token::create_token_address(
            creator,
            collection,
            name,
        );
        (object::address_to_object<Cat>(token_address), borrow_global<Cat>(token_address))
    }



    entry fun update_config(
        account: &signer,
        status: bool,
        price: u64
    ) acquires OnChainConfig {
        let on_chain_config = borrow_global_mut<OnChainConfig>(signer::address_of(account));
        on_chain_config.status = status;
        on_chain_config.price = price;
    }

    fun create(creator:&signer,onchain_config:&OnChainConfig){
        let resource_signer = account::create_signer_with_capability(&onchain_config.signer_cap);
        let random_num = randomness::u64_range(0,2);
        let url = *vector::borrow(&onchain_config.image_urls,random_num);
        let name = get_token_name(onchain_config.name,onchain_config.index + 1);
        let token_object = aptos_token::mint_token_object(
            &resource_signer,
            onchain_config.collection,
            onchain_config.description,
            name,
            url,
            vector<String>[],
            vector<String>[],
            vector<vector<u8>>[],
        );
        object::transfer(&resource_signer,token_object,signer::address_of(creator));
    }

    fun get_token_name(token_base_name: String, index: u64): String {
        let num_string = num_to_index_string(index);
        string::append(&mut token_base_name, num_string);
        token_base_name
    }

    fun num_to_index_string(num: u64): String {
        let index_string = string::utf8(b" #");
        let num_string = num_to_string(num);
        string::append(&mut index_string, num_string);
        index_string
    }

    fun num_to_string(num: u64): String {
        let num_vec = vector::empty<u8>();
        if (num == 0) {
            vector::push_back(&mut num_vec, 48);
        } else {
            while (num != 0) {
                let mod = num % 10 + 48;
                vector::push_back(&mut num_vec, (mod as u8));
                num = num / 10;
            };
        };

        vector::reverse(&mut num_vec);
        string::utf8(num_vec)
    }

    entry fun reveal(account: &signer, token: Object<AptosToken>, uri: String) acquires OnChainConfig {
        let onchain_config = borrow_global_mut<OnChainConfig>(signer::address_of(account));
        let resource_signer = account::create_signer_with_capability(&onchain_config.signer_cap);
        aptos_token::set_uri(&resource_signer, token, uri);
    }






}
