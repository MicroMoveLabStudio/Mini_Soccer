## Account

### 合约地址
1. account 账号
2. soccer_coin 代币

### 资源地址
1. NFT


## 合约调用

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
    用户用代币铸造 NFT 时调用
7. soccer_coin::buy_coin
    用户用 APT 买 SoccerCoin