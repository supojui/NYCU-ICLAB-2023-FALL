## 簡介
Lab09要實作飲料調配的架構，pattern會給3種指令：
1. 做飲料：
   
   根據指定的飲料種類、大小扣除原料桶(dram)裡的數量，如果數量不構，就output error messege(2'b10)，如果原料到期了就output error messege(2'b01)，如果有正確做出飲料，就output no     error(2'b00)。
3. 補貨：

   Pattern會給定新的有效日期，將input的各種原料數量加到原料桶中，並更新有效日期，如果超過原料桶的上限，就加到上限(4095)、output error messege(2'b11)，如果正確補貨就output no       error(2'b00)。
5. 確認有效日期：

   Pattern給定今天的日期，確認原料桶的有效日期有沒有到期，如果到期就output error messege(2'b01)，沒問題就output no error(2'b00)。

## 優化Tips
