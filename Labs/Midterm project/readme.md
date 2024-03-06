## 簡介
Midterm project要實作類似於APR繞線的演算法，主要可以分成幾個steps：

1. Pattern會吐出各障礙物的起點、終點等資訊，並根據這些資訊讀出dram裡對應的map。
 
2. 從起點開始做filling，直到終點也被填到為止。
   
3. 從終點開始retrace，直到起點也被retrace到為止。

4. 更新map，並根據net_id進行下一次的filling，直到所有障礙物都被繞完。

5. 將結果寫回dram，並根據weight map計算出所有path的cost是多少。

輸出完後pattern需要檢查以下資訊：

1. 寫回dram的障礙物位置是否跟原本的一樣。

2. 檢查路徑是否可以從source到sink，且只能有一條路徑。

3. 用寫回的路徑在pattern裡計算cost，並檢查與design計算出的cost是否一致。

Midterm project可以繳交report，紀錄自己的block diagram、state machine之類的，會加總成績1分。

## 優化Tips
用看的就知道midterm project的難度有多高，光是pattern就不知道該怎麼下手，幸好這次的題目跟之前是一樣的，可以上網找考古，裡面的pattern可以直接拿來用，這邊的pattern就是學長貢獻的，寫得非常好。解決pattern的問題，design的部分反而好解決(?，因為基本上只能用助教提供的演算法去做，不然有可能會繞不出來，也就是用1122的方式去propagate，再反推回來做retrace。

在講優化的方法之前要先知道應該往什麼地方優化，因為這次大家的演算法大概都差不多，且如果仔細去看的話，會發現其實沒有大型的計算元，主要都是mux居多，所以period可以到很低，且這次的面積限制在250萬，因此可以得到結論，把面積盡量壓低，最後在慢慢調period，直到面積漲到很接近250萬。

我的優化方法就是把propagate 1122改成propagate 2233，這樣就只需要判斷msb就可以知道能不能retrace這個位置，因為這次會用很多array，所以少一個bit的判斷實際上會差好幾百個mux，這個方法大家應該都差不多。另外，我在處理loc_x、loc_y、net_id的部分是用往前推的方式，一開始先把全部的loc_x、loc_y、net_id存到對應的array裡，每做完一條net，就把loc_x、loc_y往前推兩個index(把做完的net的起點終點資訊pop掉)，把net_id往前推一個index，這樣如果要access現在這條net的資訊，起點固定會是loc_x[0]、loc_y[0]；終點固定會是loc_x[1]、loc_y[1]；net_id固定會是net_id[0]。

剩下比較細的優化方式可以直接看我的code，report裡面也有我畫的state machine，應該會很有幫助。
