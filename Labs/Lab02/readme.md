## 簡介
針對座標點的計算，一共有3個mode，input給定4個座標及mode，在一定cycle數內輸出答案。
- Mode 0：給定4個座標形成的梯形，輸出此梯形包含到的所有座標點。
- Mode 1：給定4個座標，前兩個形成一條直線，第三個座標為圓心；第四個座標為圓上一點，輸出此直線與圓的相交關係(不相交、相切、相割)。
- Mode 2：給定4個座標，輸出圍成的區域面積。

可以明顯發現難度上升了不少，最難處理的地方應該是在Mode 0，要如何判斷點是否在區域內，且盡量不用到除法器，這個可以參考Lab02_Exercise_algorithm.pdf。

## 優化Tips
重點一樣是怎麼樣減少大型運算單元的數量，尤其是除法器，能少用就盡量少用，因此一開始的演算法決定就很重要，基本上後面的lab都是演算法決定了performance，這個時候就可以凸顯報團的好處，盡量到處去問大家的想法，多跟別人討論，也不要吝嗇把自己的演算法跟大家分享，因為通常都會有很多優化空間。

如果是沒有碰過verilog的人，強烈建議這個lab不要只是做完就好了，盡量在這次把時序的概念搞懂，blocking、nonblocking分清楚，coding style、註解寫好一點，因為之後的複雜度會高很多，常常隔一天再寫會不知道前面寫了甚麼。
