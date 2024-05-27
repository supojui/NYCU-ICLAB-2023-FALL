## 簡介
Final project要實作的是CPU架構，要能支援各種指令，基本上就是計組、計結教過的5級pipeline架構。需要注意，這次lab有一定要使用SRAM的限制，不然如果所有東西都從DRAM拿其實很簡單就可以做出來，Register每次指令執行完都會檢查是否正確，而DRAM則是每10個instruction檢查，DRAM的溝通方式一樣是用AXI interface。
## 優化Tips
