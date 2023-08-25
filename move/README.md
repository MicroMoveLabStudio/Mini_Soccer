## Account

### 合约地址
```shell
soccer_coin=0x0a994161cc81f5e8bb7d690467f269213ca91088fba0f15af7ac89cec7a248cc
```
1. account 账号
2. soccer_coin 代币

### 资源地址

```shell
soccer_nft=0x9629b8aafbe31f5d065abb449eb952d99bec3247ec02c49420910e42980a936b
```
1. NFT


## 合约调用

调用合约实例

```shell
aptos move run --function-id 0x0a994161cc81f5e8bb7d690467f269213ca91088fba0f15af7ac89cec7a248cc::soccer_coin::mint \
    --args address:0xdbb08653b692fe611d6ec0133f1bf9b50c1bff93fa045ea6da40fa4b670e4350 u64:20000000000000 
```


1. account::init_account
    创建账号成功后调用
2. soccer_coin::register
    创建账号成功后调用
3. account::search_info
    开始游戏之前调用
4. account::update_info
    结束时调用更新 score 和 progress
    score 要乘以1000000 保证和代币的精度一致
5. soccer_coin::mint_coin
    用户在兑换代币时调用，调用地址为合约地址
6. soccer_nft::mint_nft
    用户用代币铸造 NFT 时调用第三个参数可选的值分别为['1', '2', '3', '4', '5']
7. soccer_coin::buy_coin_with_apt
    用户用APT买SoccerCoin, 调用完之后再调用soccer_coin::mint_coin去给钱包地址 mint 代币
8. soccer_coin::buy_coin_with_score
    用户用游戏分数兑换SoccerCoin, 调用完之后再调用soccer_coin::mint_coin去给钱包地址 mint 代币