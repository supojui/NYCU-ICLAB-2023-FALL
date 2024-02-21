## 簡介
這個lab會第一次用到designware，用foundry廠提供的block取代本來常用的運算元，需要注意這次的lab規定一定要使用designware ip，沒有用的話會直接算demo fail，概念就是把常用的運算改用廠商優化過的版本取代，PPA會更好。

Design需要完成兩個channel的運算，每個channel需要做以下幾步：
1. 根據不同mode做padding(zero padding、replication padding)，並做convolution。
2. 將結果分成4個2x2的正方形block，並取出2x2 block中最大值(共4個值)，組成2x2的block。
3. 跟weight做2x2矩陣乘法。
4. 將3得到的4個數值做normaliztion。
5. 根據不同的mode做指定的運算(sigmoid、tanh)。
6. 最後將兩channel的結果相減取絕對值後相加。

## 優化Tips
看上面的敘述大概可以知道這次lab的複雜度有多高，加上一定要用designware，所以coding style沒有建立好，debug會很痛苦。需要注意，這次的area、合成時間的上限是有可能超過的，我第一次寫出的版本area跑到1000多萬，合成時間要快2小時，因此在動手寫design前，先好好想演算法，要怎麼樣才可以盡可能共用硬體，或是有些運算可以用其他運算代替，舉例來說，除法可以用倒數跟乘法取代，取e^(-z)、e^(z)可以只用一個exponential跟一個倒數等，這種大型的designware用的越少越好，另外，designware寫的dot product(乘完再加)，不會比直接用乘法、加法還要好。

Timing、pipeline方面，可以先照著題目的每個功能切，寫出來之後再慢慢調整，一般來講面積越大的block，花的時間越多，可以打開02裡的syn.tcl，找到report area，改成下面這樣，合成出來的area report裡就會顯示各個designware佔了多少面積。

```verilog
report area -designware -hierarchy
```


最後建議提早開始寫這次的lab，應該會花不少時間，加油！
