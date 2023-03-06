# circom 
1. 所有電路都有前面的1
2. witness依序是[1, output..., input...]
3. 如果今天有其他物件一路包起來，外面的物件 output input會在前面，所以測試就寫在最前面就好，其餘猜想應該是往下長
4. 太長的數字需要用string形式input，不然進到circom會是錯誤數字，如下
5. array input要是寫成array形式
```json
{
  "digest": "7156595577437608543190201695561556177504424919525785911637562183334393590048",
  "nullifier": 4,
  "nonce": 14,
  "sibling": ["3", "19681602856558162950057707481888122737605614522678761875609416502251241175621", "4949757766996550399175443158059310394257309534281238094727193345225681506852", "18633364347856320646884886547836821398229701470730139821384419637975014912921"],
  "direction": [1, 1, 0, 0]
}
```

```
# shell package
jq format json string to number:
https://stedolan.github.io/jq/manual/#Basicfilters

miller to format number to decimal representation: 
https://github.com/johnkerl/miller#readme, https://github.com/stedolan/jq/issues/1192#issuecomment-732473203

```sh
circom spend${depth}.circom --wasm --r1cs --sym
#jq 'with_entries(.value |= tonumber)' input_spend.json | mlr --json format-values -f '%.0f' | tr -d "[]" | tail -n +2 > input_spend${depth}.json
# snarkjs r1cs print spend${depth}.r1cs spend${depth}.sym
cd spend${depth}_js
node generate_witness.js spend${depth}.wasm ../input_spend${depth}.json ../witness.wtns
cd ..
snarkjs groth16 setup spend${depth}.r1cs powersOfTau28_hez_final_12.ptau spend_0000.zkey
snarkjs zkey export verificationkey spend_0000.zkey verification_key.json
snarkjs r1cs export json spend${depth}.r1cs spend${depth}.r1cs.json
snarkjs zkey verify spend${depth}.r1cs powersOfTau28_hez_final_12.ptau spend_0000.zkey
snarkjs groth16 prove spend_0000.zkey witness.wtns proof.json public.json
snarkjs groth16 verify verification_key.json public.json proof.json
```

# sh
1. []要空格，前後
2. -eq 是給數字用的 == 是給string用的
```sh
if [ $depth -eq $num ]
then
```


