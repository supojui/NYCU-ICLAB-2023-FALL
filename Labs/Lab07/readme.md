## 簡介
這次lab要實作pseudo random generator，且要跨3個clock domain，clock domain間要分別用上課教的handshake synchronizer、FIFO synchronizer去做同步，clk3會有4種period，要通過demo必須4種period都可以跑過01，但03只需要通過20.7ns即可。另外，還需要通過JG的clock domain crossing檢查，才可以拿到全部的分數。

## 優化Tips
Lab07難的地方不是架構，基本上照著pdf上給的handshake、FIFO架構去做就可以過01
